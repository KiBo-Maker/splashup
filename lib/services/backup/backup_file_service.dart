import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

import '../../repositories/database_repository.dart';
import 'backup_payload.dart';
import 'backup_service.dart';

enum BackupActionStatus {
  success,

  /// L'utente ha chiuso il dialog di sistema senza scegliere niente.
  cancelled,

  /// Qualcosa è andato storto: [BackupImportResult.errorKind] dice cosa,
  /// quando è un problema del file.
  failed,
}

class BackupExportResult {
  final BackupActionStatus status;
  final int teams;
  final int athletes;
  final int chronos;

  /// Percorso scelto dall'utente, quando la piattaforma lo comunica.
  final String? path;

  const BackupExportResult(
    this.status, {
    this.teams = 0,
    this.athletes = 0,
    this.chronos = 0,
    this.path,
  });
}

class BackupImportResult {
  final BackupActionStatus status;
  final int teams;
  final int athletes;
  final int chronos;
  final int droppedAthletes;
  final int droppedChronos;

  /// Valorizzato solo se il file è stato rifiutato in fase di lettura.
  final BackupErrorKind? errorKind;

  const BackupImportResult(
    this.status, {
    this.teams = 0,
    this.athletes = 0,
    this.chronos = 0,
    this.droppedAthletes = 0,
    this.droppedChronos = 0,
    this.errorKind,
  });

  int get droppedTotal => droppedAthletes + droppedChronos;
}

/// Dati letti da un file di backup, prima di essere applicati.
///
/// Il ripristino è in due tempi di proposito: prima si legge e si valida il
/// file, poi si mostra all'utente cosa contiene e si chiede conferma, e solo
/// dopo si tocca il database. Così l'utente non perde i dati attuali per poi
/// scoprire che il file scelto era sbagliato.
class PendingRestore {
  final PrunedPayload pruned;

  const PendingRestore(this.pruned);

  /// Cosa c'è nel file: sono questi i numeri da mostrare nel dialog di
  /// conferma, non quelli dopo la potatura.
  int get fileTeams => pruned.source.teamCount;
  int get fileAthletes => pruned.source.athleteCount;
  int get fileChronos => pruned.source.chronoCount;

  /// Cosa verrà effettivamente scritto.
  int get teams => pruned.payload.teamCount;
  int get athletes => pruned.payload.athleteCount;
  int get chronos => pruned.payload.chronoCount;

  int get droppedTotal => pruned.droppedTotal;
  bool get hasDropped => pruned.hasDropped;
}

/// Mette insieme i dialog di sistema, la serializzazione e il database.
///
/// Due plugin invece di uno, per un motivo pratico: `file_picker` (che avrebbe
/// coperto tutto da solo) dipende da `win32 ^5`, mentre `wakelock_plus` — usato
/// dal cronometro — richiede `win32 ^6`, e le due cose non possono convivere
/// nello stesso progetto. Quindi:
///   - apertura file: `file_selector` (plugin ufficiale Flutter, va su tutte
///     le piattaforme e non tocca win32);
///   - salvataggio: `file_selector` non implementa il dialog "salva con nome"
///     su Android, quindi là si usa `flutter_file_dialog`, che lo fa via
///     Storage Access Framework.
class BackupFileService {
  /// Oltre questa dimensione il file viene rifiutato senza nemmeno leggerlo.
  /// 32 MB sono largamente sufficienti: un backup con 100 atleti e qualche
  /// migliaio di tempi sta in poche centinaia di KB, anche in JSON indentato.
  static const int maxBackupFileBytes = 32 * 1024 * 1024;

  /// Filtro usato solo sul desktop, vedi la nota in [pickAndRead].
  static const XTypeGroup _jsonTypeGroup = XTypeGroup(
    label: 'Backup SplashUp (JSON)',
    extensions: <String>['json'],
    mimeTypes: <String>['application/json'],
    uniformTypeIdentifiers: <String>['public.json'],
  );

  final DatabaseRepository _repository;
  final BackupService _service;

  const BackupFileService(
    this._repository, {
    BackupService service = const BackupService(),
  }) : _service = service;

  /// `flutter_file_dialog` esiste solo per Android e iOS: sul desktop va usato
  /// `file_selector`, altrimenti la chiamata al plugin non trova nessuna
  /// implementazione nativa.
  bool get _isMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  /// Esporta tutto il database in un file scelto dall'utente.
  ///
  /// Su Android passa dallo Storage Access Framework: l'utente può salvare in
  /// qualsiasi cartella, comprese quelle sincronizzate da Drive/Dropbox/
  /// Nextcloud. SplashUp non parla con nessun servizio cloud.
  Future<BackupExportResult> export({
    required String appVersion,
    required String appBuild,
    String? dialogTitle,
  }) async {
    final now = DateTime.now();
    final payload = await _repository.exportAll();
    final jsonText = _service.encode(
      payload,
      appVersion: appVersion,
      appBuild: appBuild,
      createdAt: now,
    );
    final bytes = Uint8List.fromList(utf8.encode(jsonText));
    final fileName = _service.suggestedFileName(now);

    final String savedPath;
    if (_isMobile) {
      // Il plugin scrive lui il file tramite SAF, a partire dai byte: nessun
      // file temporaneo da creare e da ripulire.
      final path = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(
          data: bytes,
          fileName: fileName,
          mimeTypesFilter: const <String>['application/json'],
        ),
      );
      if (path == null) {
        return const BackupExportResult(BackupActionStatus.cancelled);
      }
      savedPath = path;
    } else {
      // Sul desktop il dialog restituisce solo il percorso scelto: la
      // scrittura tocca a noi.
      final location = await getSaveLocation(
        suggestedName: fileName,
        acceptedTypeGroups: const <XTypeGroup>[_jsonTypeGroup],
        confirmButtonText: dialogTitle,
      );
      if (location == null) {
        return const BackupExportResult(BackupActionStatus.cancelled);
      }
      savedPath = location.path;
      try {
        await File(savedPath).writeAsBytes(bytes, flush: true);
      } on FileSystemException {
        // Cartella non scrivibile, disco pieno, percorso di rete caduto.
        return const BackupExportResult(BackupActionStatus.failed);
      }
    }

    return BackupExportResult(
      BackupActionStatus.success,
      teams: payload.teamCount,
      athletes: payload.athleteCount,
      chronos: payload.chronoCount,
      path: savedPath,
    );
  }

  /// Primo passo del ripristino: sceglie il file, lo legge e lo valida.
  ///
  /// Restituisce `null` se l'utente annulla. Lancia [BackupException] se il
  /// file non è un backup valido.
  Future<PendingRestore?> pickAndRead({String? dialogTitle}) async {
    // Su Android NON filtriamo per tipo: molti provider di file non associano
    // un MIME type ai `.json`, e un filtro finirebbe per nascondere
    // all'utente proprio il file che sta cercando. La validazione del
    // contenuto (sotto) è la vera protezione. Sul desktop il filtro per
    // estensione è invece affidabile e comodo.
    final file = await openFile(
      acceptedTypeGroups:
          _isMobile ? const <XTypeGroup>[] : const <XTypeGroup>[_jsonTypeGroup],
      confirmButtonText: dialogTitle,
    );
    if (file == null) return null;

    // Il controllo sulla dimensione arriva prima di qualunque lettura: senza
    // filtro sui tipi, un tap sbagliato può capitare su un video da centinaia
    // di MB, e caricarlo in memoria (byte + stringa UTF-16 + albero JSON,
    // cioè diverse volte la dimensione del file) farebbe morire l'app per
    // esaurimento memoria invece di dire "questo non è un backup".
    final int length;
    try {
      length = await file.length();
    } catch (e) {
      throw BackupException(
        BackupErrorKind.notASplashUpBackup,
        'Il file selezionato non è leggibile: $e',
      );
    }
    if (length > maxBackupFileBytes) {
      throw BackupException(
        BackupErrorKind.notASplashUpBackup,
        'File da $length byte: troppo grande per essere un backup '
        '(limite $maxBackupFileBytes)',
      );
    }

    final Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (e) {
      throw BackupException(
        BackupErrorKind.notASplashUpBackup,
        'Il file selezionato non è leggibile: $e',
      );
    }

    String jsonText;
    try {
      jsonText = utf8.decode(bytes);
    } catch (e) {
      // Un binario qualsiasi (una foto, un PDF) finisce qui.
      throw BackupException(
        BackupErrorKind.notASplashUpBackup,
        'Il file non è testo UTF-8: $e',
      );
    }

    final payload = _service.decode(jsonText);
    return PendingRestore(_service.pruneOrphans(payload));
  }

  /// Secondo passo: sostituisce TUTTI i dati con quelli del backup.
  ///
  /// La sostituzione avviene in una singola transazione Sembast: se qualcosa
  /// va storto a metà, il database resta come prima invece di rimanere
  /// mezzo svuotato.
  Future<BackupImportResult> applyRestore(PendingRestore pending) async {
    await _repository.replaceAll(pending.pruned.payload);
    return BackupImportResult(
      BackupActionStatus.success,
      teams: pending.teams,
      athletes: pending.athletes,
      chronos: pending.chronos,
      droppedAthletes: pending.pruned.droppedAthletes,
      droppedChronos: pending.pruned.droppedChronos,
    );
  }
}
