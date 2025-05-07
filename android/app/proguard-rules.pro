# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep ML Kit classes
-keep class com.google.mlkit.** { *; }

# Specifically keep the missing class
-keep class com.google.firebase.iid.FirebaseInstanceId { *; }
