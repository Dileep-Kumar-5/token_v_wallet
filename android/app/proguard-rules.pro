## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

## Supabase
-keep class io.supabase.** { *; }
-keepattributes *Annotation*

## freeRASP
-keep class com.aheaditec.talsec.** { *; }

## Gson
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

## OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

## Native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

## Keep model classes (replace with your actual package name)
-keep class com.token_v_wallet.app.models.** { *; }

## Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

## Prevent obfuscation of crash reporting
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

## Ignore Play Core classes (only needed for AAB/App Bundle, not APK)
-dontwarn com.google.android.play.core.**
-dontnote com.google.android.play.core.**

## Ignore Stripe push provisioning classes (optional feature)
-dontwarn com.stripe.android.pushProvisioning.**
-dontnote com.stripe.android.pushProvisioning.**

## Keep Flutter Play Store classes but don't fail if dependencies missing
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }