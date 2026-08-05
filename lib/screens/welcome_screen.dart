import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../repositories/database_repository.dart';
import '../utils/dummy_data_generator.dart'; // Importiamo il generatore
import 'teams_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;

  Future<void> _handleDiveIn(BuildContext context, AppLocalizations l10n) async {
    final db = context.read<DatabaseRepository>();
    
    setState(() => _isLoading = true);
    
    // Controlliamo se il database è vuoto leggendo la lista delle squadre
    final teams = await db.getTeamsStream().first;

    // Il widget potrebbe essere stato smontato durante l'await:
    // chiamare setState in quel caso causerebbe un crash.
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (teams.isEmpty && context.mounted) {
      // Il database è vuoto: Mostriamo il dialog
      final wantTestData = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.loadTestDataTitle),
          content: Text(l10n.loadTestDataMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.startFreshBtn),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.loadTestDataBtn),
            ),
          ],
        ),
      );

      // Se l'utente ha scelto di caricare i dati
      if (wantTestData == true && context.mounted) {
        setState(() => _isLoading = true);
        await DummyDataGenerator.populateDatabase(db, l10n);
        // Guardia anche qui: populateDatabase è un await e il check
        // a riga sopra non copre questo punto.
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    }

    // A prescindere dalla scelta, andiamo alla schermata principale
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const TeamsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/SplashUp_Icon.svg',
                height: 120, // Leggermente più grande per la copertina
                width: 120,
                colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
              ),
              const SizedBox(height: 32),
              
              // TITOLO APP
              Text(
                'SplashUp',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 8), // Piccolo spazio tra titolo e slogan
              // SLOGAN
              Text(
                l10n.appSlogan, // "Dive in. Stand out. SplashUp"
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade600, // Un po' più chiaro del titolo
                  fontStyle: FontStyle.italic, // Opzionale: corsivo per lo slogan
                ),
              ),
              const SizedBox(height: 24), // Spazio maggiore prima della descrizione
              // DESCRIZIONE / SOTTOTITOLO (LOCALIZZATO)
              Text(
                l10n.welcomeSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              
              const SizedBox(height: 64),

              // TASTO "TUFFATI!"
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  // Disabilita il tasto se sta caricando
                  onPressed: _isLoading ? null : () => _handleDiveIn(context, l10n),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        l10n.diveInButton,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}