# Preserve Google Tink / Crypto annotations
-keep class com.google.errorprone.annotations.** { *; }
-keep class javax.annotation.** { *; }
-keep class javax.annotation.concurrent.** { *; }

# Keep Crypto / Tink internals
-keep class com.google.crypto.tink.** { *; }

# If you're using flutter_secure_storage or firebase:
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
