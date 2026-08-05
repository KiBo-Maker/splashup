import 'package:flutter_test/flutter_test.dart';
import 'package:splashup/services/update/app_version.dart';

void main() {
  group('tryParse', () {
    test('versione semplice', () {
      final version = AppVersion.tryParse('2.5.0')!;
      expect(version.major, 2);
      expect(version.minor, 5);
      expect(version.patch, 0);
      expect(version.preRelease, '');
    });

    test('tag GitHub con la v davanti', () {
      expect(AppVersion.tryParse('v2.5.0'), AppVersion.tryParse('2.5.0'));
      expect(AppVersion.tryParse('V2.5.0'), AppVersion.tryParse('2.5.0'));
    });

    test('il build number di pubspec viene ignorato', () {
      // 2.5.0+31 e 2.5.0+32 sono la stessa versione per l'utente: se il build
      // number contasse, l'app segnalerebbe un aggiornamento inesistente.
      expect(AppVersion.tryParse('2.5.0+31'), AppVersion.tryParse('2.5.0'));
      expect(
        AppVersion.tryParse('2.5.0+31')!
            .compareTo(AppVersion.tryParse('2.5.0+99')!),
        0,
      );
    });

    test('pre-release', () {
      final beta = AppVersion.tryParse('2.5.0-beta.1')!;
      expect(beta.preRelease, 'beta.1');
      expect(beta.toString(), '2.5.0-beta.1');
    });

    test('versione a due cifre completata con lo zero', () {
      expect(AppVersion.tryParse('3.1'), AppVersion.tryParse('3.1.0'));
    });

    test('spazi intorno', () {
      expect(AppVersion.tryParse('  2.5.0 '), AppVersion.tryParse('2.5.0'));
    });

    test('numeri non decimali vengono rifiutati', () {
      // int.tryParse accetterebbe '0x10' come 16: un tag "v0x10.0.0"
      // diventerebbe la versione 16.0.0, cioe' un aggiornamento fantasma che
      // non si risolve mai.
      expect(AppVersion.tryParse('v0x10.0.0'), isNull);
      expect(AppVersion.tryParse('2. 5.0'), isNull);
      expect(AppVersion.tryParse('2..0'), isNull);
      expect(AppVersion.tryParse('+2.5.0'), isNull);
    });

    test('stringhe non valide danno null (non 0.0.0)', () {
      // Restituire 0.0.0 sarebbe pericoloso: qualunque release risulterebbe
      // "più recente" e l'app spammerebbe aggiornamenti.
      expect(AppVersion.tryParse(''), isNull);
      expect(AppVersion.tryParse('nightly'), isNull);
      expect(AppVersion.tryParse('2.x.0'), isNull);
      expect(AppVersion.tryParse('1.2.3.4'), isNull);
      expect(AppVersion.tryParse('-1.0.0'), isNull);
    });
  });

  group('confronto', () {
    AppVersion v(String raw) => AppVersion.tryParse(raw)!;

    test('ordina per major, minor, patch', () {
      expect(v('2.5.0').isNewerThan(v('2.4.9')), isTrue);
      expect(v('2.5.1').isNewerThan(v('2.5.0')), isTrue);
      expect(v('3.0.0').isNewerThan(v('2.99.99')), isTrue);
      expect(v('2.4.2').isNewerThan(v('2.5.0')), isFalse);
    });

    test('due versioni uguali non sono un aggiornamento', () {
      expect(v('2.5.0').isNewerThan(v('2.5.0')), isFalse);
    });

    test('la 10 viene dopo la 9 (confronto numerico, non alfabetico)', () {
      // Con un confronto tra stringhe "2.10.0" < "2.9.0" e l'aggiornamento
      // non verrebbe mai proposto.
      expect(v('2.10.0').isNewerThan(v('2.9.0')), isTrue);
    });

    test('la stabile viene dopo la sua pre-release', () {
      expect(v('2.5.0').isNewerThan(v('2.5.0-beta.1')), isTrue);
      expect(v('2.5.0-beta.1').isNewerThan(v('2.5.0')), isFalse);
    });

    test('le pre-release si confrontano per numero, non per stringa', () {
      // Con un compareTo tra stringhe 'beta.10' < 'beta.9' e un aggiornamento
      // reale non verrebbe mai proposto.
      expect(v('2.6.0-beta.10').isNewerThan(v('2.6.0-beta.9')), isTrue);
      expect(v('2.6.0-beta.9').isNewerThan(v('2.6.0-beta.10')), isFalse);
      expect(v('2.6.0-rc.2').isNewerThan(v('2.6.0-rc.1')), isTrue);
    });

    test('una pre-release piu\' specifica viene dopo (beta < beta.1)', () {
      expect(v('2.6.0-beta.1').isNewerThan(v('2.6.0-beta')), isTrue);
    });

    test('un identificatore alfanumerico batte quello numerico (semver)', () {
      expect(v('2.6.0-rc').isNewerThan(v('2.6.0-1')), isTrue);
    });

    test('una lista si ordina correttamente', () {
      final versions = [v('2.10.0'), v('2.4.2'), v('2.5.0-beta.1'), v('2.5.0')]
        ..sort();
      expect(
        versions.map((e) => e.toString()).toList(),
        ['2.4.2', '2.5.0-beta.1', '2.5.0', '2.10.0'],
      );
    });
  });
}
