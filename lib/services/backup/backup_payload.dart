/// Contenuto grezzo del database locale, così come sta negli store Sembast.
///
/// IMPORTANTE: il backup NON passa dai modelli (`Team`/`Athlete`/`Chrono`).
/// I loro `toMap()` omettono i campi di collegamento e di servizio —
/// `Athlete.toMap()` non scrive `teamId` né `createdAt`, `Chrono.toMap()` non
/// scrive `athleteId` né `teamId` — perché nel normale flusso di scrittura
/// quei campi vengono aggiunti dal repository. Passando dai modelli, un
/// backup/ripristino perderebbe il legame atleta-squadra e tempo-atleta,
/// cioè esattamente la struttura dei dati.
///
/// Per questo qui si lavora sulle mappe dei record così come sono: quello che
/// c'è nel DB finisce nel file, e viceversa.
class BackupPayload {
  /// id record -> contenuto del record.
  final Map<String, Map<String, Object?>> teams;
  final Map<String, Map<String, Object?>> athletes;
  final Map<String, Map<String, Object?>> chronos;

  const BackupPayload({
    required this.teams,
    required this.athletes,
    required this.chronos,
  });

  const BackupPayload.empty()
      : teams = const {},
        athletes = const {},
        chronos = const {};

  int get teamCount => teams.length;
  int get athleteCount => athletes.length;
  int get chronoCount => chronos.length;

  bool get isEmpty => teams.isEmpty && athletes.isEmpty && chronos.isEmpty;
}

/// Esito della potatura dei record scollegati, vedi
/// [BackupService.pruneOrphans].
class PrunedPayload {
  /// Quello che verrà effettivamente scritto nel database.
  final BackupPayload payload;

  /// Quello che c'è nel file, potatura esclusa.
  ///
  /// Serve per dire all'utente la verità nel dialog di conferma: se mostrassimo
  /// i conteggi dopo la potatura, un file con le squadre danneggiate direbbe
  /// "atleti: 0, tempi: 0", l'utente confermerebbe, e scoprirebbe solo dopo —
  /// con i dati già cancellati — che il ripristino non ha riportato niente.
  final BackupPayload source;

  /// Atleti scartati perché la loro squadra non esiste nel backup.
  final int droppedAthletes;

  /// Tempi scartati perché il loro atleta non esiste (o è stato scartato).
  final int droppedChronos;

  const PrunedPayload({
    required this.payload,
    required this.source,
    required this.droppedAthletes,
    required this.droppedChronos,
  });

  int get droppedTotal => droppedAthletes + droppedChronos;
  bool get hasDropped => droppedTotal > 0;
}
