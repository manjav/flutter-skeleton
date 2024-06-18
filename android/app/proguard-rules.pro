-keepattributes Signature

-keep class sources.** { *; }

##------------------------------ Begin: Gson ------------------------------
## See https://github.com/google/gson/blob/master/examples/android-proguard-example/proguard.cfg

# Gson specific classes
-keep class sun.misc.Unsafe { *; }
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# For using GSON @Expose annotation
-keepattributes *Annotation*

# Prevent R8 from leaving Data object members always null
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}
##------------------------------ End: Gson ------------------------------