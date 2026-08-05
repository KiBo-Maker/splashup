<p align="center">
  <img src="assets/images/SplashUp_Icon.png" alt="SplashUp" width="120">
</p>

<h1 align="center">SplashUp</h1>

<p align="center">
  🇮🇹 Italiano | <a href="README.en.md">🇬🇧 English</a>
</p>

<p align="center">
  L'app semplice per allenatori di nuoto 🏊
</p>

SplashUp è un'app Flutter pensata per allenatori di nuoto che vogliono cronometrare gli atleti in vasca e tenere traccia dei loro progressi, senza bisogno di connessione internet: tutti i dati restano sul dispositivo.

## Funzionalità principali

- **Gestione squadre e atleti**: crea squadre, aggiungi atleti, spostali tra squadre o disattivali/eliminali quando non sono più attivi.
- **Cronometro con parziali**: avvia, ferma e prendi i tempi di passaggio ("giri") con feedback aptico e sonoro configurabili, e schermo sempre acceso durante l'uso.
- **Analisi dei parziali**: grafici dedicati per visualizzare l'andamento dei tempi nel corso di allenamenti e gare.
- **Funziona offline**: i dati sono salvati in un database locale (Sembast), nessuna connessione richiesta.
- **Backup e ripristino**: esporta squadre, atleti e tempi in un file JSON dove vuoi tu (anche in una cartella sincronizzata col tuo cloud) e ripristinali su un altro dispositivo.
- **Personalizzazione ed accessibilità**: tema chiaro/scuro/automatico, 6 palette colore, dimensione del testo regolabile e font OpenDyslexic per utenti con dislessia.
- **Multilingua**: interfaccia disponibile in italiano e inglese, con possibilità di seguire la lingua di sistema o sceglierla manualmente.
- **Controllo aggiornamenti**: l'app ti avvisa quando su GitHub esce una versione nuova. È l'unica connessione a internet che fa, e si può disattivare.

## Screenshot

<p align="center">
  <img src="assets/Screenshots/Squadre.jpg" alt="Squadre" width="18%">
  <img src="assets/Screenshots/Modifica.jpg" alt="Modifica" width="18%">
  <img src="assets/Screenshots/Crono.jpg" alt="Crono" width="18%">
  <img src="assets/Screenshots/Impostazioni.jpg" alt="Impostazioni" width="18%">
  <img src="assets/Screenshots/Personalizzazione.jpg" alt="Personalizzazione" width="18%">
</p>

## Stack tecnologico

- [Flutter](https://flutter.dev) / Dart
- [Provider](https://pub.dev/packages/provider) per la gestione dello stato
- [Sembast](https://pub.dev/packages/sembast) come database locale
- [fl_chart](https://pub.dev/packages/fl_chart) per i grafici
- [shared_preferences](https://pub.dev/packages/shared_preferences) per le impostazioni utente
- [file_selector](https://pub.dev/packages/file_selector) e [flutter_file_dialog](https://pub.dev/packages/flutter_file_dialog) per il backup/ripristino tramite i dialog di sistema
- [http](https://pub.dev/packages/http) per leggere le release pubbliche su GitHub

## Per iniziare

Requisiti: [Flutter SDK](https://docs.flutter.dev/get-started/install) (vedi `environment.sdk` in `pubspec.yaml` per la versione minima).

```bash
flutter pub get
flutter run
```

## Struttura del progetto

```
lib/
├── models/       # Modelli dati (atleta, squadra, cronometraggio)
├── repositories/ # Accesso al database locale
├── screens/      # Schermate dell'app
├── services/     # Servizi (tema, lingua, cronometro, backup, aggiornamenti)
├── l10n/         # File di localizzazione (it/en)
└── utils/        # Utility varie
```

## Build e release

Ogni push su `main` passa da `flutter analyze` e `flutter test` su GitHub Actions.
Al push di un tag `vX.Y.Z` viene compilato un APK di release firmato e allegato a una
GitHub Release in bozza, pronta da rivedere e pubblicare. Vedi
[.github/workflows](.github/workflows) e [CONTRIBUTING.md](CONTRIBUTING.md#pubblicare-una-release).

## Changelog

Le modifiche di ogni versione sono documentate in [CHANGELOG.md](CHANGELOG.md).

## Contribuire

I contributi sono benvenuti! Vedi [CONTRIBUTING.md](CONTRIBUTING.md) per come iniziare.

## Licenza

Distribuito con licenza [MIT](LICENSE). Il nome "SplashUp" e l'icona dell'app sono riservati alla versione ufficiale (vedi la nota nel file [LICENSE](LICENSE)).
