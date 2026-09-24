# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Mobile Scanner
-keep class dev.steenbakker.mobile_scanner.** { *; }

# CameraX
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

# Google ML Kit Barcode Scanning
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_barcode.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.**
# Google Play Core & Deferred Components
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.libraries.barhopper.**

# Flutter Secure Storage & Crypto
-keep class androidx.security.crypto.** { *; }

# Flutter Image Compress
-keep class com.fluttercandies.flutter_image_compress.** { *; }
