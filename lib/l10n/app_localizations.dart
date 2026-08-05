import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @myTeams.
  ///
  /// In en, this message translates to:
  /// **'My Teams'**
  String get myTeams;

  /// No description provided for @addTeam.
  ///
  /// In en, this message translates to:
  /// **'Add Team'**
  String get addTeam;

  /// No description provided for @addNewTeam.
  ///
  /// In en, this message translates to:
  /// **'Add New Team'**
  String get addNewTeam;

  /// No description provided for @teamName.
  ///
  /// In en, this message translates to:
  /// **'Team Name'**
  String get teamName;

  /// No description provided for @teamNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Varsity Girls - Category'**
  String get teamNameHint;

  /// No description provided for @pool.
  ///
  /// In en, this message translates to:
  /// **'Pool'**
  String get pool;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @noTeamsYet.
  ///
  /// In en, this message translates to:
  /// **'No teams yet.'**
  String get noTeamsYet;

  /// No description provided for @noTeamsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first team!'**
  String get noTeamsHint;

  /// No description provided for @athletes.
  ///
  /// In en, this message translates to:
  /// **'Athletes'**
  String get athletes;

  /// No description provided for @addAthlete.
  ///
  /// In en, this message translates to:
  /// **'Add Athlete'**
  String get addAthlete;

  /// No description provided for @addNewAthlete.
  ///
  /// In en, this message translates to:
  /// **'Add New Athlete'**
  String get addNewAthlete;

  /// No description provided for @athleteName.
  ///
  /// In en, this message translates to:
  /// **'Athlete Name'**
  String get athleteName;

  /// No description provided for @birthYear.
  ///
  /// In en, this message translates to:
  /// **'Birth Year'**
  String get birthYear;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @preferredStyles.
  ///
  /// In en, this message translates to:
  /// **'Preferred Styles'**
  String get preferredStyles;

  /// No description provided for @freestyle.
  ///
  /// In en, this message translates to:
  /// **'Freestyle'**
  String get freestyle;

  /// No description provided for @butterfly.
  ///
  /// In en, this message translates to:
  /// **'Butterfly'**
  String get butterfly;

  /// No description provided for @backstroke.
  ///
  /// In en, this message translates to:
  /// **'Backstroke'**
  String get backstroke;

  /// No description provided for @breaststroke.
  ///
  /// In en, this message translates to:
  /// **'Breaststroke'**
  String get breaststroke;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @noAthletesYet.
  ///
  /// In en, this message translates to:
  /// **'No athletes yet.'**
  String get noAthletesYet;

  /// No description provided for @noAthletesHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first athlete!'**
  String get noAthletesHint;

  /// No description provided for @searchAthletes.
  ///
  /// In en, this message translates to:
  /// **'Search athletes...'**
  String get searchAthletes;

  /// No description provided for @showInactive.
  ///
  /// In en, this message translates to:
  /// **'Show Inactive'**
  String get showInactive;

  /// No description provided for @notesTitle.
  ///
  /// In en, this message translates to:
  /// **'Athlete Notes'**
  String get notesTitle;

  /// No description provided for @noNotesForAthlete.
  ///
  /// In en, this message translates to:
  /// **'No notes for this athlete.'**
  String get noNotesForAthlete;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @athleteDetails.
  ///
  /// In en, this message translates to:
  /// **'Athlete Details'**
  String get athleteDetails;

  /// No description provided for @editAthlete.
  ///
  /// In en, this message translates to:
  /// **'Edit Athlete'**
  String get editAthlete;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @noTimesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No times recorded yet.'**
  String get noTimesRecorded;

  /// No description provided for @addYourFirstTime.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add the first time!'**
  String get addYourFirstTime;

  /// No description provided for @addChrono.
  ///
  /// In en, this message translates to:
  /// **'Add Chrono'**
  String get addChrono;

  /// No description provided for @editChrono.
  ///
  /// In en, this message translates to:
  /// **'Edit Chrono'**
  String get editChrono;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @poolLength.
  ///
  /// In en, this message translates to:
  /// **'Pool Length'**
  String get poolLength;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance (meters)'**
  String get distance;

  /// No description provided for @style.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get style;

  /// No description provided for @im.
  ///
  /// In en, this message translates to:
  /// **'IM (Individual Medley)'**
  String get im;

  /// No description provided for @finalTime.
  ///
  /// In en, this message translates to:
  /// **'Final Time'**
  String get finalTime;

  /// No description provided for @finalTimeHint.
  ///
  /// In en, this message translates to:
  /// **'MM:SS.ss'**
  String get finalTimeHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this record?'**
  String get deleteConfirmation;

  /// No description provided for @deleteChronoTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Chrono'**
  String get deleteChronoTitle;

  /// No description provided for @unsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChanges;

  /// No description provided for @discardChangesWarning.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Are you sure you want to discard them?'**
  String get discardChangesWarning;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @filterBy.
  ///
  /// In en, this message translates to:
  /// **'Filter by:'**
  String get filterBy;

  /// No description provided for @allDistances.
  ///
  /// In en, this message translates to:
  /// **'All Distances'**
  String get allDistances;

  /// No description provided for @allStyles.
  ///
  /// In en, this message translates to:
  /// **'All Styles'**
  String get allStyles;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found for the selected filters.'**
  String get noResultsFound;

  /// No description provided for @favoriteStyles.
  ///
  /// In en, this message translates to:
  /// **'Favorite Styles'**
  String get favoriteStyles;

  /// No description provided for @chronoType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get chronoType;

  /// No description provided for @training.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get training;

  /// No description provided for @race.
  ///
  /// In en, this message translates to:
  /// **'Race'**
  String get race;

  /// No description provided for @allTypes.
  ///
  /// In en, this message translates to:
  /// **'All Types'**
  String get allTypes;

  /// No description provided for @personalBestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Bests'**
  String get personalBestsTitle;

  /// No description provided for @noBestsYet.
  ///
  /// In en, this message translates to:
  /// **'No personal bests recorded yet.'**
  String get noBestsYet;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @teamDeleted.
  ///
  /// In en, this message translates to:
  /// **'\"{teamName}\" deleted.'**
  String teamDeleted(String teamName);

  /// No description provided for @deleteData.
  ///
  /// In en, this message translates to:
  /// **'Reset App Data'**
  String get deleteData;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteDataWarning.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible. All your teams, athletes, and records will be permanently deleted.'**
  String get deleteDataWarning;

  /// No description provided for @dataReset.
  ///
  /// In en, this message translates to:
  /// **'All data has been reset.'**
  String get dataReset;

  /// No description provided for @dataResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset data.'**
  String get dataResetFailed;

  /// No description provided for @typeToDelete.
  ///
  /// In en, this message translates to:
  /// **'Type \'DELETE\' to confirm'**
  String get typeToDelete;

  /// No description provided for @editTeam.
  ///
  /// In en, this message translates to:
  /// **'Edit Team'**
  String get editTeam;

  /// No description provided for @deleteAthlete.
  ///
  /// In en, this message translates to:
  /// **'Delete Athlete'**
  String get deleteAthlete;

  /// No description provided for @deleteAthleteWarning.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the athlete and all their recorded times. Would you like to deactivate them instead?'**
  String get deleteAthleteWarning;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @deleteAnyway.
  ///
  /// In en, this message translates to:
  /// **'Delete Anyway'**
  String get deleteAnyway;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @moveAthletes.
  ///
  /// In en, this message translates to:
  /// **'Move Athletes'**
  String get moveAthletes;

  /// No description provided for @moveAthletesDescription.
  ///
  /// In en, this message translates to:
  /// **'Move athletes between teams.'**
  String get moveAthletesDescription;

  /// No description provided for @moveAthletesDeny.
  ///
  /// In en, this message translates to:
  /// **'You need at least two teams to use this feature.'**
  String get moveAthletesDeny;

  /// No description provided for @moveSingleAthlete.
  ///
  /// In en, this message translates to:
  /// **'Move a single athlete'**
  String get moveSingleAthlete;

  /// No description provided for @moveAthletesByYear.
  ///
  /// In en, this message translates to:
  /// **'Move athletes by birth year'**
  String get moveAthletesByYear;

  /// No description provided for @moveAllAthletes.
  ///
  /// In en, this message translates to:
  /// **'Move all athletes from a team'**
  String get moveAllAthletes;

  /// No description provided for @sourceTeam.
  ///
  /// In en, this message translates to:
  /// **'Source Team'**
  String get sourceTeam;

  /// No description provided for @destinationTeam.
  ///
  /// In en, this message translates to:
  /// **'Destination Team'**
  String get destinationTeam;

  /// No description provided for @selectAthlete.
  ///
  /// In en, this message translates to:
  /// **'Select Athlete'**
  String get selectAthlete;

  /// No description provided for @noAthletesInTeam.
  ///
  /// In en, this message translates to:
  /// **'No athletes in this team.'**
  String get noAthletesInTeam;

  /// No description provided for @move.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get move;

  /// No description provided for @selectTeamsFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select source and destination teams first.'**
  String get selectTeamsFirst;

  /// No description provided for @moveConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to move the selected athlete(s)?'**
  String get moveConfirmation;

  /// No description provided for @moveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Athletes moved successfully.'**
  String get moveSuccess;

  /// No description provided for @selectBirthYear.
  ///
  /// In en, this message translates to:
  /// **'Select Birth Year'**
  String get selectBirthYear;

  /// No description provided for @selectSourceTeamFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a source team first'**
  String get selectSourceTeamFirst;

  /// No description provided for @noYearsInTeam.
  ///
  /// In en, this message translates to:
  /// **'No athletes with birth years found.'**
  String get noYearsInTeam;

  /// No description provided for @deleteTeam.
  ///
  /// In en, this message translates to:
  /// **'Delete Team'**
  String get deleteTeam;

  /// No description provided for @deleteTeamDescription.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete a team and its athletes.'**
  String get deleteTeamDescription;

  /// No description provided for @selectTeamToDelete.
  ///
  /// In en, this message translates to:
  /// **'Select Team to Delete'**
  String get selectTeamToDelete;

  /// No description provided for @deleteTeamWarning.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the team and all its athletes. What would you like to do?'**
  String get deleteTeamWarning;

  /// No description provided for @moveAthletesOption.
  ///
  /// In en, this message translates to:
  /// **'Move Athletes First'**
  String get moveAthletesOption;

  /// No description provided for @deleteTeamConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible. To confirm, please type DELETE below.'**
  String get deleteTeamConfirmation;

  /// No description provided for @dataCleanup.
  ///
  /// In en, this message translates to:
  /// **'Data Cleanup'**
  String get dataCleanup;

  /// No description provided for @deactivateInactiveAthletes.
  ///
  /// In en, this message translates to:
  /// **'Deactivate Inactive Athletes'**
  String get deactivateInactiveAthletes;

  /// No description provided for @deactivateInactiveDescription.
  ///
  /// In en, this message translates to:
  /// **'Sets athletes with no new recorded times for longer than the selected period as \'Inactive\'.'**
  String get deactivateInactiveDescription;

  /// No description provided for @deactivateAfter.
  ///
  /// In en, this message translates to:
  /// **'No times for'**
  String get deactivateAfter;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @run.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get run;

  /// No description provided for @deactivationConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will check all active athletes. If their last recorded time is older than the selected period, they will be set to \'Inactive\'. Are you sure you want to proceed?'**
  String get deactivationConfirmation;

  /// No description provided for @deactivationComplete.
  ///
  /// In en, this message translates to:
  /// **'Cleanup complete. {count} athlete(s) were deactivated.'**
  String deactivationComplete(Object count);

  /// No description provided for @deleteInactiveAthletes.
  ///
  /// In en, this message translates to:
  /// **'Delete Inactive Athletes'**
  String get deleteInactiveAthletes;

  /// No description provided for @deleteInactiveDescription.
  ///
  /// In en, this message translates to:
  /// **'Permanently deletes athletes who have been \'Inactive\' for longer than the selected period.'**
  String get deleteInactiveDescription;

  /// No description provided for @deleteAfter.
  ///
  /// In en, this message translates to:
  /// **'Inactive for'**
  String get deleteAfter;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @deletionConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all athletes who have been inactive for more than the selected period. This action cannot be undone. Are you sure?'**
  String get deletionConfirmation;

  /// No description provided for @deletionComplete.
  ///
  /// In en, this message translates to:
  /// **'Cleanup complete. {count} athlete(s) were deleted.'**
  String deletionComplete(Object count);

  /// No description provided for @googleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get googleSignIn;

  /// No description provided for @stopwatch.
  ///
  /// In en, this message translates to:
  /// **'Stopwatch'**
  String get stopwatch;

  /// No description provided for @lap.
  ///
  /// In en, this message translates to:
  /// **'Lap'**
  String get lap;

  /// No description provided for @laps.
  ///
  /// In en, this message translates to:
  /// **'Laps'**
  String get laps;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @saveTime.
  ///
  /// In en, this message translates to:
  /// **'Save Time'**
  String get saveTime;

  /// No description provided for @chronoNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Notes'**
  String get chronoNotesTitle;

  /// No description provided for @noNotesForChrono.
  ///
  /// In en, this message translates to:
  /// **'No notes for this time record.'**
  String get noNotesForChrono;

  /// No description provided for @splits.
  ///
  /// In en, this message translates to:
  /// **'Splits'**
  String get splits;

  /// No description provided for @splitDistance.
  ///
  /// In en, this message translates to:
  /// **'Split Distance'**
  String get splitDistance;

  /// No description provided for @noSplitsYet.
  ///
  /// In en, this message translates to:
  /// **'No splits added yet'**
  String get noSplitsYet;

  /// No description provided for @splitTimeHint.
  ///
  /// In en, this message translates to:
  /// **'MM:SS.ss'**
  String get splitTimeHint;

  /// No description provided for @splitTimeInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Split {index}: please enter a valid cumulative time'**
  String splitTimeInvalidError(Object index);

  /// No description provided for @splitDistanceMultiple.
  ///
  /// In en, this message translates to:
  /// **'Split {number}: distance must be a multiple of {poolLength} m'**
  String splitDistanceMultiple(Object number, Object poolLength);

  /// No description provided for @splitDistanceExceeds.
  ///
  /// In en, this message translates to:
  /// **'Split {number}: distance ({splitDistance} m) exceeds total distance ({totalDistance} m)'**
  String splitDistanceExceeds(
    Object number,
    Object splitDistance,
    Object totalDistance,
  );

  /// No description provided for @splitDistanceOrder.
  ///
  /// In en, this message translates to:
  /// **'Split {number}: distances must be in ascending order'**
  String splitDistanceOrder(Object number);

  /// No description provided for @splitTimeOrder.
  ///
  /// In en, this message translates to:
  /// **'Split {number}: times must be in ascending order'**
  String splitTimeOrder(Object number);

  /// No description provided for @segment.
  ///
  /// In en, this message translates to:
  /// **'Segment'**
  String get segment;

  /// No description provided for @cumulative.
  ///
  /// In en, this message translates to:
  /// **'Cumulative'**
  String get cumulative;

  /// No description provided for @invalidTimeFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid time format'**
  String get invalidTimeFormat;

  /// No description provided for @splitAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Split Analysis'**
  String get splitAnalysis;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @legend.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get legend;

  /// No description provided for @noSplitData.
  ///
  /// In en, this message translates to:
  /// **'No split data available'**
  String get noSplitData;

  /// No description provided for @tryDifferentFilter.
  ///
  /// In en, this message translates to:
  /// **'Try selecting a different distance or style'**
  String get tryDifferentFilter;

  /// No description provided for @noVisibleLines.
  ///
  /// In en, this message translates to:
  /// **'No visible lines. Enable at least one from the legend below.'**
  String get noVisibleLines;

  /// No description provided for @showRecords.
  ///
  /// In en, this message translates to:
  /// **'Show records: {count}'**
  String showRecords(Object count);

  /// No description provided for @distanceMeters.
  ///
  /// In en, this message translates to:
  /// **'Distance (m)'**
  String get distanceMeters;

  /// No description provided for @timeSeconds.
  ///
  /// In en, this message translates to:
  /// **'Time (s)'**
  String get timeSeconds;

  /// No description provided for @tooltipMode.
  ///
  /// In en, this message translates to:
  /// **'Tooltip Display'**
  String get tooltipMode;

  /// No description provided for @compactData.
  ///
  /// In en, this message translates to:
  /// **'Compact (all times at distance)'**
  String get compactData;

  /// No description provided for @detailedData.
  ///
  /// In en, this message translates to:
  /// **'Detailed (segment analysis)'**
  String get detailedData;

  /// No description provided for @selectSingleLineForDetails.
  ///
  /// In en, this message translates to:
  /// **'Select only one line in the checkbox to view correct details'**
  String get selectSingleLineForDetails;

  /// No description provided for @appSlogan.
  ///
  /// In en, this message translates to:
  /// **'Dive in. Stand out. SplashUp'**
  String get appSlogan;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your swimming companion\n100% Offline & Private'**
  String get welcomeSubtitle;

  /// No description provided for @diveInButton.
  ///
  /// In en, this message translates to:
  /// **'Dive In!'**
  String get diveInButton;

  /// No description provided for @loadTestDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to SplashUp!'**
  String get loadTestDataTitle;

  /// No description provided for @loadTestDataMessage.
  ///
  /// In en, this message translates to:
  /// **'It looks like your database is empty. Would you like to load some sample data to explore the app, or start fresh?'**
  String get loadTestDataMessage;

  /// No description provided for @loadTestDataBtn.
  ///
  /// In en, this message translates to:
  /// **'Load Sample Data'**
  String get loadTestDataBtn;

  /// No description provided for @startFreshBtn.
  ///
  /// In en, this message translates to:
  /// **'Start Fresh'**
  String get startFreshBtn;

  /// No description provided for @sameSourceDestError.
  ///
  /// In en, this message translates to:
  /// **'Source and destination teams cannot be the same.'**
  String get sameSourceDestError;

  /// No description provided for @noAthletesToMove.
  ///
  /// In en, this message translates to:
  /// **'No athletes found to move.'**
  String get noAthletesToMove;

  /// No description provided for @teamAlsoDeleted.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" was also deleted.'**
  String teamAlsoDeleted(Object name);

  /// No description provided for @errorMovingAthletes.
  ///
  /// In en, this message translates to:
  /// **'Error moving athletes'**
  String get errorMovingAthletes;

  /// No description provided for @moveType.
  ///
  /// In en, this message translates to:
  /// **'Move Type'**
  String get moveType;

  /// No description provided for @errorDeactivation.
  ///
  /// In en, this message translates to:
  /// **'Error during deactivation'**
  String get errorDeactivation;

  /// No description provided for @errorDeletion.
  ///
  /// In en, this message translates to:
  /// **'Error during deletion'**
  String get errorDeletion;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @timeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Time must be greater than zero'**
  String get timeGreaterThanZero;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @pleaseSelectYear.
  ///
  /// In en, this message translates to:
  /// **'Please select a year'**
  String get pleaseSelectYear;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @errorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithDetails(Object error);

  /// No description provided for @hideSplits.
  ///
  /// In en, this message translates to:
  /// **'Hide splits'**
  String get hideSplits;

  /// No description provided for @showSplits.
  ///
  /// In en, this message translates to:
  /// **'Show splits'**
  String get showSplits;

  /// No description provided for @startLabel.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startLabel;

  /// No description provided for @splitLabel.
  ///
  /// In en, this message translates to:
  /// **'Split:'**
  String get splitLabel;

  /// No description provided for @errorSavingAthlete.
  ///
  /// In en, this message translates to:
  /// **'Error saving athlete: {error}'**
  String errorSavingAthlete(Object error);

  /// No description provided for @errorSavingChrono.
  ///
  /// In en, this message translates to:
  /// **'Error saving chrono: {error}'**
  String errorSavingChrono(Object error);

  /// No description provided for @dummyTeamNoviceA.
  ///
  /// In en, this message translates to:
  /// **'Team A - Novice A'**
  String get dummyTeamNoviceA;

  /// No description provided for @dummyTeamMasters.
  ///
  /// In en, this message translates to:
  /// **'Team A - Masters'**
  String get dummyTeamMasters;

  /// No description provided for @dummyTeamB.
  ///
  /// In en, this message translates to:
  /// **'Team B'**
  String get dummyTeamB;

  /// No description provided for @dummyTeamJuniors.
  ///
  /// In en, this message translates to:
  /// **'Team C - Juniors'**
  String get dummyTeamJuniors;

  /// Generic name for a sample athlete, e.g. 'Athlete A1N'
  ///
  /// In en, this message translates to:
  /// **'Athlete {code}'**
  String dummyAthleteName(Object code);

  /// Suffix appended to sample athlete codes of the Novice category
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get dummyCodeNovice;

  /// Suffix appended to sample athlete codes of the Masters category
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get dummyCodeMasters;

  /// Suffix appended to sample athlete codes of the Juniors category
  ///
  /// In en, this message translates to:
  /// **'J'**
  String get dummyCodeJuniors;

  /// No description provided for @dummyAthleteNote.
  ///
  /// In en, this message translates to:
  /// **'Sample athlete created for demo purposes.'**
  String get dummyAthleteNote;

  /// No description provided for @dummyNoteRace.
  ///
  /// In en, this message translates to:
  /// **'Sample race'**
  String get dummyNoteRace;

  /// No description provided for @dummyNoteTraining.
  ///
  /// In en, this message translates to:
  /// **'Sample training'**
  String get dummyNoteTraining;

  /// No description provided for @dummyNotePersonalBest.
  ///
  /// In en, this message translates to:
  /// **'Personal best!'**
  String get dummyNotePersonalBest;

  /// No description provided for @customizeExperience.
  ///
  /// In en, this message translates to:
  /// **'Customize experience'**
  String get customizeExperience;

  /// No description provided for @customizeExperienceDescription.
  ///
  /// In en, this message translates to:
  /// **'Theme, colors, font, text size and language'**
  String get customizeExperienceDescription;

  /// No description provided for @colorTheme.
  ///
  /// In en, this message translates to:
  /// **'Color theme'**
  String get colorTheme;

  /// No description provided for @colorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// No description provided for @colorTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get colorTeal;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorCoral.
  ///
  /// In en, this message translates to:
  /// **'Coral'**
  String get colorCoral;

  /// No description provided for @colorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorPurple;

  /// No description provided for @colorPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorPink;

  /// No description provided for @font.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get font;

  /// No description provided for @fontStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get fontStandard;

  /// No description provided for @fontOpenDyslexic.
  ///
  /// In en, this message translates to:
  /// **'OpenDyslexic'**
  String get fontOpenDyslexic;

  /// No description provided for @fontOpenDyslexicDescription.
  ///
  /// In en, this message translates to:
  /// **'Font designed to improve readability for people with dyslexia'**
  String get fontOpenDyslexicDescription;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// No description provided for @textSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get textSizeSmall;

  /// No description provided for @textSizeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get textSizeNormal;

  /// No description provided for @textSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get textSizeLarge;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @previewPangram.
  ///
  /// In en, this message translates to:
  /// **'The quick brown fox jumps over the lazy dog. 0123456789'**
  String get previewPangram;

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get hapticFeedback;

  /// No description provided for @hapticFeedbackDescription.
  ///
  /// In en, this message translates to:
  /// **'Vibrate on start, stop and lap'**
  String get hapticFeedbackDescription;

  /// No description provided for @soundFeedback.
  ///
  /// In en, this message translates to:
  /// **'Sound feedback'**
  String get soundFeedback;

  /// No description provided for @soundFeedbackDescription.
  ///
  /// In en, this message translates to:
  /// **'Play a click sound on start, stop and lap'**
  String get soundFeedbackDescription;

  /// No description provided for @keepScreenOn.
  ///
  /// In en, this message translates to:
  /// **'Keep screen on'**
  String get keepScreenOn;

  /// No description provided for @keepScreenOnDescription.
  ///
  /// In en, this message translates to:
  /// **'Prevent the screen from turning off while on the stopwatch'**
  String get keepScreenOnDescription;

  /// No description provided for @timePrecision.
  ///
  /// In en, this message translates to:
  /// **'Time precision'**
  String get timePrecision;

  /// No description provided for @precisionHundredths.
  ///
  /// In en, this message translates to:
  /// **'Hundredths (0.01 s)'**
  String get precisionHundredths;

  /// No description provided for @precisionTenths.
  ///
  /// In en, this message translates to:
  /// **'Tenths (0.1 s)'**
  String get precisionTenths;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get appVersion;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get openSourceLicenses;

  /// No description provided for @timePrecisionDescription.
  ///
  /// In en, this message translates to:
  /// **'Display only: times are always saved to the hundredth.'**
  String get timePrecisionDescription;

  /// No description provided for @backupSection.
  ///
  /// In en, this message translates to:
  /// **'Backup and restore'**
  String get backupSection;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get exportBackup;

  /// No description provided for @exportBackupDescription.
  ///
  /// In en, this message translates to:
  /// **'Save teams, athletes and times to a JSON file, in the folder you choose.'**
  String get exportBackupDescription;

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get importBackup;

  /// No description provided for @importBackupDescription.
  ///
  /// In en, this message translates to:
  /// **'Replaces all current data with the contents of the file you pick.'**
  String get importBackupDescription;

  /// No description provided for @backupCancelled.
  ///
  /// In en, this message translates to:
  /// **'Operation cancelled.'**
  String get backupCancelled;

  /// No description provided for @backupExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup saved — teams: {teams}, athletes: {athletes}, times: {chronos}.'**
  String backupExportSuccess(int teams, int athletes, int chronos);

  /// No description provided for @backupExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed.'**
  String get backupExportFailed;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace all data?'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The file contains — teams: {teams}, athletes: {athletes}, times: {chronos}.\n\nEverything currently on this device will be deleted and replaced. This cannot be undone.'**
  String restoreConfirmBody(int teams, int athletes, int chronos);

  /// No description provided for @restoreConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get restoreConfirmAction;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restore complete — teams: {teams}, athletes: {athletes}, times: {chronos}.'**
  String restoreSuccess(int teams, int athletes, int chronos);

  /// No description provided for @restoreSkipped.
  ///
  /// In en, this message translates to:
  /// **'Orphaned records skipped: {count}.'**
  String restoreSkipped(int count);

  /// No description provided for @restoreFailedInvalidFile.
  ///
  /// In en, this message translates to:
  /// **'This file is not a SplashUp backup.'**
  String get restoreFailedInvalidFile;

  /// No description provided for @restoreFailedNewerVersion.
  ///
  /// In en, this message translates to:
  /// **'This backup was created by a newer version of SplashUp. Update the app and try again.'**
  String get restoreFailedNewerVersion;

  /// No description provided for @restoreFailedCorrupted.
  ///
  /// In en, this message translates to:
  /// **'The backup file is damaged or incomplete.'**
  String get restoreFailedCorrupted;

  /// No description provided for @restoreFailedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Restore failed. Your existing data has not been changed.'**
  String get restoreFailedGeneric;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdates;

  /// No description provided for @checkForUpdatesDescription.
  ///
  /// In en, this message translates to:
  /// **'Ask GitHub whether a newer version has been released.'**
  String get checkForUpdatesDescription;

  /// No description provided for @autoCheckUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check on startup'**
  String get autoCheckUpdates;

  /// No description provided for @autoCheckUpdatesDescription.
  ///
  /// In en, this message translates to:
  /// **'Once a day at most. This is the only internet connection SplashUp makes: it reads the public release on GitHub and sends no data.'**
  String get autoCheckUpdatesDescription;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'SplashUp {version} is available'**
  String updateAvailableTitle(String version);

  /// No description provided for @updateReleaseNotes.
  ///
  /// In en, this message translates to:
  /// **'What’s new'**
  String get updateReleaseNotes;

  /// No description provided for @updateWhereToDownload.
  ///
  /// In en, this message translates to:
  /// **'Download the update from GitHub and install it the same way you installed the app.'**
  String get updateWhereToDownload;

  /// No description provided for @updateDownloadApk.
  ///
  /// In en, this message translates to:
  /// **'Download APK'**
  String get updateDownloadApk;

  /// No description provided for @updateOpenPage.
  ///
  /// In en, this message translates to:
  /// **'Open on GitHub'**
  String get updateOpenPage;

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// No description provided for @updateUpToDate.
  ///
  /// In en, this message translates to:
  /// **'You already have the latest version ({version}).'**
  String updateUpToDate(String version);

  /// No description provided for @updateErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Could not reach GitHub. Check your connection and try again.'**
  String get updateErrorNetwork;

  /// No description provided for @updateErrorRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Too many requests to GitHub in a short time. Try again later.'**
  String get updateErrorRateLimit;

  /// No description provided for @updateErrorNoRelease.
  ///
  /// In en, this message translates to:
  /// **'No release has been published on GitHub yet.'**
  String get updateErrorNoRelease;

  /// No description provided for @updateErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Update check failed.'**
  String get updateErrorGeneric;

  /// No description provided for @updateOpenLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link. Go to github.com/mattileap/splashup/releases.'**
  String get updateOpenLinkFailed;

  /// No description provided for @restoreConfirmBodyWithDropped.
  ///
  /// In en, this message translates to:
  /// **'The file contains — teams: {teams}, athletes: {athletes}, times: {chronos}.\n\nCareful: {dropped} records in the file are orphaned (athletes with no team, or times with no athlete) and will NOT be restored.\n\nEverything currently on this device will be deleted and replaced. This cannot be undone.'**
  String restoreConfirmBodyWithDropped(
    int teams,
    int athletes,
    int chronos,
    int dropped,
  );
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
