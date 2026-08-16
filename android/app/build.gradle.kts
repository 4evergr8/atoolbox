plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    signingConfigs {
        create("release") {
            storeFile = file("D:\\Project\\SDK\\sign\\my-release-key.jks")
            storePassword = "aaa111111@"
            keyAlias = "my-key-alias"
            keyPassword = "aaa111111@"
        }
    }
    namespace = "app.flutter.picorigin"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "app.flutter.picorigin"
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false // 禁用代码混淆
            isShrinkResources = false // 禁用资源压缩
        }
    }
}

dependencies {
    // 添加中文和日语语言包依赖
    implementation("com.google.mlkit:text-recognition-chinese:16.0.0")
    implementation("com.google.mlkit:text-recognition-japanese:16.0.0")
}

flutter {
    source = "../.."
}
