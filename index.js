const { NativeModules, Platform, DeviceEventEmitter } = require("react-native");

const { ClickioSDKModule, ClickioConsentManagerModule } = NativeModules;

const isIOS = Platform.OS === "ios";
const NativeModule = isIOS ? ClickioConsentManagerModule : ClickioSDKModule;

// ---------- Consent Dialog ----------
/**
 * Opens the consent dialog and resolves the promise based on the user's response.
 * Supports passing options like mode, width, height, gravity, backgroundColor.
 */
const openConsentDialog = (options = {}) => {
  return new Promise((resolve, reject) => {
    try {
      if (isIOS) {
        NativeModule.webviewLoadUrl(options, (response) => {
          if (response.status === "shown" || response.status === "success") {
            resolve(response);
          } else {
            reject(new Error(`Consent Dialog failed: ${response.status}`));
          }
        });
      } else {
        NativeModule.webviewLoadUrl(options).then(resolve).catch(reject);
      }
    } catch (error) {
      console.error("NativeModule.openConsentDialog::", error);
      reject(error);
    }
  });
};

// ---------- SDK Initialization ----------
/**
 * Initializes the SDK and triggers the consent dialog.
 * Supports both iOS and Android with platform-specific handling.
 * @param {string} siteId
 * @param {string} language
 * @param {string} mode
 */
const initializeSDK = async (siteId, language = "en", mode = "default") => {
  if (isIOS) {
    try {
      await NativeModule.requestATTPermission();
      const result = await NativeModule.initializeConsentSDK({
        siteId,
        appLanguage: language,
      });
      console.log("iOS SDK init result:", result);
      return openConsentDialog({ mode });
    } catch (error) {
      console.error("initializeSDK (iOS) error:", error);
      throw error;
    }
  } else {
    return new Promise((resolve, reject) => {
      try {
        NativeModule.initializeSDK(siteId, language);
        NativeModule.onReady(mode, (msg) => resolve(msg));
      } catch (error) {
        reject(new Error("SDK initialization failed on Android."));
      }
    });
  }
};

// ---------- Reset App Data ----------
/**
 * Clears SDK data and re-initializes.
 */
const resetAppData = async (siteId, language) => {
  if (isIOS) {
    await ClickioConsentManagerModule.resetData();
    return initializeSDK(siteId, language);
  } else {
    await NativeModule.resetSDK();
    return initializeSDK(siteId, language);
  }
};

// ---------- Logging (Android only) ----------
const startLoggingLogsFromAndroid = () => {
  if (!isIOS) {
    ClickioSDKModule.startLoggingLogsFromAndroid();
  }
};

const listenToLogs = (callback) => {
  return DeviceEventEmitter.addListener("ClickioLog", callback);
};

// ---------- Consent Flags ----------
const getGoogleConsentFlags = () => NativeModule.getGoogleConsentFlags();

// ---------- Export Data ----------
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
    return NativeModules.ExportDataModule.getAllExportData();
  }
};

// ---------- SDK Availability Checks (Android only) ----------
const isFirebaseAvailable = () =>
  isIOS ? Promise.resolve(false) : ClickioSDKModule.isFirebaseAvailable();
const isAdjustAvailable = () =>
  isIOS ? Promise.resolve(false) : ClickioSDKModule.isAdjustAvailable();
const isAirbridgeAvailable = () =>
  isIOS ? Promise.resolve(false) : ClickioSDKModule.isAirbridgeAvailable();
const isAppsFlyerAvailable = () =>
  isIOS ? Promise.resolve(false) : ClickioSDKModule.isAppsFlyerAvailable();

// ---------- Manual Consent Dispatch (Android only) ----------
const sendManualConsentToFirebase = (consent) =>
  !isIOS && ClickioSDKModule.sendManualConsentToFirebase(consent);
const sendManualConsentToAdjust = (consent) =>
  !isIOS && ClickioSDKModule.sendManualConsentToAdjust(consent);
const sendManualConsentToAirbridge = (consent) =>
  !isIOS && ClickioSDKModule.sendManualConsentToAirbridge(consent);
const sendManualConsentToAppsFlyer = (consent) =>
  !isIOS && ClickioSDKModule.sendManualConsentToAppsFlyer(consent);

// ---------- Sync Android Consent ----------
const syncClickioConsentWithFirebase = () =>
  !isIOS
    ? ClickioSDKModule.syncClickioConsentWithFirebase()
    : Promise.resolve("Not applicable on iOS");
const getGoogleConsentFlagsAndroid = () => NativeModule.getGoogleConsentFlags();

// ---------- Reset App Data ----------
/**
 * Clears SDK data and re-initializes.
 */

// ---------- Exported Methods ----------
module.exports = {
  initializeSDK,
  openConsentDialog,
  resetAppData,
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
};
