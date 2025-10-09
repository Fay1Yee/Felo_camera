plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.pet_camera_demo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // 智能相机助手应用ID
        applicationId = "com.smartcamera.pet_assistant"
        // Nothing Phone 3a 优化配置
        minSdk = 24  // Android 7.0+，支持现代相机API
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Nothing Phone 3a 架构优化（主要使用 arm64-v8a）
        ndk {
            abiFilters += listOf("arm64-v8a", "armeabi-v7a")
        }
        
        // 多dex支持，防止方法数超限
        multiDexEnabled = true
        
        // 向量图支持
        vectorDrawables.useSupportLibrary = true
        
        // 性能优化配置
        manifestPlaceholders["enableCrashlytics"] = "false"
    }

    buildTypes {
        release {
            // 发布版本配置
            signingConfig = signingConfigs.getByName("debug")
            
            // 启用代码优化和资源压缩
            isMinifyEnabled = true
            isShrinkResources = true
            
            // ProGuard配置
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // 性能优化
            isDebuggable = false
            isJniDebuggable = false
            isRenderscriptDebuggable = false
            
            // Nothing Phone 3a 特定优化
            manifestPlaceholders["enablePerformanceMode"] = "true"
        }
        debug {
            isDebuggable = true
            applicationIdSuffix = ".debug"
            isMinifyEnabled = false
            isShrinkResources = false
            
            // 开发调试配置
            manifestPlaceholders["enablePerformanceMode"] = "false"
        }
    }
    
    // Nothing Phone 3a 优化配置
    packagingOptions {
        resources {
            excludes += setOf(
                "/META-INF/{AL2.0,LGPL2.1}",
                "/META-INF/DEPENDENCIES",
                "/META-INF/LICENSE",
                "/META-INF/LICENSE.txt",
                "/META-INF/license.txt",
                "/META-INF/NOTICE",
                "/META-INF/NOTICE.txt",
                "/META-INF/notice.txt",
                "/META-INF/ASL2.0",
                "**/*.kotlin_module",
                "**/*.version"
            )
        }
        jniLibs {
            useLegacyPackaging = false
        }
    }
    
    // 编译优化
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // 移除coreLibraryDesugaringEnabled以避免依赖问题
    }
    
    // Lint配置
    lint {
        checkReleaseBuilds = false
        abortOnError = false
    }
}

flutter {
    source = "../.."
}
