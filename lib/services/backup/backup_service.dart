import 'dart:convert';

import 'backup_payload.dart';

/// Motivi per cui un file non può essere ripristinato.
enum BackupErrorKind {
  /// Non è un JSON valido, o non ha la struttura di un backup SplashUp.
  notASplashUpBackup,

  /// Creato da una versione futura di SplashUp, con uno schema che questa
  /// versione non sa leggere.
  unsupportedSchemaVersion,

  /// Struttura riconosciuta ma contenuto inutilizzabile.
  corrupted,
}

class BackupException implements Exception {
  final BackupErrorKind kind;
  final String details;

  const BackupException(this.kind, [this.details = '']);

  @override
  String toString() => 'BackupException(${kind.name}): $details';
}

/// Serializzazione e validazione del file di backup.
///
/// Tutto qui dentro è logica pura (nessun plugin, nessun I/O): si può testare
/// con `flutter test` senza device. Il file picker e il repository stanno in
/// [BackupFileService].
class BackupService {
  /// Versione dello schema del file. Da incrementare SOLO se la struttura
  /// cambia in modo non retrocompatibile; i lettori più vecchi rifiutano
  /// esplicitamente i numeri più alti invece di leggere male i dati.
  static const int schemaVersion = 1;

  /// Chiave "firma": la sua presenza distingue un backup SplashUp da un
  /// qualsiasi altro JSON che l'utente potrebbe selezionare per sbaglio.
  static const String signatureKey = 'splashupBackup';

  const BackupService();

  /// Nome file proposto nel dialog di salvataggio, es.
  /// `splashup-backup-2026-08-05.json`.
  String suggestedFileName(DateTime now) {
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return 'splashup-backup-$y-$m-$d.json';
  }

  /// Serializza il contenuto del DB in JSON indentato (leggibile a occhio e
  /// diffabile, a costo di qualche KB in più).
  String encode(
    BackupPayload payload, {
    required String appVersion,
    required String appBuild,
    required DateTime createdAt,
  }) {
    final document = <String, Object?>{
      signatureKey: schemaVersion,
      'appVersion': appVersion,
      'appBuild': appBuild,
      'createdAt': createdAt.toUtc().toIso8601String(),
      // Ridondante rispetto a `data`, ma permette di controllare l'integrità
      // del file e di mostrare all'utente cosa sta per ripristinare senza
      // dover contare i record a mano.
      'counts': <String, Object?>{
        'teams': payload.teamCount,
        'athletes': payload.athleteCount,
        'chronos': payload.chronoCount,
      },
      'data': <String, Object?>{
        'teams': payload.teams,
        'athletes': payload.athletes,
        'chronos': payload.chronos,
      },
    };
    return const JsonEncoder.withIndent('  ').convert(document);
  }

  /// Legge e valida un file di backup.
  ///
  /// Lancia [BackupException] con il motivo preciso: la UI traduce il motivo
  /// in un messaggio utile invece di un generico "errore".
  BackupPayload decode(String jsonText) {
    Object? decoded;
    try {
      decoded = jsonDecode(jsonText);
    } catch (e) {
      throw BackupException(
        BackupErrorKind.notASplashUpBackup,
        'JSON non valido: $e',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const BackupException(
        BackupErrorKind.notASplashUpBackup,
        'La radice del documento non è un oggetto JSON',
      );
    }

    final signature = decoded[signatureKey];
    if (signature is! int) {
      throw const BackupException(
        BackupErrorKind.notASplashUpBackup,
        'Chiave "$signatureKey" assente o non numerica',
      );
    }
    if (signature > schemaVersion) {
      throw BackupException(
        BackupErrorKind.unsupportedSchemaVersion,
        'Schema $signature, questa versione legge fino a $schemaVersion',
      );
    }
    if (signature < 1) {
      throw BackupException(
        BackupErrorKind.corrupted,
        'Versione schema non valida: $signature',
      );
    }

    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const BackupException(
        BackupErrorKind.corrupted,
        'Sezione "data" assente',
      );
    }

    final payload = BackupPayload(
      teams: _readStore(data, 'teams'),
      athletes: _readStore(data, 'athletes'),
      chronos: _readStore(data, 'chronos'),
    );

    // Controllo di integrità: se i contatori dichiarati non corrispondono ai
    // record presenti, il file è stato troncato o modificato a mano. I
    // contatori sono OBBLIGATORI: se fossero opzionali, cancellare la chiave
    // "counts" basterebbe a disattivare il controllo, cioè proprio la mossa
    // che farebbe chi modifica il file a mano.
    final counts = decoded['counts'];
    if (counts is! Map<String, dynamic>) {
      throw const BackupException(
        BackupErrorKind.corrupted,
        'Sezione "counts" assente o non valida',
      );
    }
    void expectCount(String key, int actual) {
      final declared = counts[key];
      if (declared is! int) {
        throw BackupException(
          BackupErrorKind.corrupted,
          'Contatore "$key" assente o non numerico',
        );
      }
      if (declared != actual) {
        throw BackupException(
          BackupErrorKind.corrupted,
          'Il file dichiara $declared record in "$key" ma ne contiene $actual',
        );
      }
    }

    expectCount('teams', payload.teamCount);
    expectCount('athletes', payload.athleteCount);
    expectCount('chronos', payload.chronoCount);

    return payload;
  }

  Map<String, Map<String, Object?>> _readStore(
    Map<String, dynamic> data,
    String storeName,
  ) {
    final raw = data[storeName];
    if (raw == null) return const {};
    if (raw is! Map<String, dynamic>) {
      throw BackupException(
        BackupErrorKind.corrupted,
        'La sezione "$storeName" non è un oggetto JSON',
      );
    }

    final result = <String, Map<String, Object?>>{};
    raw.forEach((id, record) {
      if (id.isEmpty) {
        throw BackupException(
          BackupErrorKind.corrupted,
          'Record senza id in "$storeName"',
        );
      }
      if (record is! Map<String, dynamic>) {
        throw BackupException(
          BackupErrorKind.corrupted,
          'Il record "$id" di "$storeName" non è un oggetto JSON',
        );
      }
      // Conversione profonda: jsonDecode produce Map<String, dynamic> e
      // List<dynamic> anche nei livelli annidati (es. gli split dei tempi),
      // mentre Sembast vuole strutture Map<String, Object?>.
      final normalized = _normalizeMap(record);
      _validateRecord(storeName, id, normalized);
      result[id] = normalized;
    });
    return result;
  }

  /// Controlla il TIPO dei campi noti, non solo la struttura.
  ///
  /// Serve perché i modelli leggono il database con cast diretti
  /// (`map['poolLength'] as int?`, `map['distance'] as int`,
  /// `List<String>.from(map['preferredStyles'])`). Un valore del tipo
  /// sbagliato non fa rumore al momento del ripristino: esplode dopo, quando
  /// l'app rilegge i dati — e a quel punto il ripristino ha già cancellato i
  /// dati precedenti, quindi l'utente si ritrova un'app che non mostra più
  /// niente e nessun modo di tornare indietro. Meglio rifiutare il file.
  ///
  /// Un campo ASSENTE è ammesso: i `fromMap()` hanno tutti un default.
  /// Un campo PRESENTE col tipo sbagliato no.
  void _validateRecord(
    String storeName,
    String id,
    Map<String, Object?> record,
  ) {
    void check(String field, bool Function(Object? value) isValid, String expected) {
      final value = record[field];
      if (value == null) return; // assente o null esplicito: default del modello
      if (!isValid(value)) {
        throw BackupException(
          BackupErrorKind.corrupted,
          'Il record "$id" di "$storeName" ha "$field" di tipo '
          '${value.runtimeType} invece di $expected',
        );
      }
    }

    bool isInt(Object? value) => value is int;
    bool isString(Object? value) => value is String;
    bool isBool(Object? value) => value is bool;

    if (storeName == 'teams') {
      check('name', isString, 'String');
      check('poolLength', isInt, 'int');
    } else if (storeName == 'athletes') {
      check('name', isString, 'String');
      check('birthYear', isInt, 'int');
      check('gender', isString, 'String');
      check('isActive', isBool, 'bool');
      check('notes', isString, 'String');
      check('teamId', isString, 'String');
      check('createdAt', isInt, 'int');
      // Athlete.fromMap fa List<String>.from(...): un elemento non-stringa
      // fa fallire la conversione.
      check(
        'preferredStyles',
        (value) => value is List && value.every((item) => item is String),
        'lista di String',
      );
    } else if (storeName == 'chronos') {
      check('date', isInt, 'int');
      check('poolLength', isInt, 'int');
      check('distance', isInt, 'int');
      check('style', isString, 'String');
      check('finalTime', isString, 'String');
      check('finalTimeMs', isInt, 'int'); // può essere null: lo copre `check`
      check('notes', isString, 'String');
      check('type', isString, 'String');
      check('athleteId', isString, 'String');
      check('teamId', isString, 'String');
      _validateSplits(id, record['splits']);
    }
  }

  void _validateSplits(String chronoId, Object? splits) {
    if (splits == null) return;
    if (splits is! List) {
      throw BackupException(
        BackupErrorKind.corrupted,
        'Gli split del tempo "$chronoId" non sono una lista',
      );
    }
    for (final split in splits) {
      if (split is! Map<String, Object?>) {
        throw BackupException(
          BackupErrorKind.corrupted,
          'Uno split del tempo "$chronoId" non è un oggetto JSON',
        );
      }
      // Chrono.fromMap costruisce un ChronoSplit solo per gli split con
      // `time` non nullo, e ChronoSplit.fromMap fa `map['distance'] as int`
      // NON nullable: uno split con il tempo ma senza distanza fa crashare
      // la lettura del record.
      final time = split['time'];
      final distance = split['distance'];
      if (time != null && time is! int) {
        throw BackupException(
          BackupErrorKind.corrupted,
          'Uno split del tempo "$chronoId" ha "time" non numerico',
        );
      }
      final splitTime = split['splitTime'];
      if (splitTime != null && splitTime is! int) {
        throw BackupException(
          BackupErrorKind.corrupted,
          'Uno split del tempo "$chronoId" ha "splitTime" non numerico',
        );
      }
      if (time != null && distance is! int) {
        throw BackupException(
          BackupErrorKind.corrupted,
          'Uno split del tempo "$chronoId" ha un tempo ma nessuna distanza valida',
        );
      }
    }
  }

  Map<String, Object?> _normalizeMap(Map<String, dynamic> source) {
    return <String, Object?>{
      for (final entry in source.entries) entry.key: _normalizeValue(entry.value),
    };
  }

  Object? _normalizeValue(Object? value) {
    if (value is Map<String, dynamic>) return _normalizeMap(value);
    if (value is Map) {
      return <String, Object?>{
        for (final entry in value.entries)
          entry.key.toString(): _normalizeValue(entry.value),
      };
    }
    if (value is List) {
      return <Object?>[for (final item in value) _normalizeValue(item)];
    }
    return value;
  }

  /// Scarta atleti senza squadra e tempi senza atleta.
  ///
  /// Un backup prodotto da SplashUp è sempre coerente, quindi in condizioni
  /// normali questo metodo non scarta niente. Serve per i file modificati a
  /// mano o parzialmente danneggiati: meglio ripristinare i dati buoni e dire
  /// quanti record sono stati ignorati, che rifiutare tutto il file o —
  /// peggio — riempire il DB di record irraggiungibili dalla UI (la UI legge
  /// gli atleti per `teamId` e i tempi per `athleteId`: un record scollegato
  /// occuperebbe spazio senza essere mai visibile né cancellabile).
  PrunedPayload pruneOrphans(BackupPayload payload) {
    final teamIds = payload.teams.keys.toSet();

    final athletes = <String, Map<String, Object?>>{};
    var droppedAthletes = 0;
    payload.athletes.forEach((id, record) {
      final teamId = record['teamId'];
      if (teamId is String && teamIds.contains(teamId)) {
        athletes[id] = record;
      } else {
        droppedAthletes++;
      }
    });

    final athleteIds = athletes.keys.toSet();
    final chronos = <String, Map<String, Object?>>{};
    var droppedChronos = 0;
    payload.chronos.forEach((id, record) {
      final athleteId = record['athleteId'];
      if (athleteId is String && athleteIds.contains(athleteId)) {
        chronos[id] = record;
      } else {
        droppedChronos++;
      }
    });

    return PrunedPayload(
      payload: BackupPayload(
        teams: payload.teams,
        athletes: athletes,
        chronos: chronos,
      ),
      source: payload,
      droppedAthletes: droppedAthletes,
      droppedChronos: droppedChronos,
    );
  }
}
