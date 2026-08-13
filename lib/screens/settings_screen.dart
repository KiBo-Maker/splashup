import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/team_model.dart';
import '../repositories/database_repository.dart';
import '../services/backup/backup_file_service.dart';
import '../services/backup/backup_service.dart';
import '../services/stopwatch_settings_service.dart';
import '../services/update/update_flow.dart';
import '../services/update/update_settings_service.dart';
import 'customize_experience_screen.dart';
import 'move_athletes_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Rosso fisso per tutta la "danger zone" (azioni distruttive), volutamente
  // NON legato a colorScheme.error: deve restare rosso anche cambiando tema.
  // shade700 invece del rosso pieno per non risultare troppo acceso in dark
  // mode, pur restando riconoscibile come "pericoloso" in entrambi i temi.
  static final Color _dangerColor = Colors.red.shade700;

  int _selectedMonths = 12;
  int _selectedYears = 2;

  // Il conteggio squadre arriva da uno stream live invece che da una lettura
  // una tantum: i tile "Sposta atleti" ed "Elimina squadra" devono restare
  // coerenti con le squadre aggiunte o eliminate altrove.
  //
  // Ci iscriviamo UNA volta qui e teniamo i dati nello stato, invece di usare
  // uno StreamBuilder dentro la lista. Il motivo: `getTeamsStream()` e' un
  // `async*`, quindi produce uno stream a sottoscrizione singola. Dentro una
  // ListView lo StreamBuilder viene smontato quando esce dall'area di cache e
  // ricostruito quando si torna a scorrere in su: la seconda iscrizione allo
  // stesso stream lancia "Bad state: Stream has already been listened to", e
  // in una build di release l'eccezione diventa un riquadro grigio al posto
  // di mezza schermata (visibile solo scorrendo giu' e poi su).
  StreamSubscription<List<Team>>? _teamsSubscription;
  List<Team> _teams = const <Team>[];

  /// Backup ed esportazione toccano tutto il database: mentre sono in corso,
  /// tutte le altre azioni distruttive della schermata restano disabilitate.
  /// Sembast serializza le transazioni, quindi niente si corrompe, ma l'ordine
  /// non sarebbe garantito: un "elimina dati" partito durante un ripristino
  /// potrebbe atterrare dopo e cancellare quello che si è appena ripristinato.
  bool _backupBusy = false;
  bool _updateBusy = false;

  /// Creata una sola volta: costruirla dentro build() significa passare una
  /// Future nuova a ogni rebuild, e il FutureBuilder tornerebbe a mostrare
  /// "…" al posto della versione ogni volta che si tocca un'altra impostazione.
  late final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  @override
  void initState() {
    super.initState();
    _teamsSubscription =
        context.read<DatabaseRepository>().getTeamsStream().listen(
      (teams) {
        if (!mounted) return;
        setState(() => _teams = teams);
      },
      onError: (Object error) => debugPrint('Teams stream error: $error'),
    );
  }

  @override
  void dispose() {
    _teamsSubscription?.cancel();
    super.dispose();
  }

  // --- BACKUP / RIPRISTINO ---

  Future<void> _handleExportBackup() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final service = BackupFileService(context.read<DatabaseRepository>());

    setState(() => _backupBusy = true);
    try {
      final info = await _packageInfo;
      final result = await service.export(
        appVersion: info.version,
        appBuild: info.buildNumber,
        dialogTitle: l10n.exportBackup,
      );
      if (!mounted) return;

      final message = switch (result.status) {
        BackupActionStatus.success => l10n.backupExportSuccess(
            result.teams,
            result.athletes,
            result.chronos,
          ),
        BackupActionStatus.cancelled => l10n.backupCancelled,
        BackupActionStatus.failed => l10n.backupExportFailed,
      };
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      debugPrint('Backup export failed: $e');
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.backupExportFailed)));
      }
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  Future<void> _handleImportBackup() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final service = BackupFileService(context.read<DatabaseRepository>());

    setState(() => _backupBusy = true);
    try {
      // Prima si legge e valida il file, poi si chiede conferma, e solo dopo
      // si tocca il database: se il file scelto è sbagliato, i dati attuali
      // non sono ancora stati cancellati.
      final pending = await service.pickAndRead(dialogTitle: l10n.importBackup);
      if (!mounted) return;

      if (pending == null) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.backupCancelled)));
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.restoreConfirmTitle),
          // I numeri mostrati sono quelli del FILE, non quelli che
          // sopravvivono alla potatura: se il file ha record scollegati,
          // l'utente deve saperlo PRIMA di confermare, non scoprirlo dopo che
          // i suoi dati sono stati cancellati.
          content: Text(
            pending.hasDropped
                ? l10n.restoreConfirmBodyWithDropped(
                    pending.fileTeams,
                    pending.fileAthletes,
                    pending.fileChronos,
                    pending.droppedTotal,
                  )
                : l10n.restoreConfirmBody(
                    pending.fileTeams,
                    pending.fileAthletes,
                    pending.fileChronos,
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _dangerColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.restoreConfirmAction),
            ),
          ],
        ),
      );

      if (confirmed != true || !mounted) return;

      final result = await service.applyRestore(pending);
      if (!mounted) return;

      final done = l10n.restoreSuccess(
        result.teams,
        result.athletes,
        result.chronos,
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.droppedTotal > 0
                ? '$done ${l10n.restoreSkipped(result.droppedTotal)}'
                : done,
          ),
        ),
      );
    } on BackupException catch (e) {
      debugPrint('Backup restore rejected: $e');
      if (!mounted) return;
      final message = switch (e.kind) {
        BackupErrorKind.notASplashUpBackup => l10n.restoreFailedInvalidFile,
        BackupErrorKind.unsupportedSchemaVersion =>
          l10n.restoreFailedNewerVersion,
        BackupErrorKind.corrupted => l10n.restoreFailedCorrupted,
      };
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      debugPrint('Backup restore failed: $e');
      if (mounted) {
        messenger
            .showSnackBar(SnackBar(content: Text(l10n.restoreFailedGeneric)));
      }
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  // --- AGGIORNAMENTI ---

  Future<void> _handleCheckUpdates() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _updateBusy = true);
    try {
      await UpdateFlow.checkManually(context);
    } catch (e) {
      // UpdateFlow gestisce già i suoi errori, ma senza questo catch un
      // imprevisto qui spegnerebbe lo spinner senza dire niente all'utente.
      debugPrint('Update check failed: $e');
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.updateErrorGeneric)));
      }
    } finally {
      if (mounted) setState(() => _updateBusy = false);
    }
  }

  Future<void> _runDeactivation() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final db = context.read<DatabaseRepository>();

    // I pulsanti chiudono il dialog col SUO context: usando il navigator
    // della schermata, un doppio tap veloce poteva chiudere anche la
    // schermata sottostante.
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deactivateInactiveAthletes),
        content: Text(l10n.deactivationConfirmation),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.cancel)),
          ElevatedButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.run)),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      // Usiamo la funzione ottimizzata del repository locale
      final deactivatedCount = await db.deactivateInactiveAthletes(_selectedMonths);
      
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.deactivationComplete(deactivatedCount))));
      }
    } catch (e) {
      debugPrint('Error running deactivation: $e');
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.errorDeactivation)));
      }
    }
  }

  Future<void> _runDeletion() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final db = context.read<DatabaseRepository>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteInactiveAthletes),
        content: Text(l10n.deletionConfirmation),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _dangerColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      // Usiamo la funzione ottimizzata del repository locale
      final deletedCount = await db.deleteInactiveAthletes(_selectedYears);
      
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.deletionComplete(deletedCount))));
      }
    } catch (e) {
      debugPrint('Error running deletion: $e');
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.errorDeletion)));
      }
    }
  }
  
  Future<void> _showDeleteTeamDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final db = context.read<DatabaseRepository>();

    final teamToDelete = await showDialog<Team>(
      context: context,
      builder: (dialogContext) {
        return StreamBuilder<List<Team>>(
          stream: db.getTeamsStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final teams = snapshot.data ?? [];
            return SimpleDialog(
              title: Text(l10n.selectTeamToDelete),
              children: teams.map((team) => SimpleDialogOption(
                onPressed: () => Navigator.of(dialogContext).pop(team),
                child: Text(team.name),
              )).toList(),
            );
          },
        );
      },
    );

    if (teamToDelete == null || !mounted) return;

    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteTeam),
        content: Text(l10n.deleteTeamWarning),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop('cancel'), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop('move'), child: Text(l10n.moveAthletesOption)),
          ElevatedButton(onPressed: () => Navigator.of(dialogContext).pop('delete'), child: Text(l10n.deleteAnyway)),
        ],
      ),
    );

    if (choice == 'move') {
      if (!mounted) return;
      // Navighiamo alla schermata di spostamento, che è già configurata per gestire ID locali
      navigator.push(MaterialPageRoute(
        builder: (context) => MoveAthletesScreen(
          initialSourceTeam: teamToDelete,
          deleteSourceTeamOnSuccess: true,
        ),
      ));
    } else if (choice == 'delete') {
      // Step 3: Final confirmation with text input.
      if (!mounted) return;
      final confirmationController = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.deleteTeam),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.deleteTeamConfirmation),
              TextField(controller: confirmationController, decoration: InputDecoration(labelText: l10n.typeToDelete)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.cancel)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _dangerColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (confirmationController.text == 'DELETE') {
                  Navigator.of(dialogContext).pop(true);
                }
              },
              child: Text(l10n.delete),
            ),
          ],
        ),
      );

      // Dispose del controller del dialog (prima non veniva mai rilasciato)
      confirmationController.dispose();

      if (confirmed == true) {
        try {
          // Il metodo deleteTeam del repository è già cascading (elimina anche atleti e crono)
          await db.deleteTeam(teamToDelete.id);
          
          if (mounted) {
            // Usa il metodo l10n corretto con parametro
            messenger.showSnackBar(SnackBar(content: Text(l10n.teamDeleted(teamToDelete.name))));
            // Il conteggio squadre si aggiorna da solo: siamo iscritti allo
            // stream delle squadre in initState.
          }
        } catch (e) {
          debugPrint('Error deleting team: $e');
        }
      }
    }
  }

  // Trasformato da "Elimina Account" a "Elimina Tutti i Dati" (Factory Reset locale)
  Future<void> _showDeleteAllDataDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmationController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final db = context.read<DatabaseRepository>();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.dataReset),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(l10n.deleteDataWarning), // "Questa azione è irreversibile..." va bene anche qui
                    const SizedBox(height: 20),
                    Form(
                      key: formKey,
                      child: TextFormField(
                        controller: confirmationController,
                        decoration: InputDecoration(
                          labelText: l10n.typeToDelete,
                        ),
                        onChanged: (value) {
                          setState(() {
                            formKey.currentState!.validate();
                          });
                        },
                        validator: (value) {
                          if (value != 'DELETE') {
                            // Prima ritornava '' che disegnava una striscia
                            // d'errore vuota sotto il campo.
                            return l10n.typeToDelete;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(l10n.cancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: confirmationController,
                  builder: (context, value, child) {
                    return ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.disabled)) {
                              return Colors.grey;
                            }
                            return _dangerColor;
                          },
                        ),
                        foregroundColor: const WidgetStatePropertyAll<Color>(Colors.white),
                      ),
                      onPressed: value.text == 'DELETE'
                          ? () async {
                              final navigator = Navigator.of(context);
                              final messenger = ScaffoldMessenger.of(context);
                              try {
                                // Svuotamento atomico dei tre store. Prima si
                                // cancellava squadra per squadra: un eventuale
                                // record scollegato (atleta con una squadra che
                                // non esiste più) sopravviveva al "reset dati"
                                // restando invisibile nella UI.
                                await db.deleteAllData();

                                if (!mounted) return;
                                navigator.popUntil((route) => route.isFirst);
                                messenger.showSnackBar(
                                  SnackBar(content: Text(l10n.dataReset)),
                                );
                              } catch (e) {
                                if (!mounted) return;
                                navigator.pop();
                                messenger.showSnackBar(
                                  SnackBar(content: Text(l10n.dataResetFailed)),
                                );
                              }
                            }
                          : null,
                      child: Text(l10n.delete),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );

    // Dispose del controller del dialog (prima non veniva mai rilasciato)
    confirmationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stopwatchSettings = Provider.of<StopwatchSettingsService>(context);
    final teamCount = _teams.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.appearance,
                style: Theme.of(context).textTheme.titleSmall),
          ),
          // La scelta del tema (e le nuove opzioni di personalizzazione)
          // vive ora nella pagina dedicata "Personalizza esperienza".
          ListTile(
            leading: const Icon(Icons.tune_outlined),
            title: Text(l10n.customizeExperience),
            subtitle: Text(l10n.customizeExperienceDescription),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CustomizeExperienceScreen(),
                ),
              );
            },
          ),
          const Divider(),
          // --- SEZIONE CRONOMETRO ---
          ListTile(
            title: Text(l10n.stopwatch,
                style: Theme.of(context).textTheme.titleSmall),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration_outlined),
            title: Text(l10n.hapticFeedback),
            subtitle: Text(l10n.hapticFeedbackDescription),
            value: stopwatchSettings.hapticFeedback,
            onChanged: stopwatchSettings.setHapticFeedback,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up_outlined),
            title: Text(l10n.soundFeedback),
            subtitle: Text(l10n.soundFeedbackDescription),
            value: stopwatchSettings.soundFeedback,
            onChanged: stopwatchSettings.setSoundFeedback,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.screen_lock_portrait_outlined),
            title: Text(l10n.keepScreenOn),
            subtitle: Text(l10n.keepScreenOnDescription),
            value: stopwatchSettings.keepScreenOn,
            onChanged: stopwatchSettings.setKeepScreenOn,
          ),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: Text(l10n.timePrecision),
            subtitle: Text(l10n.timePrecisionDescription),
            trailing: DropdownButton<StopwatchPrecision>(
              value: stopwatchSettings.precision,
              items: [
                DropdownMenuItem(
                  value: StopwatchPrecision.hundredths,
                  child: Text(l10n.precisionHundredths),
                ),
                DropdownMenuItem(
                  value: StopwatchPrecision.tenths,
                  child: Text(l10n.precisionTenths),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  stopwatchSettings.setPrecision(value);
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.dataManagement,
                style: Theme.of(context).textTheme.titleSmall),
          ),
          ListTile(
            enabled: teamCount >= 2 && !_backupBusy,
            leading: const Icon(Icons.sync_alt),
            title: Text(l10n.moveAthletes),
            subtitle: Text(
              teamCount < 2 ? l10n.moveAthletesDeny : l10n.moveAthletesDescription,
            ),
            onTap: (teamCount >= 2 && !_backupBusy)
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MoveAthletesScreen(),
                      ),
                    );
                  }
                : null,
          ),
          ListTile(
            enabled: teamCount > 0 && !_backupBusy,
            leading: const Icon(Icons.group_remove_outlined),
            title: Text(l10n.deleteTeam),
            subtitle: Text(l10n.deleteTeamDescription),
            onTap: (teamCount > 0 && !_backupBusy) ? _showDeleteTeamDialog : null,
          ),

          const Divider(),
          // --- SEZIONE BACKUP / RIPRISTINO ---
          ListTile(
            title: Text(l10n.backupSection,
                style: Theme.of(context).textTheme.titleSmall),
          ),
          ListTile(
            enabled: !_backupBusy,
            leading: _backupBusy
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_alt_outlined),
            title: Text(l10n.exportBackup),
            subtitle: Text(l10n.exportBackupDescription),
            onTap: _backupBusy ? null : _handleExportBackup,
          ),
          ListTile(
            enabled: !_backupBusy,
            leading: const Icon(Icons.restore_page_outlined),
            title: Text(l10n.importBackup),
            subtitle: Text(l10n.importBackupDescription),
            onTap: _backupBusy ? null : _handleImportBackup,
          ),

          const Divider(),
          // --- DANGER ZONE --- (raggruppa pulizia dati + reset, tutte
          // azioni distruttive: un unico header le segnala come sezione a
          // rischio, invece di sembrare impostazioni normali).
          ListTile(
            leading: Icon(Icons.warning_amber_rounded, color: _dangerColor),
            title: Text(
              l10n.dangerZone,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _dangerColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ListTile(
            title: Text(l10n.dataCleanup,
                style: Theme.of(context).textTheme.titleSmall),
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: Text(l10n.deactivateInactiveAthletes),
            subtitle: Text(l10n.deactivateInactiveDescription),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.deactivateAfter),
                DropdownButton<int>(
                  value: _selectedMonths,
                  items: [3, 6, 12, 18, 24].map((months) {
                    return DropdownMenuItem(
                      value: months,
                      child: Text('$months ${l10n.months}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedMonths = value);
                    }
                  },
                ),
                ElevatedButton(
                  onPressed: _backupBusy ? null : _runDeactivation,
                  child: Text(l10n.run),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          // ADDED: New UI for the deletion feature.
          ListTile(
            leading: const Icon(Icons.person_remove_outlined),
            title: Text(l10n.deleteInactiveAthletes),
            subtitle: Text(l10n.deleteInactiveDescription),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.deleteAfter),
                DropdownButton<int>(
                  value: _selectedYears,
                  items: [1, 2, 3, 5].map((years) {
                    return DropdownMenuItem(
                      value: years,
                      child: Text('$years ${l10n.years}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedYears = value);
                    }
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _dangerColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _backupBusy ? null : _runDeletion,
                  child: Text(l10n.run),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          // Chiusura della danger zone: sfondo rosso pieno (non legato al
          // tema) e testo bianco, così il reset totale risalta anche a
          // scorrimento veloce rispetto alle altre voci della sezione.
          ListTile(
            enabled: !_backupBusy,
            tileColor: _dangerColor,
            leading: const Icon(Icons.delete_forever, color: Colors.white),
            title: Text(
              l10n.deleteData,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onTap: _backupBusy ? null : _showDeleteAllDataDialog,
          ),

          const Divider(),
          // --- SEZIONE INFO ---
          ListTile(
            title: Text(l10n.info,
                style: Theme.of(context).textTheme.titleSmall),
          ),
          FutureBuilder<PackageInfo>(
            future: _packageInfo,
            builder: (context, snapshot) {
              final info = snapshot.data;
              return ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.appVersion),
                subtitle: Text(
                  info == null ? '…' : '${info.version} (${info.buildNumber})',
                ),
              );
            },
          ),
          ListTile(
            enabled: !_updateBusy,
            leading: _updateBusy
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.system_update_outlined),
            title: Text(l10n.checkForUpdates),
            subtitle: Text(l10n.checkForUpdatesDescription),
            onTap: _updateBusy ? null : _handleCheckUpdates,
          ),
          // Il check automatico è l'unica chiamata di rete di tutta l'app:
          // chi vuole SplashUp a traffico zero deve poterlo spegnere.
          Consumer<UpdateSettingsService>(
            builder: (context, updateSettings, child) => SwitchListTile(
              secondary: const Icon(Icons.update_outlined),
              title: Text(l10n.autoCheckUpdates),
              subtitle: Text(l10n.autoCheckUpdatesDescription),
              value: updateSettings.autoCheckEnabled,
              onChanged: updateSettings.setAutoCheckEnabled,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.openSourceLicenses),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final info = await _packageInfo;
              if (!context.mounted) return;
              showLicensePage(
                context: context,
                applicationName: 'SplashUp',
                applicationVersion: info.version,
              );
            },
          ),

        ],
      ),
    );
  }
}