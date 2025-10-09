# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Keep TensorFlow Lite classes
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.lite.**

# Keep Flutter classes
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Keep camera plugin classes
-keep class io.flutter.plugins.camera.** { *; }
-dontwarn io.flutter.plugins.camera.**

# Keep permission handler classes
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# Keep path provider classes
-keep class io.flutter.plugins.pathprovider.** { *; }
-dontwarn io.flutter.plugins.pathprovider.**

# Keep flutter_gemma classes and native methods
-keep class dev.flutter.plugins.flutter_gemma.** { *; }
-dontwarn dev.flutter.plugins.flutter_gemma.**

# Keep Google AI classes for Gemma
-keep class com.google.ai.** { *; }
-dontwarn com.google.ai.**

# Nothing Phone 3a 特定优化
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-dontpreverify

# 保持应用性能管理器类
-keep class com.smartcamera.pet_assistant.** { *; }

# 保持图像处理相关类
-keep class * extends android.graphics.drawable.Drawable { *; }
-keep class * implements java.io.Serializable { *; }

# 保持网络请求相关类
-keepclassmembers class * {
    @retrofit2.http.* <methods>;
}
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**

# 保持JSON序列化类
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# 移动端性能优化
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Keep MediaPipe classes
-keep class com.google.mediapipe.** { *; }
-dontwarn com.google.mediapipe.**

# Keep AutoValue classes (used by flutter_gemma)
-keep class com.google.auto.value.** { *; }
-dontwarn com.google.auto.value.**

# Disable obfuscation for reflection-based code
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}