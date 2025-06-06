plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.reader().use { reader ->
        localProperties.load(reader)
    }
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
var configured = false
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    configured = true
}

project.ext {
    set("APP_ID", keystoreProperties.getProperty("appId", "dev.helpis.google_maps_clustering_example"))
    set("KEYSTORE_STORE_FILE", rootProject.file(keystoreProperties.getProperty("storeFile", "debug.keystore")))
    set("KEYSTORE_STORE_PASSWORD", keystoreProperties.getProperty("storePassword", "android"))
    set("KEYSTORE_KEY_ALIAS", keystoreProperties.getProperty("keyAlias", "androiddebugkey"))
    set("KEYSTORE_KEY_PASSWORD", keystoreProperties.getProperty("keyPassword", "android"))
    set("VERSION_CODE", if (configured) keystoreProperties.getProperty("versionCode").toInt() else 1)
    set("VERSION_NAME", if (configured) keystoreProperties.getProperty("versionName") else "0.0.1")
}

android {
    namespace = project.ext.get("APP_ID") as String
    buildToolsVersion = "35.0.0"
    compileSdk = 35
    ndkVersion = "28.0.12674087"

    signingConfigs {
        getByName("debug") {
            storeFile = project.ext.get("KEYSTORE_STORE_FILE") as File
            storePassword = project.ext.get("KEYSTORE_STORE_PASSWORD") as String
            keyAlias = project.ext.get("KEYSTORE_KEY_ALIAS") as String
            keyPassword = project.ext.get("KEYSTORE_KEY_PASSWORD") as String
        }
        create("profile") {
            storeFile = project.ext.get("KEYSTORE_STORE_FILE") as File
            storePassword = project.ext.get("KEYSTORE_STORE_PASSWORD") as String
            keyAlias = project.ext.get("KEYSTORE_KEY_ALIAS") as String
            keyPassword = project.ext.get("KEYSTORE_KEY_PASSWORD") as String
        }
        create("release") {
            storeFile = project.ext.get("KEYSTORE_STORE_FILE") as File
            storePassword = project.ext.get("KEYSTORE_STORE_PASSWORD") as String
            keyAlias = project.ext.get("KEYSTORE_KEY_ALIAS") as String
            keyPassword = project.ext.get("KEYSTORE_KEY_PASSWORD") as String
        }
    }

    buildTypes {
        getByName("debug") {
            applicationIdSuffix = ".debug"
            isDebuggable = true
            signingConfig = signingConfigs.getByName("debug")
        }
        getByName("profile") {
            signingConfig = signingConfigs.getByName("profile")
        }
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), file("../proguard-rules.pro"))
            setProguardFiles(listOf(getDefaultProguardFile("proguard-android.txt"), file("../proguard-rules.pro"), file("../multidex-config.pro")))
        }
    }

    splits {
        abi {
            isEnable = gradle.startParameter.taskNames.any { it.contains("Release") }
            reset()
            include("x86_64", "armeabi-v7a", "arm64-v8a")
            isUniversalApk = true
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = "21"
        freeCompilerArgs = listOf("-Xjvm-default=all-compatibility")
    }

    kotlin {
        jvmToolchain(21)
    }

    java {
        toolchain {
            languageVersion.set(JavaLanguageVersion.of(21))
        }
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/java")
            kotlin.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        applicationId = project.ext.get("APP_ID") as String
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = project.ext.get("VERSION_CODE") as Int
        versionName = project.ext.get("VERSION_NAME") as String
        multiDexEnabled = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
