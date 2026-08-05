import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';
import 'screens/welcome_screen.dart';
import 'services/locale_service.dart';
import 'services/stopwatch_settings_service.dart';
import 'services/theme_service.dart';
import 'services/update/update_settings_service.dart';

// NUOVI IMPORT PER IL DATABASE
import 'repositories/database_repository.dart';
import 'repositories/sembast_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  final prefs = await SharedPreferences.getInstance();

  // Inizializziamo il Database Locale (Sembast)
  final databaseRepository = SembastRepository();
  await databaseRepository.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeService(prefs)),
        ChangeNotifierProvider(create: (context) => LocaleService(prefs)),
        ChangeNotifierProvider(
            create: (context) => StopwatchSettingsService(prefs)),
        ChangeNotifierProvider(
            create: (context) => UpdateSettingsService(prefs)),
        // NUOVO: Iniettiamo il Repository del Database in tutta l'app
        Provider<DatabaseRepository>.value(value: databaseRepository),
      ],
      child: const SplashUpApp(),
    ),
  );
}

class SplashUpApp extends StatelessWidget {
  const SplashUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeService, LocaleService>(
      builder: (context, themeService, localeService, child) {
        return MaterialApp(
          title: 'SplashUp',
          // Manteniamo la tua configurazione di localizzazione originale
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // Lingua scelta dall'utente; null = segui il sistema
          locale: localeService.locale,

          // Temi costruiti dal ThemeService (colore, font, chiaro/scuro)
          theme: themeService.buildLightTheme(),
          darkTheme: themeService.buildDarkTheme(),
          themeMode: themeService.themeMode,

          // Applichiamo la dimensione testo scelta sopra la scala di sistema
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(
                  mediaQuery.textScaler.scale(1.0) *
                      themeService.textSize.factor,
                ),
              ),
              child: child!,
            );
          },

          // Home: Parte dalla nuova schermata di benvenuto con l'icona SVG
          home: const WelcomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
