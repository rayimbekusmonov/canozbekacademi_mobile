plugins {
    id("com.android.application")
    // Firebase uchun
    id("com.google.gms.google-services")
    id("kotlin-android")
    // Flutter plugin har doim oxirida bo'lishi kerak
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Sening loyihang paketi
    namespace = "com.rayimbek.canozbekacademi"

    // Android 14 (API 34) darajasida build qilamiz
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Desugaring - eski Androidlarda yangi Java funksiyalarini ishlatish uchun (Notification uchun shart)
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.rayimbek.canozbekacademi"

        // Android 5.0 dan past telefonlarni qo'llab-quvvatlamaymiz (Notification barqarorligi uchun)
        minSdk = flutter.minSdkVersion

        // Target API 34 - bu ruxsatnomalar chiqishini ta'minlaydi
        targetSdk = 36

        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Metodlar ko'payib ketsa xato bermasligi uchun
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Hozircha debug kaliti bilan imzolaymiz
            signingConfig = signingConfigs.getByName("debug")

            // Release versiyada kodni siqish (ixtiyoriy)
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Notification-lar va Timezone to'g'ri ishlashi uchun desugaring kutubxonasi
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
