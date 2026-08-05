import 'dart:convert';

import 'package:http/http.dart' as http;

import 'app_version.dart';

/// Esito del controllo aggiornamenti.
enum UpdateStatus {
  /// La versione installata è l'ultima pubblicata.
  upToDate,

  /// Su GitHub c'è una release più recente.
  updateAvailable,

  /// GitHub non raggiungibile (offline, DNS, timeout).
  networkError,

  /// Rate limit delle API GitHub esaurito (60 richieste/ora per IP).
  rateLimited,

  /// Il repository non ha nessuna release pubblicata.
  noRelease,

  /// Qualsiasi altro errore (risposta inattesa, JSON malformato...).
  unknownError,
}

/// Una release pubblicata su GitHub, ridotta ai campi che servono all'app.
class GitHubRelease {
  final String tag;
  final AppVersion version;
  final String title;

  /// Corpo della release in Markdown, così come scritto su GitHub.
  final String notes;

  /// Pagina web della release (fallback universale: su Windows non ha senso
  /// scaricare un APK, e su Android l'utente potrebbe volere gli altri file).
  final String pageUrl;

  /// Link diretto all'APK allegato, se presente.
  final String? apkUrl;

  final DateTime? publishedAt;

  const GitHubRelease({
    required this.tag,
    required this.version,
    required this.title,
    required this.notes,
    required this.pageUrl,
    this.apkUrl,
    this.publishedAt,
  });
}

class UpdateCheckResult {
  final UpdateStatus status;

  /// Valorizzata quando lo status è [UpdateStatus.updateAvailable] oppure
  /// [UpdateStatus.upToDate] (nel secondo caso è la release corrente).
  final GitHubRelease? release;

  const UpdateCheckResult(this.status, {this.release});

  bool get hasUpdate => status == UpdateStatus.updateAvailable;
  bool get isError =>
      status == UpdateStatus.networkError ||
      status == UpdateStatus.rateLimited ||
      status == UpdateStatus.unknownError ||
      status == UpdateStatus.noRelease;
}

/// Legge l'ultima release pubblicata sul repository GitHub di SplashUp e la
/// confronta con la versione installata.
///
/// Volutamente senza token: usa le API pubbliche e anonime di GitHub, quindi
/// non serve nessuna credenziale nell'app e nessun dato dell'utente viene
/// inviato (nemmeno la versione installata: il confronto è locale).
///
/// Nota: `/releases/latest` ignora bozze e prerelease, quindi l'app annuncia
/// un aggiornamento solo per le release effettivamente pubblicate.
class UpdateService {
  static const String repositoryOwner = 'mattileap';
  static const String repositoryName = 'splashup';

  static const String releasesPageUrl =
      'https://github.com/$repositoryOwner/$repositoryName/releases';

  static final Uri _latestReleaseUri = Uri.https(
    'api.github.com',
    '/repos/$repositoryOwner/$repositoryName/releases/latest',
  );

  final http.Client _client;
  final bool _ownsClient;
  final Duration timeout;

  UpdateService({http.Client? client, this.timeout = const Duration(seconds: 10)})
      : _client = client ?? http.Client(),
        _ownsClient = client == null;

  /// Chiude il client HTTP se è stato creato dal servizio stesso.
  void dispose() {
    if (_ownsClient) _client.close();
  }

  /// [currentVersion] è la versione installata (es. `PackageInfo.version`).
  Future<UpdateCheckResult> check({required String currentVersion}) async {
    final current = AppVersion.tryParse(currentVersion);
    if (current == null) {
      // Non sappiamo che versione stiamo eseguendo: meglio non dire niente
      // che dire una cosa sbagliata.
      return const UpdateCheckResult(UpdateStatus.unknownError);
    }

    http.Response response;
    try {
      response = await _client.get(
        _latestReleaseUri,
        headers: const {
          'Accept': 'application/vnd.github+json',
          'X-GitHub-Api-Version': '2022-11-28',
          // GitHub richiede uno User-Agent identificabile sulle API.
          'User-Agent': 'SplashUp-App',
        },
      ).timeout(timeout);
    } catch (_) {
      // Copre offline, DNS, TLS e timeout senza importare dart:io, così il
      // servizio resta compilabile anche per il target web.
      return const UpdateCheckResult(UpdateStatus.networkError);
    }

    if (response.statusCode == 404) {
      return const UpdateCheckResult(UpdateStatus.noRelease);
    }
    if (response.statusCode == 403 || response.statusCode == 429) {
      return const UpdateCheckResult(UpdateStatus.rateLimited);
    }
    if (response.statusCode != 200) {
      return const UpdateCheckResult(UpdateStatus.unknownError);
    }

    final release = parseRelease(response.body);
    if (release == null) {
      return const UpdateCheckResult(UpdateStatus.unknownError);
    }

    return UpdateCheckResult(
      release.version.isNewerThan(current)
          ? UpdateStatus.updateAvailable
          : UpdateStatus.upToDate,
      release: release,
    );
  }

  /// Estratta dal metodo di rete per poter essere testata senza HTTP.
  /// Restituisce `null` se la risposta non è utilizzabile.
  static GitHubRelease? parseRelease(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;

      final tag = decoded['tag_name'];
      if (tag is! String) return null;

      final version = AppVersion.tryParse(tag);
      if (version == null) return null;

      String? apkUrl;
      final assets = decoded['assets'];
      if (assets is List) {
        for (final asset in assets) {
          if (asset is! Map) continue;
          final name = asset['name'];
          final url = asset['browser_download_url'];
          if (name is String &&
              url is String &&
              name.toLowerCase().endsWith('.apk')) {
            apkUrl = url;
            break;
          }
        }
      }

      final publishedRaw = decoded['published_at'];
      final title = decoded['name'];
      final notes = decoded['body'];
      final pageUrl = decoded['html_url'];

      return GitHubRelease(
        tag: tag,
        version: version,
        title: (title is String && title.trim().isNotEmpty)
            ? title
            : 'SplashUp $tag',
        notes: notes is String ? notes.trim() : '',
        pageUrl: pageUrl is String ? pageUrl : releasesPageUrl,
        apkUrl: apkUrl,
        publishedAt:
            publishedRaw is String ? DateTime.tryParse(publishedRaw) : null,
      );
    } catch (_) {
      return null;
    }
  }
}
