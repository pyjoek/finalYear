# --- Tink (Google Crypto) ---
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# --- Annotations ---
-keep class javax.annotation.** { *; }
-keep class javax.annotation.concurrent.** { *; }
-keep class com.google.errorprone.annotations.** { *; }
-dontwarn javax.annotation.**
-dontwarn com.google.errorprone.annotations.**

# --- Flutter Plugins (e.g., flutter_secure_storage) ---
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# --- Play Core (SplitCompat and SplitInstall) ---
-keep class com.google.android.play.** { *; }
-dontwarn com.google.android.play.**

# --- Google API Client (if used) ---
-keep class com.google.api.client.** { *; }
-dontwarn com.google.api.client.**
