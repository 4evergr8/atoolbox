plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "a.forevergreat.atoolbox"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "a.forevergreat.atoolbox"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    splits {
        abi {
            isEnable = true
            reset()
            //include("arm64-v8a")
            include("armeabi-v7a", "arm64-v8a", "x86", "x86_64")
            isUniversalApk = false
        }
    }
    buildTypes {
        getByName("release") {
            // 使用 debug 签名配置（用于调试发布）
            signingConfig = signingConfigs.getByName("debug")

            // 禁用 R8 混淆和资源压缩
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
