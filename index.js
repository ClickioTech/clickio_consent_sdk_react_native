const { NativeModules, Platform, DeviceEventEmitter } = require("react-native");

const { ClickioSDKModule, ClickioConsentManagerModule } = NativeModules;

// Determine the platform (iOS or Android)
const isIOS = Platform.OS === "ios";
const NativeModule = isIOS ? ClickioConsentManagerModule : ClickioSDKModule;

// ---------- Consent Dialog ----------
/**
 * Opens the consent dialog and resolves the promise based on the user's response.
 */
const openConsentDialog = (mode) => {
  return new Promise((resolve, reject) => {
    try {
      if (isIOS) {
        NativeModule.openDialog(mode, (response) => {
          // Handle response based on status
          if (response.status === "success") {
            resolve(response);
          } else {
            reject(new Error(`Consent Dialog failed: ${response.status}`));
          }
        });
      } else {
        NativeModule.openDialog(mode, (response) => {
          // Handle response based on status
          if (response.status === "success") {
            resolve(response);
          } else {
            reject(new Error(`Consent Dialog failed: ${response.status}`));
          }
        });
      }
    } catch (error) {
      console.error("NativeModule.openDialog::", error);
      reject(error); // Reject with the error
    }
  });
};

// ---------- SDK Initialization ----------
/**
 * Initializes the SDK and triggers the consent dialog.
 * Supports both iOS and Android with platform-specific handling.
 * @param {string} siteId - The site ID for SDK initialization.
 * @param {string} language - Language for the SDK (default: "en").
 * @param {string} mode
 */
const initializeSDK = async (siteId, language = "en", mode = "default") => {
  if (isIOS) {
    try {
      // Request ATT permission on iOS
      await NativeModule.requestATTPermission();

      // Initialize SDK with siteId and language
      const result = await NativeModule.initializeConsentSDK({
        siteId,
        language,
      });
      console.log("iOS SDK init result:", result);

      // Show consent dialog after initialization
      return openConsentDialog(mode);
    } catch (error) {
      console.error("initializeSDK (iOS) error:", error);
      throw error;
    }
  } else {
    // Android-specific SDK initialization
    return new Promise((resolve, reject) => {
      try {
        NativeModule.initializeSDK(siteId, language);
        NativeModule.onReady(mode, (msg) => resolve(msg)); // Resolve when ready
      } catch (error) {
        reject(new Error("SDK initialization failed on Android."));
      }
    });
  }
};

// ---------- Android ONready  ----------
/**
 * Initializes the SDK and triggers the consent dialog.
 * Supports both iOS and Android with platform-specific handling.
 * @param {string} dialogMode - The site ID for SDK initialization.
 * @returns {Promise<string>} Resolves when SDK is ready

 */
const onReady = (dialogMode) => {
  NativeModule.onReady(dialogMode, (message) => {
    resolve(message);
  });
};
const resetAppData = async (siteId, language) => {
  if (isIOS) {
    ClickioConsentManagerModule.resetData().then((res) => {
      initializeSDK(siteId, language);
    });
  } else {
    await NativeModule.resetSDK();
  }
};
// ---------- Logging (Android only) ----------
/**
 * Starts logging logs on Android.
 */
const startLoggingLogsFromAndroid = () => {
  if (!isIOS) {
    ClickioSDKModule.startLoggingLogsFromAndroid();
  }
};

// ---------- Log Listener ----------
/**
 * Listens to logs from the native module (Android only).
 * @param {function} callback - Callback to handle incoming logs.
 */
const listenToLogs = (callback) => {
  return DeviceEventEmitter.addListener("ClickioLog", callback);
};

// ---------- Consent Flags ----------
/**
 * Retrieves the Google Consent Flags.
 */
const getGoogleConsentFlags = () => {
  return NativeModule.getGoogleConsentFlags();
};

// ---------- Export Data ----------
/**
 * Retrieves consent data or export data.
 */
const getExportData = () => {
  if (isIOS) {
    return new Promise((resolve, reject) => {
      NativeModule.getConsentData((response) => {
        if (response.status === "success") {
          resolve(response.data);
        } else {
          reject(new Error("Failed to fetch consent data."));
        }
      });
    });
  } else {
    // Android-specific export data
    return NativeModules.ExportDataModule.getAllExportData();
  }
};

// ---------- SDK Availability Checks (Android only) ----------
/**
 * Checks if Firebase is available (Android only).
 */
const isFirebaseAvailable = () => {
  return isIOS
    ? Promise.resolve(false)
    : ClickioSDKModule.isFirebaseAvailable();
};

/**
 * Checks if Adjust is available (Android only).
 */
const isAdjustAvailable = () => {
  return isIOS ? Promise.resolve(false) : ClickioSDKModule.isAdjustAvailable();
};

/**
 * Checks if Airbridge is available (Android only).
 */
const isAirbridgeAvailable = () => {
  return isIOS
    ? Promise.resolve(false)
    : ClickioSDKModule.isAirbridgeAvailable();
};

/**
 * Checks if AppsFlyer is available (Android only).
 */
const isAppsFlyerAvailable = () => {
  return isIOS
    ? Promise.resolve(false)
    : ClickioSDKModule.isAppsFlyerAvailable();
};

// ---------- Manual Consent Dispatch (Android only) ----------
/**
 * Sends manual consent to Firebase (Android only).
 * @param {boolean} consent - Consent status (true/false).
 */
const sendManualConsentToFirebase = (consent) => {
  if (!isIOS) {
    ClickioSDKModule.sendManualConsentToFirebase(consent);
  }
};

/**
 * Sends manual consent to Adjust (Android only).
 * @param {boolean} consent - Consent status (true/false).
 */
const sendManualConsentToAdjust = (consent) => {
  if (!isIOS) {
    ClickioSDKModule.sendManualConsentToAdjust(consent);
  }
};

/**
 * Sends manual consent to Airbridge (Android only).
 * @param {boolean} consent - Consent status (true/false).
 */
const sendManualConsentToAirbridge = (consent) => {
  if (!isIOS) {
    ClickioSDKModule.sendManualConsentToAirbridge(consent);
  }
};

/**
 * Sends manual consent to AppsFlyer (Android only).
 * @param {boolean} consent - Consent status (true/false).
 */
const sendManualConsentToAppsFlyer = (consent) => {
  if (!isIOS) {
    ClickioSDKModule.sendManualConsentToAppsFlyer(consent);
  }
};

/**
 * Syncs Clickio consent with Firebase (Android only).
 */
export const syncClickioConsentWithFirebase = () => {
  if (!isIOS) {
    return ClickioSDKModule.syncClickioConsentWithFirebase();
  }
  return Promise.resolve("Not applicable on iOS");
};

/**
 * Retrieves Google consent flags specifically for Android.
 */
export const getGoogleConsentFlagsAndroid = () => {
  return NativeModule.getGoogleConsentFlags();
};

// ---------- Exported Methods ----------
module.exports = {
  initializeSDK,
  openConsentDialog,
  startLoggingLogsFromAndroid,
  listenToLogs,
  getGoogleConsentFlags,
  getExportData,
  isFirebaseAvailable,
  isAdjustAvailable,
  isAirbridgeAvailable,
  isAppsFlyerAvailable,
  sendManualConsentToFirebase,
  sendManualConsentToAdjust,
  sendManualConsentToAirbridge,
  sendManualConsentToAppsFlyer,
  syncClickioConsentWithFirebase,
  getGoogleConsentFlagsAndroid,
  resetAppData,
  onReady,
};
