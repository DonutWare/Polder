import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties().apply {
    val file = file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
val hasReleaseKeystore = file("keystore.jks").exists() && keystoreProperties.containsKey("keyAlias")

android {
    namespace = "org.knaapen.polder"
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "org.knaapen.polder"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "channel"
    productFlavors {
        create("prod") {
            dimension = "channel"
            manifestPlaceholders["appLabel"] = "Polder"
        }
        // Installs next to prod with its own package, data and orange icon (src/dev/res).
        create("dev") {
            dimension = "channel"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            manifestPlaceholders["appLabel"] = "Polder Dev"
        }
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = file("keystore.jks")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(if (hasReleaseKeystore) "release" else "debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
