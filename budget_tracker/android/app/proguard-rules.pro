# Flutter ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Local Auth Plugin
-keep class androidx.biometric.** { *; }
-keep class androidx.lifecycle.** { *; }

# Keep Image Picker Plugin
-keep class androidx.exifinterface.** { *; }

# Keep shared_preferences
-keep class androidx.preference.** { *; }

# Keep sqflite
-keep class androidx.sqlite.** { *; }

# Keep provider
-keep class androidx.lifecycle.** { *; }

# Don't warn about missing classes
-dontwarn io.flutter.embedding.**

# Optimize code
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-dontpreverify

# Keep application class
-keep public class * extends android.app.Application

# Keep Android support library classes
-keep class androidx.** { *; }
-keep interface androidx.** { *; }

# Remove debug logging
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}