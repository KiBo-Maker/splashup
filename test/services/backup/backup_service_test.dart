import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:splashup/services/backup/backup_payload.dart';
import 'package:splashup/services/backup/backup_service.dart';

BackupPayload buildPayload() => BackupPayload(
      teams: {
        'team-1': {'name': 'Esordienti', 'poolLength': 25},
      },
      athletes: {
        'ath-1': {
          'name': 'Anna',
          'birthYear': 2010,
          'gender': 'Female',
          'preferredStyles': ['Freestyle', 'Butterfly'],
          'isActive': true,
          'notes': '',
          'teamId': 'team-1',
          'createdAt': 1700000000000,
        },
      },
      chronos: {
        'chr-1': {
          'date': 1700000001000,
          'poolLength': 25,
          'distance': 100,
          'style': 'Freestyle',
          'finalTime': '01:05.00',
          'finalTimeMs': 65000,
          'splits': [
            {'distance': 50, 'time': 31000, 'splitTime': 31000},
            {'distance': 100, 'time': 65000, 'splitTime': 34000},
          ],
          'notes': '',
          'type': 'Training',
          'athleteId': 'ath-1',
          'teamId': 'team-1',
        },
      },
    );

void main() {
  const service = BackupService();
  final createdAt = DateTime.utc(2026, 8, 5, 12, 30);

  String encodeSample([BackupPayload? payload]) => service.encode(
        payload ?? buildPayload(),
        appVersion: '2.5.0',
        appBuild: '31',
        createdAt: createdAt,
      );

  group('encode/decode', () {
    test('il round-trip conserva i record identici, campi di legame compresi',
        () {
      final original = buildPayload();
      final restored = service.decode(encodeSample(original));

      expect(restored.teams, original.teams);
      // teamId/athleteId/createdAt NON sono nei modelli: se il backup
      // passasse da Team.toMap()/Athlete.toMap() andrebbero persi e gli
      // atleti resterebbero senza squadra.
      expect(restored.athletes['ath-1']!['teamId'], 'team-1');
      expect(restored.athletes['ath-1']!['createdAt'], 1700000000000);
      expect(restored.chronos['chr-1']!['athleteId'], 'ath-1');
      expect(restored.chronos['chr-1']!['teamId'], 'team-1');
    });

    test('le liste annidate (split e stili) sopravvivono al round-trip', () {
      final restored = service.decode(encodeSample());

      final styles = restored.athletes['ath-1']!['preferredStyles'] as List;
      expect(styles, ['Freestyle', 'Butterfly']);

      final splits = restored.chronos['chr-1']!['splits'] as List;
      expect(splits.length, 2);
      final second = splits[1] as Map<String, Object?>;
      expect(second['distance'], 100);
      expect(second['time'], 65000);
    });

    test('il file contiene versione schema, versione app e contatori', () {
      final document = jsonDecode(encodeSample()) as Map<String, dynamic>;

      expect(document[BackupService.signatureKey], BackupService.schemaVersion);
      expect(document['appVersion'], '2.5.0');
      expect(document['appBuild'], '31');
      expect(document['createdAt'], createdAt.toIso8601String());
      expect(document['counts'], {'teams': 1, 'athletes': 1, 'chronos': 1});
    });

    test('un backup vuoto si esporta e si reimporta senza errori', () {
      final restored = service.decode(
        service.encode(
          const BackupPayload.empty(),
          appVersion: '2.5.0',
          appBuild: '31',
          createdAt: createdAt,
        ),
      );
      expect(restored.isEmpty, isTrue);
    });
  });

  group('file rifiutati', () {
    test('JSON non valido', () {
      expect(
        () => service.decode('non sono json'),
        throwsA(
          isA<BackupException>().having(
            (e) => e.kind,
            'kind',
            BackupErrorKind.notASplashUpBackup,
          ),
        ),
      );
    });

    test('JSON valido ma senza la firma di SplashUp', () {
      expect(
        () => service.decode('{"qualcosa": "altro"}'),
        throwsA(
          isA<BackupException>().having(
            (e) => e.kind,
            'kind',
            BackupErrorKind.notASplashUpBackup,
          ),
        ),
      );
    });

    test('schema più recente di quello supportato', () {
      final future = jsonEncode({
        BackupService.signatureKey: BackupService.schemaVersion + 1,
        'data': {'teams': {}, 'athletes': {}, 'chronos': {}},
      });
      expect(
        () => service.decode(future),
        throwsA(
          isA<BackupException>().having(
            (e) => e.kind,
            'kind',
            BackupErrorKind.unsupportedSchemaVersion,
          ),
        ),
      );
    });

    test('sezione data assente', () {
      expect(
        () => service.decode(
          jsonEncode({BackupService.signatureKey: BackupService.schemaVersion}),
        ),
        throwsA(
          isA<BackupException>()
              .having((e) => e.kind, 'kind', BackupErrorKind.corrupted),
        ),
      );
    });

    test('contatori incoerenti con i record presenti (file troncato)', () {
      final tampered = jsonDecode(encodeSample()) as Map<String, dynamic>;
      (tampered['counts'] as Map<String, dynamic>)['athletes'] = 99;

      expect(
        () => service.decode(jsonEncode(tampered)),
        throwsA(
          isA<BackupException>()
              .having((e) => e.kind, 'kind', BackupErrorKind.corrupted),
        ),
      );
    });

    test('un record che non è un oggetto JSON', () {
      final tampered = jsonDecode(encodeSample()) as Map<String, dynamic>;
      ((tampered['data'] as Map<String, dynamic>)['teams']
          as Map<String, dynamic>)['team-1'] = 'stringa';
      // I contatori restano coerenti (1 record c'è, è solo del tipo sbagliato):
      // così il test verifica davvero il controllo sul tipo del record.

      expect(
        () => service.decode(jsonEncode(tampered)),
        throwsA(
          isA<BackupException>()
              .having((e) => e.kind, 'kind', BackupErrorKind.corrupted),
        ),
      );
    });
  });

  group('validazione dei tipi dei campi', () {
    // Questi file passerebbero un controllo puramente strutturale, ma i
    // modelli leggono il DB con cast diretti: se arrivassero fino al database
    // farebbero fallire la lettura DOPO che il ripristino ha cancellato i dati
    // precedenti, lasciando l'app senza niente da mostrare e senza via
    // d'uscita. Devono essere rifiutati prima.
    String tamper(String store, String id, Map<String, Object?> record) {
      final document = jsonDecode(encodeSample()) as Map<String, dynamic>;
      ((document['data'] as Map<String, dynamic>)[store]
          as Map<String, dynamic>)[id] = record;
      return jsonEncode(document);
    }

    void expectCorrupted(String json) {
      expect(
        () => service.decode(json),
        throwsA(
          isA<BackupException>()
              .having((e) => e.kind, 'kind', BackupErrorKind.corrupted),
        ),
      );
    }

    test('poolLength come stringa (Team.fromMap farebbe un CastError)', () {
      expectCorrupted(tamper('teams', 'team-1', {
        'name': 'Esordienti',
        'poolLength': '25',
      }));
    });

    test('poolLength come double', () {
      expectCorrupted(tamper('teams', 'team-1', {
        'name': 'Esordienti',
        'poolLength': 25.0,
      }));
    });

    test('nome squadra numerico', () {
      expectCorrupted(tamper('teams', 'team-1', {'name': 42, 'poolLength': 25}));
    });

    test('preferredStyles con elementi non stringa', () {
      expectCorrupted(tamper('athletes', 'ath-1', {
        'name': 'Anna',
        'teamId': 'team-1',
        'preferredStyles': [1, 2],
      }));
    });

    test('isActive come stringa', () {
      expectCorrupted(tamper('athletes', 'ath-1', {
        'name': 'Anna',
        'teamId': 'team-1',
        'isActive': 'true',
      }));
    });

    test('data del tempo non numerica (romperebbe la pulizia dati)', () {
      expectCorrupted(tamper('chronos', 'chr-1', {
        'athleteId': 'ath-1',
        'date': '2026-01-01',
      }));
    });

    test('split con tempo ma senza distanza (ChronoSplit.fromMap crasherebbe)',
        () {
      expectCorrupted(tamper('chronos', 'chr-1', {
        'athleteId': 'ath-1',
        'date': 1700000001000,
        'splits': [
          {'time': 31000, 'splitTime': 31000},
        ],
      }));
    });

    test('split che non è un oggetto', () {
      expectCorrupted(tamper('chronos', 'chr-1', {
        'athleteId': 'ath-1',
        'date': 1700000001000,
        'splits': ['31000'],
      }));
    });

    test('un campo assente resta ammesso (i modelli hanno un default)', () {
      // Nessun poolLength: Team.fromMap usa 25. Non è un motivo per rifiutare
      // il file.
      final json = tamper('teams', 'team-1', {'name': 'Solo il nome'});
      final restored = service.decode(json);
      expect(restored.teams['team-1'], {'name': 'Solo il nome'});
    });

    test('un campo esplicitamente null resta ammesso', () {
      final json = tamper('chronos', 'chr-1', {
        'athleteId': 'ath-1',
        'date': 1700000001000,
        'finalTimeMs': null,
      });
      final restored = service.decode(json);
      expect(restored.chronos['chr-1']!['finalTimeMs'], isNull);
    });
  });

  group('contatori obbligatori', () {
    test('senza la sezione counts il file viene rifiutato', () {
      // Se i contatori fossero opzionali, cancellare la chiave basterebbe a
      // disattivare il controllo di integrità.
      final document = jsonDecode(encodeSample()) as Map<String, dynamic>;
      document.remove('counts');

      expect(
        () => service.decode(jsonEncode(document)),
        throwsA(
          isA<BackupException>()
              .having((e) => e.kind, 'kind', BackupErrorKind.corrupted),
        ),
      );
    });

    test('un contatore non numerico viene rifiutato', () {
      final document = jsonDecode(encodeSample()) as Map<String, dynamic>;
      (document['counts'] as Map<String, dynamic>)['teams'] = 'uno';

      expect(
        () => service.decode(jsonEncode(document)),
        throwsA(
          isA<BackupException>()
              .having((e) => e.kind, 'kind', BackupErrorKind.corrupted),
        ),
      );
    });
  });

  group('pruneOrphans', () {
    test('un backup coerente non perde niente', () {
      final pruned = service.pruneOrphans(buildPayload());

      expect(pruned.hasDropped, isFalse);
      expect(pruned.payload.athleteCount, 1);
      expect(pruned.payload.chronoCount, 1);
    });

    test('i conteggi del file restano disponibili accanto a quelli potati', () {
      // Sono questi i numeri che il dialog di conferma deve mostrare: senza
      // `source`, un file con le squadre danneggiate direbbe "atleti: 0" e
      // l'utente confermerebbe una cancellazione totale credendo di
      // ripristinare qualcosa.
      final broken = BackupPayload(
        teams: const {},
        athletes: {
          'ath-1': {'name': 'Anna', 'teamId': 'squadra-che-non-esiste'},
          'ath-2': {'name': 'Bruno', 'teamId': 'squadra-che-non-esiste'},
        },
        chronos: {
          'chr-1': {'athleteId': 'ath-1'},
        },
      );

      final pruned = service.pruneOrphans(broken);

      expect(pruned.source.athleteCount, 2, reason: 'quello che c\'è nel file');
      expect(pruned.payload.athleteCount, 0, reason: 'quello che si ripristina');
      expect(pruned.source.chronoCount, 1);
      expect(pruned.droppedTotal, 3);
    });

    test('scarta gli atleti la cui squadra non è nel backup', () {
      final broken = BackupPayload(
        teams: const {},
        athletes: {
          'ath-1': {'name': 'Anna', 'teamId': 'squadra-che-non-esiste'},
        },
        chronos: const {},
      );

      final pruned = service.pruneOrphans(broken);

      expect(pruned.droppedAthletes, 1);
      expect(pruned.payload.athletes, isEmpty);
      // Le squadre non vengono mai scartate: non dipendono da nessuno.
      expect(pruned.payload.teams, isEmpty);
    });

    test('scarta i tempi il cui atleta è stato scartato (a cascata)', () {
      final broken = BackupPayload(
        teams: const {},
        athletes: {
          'ath-1': {'name': 'Anna', 'teamId': 'squadra-che-non-esiste'},
        },
        chronos: {
          'chr-1': {'athleteId': 'ath-1', 'finalTimeMs': 65000},
          'chr-2': {'athleteId': 'ath-mai-esistito', 'finalTimeMs': 70000},
        },
      );

      final pruned = service.pruneOrphans(broken);

      expect(pruned.droppedAthletes, 1);
      expect(pruned.droppedChronos, 2);
      expect(pruned.droppedTotal, 3);
      expect(pruned.payload.chronos, isEmpty);
    });

    test('scarta i record senza campo di legame', () {
      final broken = BackupPayload(
        teams: {
          'team-1': {'name': 'Esordienti'},
        },
        athletes: {
          'ath-1': {'name': 'Senza squadra'},
        },
        chronos: const {},
      );

      final pruned = service.pruneOrphans(broken);
      expect(pruned.droppedAthletes, 1);
    });
  });

  test('il nome file proposto contiene la data', () {
    expect(
      service.suggestedFileName(DateTime(2026, 8, 5)),
      'splashup-backup-2026-08-05.json',
    );
    // Mese e giorno sempre a due cifre, così i file si ordinano da soli.
    expect(
      service.suggestedFileName(DateTime(2026, 1, 9)),
      'splashup-backup-2026-01-09.json',
    );
  });
}
