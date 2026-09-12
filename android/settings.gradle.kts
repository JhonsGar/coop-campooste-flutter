pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        val localPropertiesFile = file("local.properties")

        if (localPropertiesFile.exists()) {
            localPropertiesFile.inputStream().use {
                properties.load(it)
            }
        }

        val path = properties.getProperty("flutter.sdk")
        requireNotNull(path) {
            "flutter.sdk no está configurado en local.properties"
        }
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
    id("com.android.application") version "8.11.1" apply false // ✅ AGP compatible
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false // ✅ Kotlin compatible
}

include(":app")