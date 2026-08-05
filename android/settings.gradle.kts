pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // AGP 9.0.1 (stessa versione del template di Flutter 3.44): librerie
    // native allineate a 16 KB e Kotlin integrato (Built-in Kotlin).
    // Richiede Gradle >= 9.1 (wrapper aggiornato) e JDK 17 per il build.
    id("com.android.application") version "9.0.1" apply false
    // RIMOSSO org.jetbrains.kotlin.android: da AGP 9 il Kotlin è integrato
    // nell'Android Gradle Plugin (migrazione "Built-in Kotlin" richiesta
    // dal warning di Flutter).
}

include(":app")
