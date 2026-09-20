import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Читаем key.properties из корня android/. Файл содержит пароли
// для release-подписи и НЕ должен попадать в git.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.pykaxaoca.pocketbotanist"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Core library desugaring — требуется плагином flutter_local_notifications
        // для использования java.time и других API на старых версиях Android.
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.pykaxaoca.pocketbotanist"
        // minSdk 24 = Android 7.0. RuStore работает на Android 8.0+,
        // но 24 покрывает это с запасом и отсекает устаревшие устройства.
        minSdk = 24
        // targetSdk 34 = Android 14. Актуальный target для RuStore.
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            // Release-сборка подписывается ключом из android/key.properties.
            signingConfig = signingConfigs.getByName("release")
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

dependencies {
    implementation("androidx.concurrent:concurrent-futures:1.2.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}