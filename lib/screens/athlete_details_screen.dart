import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/athlete_model.dart';
import '../models/chrono_model.dart';
import '../models/team_model.dart';
import '../repositories/database_repository.dart';
import 'add_edit_chrono_screen.dart';
import 'edit_athlete_screen.dart';
import 'stopwatch_screen.dart';
import 'splits_chart_screen.dart'; // NEW

/// Menu options for the athlete details screen
enum AthleteMenuAction {
  notes,
  personalBests,
  stopwatch,
  splitAnalysis,  // NEW
  // statistics,  // FUTURE
}

/// Displays the details for a single athlete, including their personal information
/// and a filterable list of all their recorded times (chronos).
class AthleteDetailsScreen extends StatefulWidget {
  final Team team;
  final Athlete athlete;

  const AthleteDetailsScreen({
    super.key,
    required this.team,
    required this.athlete,
  });

  @override
  State<AthleteDetailsScreen> createState() => _AthleteDetailsScreenState();
}

class _AthleteDetailsScreenState extends State<AthleteDetailsScreen> {
  // State variables to hold the current filter selections.
  int? _selectedDistance;
  String? _selectedStyle;
  String? _selectedType;
  
  // Track which chrono cards are expanded for splits
  final Set<String> _expandedChronos = {};

  // Stream creati una sola volta: crearli dentro build() causava una nuova
  // sottoscrizione a ogni rebuild (es. a ogni cambio di filtro).
  // Due stream separati perché gli stream async* di Sembast sono
  // single-subscription e qui servono due StreamBuilder (menu AppBar + lista).
  late final Stream<List<Chrono>> _menuChronosStream;
  late final Stream<List<Chrono>> _listChronosStream;

  @override
  void initState() {
    super.initState();
    final db = context.read<DatabaseRepository>();
    _menuChronosStream = db.getChronosStream(widget.athlete.id);
    _listChronosStream = db.getChronosStream(widget.athlete.id);
  }

  /// Returns the duration of a chrono for comparison purposes.
  /// Usa finalTimeMs (il dato canonico) e ripiega sul parse della stringa
  /// solo per record legacy; i tempi non validi o a 0 vengono ordinati
  /// in fondo così non diventano mai personal best.
  Duration _chronoDuration(Chrono chrono) {
    final ms = chrono.finalTimeMs ?? Chrono.parseTimeToMilliseconds(chrono.finalTime);
    if (ms == null || ms <= 0) return const Duration(days: 999); // Sort last
    return Duration(milliseconds: ms);
  }

  /// Calculates and displays the athlete's personal best times in a dialog.
  void _showPersonalBestsDialog(BuildContext context, List<Chrono> allChronos, AppLocalizations l10n) {
    // A map to hold the best time for each unique event (e.g., "50-Freestyle").
    final personalBests = <String, Chrono>{};

    final styleDisplayNames = {
      'Freestyle': l10n.freestyle,
      'Butterfly': l10n.butterfly,
      'Backstroke': l10n.backstroke,
      'Breaststroke': l10n.breaststroke,
      'IM': l10n.im,
    };

    // Iterate through all chronos to find the best time for each event.
    for (final chrono in allChronos) {
      final key = '${chrono.distance}-${chrono.style}';
      final existingBest = personalBests[key];

      if (existingBest == null || _chronoDuration(chrono) < _chronoDuration(existingBest)) {
        personalBests[key] = chrono;
      }
    }

    // Sort the best times first by distance, then by style.
    final sortedBests = personalBests.values.toList()
      ..sort((a, b) {
        int distanceCompare = a.distance.compareTo(b.distance);
        if (distanceCompare != 0) return distanceCompare;
        return a.style.compareTo(b.style);
      });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.personalBestsTitle),
          content: SizedBox(
            width: double.maxFinite,
            child: personalBests.isEmpty
                ? Text(l10n.noBestsYet)
                : ListView(
                    shrinkWrap: true,
                    children: sortedBests.map((chrono) {
                      final translatedStyle = styleDisplayNames[chrono.style] ?? chrono.style;
                      return ListTile(
                        title: Text('${chrono.distance}m $translatedStyle'),
                        subtitle: Text(chrono.displayTime),
                      );
                    }).toList(),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  /// Displays the athlete's notes in a simple dialog.
  void _showAthleteNotesDialog(BuildContext context, Athlete athlete, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.notesTitle),
          content: Text(
            athlete.notes.isNotEmpty ? athlete.notes : l10n.noNotesForAthlete,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // Function to show notes for a specific chrono.
  void _showChronoNotesDialog(BuildContext context, Chrono chrono, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.chronoNotesTitle),
          content: Text(chrono.notes), // No need for an empty check, this is only shown if notes exist.
          actions: <Widget>[
            TextButton(
              child: Text(l10n.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  /// Handles menu action selection
  Future<void> _handleMenuAction(
    AthleteMenuAction action,
    List<Chrono> allChronos, // Pass to the already loaded list
    AppLocalizations l10n,
  ) async {
    switch (action) {
      case AthleteMenuAction.notes:
        _showAthleteNotesDialog(context, widget.athlete, l10n);
        break;
        
      case AthleteMenuAction.personalBests:
        _showPersonalBestsDialog(context, allChronos, l10n);
        break;
        
      case AthleteMenuAction.stopwatch:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StopwatchScreen(
              team: widget.team,
              athlete: widget.athlete,
            ),
          ),
        );
        break;
        
      case AthleteMenuAction.splitAnalysis:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SplitsChartScreen(
              team: widget.team,
              athlete: widget.athlete,
              allChronos: allChronos,
            ),
          ),
        );
        break;
    }
  }

  /// Handles the multi-step process for deleting an athlete.
  Future<void> _showDeleteAthleteDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);
    final db = context.read<DatabaseRepository>();

    // Show a dialog with options: Cancel, Deactivate, or Delete.
    final result = await showDialog<String>(
      context: context,
      // I pulsanti chiudono il dialog col SUO context (dialogContext):
      // usando il navigator della schermata, un doppio tap veloce poteva
      // chiudere anche la schermata sottostante.
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteAthlete),
        content: Text(l10n.deleteAthleteWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop('cancel'),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop('deactivate'),
            child: Text(l10n.deactivate),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop('delete'),
            child: Text(l10n.deleteAnyway),
          ),
        ],
      ),
    );

    if (!mounted || result == 'cancel' || result == null) return;

    if (result == 'deactivate') {
      // Creiamo un nuovo oggetto atleta con isActive = false
      final updatedAthlete = Athlete(
        id: widget.athlete.id,
        name: widget.athlete.name,
        birthYear: widget.athlete.birthYear,
        gender: widget.athlete.gender,
        preferredStyles: widget.athlete.preferredStyles,
        isActive: false, // Disattiva
        notes: widget.athlete.notes,
      );
      await db.updateAthlete(widget.team.id, updatedAthlete);
      if(mounted) navigator.pop(); 
    } else if (result == 'delete') {
      await db.deleteAthlete(widget.athlete.id);
      if(mounted) navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final db = Provider.of<DatabaseRepository>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        // AppBar title is now simpler.
        title: Text(l10n.athleteDetails),
        actions: [
          // Per popolare il menu Action, abbiamo bisogno dei dati.
          // Usiamo uno StreamBuilder per avere i dati aggiornati anche per il menu.
          StreamBuilder<List<Chrono>>(
            stream: _menuChronosStream,
            builder: (context, snapshot) {
              final allChronos = snapshot.data ?? [];
              
              return PopupMenuButton<AthleteMenuAction>(
                icon: const Icon(Icons.more_vert),
                onSelected: (action) => _handleMenuAction(action, allChronos, l10n),
                itemBuilder: (context) {
                  final iconColor = Theme.of(context).iconTheme.color;
                  return [
                    PopupMenuItem(
                      value: AthleteMenuAction.notes,
                      child: Row(
                        children: [
                          Icon(Icons.note_alt_outlined, color: iconColor),
                          const SizedBox(width: 12),
                          Text(l10n.notes),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: AthleteMenuAction.personalBests,
                      child: Row(
                        children: [
                          Icon(Icons.emoji_events_outlined, color: iconColor),
                          const SizedBox(width: 12),
                          Text(l10n.personalBestsTitle),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: AthleteMenuAction.stopwatch,
                      child: Row(
                        children: [
                          Icon(Icons.timer_outlined, color: iconColor),
                          const SizedBox(width: 12),
                          Text(l10n.stopwatch),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: AthleteMenuAction.splitAnalysis,
                      child: Row(
                        children: [
                          Icon(Icons.show_chart, color: iconColor),
                          const SizedBox(width: 12),
                          Text(l10n.splitAnalysis),
                        ],
                      ),
                    ),
                  ];
                },
              );
                // FUTURE: Uncomment when statistics screen is ready
                // PopupMenuItem(
                //   value: AthleteMenuAction.statistics,
                //   child: Row(
                //     children: [
                //       Icon(Icons.analytics_outlined, color: iconColor),
                //       const SizedBox(width: 12),
                //       Text(l10n.statistics),
                //     ],
                //   ),
                // ),
            },
          ),
          // Keep Edit and Delete as separate buttons (important actions)
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: l10n.editAthlete,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditAthleteScreen(
                    team: widget.team,
                    athlete: widget.athlete,
                  ),
                ),
              );
            },
          ),
          // Button to delete the athlete.
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: l10n.deleteAthlete,
            onPressed: _showDeleteAthleteDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header card with athlete's personal information.
          _buildAthleteHeader(context, widget.athlete, widget.team, l10n),
          // The rest of the screen is a scrollable list of chronos.
          Expanded(
            child: StreamBuilder<List<Chrono>>(
              stream: _listChronosStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final chronosList = snapshot.data ?? [];
                
                if (chronosList.isEmpty) {
                  return Center(child: Text(l10n.noTimesRecorded));
                }

                // Apply the filters selected by the user.
                final filteredChronos = chronosList.where((chrono) {
                  final distanceMatch = _selectedDistance == null || chrono.distance == _selectedDistance;
                  final styleMatch = _selectedStyle == null || chrono.style == _selectedStyle;
                  final typeMatch = _selectedType == null || chrono.type == _selectedType;
                  return distanceMatch && styleMatch && typeMatch;
                }).toList();

                // The main content area, including the filter bar and the list.
                return Column(
                  children: [
                    _buildFilterBar(context, chronosList, l10n),
                    if (filteredChronos.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(l10n.noResultsFound),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredChronos.length,
                          itemBuilder: (context, index) {
                            // Qui usiamo 'db' (il repository) invece di 'chronoCollection'
                            return _buildChronoCard(context, filteredChronos[index], db, l10n);
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  AddEditChronoScreen(
                    teamId: widget.team.id,
                    athleteId: widget.athlete.id,
                    team: widget.team, // Serve per la pool length di default
                  )));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Builds the non-scrolling header card with athlete details.
  Widget _buildAthleteHeader(BuildContext context, Athlete athlete, Team team, AppLocalizations l10n) {
    final int age = DateTime.now().year - athlete.birthYear;
    final Map<String, String> styleDisplayNames = {
      'Freestyle': l10n.freestyle,
      'Butterfly': l10n.butterfly,
      'Backstroke': l10n.backstroke,
      'Breaststroke': l10n.breaststroke,
      'IM': l10n.im,
    };

    final Map<String, String> genderDisplayNames = {
      'Male': l10n.male,
      'Female': l10n.female,
    };
    final translatedGender = genderDisplayNames[athlete.gender] ?? athlete.gender;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(athlete.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(team.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('${l10n.age}: $age • $translatedGender'),
            const SizedBox(height: 8),
            Text(l10n.favoriteStyles, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8.0,
              children: athlete.preferredStyles
                  .map((styleKey) => Chip(label: Text(styleDisplayNames[styleKey] ?? styleKey)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the filter bar with dropdowns for distance, style, and type.
  Widget _buildFilterBar(BuildContext context, List<Chrono> allChronos, AppLocalizations l10n) {
    final uniqueDistances = allChronos.map((c) => c.distance).toSet().toList()..sort();
    final uniqueStyles = allChronos.map((c) => c.style).toSet().toList()..sort();
    final uniqueTypes = allChronos.map((c) => c.type).toSet().toList()..sort();

    final Map<String, String> styleDisplayNames = {
      'Freestyle': l10n.freestyle,
      'Butterfly': l10n.butterfly,
      'Backstroke': l10n.backstroke,
      'Breaststroke': l10n.breaststroke,
      'IM': l10n.im,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _selectedDistance,
                  hint: Text(l10n.allDistances),
                  onChanged: (value) => setState(() => _selectedDistance = value),
                  items: [
                    DropdownMenuItem<int>(value: null, child: Text(l10n.allDistances)),
                    ...uniqueDistances.map((d) => DropdownMenuItem(value: d, child: Text("$d m"))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedStyle,
                  hint: Text(l10n.allStyles),
                  onChanged: (value) => setState(() => _selectedStyle = value),
                  items: [
                    DropdownMenuItem<String>(value: null, child: Text(l10n.allStyles)),
                    ...uniqueStyles.map((s) => DropdownMenuItem(value: s, child: Text(styleDisplayNames[s] ?? s))),
                  ],
                ),
              ),
            ],
          ),
          DropdownButton<String>(
            isExpanded: true,
            value: _selectedType,
            hint: Text(l10n.allTypes),
            onChanged: (value) => setState(() => _selectedType = value),
            items: [
              DropdownMenuItem<String>(value: null, child: Text(l10n.allTypes)),
              ...uniqueTypes.map((t) => DropdownMenuItem(value: t, child: Text(t == 'Race' ? l10n.race : l10n.training))),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a single card for a chrono entry in the list.
  Widget _buildChronoCard(BuildContext context, Chrono chrono, DatabaseRepository db, AppLocalizations l10n) {
    final Map<String, String> typeDisplayNames = {
      'Training': l10n.training,
      'Race': l10n.race,
    };
    
    final Map<String, String> styleDisplayNames = {
      'Freestyle': l10n.freestyle,
      'Butterfly': l10n.butterfly,
      'Backstroke': l10n.backstroke,
      'Breaststroke': l10n.breaststroke,
      'IM': l10n.im,
    };

    // Check if this card is expanded
    final isExpanded = _expandedChronos.contains(chrono.id);
    final validSplits = chrono.splits.where((s) => s.time != null && s.time! > 0).toList();
    final hasSplits = validSplits.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Text(chrono.distance.toString()),
            ),
            title: Text('${styleDisplayNames[chrono.style] ?? chrono.style} - ${chrono.displayTime}'),
            subtitle: Text(
              '${DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(chrono.date)} • ${typeDisplayNames[chrono.type] ?? chrono.type}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show expand icon if there are splits
                if (hasSplits)
                  IconButton(
                    icon: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    tooltip: isExpanded ? l10n.hideSplits : l10n.showSplits,
                    onPressed: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedChronos.remove(chrono.id);
                        } else {
                          _expandedChronos.add(chrono.id);
                        }
                      });
                    },
                  ),
                // Conditionally show the notes button.
                if (chrono.notes.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.note_alt_outlined, color: Colors.grey),
                    tooltip: l10n.notes,
                    onPressed: () => _showChronoNotesDialog(context, chrono, l10n),
                  ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  tooltip: l10n.editChrono,
                  onPressed: () {
                     Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AddEditChronoScreen(
                            teamId: widget.team.id,
                            athleteId: widget.athlete.id,
                            team: widget.team,
                            existingChrono: chrono,
                        )));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  tooltip: l10n.deleteChronoTitle,
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.deleteChronoTitle),
                        content: Text(l10n.deleteConfirmation),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
                          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.delete)),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await db.deleteChrono(widget.athlete.id, chrono.id);
                    }
                  },
                ),
              ],
            ),
          ),
          // Expandable splits section
          if (isExpanded && hasSplits)
            _buildSplitsTable(context, validSplits, l10n),
        ],
      ),
    );
  }

  Widget _buildSplitsTable(BuildContext context, List<ChronoSplit> splits, AppLocalizations l10n) {
    // Use theme colors for dark mode compatibility
    final theme = Theme.of(context);
    final headerColor = theme.colorScheme.surfaceContainerHighest;
    final borderColor = theme.dividerColor;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(l10n.splits, style: theme.textTheme.titleMedium),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(3),
                },
                border: TableBorder.all(color: borderColor),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: headerColor),
                    children: [
                      _buildTableCell(l10n.distance, isHeader: true, theme: theme),
                      _buildTableCell(l10n.segment, isHeader: true, theme: theme),
                      _buildTableCell(l10n.cumulative, isHeader: true, theme: theme),
                    ],
                  ),
                  ...splits.map((split) {
                    return TableRow(
                      children: [
                        _buildTableCell('${split.distance}m', theme: theme),
                        _buildTableCell(split.formattedSplitTime, theme: theme),
                        _buildTableCell(split.formattedTime, theme: theme),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to build table cells
  Widget _buildTableCell(String text, {bool isHeader = false, required ThemeData theme}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 14 : 12,
          // Use theme text color for proper contrast
          color: theme.textTheme.bodyMedium?.color,
        ),
      ),
    );
  }
}