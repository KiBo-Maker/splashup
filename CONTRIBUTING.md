# Contribuire a SplashUp

🇮🇹 Italiano | [🇬🇧 English](CONTRIBUTING.en.md)

Grazie per l'interesse a contribuire! SplashUp è open source (licenza MIT, vedi [LICENSE](LICENSE)) e i contributi sono benvenuti: fix, nuove funzionalità, supporto a nuove piattaforme, traduzioni, ecc.

## Requisiti

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (vedi `environment.sdk` in `pubspec.yaml` per la versione minima).
- Un editor con supporto Dart/Flutter (VS Code o Android Studio consigliati).

## Come iniziare

1. Fai un fork del repository e clonalo in locale.
2. Installa le dipendenze:
   ```bash
   flutter pub get
   ```
3. Avvia l'app su un emulatore/dispositivo (o su desktop/web):
   ```bash
   flutter run
   ```
4. Crea un branch per la tua modifica:
   ```bash
   git checkout -b nome-branch-descrittivo
   ```

## Prima di aprire una Pull Request

- Esegui l'analisi statica e i test:
  ```bash
  flutter analyze
  flutter test
  ```
- Se aggiungi testi visibili nell'app, aggiorna le chiavi di localizzazione in `lib/l10n/app_it.arb` e `lib/l10n/app_en.arb` e **rigenera** i file di traduzione:
  ```bash
  flutter gen-l10n
  ```
  I file generati (`lib/l10n/app_localizations*.dart`) sono versionati e la CI controlla che siano allineati agli `.arb`.
- Se la modifica è visibile all'utente, aggiorna il [CHANGELOG.md](CHANGELOG.md).
- Descrivi nella PR cosa cambia e perché; per bug fix, indica come riprodurre il problema originale.


## Pubblicare una release

Solo per chi ha i permessi di scrittura sul repository.

1. Aggiorna `version:` in `pubspec.yaml` (es. `2.5.0+31`) e aggiungi la voce in [CHANGELOG.md](CHANGELOG.md).
2. Committa, poi crea e pubblica il tag:
   ```bash
   git tag v2.5.0
   git push origin v2.5.0
   ```
3. Il workflow [`release.yml`](.github/workflows/release.yml) compila l'APK firmato e crea una GitHub Release **in bozza** con l'APK allegato.
4. Scrivi le note di rilascio nella bozza e premi "Publish release".

Il tag deve corrispondere alla `version:` di `pubspec.yaml` (senza il build number): il workflow si ferma se divergono, perché il controllo aggiornamenti in-app confronta proprio quei due numeri.

Finché la release resta in bozza, l'app non la annuncia: `GET /releases/latest` ignora bozze e prerelease.

### Secrets richiesti

Per firmare l'APK, il repository deve avere questi secrets (Settings → Secrets and variables → Actions):

| Secret | Contenuto |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | il file `.jks` codificato in base64 |
| `ANDROID_KEYSTORE_PASSWORD` | `storePassword` |
| `ANDROID_KEY_PASSWORD` | `keyPassword` |
| `ANDROID_KEY_ALIAS` | `keyAlias` (es. `upload`) |

Per generare il primo:

```powershell
# Windows PowerShell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\percorso\splashupkey.jks")) | Set-Clipboard
```

```bash
# Linux/macOS
base64 -w0 splashupkey.jks
```

Per compilare in locale un APK firmato, copia `android/key.properties.example` in `android/key.properties` e riempilo: il file è escluso da git.

## Segnalare bug o proporre idee

Apri una [Issue](../../issues) descrivendo il problema (con passi per riprodurlo, se possibile) o l'idea proposta. Per nuove piattaforme o feature importanti, è utile aprire prima una Issue di discussione prima di iniziare a scrivere codice, per allinearsi sull'approccio.

## Nota sul brand

Il codice è MIT, ma il nome "SplashUp" e l'icona dell'app sono riservati alla versione ufficiale (vedi [LICENSE](LICENSE)). Se pubblichi un fork su uno store, usa un nome e un'icona diversi.
