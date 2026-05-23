# Keep the AdvertisingIdClient class and its static getAdvertisingIdInfo(Context) method.
-keep class com.google.android.gms.ads.identifier.AdvertisingIdClient {
    public static com.google.android.gms.ads.identifier.AdvertisingIdClient$Info getAdvertisingIdInfo(android.content.Context);
}

# Keep the nested Info class and the methods invoked via reflection.
-keep class com.google.android.gms.ads.identifier.AdvertisingIdClient$Info {
    public java.lang.String getId();
    public boolean isLimitAdTrackingEnabled();
}
