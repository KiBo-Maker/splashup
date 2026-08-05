import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // RIMOSSO id("kotlin-android"): con AGP 9 il Kotlin è integrato
    // (Built-in Kotlin) — vedi guida Flutter "migrate-to-built-in-kotlin".
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Firma di release: le credenziali stanno in android/key.properties
// (NON versionato, vedi android/.gitignore). Template: key.properties.example
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.splashup.splashup"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.splashup.splashup"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Config di release creata solo se key.properties esiste
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Firma con il keystore di release se configurato (key.properties
            // presente), altrimenti fallback alle chiavi di debug così
            // `flutter run --release` funziona anche senza keystore.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

// Blocco Built-in Kotlin (sostituisce il vecchio kotlinOptions dentro
// android{}): il jvmTarget deve coincidere con compileOptions (Java 11).
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11
    }
}

flutter {
    source = "../.."
}

// Nome APK personalizzato, es. "splashup-v2.1.0.apk".
// MIGRATO alla nuova Variant API (androidComponents): la vecchia
// android.applicationVariants è stata rimossa in AGP 9.
androidComponents {
    onVariants { variant ->
        variant.outputs.forEach { output ->
            if (output is com.android.build.api.variant.impl.VariantOutputImpl) {
                output.outputFileName.set(
                    output.versionName.map { v -> "splashup-v${v ?: "dev"}.apk" }
                )
            }
        }
    }
}