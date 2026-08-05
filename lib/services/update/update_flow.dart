import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import 'update_service.dart';
import 'update_settings_service.dart';

/// Orchestrazione della UI del controllo aggiornamenti, condivisa tra il
/// bottone manuale in Impostazioni e il controllo automatico all'avvio.
class UpdateFlow {
  const UpdateFlow._();

  /// Controllo richiesto dall'utente: mostra SEMPRE un esito, anche quando non
  /// c'è nessun aggiornamento o la rete non va (altrimenti il bottone sembra
  /// non funzionare).
  static Future<void> checkManually(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final settings = context.read<UpdateSettingsService>();

    final result = await _runCheck();
    // Un tentativo fallito non deve consumare la finestra delle 24 ore: se il
    // coach prova a bordo vasca senza campo, il controllo automatico deve poter
    // ripartire appena torna sotto il wi-fi.
    if (result.isError) {
      await settings.markAttemptFailed();
    } else {
      await settings.markChecked();
    }
    if (!context.mounted) return;

    if (result.status == UpdateStatus.updateAvailable) {
      await _showUpdateDialog(context, result.release!);
      return;
    }

    final message = switch (result.status) {
      UpdateStatus.upToDate =>
        l10n.updateUpToDate(result.release?.version.toString() ?? ''),
      UpdateStatus.networkError => l10n.updateErrorNetwork,
      UpdateStatus.rateLimited => l10n.updateErrorRateLimit,
      UpdateStatus.noRelease => l10n.updateErrorNoRelease,
      _ => l10n.updateErrorGeneric,
    };
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  /// Controllo automatico all'avvio: al massimo una volta al giorno e
  /// completamente silenzioso, tranne quando c'è davvero un aggiornamento.
  /// Un errore di rete qui non deve disturbare l'allenatore a bordo vasca.
  static Future<void> maybeCheckOnStartup(BuildContext context) async {
    final settings = context.read<UpdateSettingsService>();
    if (!settings.shouldAutoCheck()) return;

    final result = await _runCheck();
    // Errore: si riprova dopo `retryInterval` (un'ora) invece di consumare la
    // finestra delle 24 ore, ma senza rifare la richiesta a ogni avvio.
    if (result.isError) {
      await settings.markAttemptFailed();
    } else {
      await settings.markChecked();
    }
    if (!context.mounted) return;
    if (!result.hasUpdate) return;

    await _showUpdateDialog(context, result.release!);
  }

  static Future<UpdateCheckResult> _runCheck() async {
    // Qualsiasi eccezione inattesa (PackageInfo che fallisce, un plugin non
    // registrato) diventa un esito, non un errore asincrono non gestito: il
    // bottone manuale deve sempre dire qualcosa all'utente invece di limitarsi
    // a spegnere lo spinner.
    try {
      final info = await PackageInfo.fromPlatform();
      final service = UpdateService();
      try {
        return await service.check(currentVersion: info.version);
      } finally {
        service.dispose();
      }
    } catch (error, stack) {
      debugPrint('Update check failed unexpectedly: $error\n$stack');
      return const UpdateCheckResult(UpdateStatus.unknownError);
    }
  }

  static Future<void> _showUpdateDialog(
    BuildContext context,
    GitHubRelease release,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.system_update_outlined),
        title: Text(l10n.updateAvailableTitle(release.version.toString())),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (release.notes.isNotEmpty) ...[
                  Text(
                    l10n.updateReleaseNotes,
                    style: Theme.of(dialogContext).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  // Le note arrivano in Markdown da GitHub: le mostriamo come
                  // testo semplice per non aggiungere una dipendenza solo per
                  // questo. Il link "Apri su GitHub" resta per la versione
                  // formattata.
                  Text(release.notes),
                  const SizedBox(height: 12),
                ],
                Text(
                  l10n.updateWhereToDownload,
                  style: Theme.of(dialogContext).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.updateLater),
          ),
          if (release.apkUrl != null)
            TextButton(
              onPressed: () => _openUrl(dialogContext, release.apkUrl!),
              child: Text(l10n.updateDownloadApk),
            ),
          ElevatedButton(
            onPressed: () => _openUrl(dialogContext, release.pageUrl),
            child: Text(l10n.updateOpenPage),
          ),
        ],
      ),
    );
  }

  static Future<void> _openUrl(BuildContext context, String url) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    var opened = false;
    try {
      // Volutamente senza canLaunchUrl: su Android 11+ richiederebbe una
      // dichiarazione <queries> nel manifest, e qui apriamo solo https.
      opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }

    // Il dialog va chiuso in ogni caso PRIMA dello snackbar: uno snackbar
    // mostrato con il dialog modale ancora aperto viene disegnato sotto la
    // barriera e l'utente non lo vede (il bottone sembra non funzionare).
    if (navigator.canPop()) navigator.pop();
    if (opened) return;
    messenger.showSnackBar(SnackBar(content: Text(l10n.updateOpenLinkFailed)));
  }
}
