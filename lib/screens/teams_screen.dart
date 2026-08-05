import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Serve per accedere al Repository
import '../l10n/app_localizations.dart';
import '../models/team_model.dart';
import 'athletes_screen.dart';
import 'settings_screen.dart';

// NUOVO IMPORT
import '../repositories/database_repository.dart';
import '../services/update/update_flow.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  // Stream creato una sola volta: crearlo dentro build() causava una nuova
  // sottoscrizione a ogni rebuild della schermata.
  late final Stream<List<Team>> _teamsStream;

  @override
  void initState() {
    super.initState();
    _teamsStream = context.read<DatabaseRepository>().getTeamsStream();

    // Check aggiornamenti all'avvio, agganciato qui e non alla schermata di
    // benvenuto: questa e' la prima schermata che resta montata, quindi il
    // dialog non rischia di comparire mentre l'utente sta ancora navigando
    // via. Il servizio decide da se' se il controllo va fatto (max 1 al
    // giorno, e solo se l'utente non l'ha disattivato) e in caso di errore
    // di rete non mostra nulla.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      UpdateFlow.maybeCheckOnStartup(context);
    });
  }

  /// Displays a dialog to edit the name and default pool length of an existing team.
  Future<void> _editTeam(Team team) async {
    final l10n = AppLocalizations.of(context)!;
    final teamNameController = TextEditingController(text: team.name);
    // Use a local variable to manage the state of the dropdown inside the dialog.
    int poolLength = team.poolLength;

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use a StatefulBuilder to allow the dialog's content to update state independently.
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.editTeam),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: teamNameController,
                    autofocus: true,
                    decoration: InputDecoration(labelText: l10n.teamName),
                  ),
                  // Dropdown to select the team's default pool length.
                  DropdownButtonFormField<int>(
                    initialValue: poolLength,
                    decoration: InputDecoration(labelText: l10n.poolLength),
                    items: [25, 50]
                        .map((len) => DropdownMenuItem(value: len, child: Text('$len m')))
                        .toList(),
                    onChanged: (value) => setState(() => poolLength = value!),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(l10n.cancel),
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                ),
                ElevatedButton(
                  child: Text(l10n.save),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true);
                  },
                ),
              ],
            );
          },
        );
      },
    );

    // .trim() per evitare nomi squadra fatti di soli spazi;
    // dispose del controller (prima non veniva mai rilasciato).
    final newTeamName = teamNameController.text.trim();
    teamNameController.dispose();

    if (result == true && mounted && newTeamName.isNotEmpty) {
      // NUOVO: Usiamo il repository locale invece di Firestore
      final db = context.read<DatabaseRepository>();
      final updatedTeam = Team(
        id: team.id,
        name: newTeamName,
        poolLength: poolLength,
      );
      await db.updateTeam(updatedTeam);
    }
  }

  /// Displays a dialog to add a new team to the user's collection.
  Future<void> _addTeam() async {
    final l10n = AppLocalizations.of(context)!;
    final teamNameController = TextEditingController();
    int poolLength = 25; // Default to 25m for new teams.

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.addNewTeam),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: teamNameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: l10n.teamName,
                      hintText: l10n.teamNameHint,
                    ),
                  ),
                  DropdownButtonFormField<int>(
                    initialValue: poolLength,
                    decoration: InputDecoration(labelText: l10n.poolLength),
                    items: [25, 50]
                        .map((len) => DropdownMenuItem(value: len, child: Text('$len m')))
                        .toList(),
                    onChanged: (value) => setState(() => poolLength = value!),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(l10n.cancel),
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(Theme.of(context).colorScheme.primary),
                    foregroundColor:
                        WidgetStateProperty.all(Theme.of(context).colorScheme.onPrimary),
                  ),
                  child: Text(l10n.add),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true);
                  },
                ),
              ],
            );
          },
        );
      },
    );

    // .trim() per evitare nomi squadra fatti di soli spazi;
    // dispose del controller (prima non veniva mai rilasciato).
    final newTeamName = teamNameController.text.trim();
    teamNameController.dispose();

    if (result == true && mounted && newTeamName.isNotEmpty) {
      // NUOVO: Salvataggio locale tramite repository
      final db = context.read<DatabaseRepository>();
      // Creiamo un team con ID vuoto, il repository ne genererà uno (UUID)
      final newTeam = Team(
        id: '',
        name: newTeamName,
        poolLength: poolLength,
      );
      await db.addTeam(newTeam);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myTeams),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      // NUOVO: StreamBuilder tipizzato su List<Team> invece di QuerySnapshot
      body: StreamBuilder<List<Team>>(
        stream: _teamsStream, // Stream dal database locale (creato in initState)
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(l10n.errorWithDetails(snapshot.error.toString())));
          }
          
          final teams = snapshot.data ?? [];

          if (teams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.group_add_outlined,
                      size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noTeamsYet,
                    style: const TextStyle(fontSize: 22, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noTeamsHint,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              
              return Card(
                elevation: 2.0,
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 16.0),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(Icons.group_work, color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  title: Text(
                    team.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  // Display the team's default pool length on the card.
                  subtitle: Text('${l10n.pool} ${team.poolLength}m '),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        tooltip: l10n.editTeam,
                        onPressed: () => _editTeam(team),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AthletesScreen(team: team),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTeam(), // Rimosso parametro teamsCollection non più necessario
        tooltip: l10n.addTeam,
        child: const Icon(Icons.add),
      ),
    );
  }
}