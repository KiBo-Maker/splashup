// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get myTeams => 'My Teams';

  @override
  String get addTeam => 'Add Team';

  @override
  String get addNewTeam => 'Add New Team';

  @override
  String get teamName => 'Team Name';

  @override
  String get teamNameHint => 'e.g., Varsity Girls - Category';

  @override
  String get pool => 'Pool';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get noTeamsYet => 'No teams yet.';

  @override
  String get noTeamsHint => 'Tap the + button to add your first team!';

  @override
  String get athletes => 'Athletes';

  @override
  String get addAthlete => 'Add Athlete';

  @override
  String get addNewAthlete => 'Add New Athlete';

  @override
  String get athleteName => 'Athlete Name';

  @override
  String get birthYear => 'Birth Year';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get preferredStyles => 'Preferred Styles';

  @override
  String get freestyle => 'Freestyle';

  @override
  String get butterfly => 'Butterfly';

  @override
  String get backstroke => 'Backstroke';

  @override
  String get breaststroke => 'Breaststroke';

  @override
  String get status => 'Status';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get notes => 'Notes';

  @override
  String get noAthletesYet => 'No athletes yet.';

  @override
  String get noAthletesHint => 'Tap the + button to add your first athlete!';

  @override
  String get searchAthletes => 'Search athletes...';

  @override
  String get showInactive => 'Show Inactive';

  @override
  String get notesTitle => 'Athlete Notes';

  @override
  String get noNotesForAthlete => 'No notes for this athlete.';

  @override
  String get close => 'Close';

  @override
  String get athleteDetails => 'Athlete Details';

  @override
  String get editAthlete => 'Edit Athlete';

  @override
  String get age => 'Age';

  @override
  String get noTimesRecorded => 'No times recorded yet.';

  @override
  String get addYourFirstTime => 'Tap the + button to add the first time!';

  @override
  String get addChrono => 'Add Chrono';

  @override
  String get editChrono => 'Edit Chrono';

  @override
  String get date => 'Date';

  @override
  String get poolLength => 'Pool Length';

  @override
  String get distance => 'Distance (meters)';

  @override
  String get style => 'Style';

  @override
  String get im => 'IM (Individual Medley)';

  @override
  String get finalTime => 'Final Time';

  @override
  String get finalTimeHint => 'MM:SS.ss';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get deleteConfirmation =>
      'Are you sure you want to delete this record?';

  @override
  String get deleteChronoTitle => 'Delete Chrono';

  @override
  String get unsavedChanges => 'Unsaved Changes';

  @override
  String get discardChangesWarning =>
      'You have unsaved changes. Are you sure you want to discard them?';

  @override
  String get discard => 'Discard';

  @override
  String get filterBy => 'Filter by:';

  @override
  String get allDistances => 'All Distances';

  @override
  String get allStyles => 'All Styles';

  @override
  String get noResultsFound => 'No results found for the selected filters.';

  @override
  String get favoriteStyles => 'Favorite Styles';

  @override
  String get chronoType => 'Type';

  @override
  String get training => 'Training';

  @override
  String get race => 'Race';

  @override
  String get allTypes => 'All Types';

  @override
  String get personalBestsTitle => 'Personal Bests';

  @override
  String get noBestsYet => 'No personal bests recorded yet.';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String teamDeleted(String teamName) {
    return '\"$teamName\" deleted.';
  }

  @override
  String get deleteData => 'Reset App Data';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteDataWarning =>
      'This action is irreversible. All your teams, athletes, and records will be permanently deleted.';

  @override
  String get dataReset => 'All data has been reset.';

  @override
  String get dataResetFailed => 'Failed to reset data.';

  @override
  String get typeToDelete => 'Type \'DELETE\' to confirm';

  @override
  String get editTeam => 'Edit Team';

  @override
  String get deleteAthlete => 'Delete Athlete';

  @override
  String get deleteAthleteWarning =>
      'This will permanently delete the athlete and all their recorded times. Would you like to deactivate them instead?';

  @override
  String get deactivate => 'Deactivate';

  @override
  String get deleteAnyway => 'Delete Anyway';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get moveAthletes => 'Move Athletes';

  @override
  String get moveAthletesDescription => 'Move athletes between teams.';

  @override
  String get moveAthletesDeny =>
      'You need at least two teams to use this feature.';

  @override
  String get moveSingleAthlete => 'Move a single athlete';

  @override
  String get moveAthletesByYear => 'Move athletes by birth year';

  @override
  String get moveAllAthletes => 'Move all athletes from a team';

  @override
  String get sourceTeam => 'Source Team';

  @override
  String get destinationTeam => 'Destination Team';

  @override
  String get selectAthlete => 'Select Athlete';

  @override
  String get noAthletesInTeam => 'No athletes in this team.';

  @override
  String get move => 'Move';

  @override
  String get selectTeamsFirst =>
      'Please select source and destination teams first.';

  @override
  String get moveConfirmation =>
      'Are you sure you want to move the selected athlete(s)?';

  @override
  String get moveSuccess => 'Athletes moved successfully.';

  @override
  String get selectBirthYear => 'Select Birth Year';

  @override
  String get selectSourceTeamFirst => 'Select a source team first';

  @override
  String get noYearsInTeam => 'No athletes with birth years found.';

  @override
  String get deleteTeam => 'Delete Team';

  @override
  String get deleteTeamDescription =>
      'Permanently delete a team and its athletes.';

  @override
  String get selectTeamToDelete => 'Select Team to Delete';

  @override
  String get deleteTeamWarning =>
      'This will permanently delete the team and all its athletes. What would you like to do?';

  @override
  String get moveAthletesOption => 'Move Athletes First';

  @override
  String get deleteTeamConfirmation =>
      'This action is irreversible. To confirm, please type DELETE below.';

  @override
  String get dataCleanup => 'Data Cleanup';

  @override
  String get deactivateInactiveAthletes => 'Deactivate Inactive Athletes';

  @override
  String get deactivateInactiveDescription =>
      'Sets athletes with no new recorded times for longer than the selected period as \'Inactive\'.';

  @override
  String get deactivateAfter => 'No times for';

  @override
  String get months => 'months';

  @override
  String get run => 'Run';

  @override
  String get deactivationConfirmation =>
      'This will check all active athletes. If their last recorded time is older than the selected period, they will be set to \'Inactive\'. Are you sure you want to proceed?';

  @override
  String deactivationComplete(Object count) {
    return 'Cleanup complete. $count athlete(s) were deactivated.';
  }

  @override
  String get deleteInactiveAthletes => 'Delete Inactive Athletes';

  @override
  String get deleteInactiveDescription =>
      'Permanently deletes athletes who have been \'Inactive\' for longer than the selected period.';

  @override
  String get deleteAfter => 'Inactive for';

  @override
  String get years => 'years';

  @override
  String get deletionConfirmation =>
      'This will permanently delete all athletes who have been inactive for more than the selected period. This action cannot be undone. Are you sure?';

  @override
  String deletionComplete(Object count) {
    return 'Cleanup complete. $count athlete(s) were deleted.';
  }

  @override
  String get googleSignIn => 'Sign in with Google';

  @override
  String get stopwatch => 'Stopwatch';

  @override
  String get lap => 'Lap';

  @override
  String get laps => 'Laps';

  @override
  String get reset => 'Reset';

  @override
  String get start => 'Start';

  @override
  String get stop => 'Stop';

  @override
  String get saveTime => 'Save Time';

  @override
  String get chronoNotesTitle => 'Time Notes';

  @override
  String get noNotesForChrono => 'No notes for this time record.';

  @override
  String get splits => 'Splits';

  @override
  String get splitDistance => 'Split Distance';

  @override
  String get noSplitsYet => 'No splits added yet';

  @override
  String get splitTimeHint => 'MM:SS.ss';

  @override
  String splitTimeInvalidError(Object index) {
    return 'Split $index: please enter a valid cumulative time';
  }

  @override
  String splitDistanceMultiple(Object number, Object poolLength) {
    return 'Split $number: distance must be a multiple of $poolLength m';
  }

  @override
  String splitDistanceExceeds(
    Object number,
    Object splitDistance,
    Object totalDistance,
  ) {
    return 'Split $number: distance ($splitDistance m) exceeds total distance ($totalDistance m)';
  }

  @override
  String splitDistanceOrder(Object number) {
    return 'Split $number: distances must be in ascending order';
  }

  @override
  String splitTimeOrder(Object number) {
    return 'Split $number: times must be in ascending order';
  }

  @override
  String get segment => 'Segment';

  @override
  String get cumulative => 'Cumulative';

  @override
  String get invalidTimeFormat => 'Invalid time format';

  @override
  String get splitAnalysis => 'Split Analysis';

  @override
  String get filters => 'Filters';

  @override
  String get type => 'Type';

  @override
  String get legend => 'Legend';

  @override
  String get noSplitData => 'No split data available';

  @override
  String get tryDifferentFilter =>
      'Try selecting a different distance or style';

  @override
  String get noVisibleLines =>
      'No visible lines. Enable at least one from the legend below.';

  @override
  String showRecords(Object count) {
    return 'Show records: $count';
  }

  @override
  String get distanceMeters => 'Distance (m)';

  @override
  String get timeSeconds => 'Time (s)';

  @override
  String get tooltipMode => 'Tooltip Display';

  @override
  String get compactData => 'Compact (all times at distance)';

  @override
  String get detailedData => 'Detailed (segment analysis)';

  @override
  String get selectSingleLineForDetails =>
      'Select only one line in the checkbox to view correct details';

  @override
  String get appSlogan => 'Dive in. Stand out. SplashUp';

  @override
  String get welcomeSubtitle =>
      'Your swimming companion\n100% Offline & Private';

  @override
  String get diveInButton => 'Dive In!';

  @override
  String get loadTestDataTitle => 'Welcome to SplashUp!';

  @override
  String get loadTestDataMessage =>
      'It looks like your database is empty. Would you like to load some sample data to explore the app, or start fresh?';

  @override
  String get loadTestDataBtn => 'Load Sample Data';

  @override
  String get startFreshBtn => 'Start Fresh';

  @override
  String get sameSourceDestError =>
      'Source and destination teams cannot be the same.';

  @override
  String get noAthletesToMove => 'No athletes found to move.';

  @override
  String teamAlsoDeleted(Object name) {
    return '\"$name\" was also deleted.';
  }

  @override
  String get errorMovingAthletes => 'Error moving athletes';

  @override
  String get moveType => 'Move Type';

  @override
  String get errorDeactivation => 'Error during deactivation';

  @override
  String get errorDeletion => 'Error during deletion';

  @override
  String get requiredField => 'Required';

  @override
  String get timeGreaterThanZero => 'Time must be greater than zero';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get pleaseSelectYear => 'Please select a year';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String errorWithDetails(Object error) {
    return 'Error: $error';
  }

  @override
  String get hideSplits => 'Hide splits';

  @override
  String get showSplits => 'Show splits';

  @override
  String get startLabel => 'Start';

  @override
  String get splitLabel => 'Split:';

  @override
  String errorSavingAthlete(Object error) {
    return 'Error saving athlete: $error';
  }

  @override
  String errorSavingChrono(Object error) {
    return 'Error saving chrono: $error';
  }

  @override
  String get dummyTeamNoviceA => 'Team A - Novice A';

  @override
  String get dummyTeamMasters => 'Team A - Masters';

  @override
  String get dummyTeamB => 'Team B';

  @override
  String get dummyTeamJuniors => 'Team C - Juniors';

  @override
  String dummyAthleteName(Object code) {
    return 'Athlete $code';
  }

  @override
  String get dummyCodeNovice => 'N';

  @override
  String get dummyCodeMasters => 'M';

  @override
  String get dummyCodeJuniors => 'J';

  @override
  String get dummyAthleteNote => 'Sample athlete created for demo purposes.';

  @override
  String get dummyNoteRace => 'Sample race';

  @override
  String get dummyNoteTraining => 'Sample training';

  @override
  String get dummyNotePersonalBest => 'Personal best!';

  @override
  String get customizeExperience => 'Customize experience';

  @override
  String get customizeExperienceDescription =>
      'Theme, colors, font, text size and language';

  @override
  String get colorTheme => 'Color theme';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorTeal => 'Teal';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorCoral => 'Coral';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorPink => 'Pink';

  @override
  String get font => 'Font';

  @override
  String get fontStandard => 'Standard';

  @override
  String get fontOpenDyslexic => 'OpenDyslexic';

  @override
  String get fontOpenDyslexicDescription =>
      'Font designed to improve readability for people with dyslexia';

  @override
  String get textSize => 'Text size';

  @override
  String get textSizeSmall => 'Small';

  @override
  String get textSizeNormal => 'Normal';

  @override
  String get textSizeLarge => 'Large';

  @override
  String get language => 'Language';

  @override
  String get preview => 'Preview';

  @override
  String get previewPangram =>
      'The quick brown fox jumps over the lazy dog. 0123456789';

  @override
  String get hapticFeedback => 'Haptic feedback';

  @override
  String get hapticFeedbackDescription => 'Vibrate on start, stop and lap';

  @override
  String get soundFeedback => 'Sound feedback';

  @override
  String get soundFeedbackDescription =>
      'Play a click sound on start, stop and lap';

  @override
  String get keepScreenOn => 'Keep screen on';

  @override
  String get keepScreenOnDescription =>
      'Prevent the screen from turning off while on the stopwatch';

  @override
  String get timePrecision => 'Time precision';

  @override
  String get precisionHundredths => 'Hundredths (0.01 s)';

  @override
  String get precisionTenths => 'Tenths (0.1 s)';

  @override
  String get info => 'Info';

  @override
  String get appVersion => 'Version';

  @override
  String get openSourceLicenses => 'Open source licenses';

  @override
  String get timePrecisionDescription =>
      'Display only: times are always saved to the hundredth.';

  @override
  String get backupSection => 'Backup and restore';

  @override
  String get exportBackup => 'Export backup';

  @override
  String get exportBackupDescription =>
      'Save teams, athletes and times to a JSON file, in the folder you choose.';

  @override
  String get importBackup => 'Restore from backup';

  @override
  String get importBackupDescription =>
      'Replaces all current data with the contents of the file you pick.';

  @override
  String get backupCancelled => 'Operation cancelled.';

  @override
  String backupExportSuccess(int teams, int athletes, int chronos) {
    return 'Backup saved — teams: $teams, athletes: $athletes, times: $chronos.';
  }

  @override
  String get backupExportFailed => 'Backup failed.';

  @override
  String get restoreConfirmTitle => 'Replace all data?';

  @override
  String restoreConfirmBody(int teams, int athletes, int chronos) {
    return 'The file contains — teams: $teams, athletes: $athletes, times: $chronos.\n\nEverything currently on this device will be deleted and replaced. This cannot be undone.';
  }

  @override
  String get restoreConfirmAction => 'Replace';

  @override
  String restoreSuccess(int teams, int athletes, int chronos) {
    return 'Restore complete — teams: $teams, athletes: $athletes, times: $chronos.';
  }

  @override
  String restoreSkipped(int count) {
    return 'Orphaned records skipped: $count.';
  }

  @override
  String get restoreFailedInvalidFile => 'This file is not a SplashUp backup.';

  @override
  String get restoreFailedNewerVersion =>
      'This backup was created by a newer version of SplashUp. Update the app and try again.';

  @override
  String get restoreFailedCorrupted =>
      'The backup file is damaged or incomplete.';

  @override
  String get restoreFailedGeneric =>
      'Restore failed. Your existing data has not been changed.';

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get checkForUpdatesDescription =>
      'Ask GitHub whether a newer version has been released.';

  @override
  String get autoCheckUpdates => 'Check on startup';

  @override
  String get autoCheckUpdatesDescription =>
      'Once a day at most. This is the only internet connection SplashUp makes: it reads the public release on GitHub and sends no data.';

  @override
  String updateAvailableTitle(String version) {
    return 'SplashUp $version is available';
  }

  @override
  String get updateReleaseNotes => 'What’s new';

  @override
  String get updateWhereToDownload =>
      'Download the update from GitHub and install it the same way you installed the app.';

  @override
  String get updateDownloadApk => 'Download APK';

  @override
  String get updateOpenPage => 'Open on GitHub';

  @override
  String get updateLater => 'Later';

  @override
  String updateUpToDate(String version) {
    return 'You already have the latest version ($version).';
  }

  @override
  String get updateErrorNetwork =>
      'Could not reach GitHub. Check your connection and try again.';

  @override
  String get updateErrorRateLimit =>
      'Too many requests to GitHub in a short time. Try again later.';

  @override
  String get updateErrorNoRelease =>
      'No release has been published on GitHub yet.';

  @override
  String get updateErrorGeneric => 'Update check failed.';

  @override
  String get updateOpenLinkFailed =>
      'Could not open the link. Go to github.com/mattileap/splashup/releases.';

  @override
  String restoreConfirmBodyWithDropped(
    int teams,
    int athletes,
    int chronos,
    int dropped,
  ) {
    return 'The file contains — teams: $teams, athletes: $athletes, times: $chronos.\n\nCareful: $dropped records in the file are orphaned (athletes with no team, or times with no athlete) and will NOT be restored.\n\nEverything currently on this device will be deleted and replaced. This cannot be undone.';
  }
}
