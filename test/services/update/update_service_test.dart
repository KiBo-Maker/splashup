import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
// MockClient sta in package:http/testing.dart
import 'package:http/testing.dart';
import 'package:splashup/services/update/update_service.dart';

/// Risposta di esempio di `GET /repos/{owner}/{repo}/releases/latest`,
/// ridotta ai campi che l'app legge.
String releaseJson({
  String tag = 'v2.6.0',
  String? name = 'SplashUp 2.6.0',
  String body = '### Novita\nUn sacco di cose.',
  List<Map<String, Object?>>? assets,
}) {
  return jsonEncode({
    'tag_name': tag,
    'name': name,
    'body': body,
    'html_url': 'https://github.com/mattileap/splashup/releases/tag/$tag',
    'published_at': '2026-09-01T10:00:00Z',
    'assets': assets ??
        [
          {
            'name': 'splashup-v2.6.0.apk',
            'browser_download_url':
                'https://github.com/mattileap/splashup/releases/download/$tag/splashup-v2.6.0.apk',
          },
        ],
  });
}

void main() {
  group('parseRelease', () {
    test('estrae versione, note, pagina e APK', () {
      final release = UpdateService.parseRelease(releaseJson())!;

      expect(release.tag, 'v2.6.0');
      expect(release.version.toString(), '2.6.0');
      expect(release.title, 'SplashUp 2.6.0');
      expect(release.notes, '### Novita\nUn sacco di cose.');
      expect(release.pageUrl, contains('/releases/tag/v2.6.0'));
      expect(release.apkUrl, endsWith('.apk'));
      expect(release.publishedAt, DateTime.utc(2026, 9, 1, 10));
    });

    test('sceglie l\'asset .apk ignorando gli altri allegati', () {
      final release = UpdateService.parseRelease(
        releaseJson(assets: [
          {
            'name': 'source-code.zip',
            'browser_download_url': 'https://example.com/source-code.zip',
          },
          {
            'name': 'SplashUp-v2.6.0.APK',
            'browser_download_url': 'https://example.com/app.APK',
          },
        ]),
      )!;

      expect(release.apkUrl, 'https://example.com/app.APK');
    });

    test('senza APK allegato resta solo il link alla pagina', () {
      final release = UpdateService.parseRelease(releaseJson(assets: []))!;
      expect(release.apkUrl, isNull);
      expect(release.pageUrl, isNotEmpty);
    });

    test('se manca il nome della release usa il tag', () {
      final release = UpdateService.parseRelease(releaseJson(name: null))!;
      expect(release.title, 'SplashUp v2.6.0');
    });

    test('risposte inutilizzabili danno null', () {
      expect(UpdateService.parseRelease('non json'), isNull);
      expect(UpdateService.parseRelease('[]'), isNull);
      expect(UpdateService.parseRelease('{}'), isNull);
      // Tag non interpretabile come versione.
      expect(UpdateService.parseRelease(releaseJson(tag: 'nightly')), isNull);
    });
  });

  group('check', () {
    UpdateService serviceReturning(int status, String body) {
      return UpdateService(
        client: MockClient(
          (request) async {
            expect(request.url.host, 'api.github.com');
            expect(request.url.path, contains('/releases/latest'));
            return http.Response(
              body,
              status,
              headers: {'content-type': 'application/json'},
            );
          },
        ),
      );
    }

    test('release più recente -> updateAvailable', () async {
      final service = serviceReturning(200, releaseJson(tag: 'v2.6.0'));
      final result = await service.check(currentVersion: '2.5.0');

      expect(result.status, UpdateStatus.updateAvailable);
      expect(result.hasUpdate, isTrue);
      expect(result.release!.version.toString(), '2.6.0');
      service.dispose();
    });

    test('stessa versione -> upToDate', () async {
      final service = serviceReturning(200, releaseJson(tag: 'v2.5.0'));
      final result = await service.check(currentVersion: '2.5.0');

      expect(result.status, UpdateStatus.upToDate);
      expect(result.hasUpdate, isFalse);
      service.dispose();
    });

    test('release più vecchia della versione installata -> upToDate', () async {
      // Caso reale: build di sviluppo più avanti della release pubblicata.
      final service = serviceReturning(200, releaseJson(tag: 'v2.4.0'));
      final result = await service.check(currentVersion: '2.5.0');

      expect(result.status, UpdateStatus.upToDate);
      service.dispose();
    });

    test('il build number locale non genera falsi aggiornamenti', () async {
      final service = serviceReturning(200, releaseJson(tag: 'v2.5.0'));
      final result = await service.check(currentVersion: '2.5.0+31');

      expect(result.status, UpdateStatus.upToDate);
      service.dispose();
    });

    test('404 -> nessuna release pubblicata', () async {
      final service = serviceReturning(404, '{"message":"Not Found"}');
      final result = await service.check(currentVersion: '2.5.0');

      expect(result.status, UpdateStatus.noRelease);
      service.dispose();
    });

    test('403 -> rate limit', () async {
      final service = serviceReturning(403, '{"message":"rate limit"}');
      final result = await service.check(currentVersion: '2.5.0');

      expect(result.status, UpdateStatus.rateLimited);
      service.dispose();
    });

    test('500 -> errore generico', () async {
      final service = serviceReturning(500, 'boom');
      final result = await service.check(currentVersion: '2.5.0');

      expect(result.status, UpdateStatus.unknownError);
      service.dispose();
    });

    test('eccezione di rete -> networkError', () async {
      final service = UpdateService(
        client: MockClient(
          (request) async => throw http.ClientException('offline'),
        ),
      );
      final result = await service.check(currentVersion: '2.5.0');

      expect(result.status, UpdateStatus.networkError);
      expect(result.isError, isTrue);
      service.dispose();
    });

    test('versione installata non interpretabile -> nessuna decisione', () async {
      final service = serviceReturning(200, releaseJson(tag: 'v9.9.9'));
      final result = await service.check(currentVersion: 'sconosciuta');

      expect(result.status, UpdateStatus.unknownError);
      expect(result.hasUpdate, isFalse);
      service.dispose();
    });
  });
}
