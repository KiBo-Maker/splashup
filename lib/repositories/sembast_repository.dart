import 'dart:async';
import 'package:flutter/foundation.dart' show debugPrint, visibleForTesting;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
// sembast.dart non serve: sembast_io.dart riesporta tutto il necessario
// (segnalato da flutter analyze come unnecessary_import)
import 'package:sembast/sembast_io.dart';
import 'package:uuid/uuid.dart';
import '../models/team_model.dart';
import '../models/athlete_model.dart';
import '../models/chrono_model.dart';
import '../services/backup/backup_payload.dart';
import 'database_repository.dart';

class SembastRepository implements DatabaseRepository {
  // Singleton instance
  static final SembastRepository _instance = SembastRepository._internal();
  factory SembastRepository() => _instance;
  SembastRepository._internal();

  Database? _database;
  final _uuid = const Uuid();

  // Stores definitions (like SQL tables)
  final _teamsStore = stringMapStoreFactory.store('teams');
  final _athletesStore = stringMapStoreFactory.store('athletes');
  final _chronosStore = stringMapStoreFactory.store('chronos');

  // Initialize DB
  Future<void> init() async {
    if (_database != null) return;
    final appDir = await getApplicationDocumentsDirectory();
    await appDir.create(recursive: true);
    final dbPath = join(appDir.path, 'splashup.db');
    try {
      _database = await databaseFactoryIo.openDatabase(dbPath);
    } catch (error) {
      // Un file di database corrotto (spazio esaurito a meta' scrittura,
      // dispositivo spento durante un salvataggio) faceva fallire main()
      // PRIMA di runApp: l'app non si apriva piu' e l'utente non aveva modo
      // di uscirne. Con neverFails Sembast apre comunque il database
      // recuperando quello che riesce a leggere, cosi' l'app parte e
      // l'allenatore puo' almeno esportare i dati sopravvissuti.
      debugPrint(
        'SplashUp: apertura database fallita ($error), '
        'riapro in modalita di recupero',
      );
      _database = await databaseFactoryIo.openDatabase(
        dbPath,
        mode: DatabaseMode.neverFails,
      );
    }
  }

  /// Test-only: inietta un database già aperto (es. in-memory) al posto
  /// di quello su file creato da init(), che richiede path_provider e
  /// quindi non è utilizzabile nei unit test.
  @visibleForTesting
  void debugSetDatabase(Database db) {
    _database = db;
  }

  Future<Database> get _readyDb async {
    if (_database == null) await init();
    return _database!;
  }

  // --- TEAMS ---

  @override
  Stream<List<Team>> getTeamsStream() async* {
    final db = await _readyDb;
    // Query: sort by name
    final query = _teamsStore.query(finder: Finder(sortOrders: [SortOrder('name')]));
    
    yield* query.onSnapshots(db).map((snapshots) {
      return snapshots.map((snapshot) {
        return Team.fromMap(snapshot.value, snapshot.key);
      }).toList();
    });
  }

  @override
  Future<String> addTeam(Team team) async {
    final db = await _readyDb;
    final id = _uuid.v4(); // Generate unique String ID
    await _teamsStore.record(id).put(db, team.toMap());
    return id;
  }

  @override
  Future<void> updateTeam(Team team) async {
    final db = await _readyDb;
    await _teamsStore.record(team.id).update(db, team.toMap());
  }

  @override
  Future<void> deleteTeam(String teamId) async {
    final db = await _readyDb;
    await db.transaction((txn) async {
      // Delete the team
      await _teamsStore.record(teamId).delete(txn);
      
      // Cascading: Find all athletes in this team
      final athletesKeys = await _athletesStore.findKeys(txn, finder: Finder(filter: Filter.equals('teamId', teamId)));
      
      // Delete all chronos for these athletes
      for (var athleteId in athletesKeys) {
        await _chronosStore.delete(txn, finder: Finder(filter: Filter.equals('athleteId', athleteId)));
      }
      
      // Delete athletes
      await _athletesStore.delete(txn, finder: Finder(filter: Filter.equals('teamId', teamId)));
    });
  }

  // --- ATHLETES ---

  @override
  Stream<List<Athlete>> getAthletesStream(String teamId) async* {
    final db = await _readyDb;
    final query = _athletesStore.query(
      finder: Finder(
        filter: Filter.equals('teamId', teamId),
        sortOrders: [SortOrder('name')],
      ),
    );

    yield* query.onSnapshots(db).map((snapshots) {
      return snapshots.map((snapshot) {
        return Athlete.fromMap(snapshot.value, snapshot.key);
      }).toList();
    });
  }

  @override
  Future<String> addAthlete(String teamId, Athlete athlete) async {
    final db = await _readyDb;
    final id = _uuid.v4();
    final map = athlete.toMap();
    map['teamId'] = teamId; // Link to parent
    map['createdAt'] = DateTime.now().millisecondsSinceEpoch; // Useful for sorting
    
    await _athletesStore.record(id).put(db, map);
    return id;
  }

  @override
  Future<void> updateAthlete(String teamId, Athlete athlete) async {
    final db = await _readyDb;
    final map = athlete.toMap();
    map['teamId'] = teamId; // Ensure link is preserved
    await _athletesStore.record(athlete.id).update(db, map);
  }

  @override
  Future<void> deleteAthlete(String athleteId) async {
    final db = await _readyDb;
    await db.transaction((txn) async {
      await _athletesStore.record(athleteId).delete(txn);
      await _chronosStore.delete(txn, finder: Finder(filter: Filter.equals('athleteId', athleteId)));
    });
  }

  // --- CHRONOS ---

  @override
  Stream<List<Chrono>> getChronosStream(String athleteId) async* {
    final db = await _readyDb;
    final query = _chronosStore.query(
      finder: Finder(
        filter: Filter.equals('athleteId', athleteId),
        sortOrders: [SortOrder('date', false)], // Descending
      ),
    );

    yield* query.onSnapshots(db).map((snapshots) {
      return snapshots.map((snapshot) {
        return Chrono.fromMap(snapshot.value, snapshot.key);
      }).toList();
    });
  }

  @override
  Future<String> addChrono(String teamId, String athleteId, Chrono chrono) async {
    final db = await _readyDb;
    final id = _uuid.v4();
    final map = chrono.toMap();
    map['athleteId'] = athleteId;
    map['teamId'] = teamId; // Optional, but good for filtering/analytics
    
    await _chronosStore.record(id).put(db, map);
    return id;
  }

  @override
  Future<void> updateChrono(String teamId, String athleteId, Chrono chrono) async {
    final db = await _readyDb;
    final map = chrono.toMap();
    map['athleteId'] = athleteId;
    map['teamId'] = teamId;
    await _chronosStore.record(chrono.id).update(db, map);
  }

  @override
  Future<void> deleteChrono(String athleteId, String chronoId) async {
    final db = await _readyDb;
    await _chronosStore.record(chronoId).delete(db);
  }

  // --- COMPLEX OPERATIONS ---

  @override
  Future<void> moveAthlete(String athleteId, String sourceTeamId, String destTeamId) async {
    final db = await _readyDb;

    // Transazione atomica: atleta e relativi crono cambiano squadra insieme.
    // Prima le due scritture erano separate e un'interruzione a metà poteva
    // lasciare i crono associati alla squadra vecchia.
    await db.transaction((txn) async {
      // Just update the teamId field in the athlete record
      await _athletesStore.record(athleteId).update(txn, {'teamId': destTeamId});

      // Update teamId in all chronos too (for consistency)
      await _chronosStore.update(
        txn,
        {'teamId': destTeamId},
        finder: Finder(filter: Filter.equals('athleteId', athleteId)),
      );
    });
  }

  @override
  Future<int> deactivateInactiveAthletes(int monthsInactive) async {
    final db = await _readyDb;
    final cutoffDate = DateTime.now().subtract(Duration(days: monthsInactive * 30)).millisecondsSinceEpoch;
    int count = 0;

    await db.transaction((txn) async {
      // Get all active athletes
      final activeAthletes = await _athletesStore.find(txn, finder: Finder(filter: Filter.equals('isActive', true)));
      
      for (var snap in activeAthletes) {
        final athleteId = snap.key;
        // Find latest chrono
        final lastChrono = await _chronosStore.findFirst(txn, 
          finder: Finder(
            filter: Filter.equals('athleteId', athleteId),
            sortOrders: [SortOrder('date', false)]
          )
        );

        bool shouldDeactivate = false;
        if (lastChrono == null) {
           // No chronos? Check creation date if available, or skip/deactivate based on policy. 
           // Let's assume if no chronos, we keep them active unless explicitly old? 
           // For now, let's strictly follow the "no new times recorded" logic.
           // If no chronos, effectively inactive? Let's check creation date fallback.
           final createdAt = snap.value['createdAt'] as int?;
           if (createdAt != null && createdAt < cutoffDate) {
             shouldDeactivate = true;
           }
        } else {
           // Cast difensivo: un record arrivato da un backup modificato a
           // mano potrebbe non avere la data, e un CastError qui romperebbe
           // per sempre la pulizia dati.
           final chronoDate = lastChrono.value['date'] as int? ?? 0;
           if (chronoDate < cutoffDate) {
             shouldDeactivate = true;
           }
        }

        if (shouldDeactivate) {
          await _athletesStore.record(athleteId).update(txn, {'isActive': false});
          count++;
        }
      }
    });
    return count;
  }

  @override
  Future<int> deleteInactiveAthletes(int yearsInactive) async {
    final db = await _readyDb;
    final cutoffDate = DateTime.now().subtract(Duration(days: yearsInactive * 365)).millisecondsSinceEpoch;
    int count = 0;

    await db.transaction((txn) async {
      // Get all inactive athletes
      final inactiveAthletes = await _athletesStore.find(txn, finder: Finder(filter: Filter.equals('isActive', false)));
      
      for (var snap in inactiveAthletes) {
        final athleteId = snap.key;
        final lastChrono = await _chronosStore.findFirst(txn, 
          finder: Finder(
            filter: Filter.equals('athleteId', athleteId),
            sortOrders: [SortOrder('date', false)]
          )
        );

        bool shouldDelete = false;
        if (lastChrono == null) {
           final createdAt = snap.value['createdAt'] as int?;
           if (createdAt != null && createdAt < cutoffDate) {
             shouldDelete = true;
           } else if (createdAt == null) {
             shouldDelete = true; // No data, safe to delete
           }
        } else {
           if ((lastChrono.value['date'] as int? ?? 0) < cutoffDate) {
             shouldDelete = true;
           }
        }

        if (shouldDelete) {
          await _chronosStore.delete(txn, finder: Finder(filter: Filter.equals('athleteId', athleteId)));
          await _athletesStore.record(athleteId).delete(txn);
          count++;
        }
      }
    });
    return count;
  }

  // --- BACKUP / RIPRISTINO ---

  /// Copia di primo livello dei record. Il chiamante puo' aggiungere o
  /// togliere chiavi dalle mappe restituite senza toccare la cache interna di
  /// Sembast; i valori annidati (es. la lista degli split) sono invece
  /// condivisi, quindi non vanno modificati sul posto.
  Map<String, Map<String, Object?>> _dump(
    List<RecordSnapshot<String, Map<String, Object?>>> snapshots,
  ) {
    return {
      for (final snapshot in snapshots)
        snapshot.key: Map<String, Object?>.from(snapshot.value),
    };
  }

  @override
  Future<BackupPayload> exportAll() async {
    final db = await _readyDb;
    // Tutto dentro una transazione: l'export e' uno snapshot coerente anche
    // se qualcosa scrive nel database mentre stiamo leggendo.
    // Il risultato passa da una variabile esterna invece di essere restituito
    // dalla transazione: cosi' il codice non dipende dal fatto che
    // transaction<T> dichiari T o T? come tipo di ritorno.
    BackupPayload? payload;
    await db.transaction((txn) async {
      payload = BackupPayload(
        teams: _dump(await _teamsStore.find(txn)),
        athletes: _dump(await _athletesStore.find(txn)),
        chronos: _dump(await _chronosStore.find(txn)),
      );
    });
    return payload ?? const BackupPayload.empty();
  }

  @override
  Future<void> replaceAll(BackupPayload payload) async {
    final db = await _readyDb;
    // Svuotamento + riempimento nella STESSA transazione: se il ripristino
    // fallisce a metà, Sembast fa rollback e l'utente si ritrova i dati di
    // prima invece di un database mezzo vuoto.
    await db.transaction((txn) async {
      await _teamsStore.delete(txn);
      await _athletesStore.delete(txn);
      await _chronosStore.delete(txn);

      for (final entry in payload.teams.entries) {
        await _teamsStore.record(entry.key).put(txn, entry.value);
      }
      for (final entry in payload.athletes.entries) {
        await _athletesStore.record(entry.key).put(txn, entry.value);
      }
      for (final entry in payload.chronos.entries) {
        await _chronosStore.record(entry.key).put(txn, entry.value);
      }
    });
  }

  @override
  Future<void> deleteAllData() async {
    final db = await _readyDb;
    await db.transaction((txn) async {
      await _teamsStore.delete(txn);
      await _athletesStore.delete(txn);
      await _chronosStore.delete(txn);
    });
  }
}
