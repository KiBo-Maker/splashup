// hide Finder: flutter_test ha un Finder per i widget che collide col
// Finder di sembast (query DB); qui serve solo quello di sembast
// (riesportato da sembast_memory.dart).
import 'package:flutter_test/flutter_test.dart' hide Finder;
import 'package:sembast/sembast_memory.dart';
import 'package:splashup/models/athlete_model.dart';
import 'package:splashup/models/chrono_model.dart';
import 'package:splashup/models/team_model.dart';
import 'package:splashup/repositories/sembast_repository.dart';
import 'package:splashup/services/backup/backup_payload.dart';

// Helpers to build valid model instances. The id is ignored on insert
// (the repository generates its own UUID keys).
Team buildTeam(String name) => Team(id: '', name: name, poolLength: 25);

Athlete buildAthlete(String name) => Athlete(
      id: '',
      name: name,
      birthYear: 2010,
      gender: 'Male',
      preferredStyles: const ['Freestyle'],
      isActive: true,
      notes: '',
    );

Chrono buildChrono({int finalTimeMs = 65000}) => Chrono(
      id: '',
      date: DateTime(2026, 1, 1),
      poolLength: 25,
      distance: 100,
      style: 'Freestyle',
      finalTime: Chrono.formatMillisecondsToTime(finalTimeMs),
      finalTimeMs: finalTimeMs,
      notes: '',
      type: 'Training',
    );

void main() {
  // SembastRepository is a singleton: inject a fresh, uniquely named
  // in-memory database before each test so tests stay independent.
  late SembastRepository repo;
  late Database db;
  var dbCounter = 0;

  // Direct store handles for assertions on raw records (e.g. the teamId
  // field of chronos, which is not exposed by the Chrono model).
  final athletesStore = stringMapStoreFactory.store('athletes');
  final chronosStore = stringMapStoreFactory.store('chronos');

  setUp(() async {
    repo = SembastRepository();
    db = await databaseFactoryMemory.openDatabase('test_db_${dbCounter++}.db');
    repo.debugSetDatabase(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('addTeam stores the team and getTeamsStream returns it sorted by name',
      () async {
    final idB = await repo.addTeam(buildTeam('Beta'));
    final idA = await repo.addTeam(buildTeam('Alpha'));

    final teams = await repo.getTeamsStream().first;

    expect(teams.length, 2);
    // Sorted by name.
    expect(teams[0].name, 'Alpha');
    expect(teams[1].name, 'Beta');
    expect(teams[0].id, idA);
    expect(teams[1].id, idB);
    expect(teams[0].poolLength, 25);
  });

  test('addAthlete stores the athlete under its team', () async {
    final teamId = await repo.addTeam(buildTeam('Team'));
    final athleteId = await repo.addAthlete(teamId, buildAthlete('Anna'));

    final athletes = await repo.getAthletesStream(teamId).first;
    expect(athletes.length, 1);
    expect(athletes.first.id, athleteId);
    expect(athletes.first.name, 'Anna');
  });

  test('moveAthlete moves the athlete AND its chronos to the new team',
      () async {
    final sourceTeamId = await repo.addTeam(buildTeam('Source'));
    final destTeamId = await repo.addTeam(buildTeam('Dest'));
    final athleteId = await repo.addAthlete(sourceTeamId, buildAthlete('Anna'));
    await repo.addChrono(sourceTeamId, athleteId, buildChrono());
    await repo.addChrono(sourceTeamId, athleteId, buildChrono(finalTimeMs: 70000));

    await repo.moveAthlete(athleteId, sourceTeamId, destTeamId);

    // Athlete no longer under source team, now under destination team.
    final sourceAthletes = await repo.getAthletesStream(sourceTeamId).first;
    final destAthletes = await repo.getAthletesStream(destTeamId).first;
    expect(sourceAthletes, isEmpty);
    expect(destAthletes.length, 1);
    expect(destAthletes.first.id, athleteId);

    // All chronos of the athlete carry the new teamId (raw record check,
    // since the Chrono model does not expose teamId).
    final chronoRecords = await chronosStore.find(
      db,
      finder: Finder(filter: Filter.equals('athleteId', athleteId)),
    );
    expect(chronoRecords.length, 2);
    for (final record in chronoRecords) {
      expect(record.value['teamId'], destTeamId);
    }

    // Chronos still readable via the public stream.
    final chronos = await repo.getChronosStream(athleteId).first;
    expect(chronos.length, 2);
  });

  test('deleteTeam cascades to its athletes and their chronos', () async {
    final teamAId = await repo.addTeam(buildTeam('A'));
    final teamBId = await repo.addTeam(buildTeam('B'));
    final athleteAId = await repo.addAthlete(teamAId, buildAthlete('AthA'));
    final athleteBId = await repo.addAthlete(teamBId, buildAthlete('AthB'));
    await repo.addChrono(teamAId, athleteAId, buildChrono());
    await repo.addChrono(teamAId, athleteAId, buildChrono(finalTimeMs: 70000));
    await repo.addChrono(teamBId, athleteBId, buildChrono());

    await repo.deleteTeam(teamAId);

    // Team A gone, team B untouched.
    final teams = await repo.getTeamsStream().first;
    expect(teams.length, 1);
    expect(teams.first.id, teamBId);

    // Athletes of team A deleted (raw check: no orphan records at all).
    final teamAAthletes = await athletesStore.find(
      db,
      finder: Finder(filter: Filter.equals('teamId', teamAId)),
    );
    expect(teamAAthletes, isEmpty);

    // Chronos of team A's athlete deleted.
    final athleteAChronos = await repo.getChronosStream(athleteAId).first;
    expect(athleteAChronos, isEmpty);

    // Team B's athlete and chrono survive.
    final teamBAthletes = await repo.getAthletesStream(teamBId).first;
    expect(teamBAthletes.length, 1);
    final athleteBChronos = await repo.getChronosStream(athleteBId).first;
    expect(athleteBChronos.length, 1);
  });

  test('deleteAthlete cascades to its chronos only', () async {
    final teamId = await repo.addTeam(buildTeam('Team'));
    final athlete1Id = await repo.addAthlete(teamId, buildAthlete('Anna'));
    final athlete2Id = await repo.addAthlete(teamId, buildAthlete('Bruno'));
    await repo.addChrono(teamId, athlete1Id, buildChrono());
    await repo.addChrono(teamId, athlete1Id, buildChrono(finalTimeMs: 70000));
    await repo.addChrono(teamId, athlete2Id, buildChrono());

    await repo.deleteAthlete(athlete1Id);

    // Athlete 1 gone, athlete 2 remains.
    final athletes = await repo.getAthletesStream(teamId).first;
    expect(athletes.length, 1);
    expect(athletes.first.id, athlete2Id);

    // Chronos of athlete 1 deleted, athlete 2's chrono intact.
    final chronos1 = await repo.getChronosStream(athlete1Id).first;
    expect(chronos1, isEmpty);
    final chronos2 = await repo.getChronosStream(athlete2Id).first;
    expect(chronos2.length, 1);
    expect(chronos2.first.finalTimeMs, 65000);
  });

  // --- BACKUP / RIPRISTINO ---

  test('exportAll restituisce i record grezzi, campi di legame compresi',
      () async {
    final teamId = await repo.addTeam(buildTeam('Team'));
    final athleteId = await repo.addAthlete(teamId, buildAthlete('Anna'));
    await repo.addChrono(teamId, athleteId, buildChrono());

    final payload = await repo.exportAll();

    expect(payload.teamCount, 1);
    expect(payload.athleteCount, 1);
    expect(payload.chronoCount, 1);
    // Sono proprio questi i campi che si perderebbero passando dai modelli.
    expect(payload.athletes[athleteId]!['teamId'], teamId);
    expect(payload.athletes[athleteId]!['createdAt'], isA<int>());
    expect(payload.chronos.values.first['athleteId'], athleteId);
    expect(payload.chronos.values.first['teamId'], teamId);
  });

  test('export + replaceAll ricostruisce lo stesso database, id compresi',
      () async {
    final teamId = await repo.addTeam(buildTeam('Team'));
    final athleteId = await repo.addAthlete(teamId, buildAthlete('Anna'));
    await repo.addChrono(teamId, athleteId, buildChrono());
    final backup = await repo.exportAll();

    // L'utente cancella tutto e poi ripristina.
    await repo.deleteAllData();
    expect(await repo.getTeamsStream().first, isEmpty);

    await repo.replaceAll(backup);

    final teams = await repo.getTeamsStream().first;
    expect(teams.length, 1);
    // Gli id vengono conservati: i tempi restano appesi allo stesso atleta.
    expect(teams.first.id, teamId);
    final athletes = await repo.getAthletesStream(teamId).first;
    expect(athletes.length, 1);
    expect(athletes.first.id, athleteId);
    expect(athletes.first.name, 'Anna');
    final chronos = await repo.getChronosStream(athleteId).first;
    expect(chronos.length, 1);
    expect(chronos.first.finalTimeMs, 65000);
  });

  test('replaceAll sostituisce, non unisce', () async {
    final oldTeamId = await repo.addTeam(buildTeam('Vecchia'));
    await repo.addAthlete(oldTeamId, buildAthlete('Da cancellare'));
    final backup = await repo.exportAll();

    // Situazione diversa da quella del backup.
    await repo.deleteAllData();
    final otherTeamId = await repo.addTeam(buildTeam('Attuale'));
    await repo.addAthlete(otherTeamId, buildAthlete('Bruno'));

    await repo.replaceAll(backup);

    final teams = await repo.getTeamsStream().first;
    expect(teams.length, 1, reason: 'la squadra attuale deve sparire');
    expect(teams.first.name, 'Vecchia');
    expect(await repo.getAthletesStream(otherTeamId).first, isEmpty);
  });

  test('replaceAll con un backup vuoto svuota il database', () async {
    final teamId = await repo.addTeam(buildTeam('Team'));
    await repo.addAthlete(teamId, buildAthlete('Anna'));

    await repo.replaceAll(const BackupPayload.empty());

    expect(await repo.getTeamsStream().first, isEmpty);
    expect(await repo.getAthletesStream(teamId).first, isEmpty);
  });

  test('deleteAllData rimuove anche i record scollegati', () async {
    final teamId = await repo.addTeam(buildTeam('Team'));
    final athleteId = await repo.addAthlete(teamId, buildAthlete('Anna'));
    await repo.addChrono(teamId, athleteId, buildChrono());
    // Atleta appeso a una squadra che non esiste: la vecchia cancellazione
    // squadra-per-squadra non lo avrebbe mai raggiunto.
    await repo.addAthlete('squadra-fantasma', buildAthlete('Orfano'));

    await repo.deleteAllData();

    expect(await repo.getTeamsStream().first, isEmpty);
    expect(await athletesStore.find(db), isEmpty);
    expect(await chronosStore.find(db), isEmpty);
  });
}
