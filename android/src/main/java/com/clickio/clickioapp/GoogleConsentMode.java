package com.clickio.clickioapp;


import com.clickio.clickioconsentsdk.GoogleConsentStatus;

public class GoogleConsentMode {
    public boolean adStorageGranted;
    public boolean analyticsStorageGranted;
    public boolean adUserDataGranted;
    public boolean adPersonalizationGranted;

    public GoogleConsentMode(boolean adStorage, boolean analyticsStorage, boolean adUserData, boolean adPersonalization) {
        this.adStorageGranted = adStorage;
        this.analyticsStorageGranted = analyticsStorage;
        this.adUserDataGranted = adUserData;
        this.adPersonalizationGranted = adPersonalization;
    }

   
    public static GoogleConsentMode fromGoogleConsentStatus(GoogleConsentStatus status) {
        return new GoogleConsentMode(
            status.getAdStorageGranted(),
            status.getAnalyticsStorageGranted(),
            status.getAdUserDataGranted(),
            status.getAdPersonalizationGranted()
        );
    }
}
