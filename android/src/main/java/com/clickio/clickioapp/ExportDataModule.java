package com.clickio.clickioapp;

import androidx.annotation.NonNull;

import com.clickio.clickioconsentsdk.ExportData;
import com.clickio.clickioconsentsdk.GoogleConsentStatus; 
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class ExportDataModule extends ReactContextBaseJavaModule {

    private final ExportData exportData;

    public ExportDataModule(ReactApplicationContext reactContext) {
        super(reactContext);
        exportData = new ExportData(reactContext);
    }

    @NonNull
    @Override
    public String getName() {
        return "ExportDataModule";
    }

    @ReactMethod
    public void getGoogleConsentMode(Promise promise) {
        try {
            GoogleConsentStatus consentStatus = exportData.getGoogleConsentMode();

            WritableMap result = Arguments.createMap();
            if (consentStatus != null) {
                result.putBoolean("adStorageGranted", consentStatus.getAdStorageGranted());
                result.putBoolean("analyticsStorageGranted", consentStatus.getAnalyticsStorageGranted());
                result.putBoolean("adUserDataGranted", consentStatus.getAdUserDataGranted());
                result.putBoolean("adPersonalizationGranted", consentStatus.getAdPersonalizationGranted());
            }
            promise.resolve(result);
        } catch (Exception e) {
            promise.reject("EXPORT_DATA_ERROR", e);
        }
    }

    @ReactMethod
    public void getConsentedTCFPurposes(Promise promise) {
        try {
            Set<Integer> purposes = new HashSet<>(exportData.getConsentedTCFPurposes()); 
            WritableArray result = Arguments.createArray();
            for (Integer purpose : purposes) {
                result.pushInt(purpose);
            }
            promise.resolve(result);
        } catch (Exception e) {
            promise.reject("EXPORT_DATA_ERROR", e);
        }
    }

    @ReactMethod
    public void getConsentedTCFVendors(Promise promise) {
        try {
            Set<Integer> vendors = new HashSet<>(exportData.getConsentedTCFVendors());
            WritableArray result = Arguments.createArray();
            for (Integer vendor : vendors) {
                result.pushInt(vendor);
            }
            promise.resolve(result);
        } catch (Exception e) {
            promise.reject("EXPORT_DATA_ERROR", e);
        }
    }

    @ReactMethod
    public void getAllExportData(Promise promise) {
        try {
            WritableMap result = Arguments.createMap();

            GoogleConsentStatus consentStatus = exportData.getGoogleConsentMode();
            if (consentStatus != null) {
                result.putBoolean("adStorageGranted", consentStatus.getAdStorageGranted());
                result.putBoolean("analyticsStorageGranted", consentStatus.getAnalyticsStorageGranted());
                result.putBoolean("adUserDataGranted", consentStatus.getAdUserDataGranted());
                result.putBoolean("adPersonalizationGranted", consentStatus.getAdPersonalizationGranted());
            }

            WritableArray purposesArray = createWritableArray(exportData.getConsentedTCFPurposes());
            result.putArray("consentedTCFPurposes", purposesArray);

            WritableArray vendorsArray = createWritableArray(exportData.getConsentedTCFVendors());
            result.putArray("consentedTCFVendors", vendorsArray);

            WritableArray googleVendorsArray = createWritableArray(exportData.getConsentedGoogleVendors());
            result.putArray("consentedGoogleVendors", googleVendorsArray);

            WritableArray otherVendorsArray = createWritableArray(exportData.getConsentedOtherVendors());
            result.putArray("consentedOtherVendors", otherVendorsArray);

            WritableArray TCFLiVendorsArray = createWritableArray(exportData.getConsentedTCFLiVendors());
            result.putArray("consentedTCFLiVendors", TCFLiVendorsArray);

            WritableArray nonTcfPurposesArray = createWritableArray(exportData.getConsentedNonTcfPurposes());
            result.putArray("nonTcfPurposes", nonTcfPurposesArray);

            WritableArray googleConsentArray = createWritableArray(exportData.getConsentedGoogleVendors());
            result.putArray("googleConsentMode", googleConsentArray);

            WritableArray otherLiVendorsArray = createWritableArray(exportData.getConsentedOtherLiVendors());
            result.putArray("consentedOtherLiVendors", otherLiVendorsArray);

            // Strings
            result.putString("acString", exportData.getACString() != null ? exportData.getACString() : "");
            result.putString("gPPString", exportData.getGPPString() != null ? exportData.getGPPString() : "");

            promise.resolve(result);
        } catch (Exception e) {
            promise.reject("EXPORT_DATA_ERROR", e);
        }
    }

  
    private WritableArray createWritableArray(List<Integer> list) {
        WritableArray array = Arguments.createArray();
        if (list != null) { 
            for (Integer value : list) {
                array.pushInt(value);
            }
        }
        return array;
    }


}
