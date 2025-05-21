# React Native Clickio SDK

A React Native wrapper for the [Clickio Consent SDK](https://www.clickio.com/), enabling GDPR/CCPA-compliant user consent management with native integrations for iOS and Android.  
This SDK supports integrations with third-party tools like Firebase, Adjust, Airbridge, and AppsFlyer.

---

## ⚠️ Requirements

Before integrating the ClickioConsentSdk (hereinafter referred to as the **Clickio SDK**), ensure that your React Native application meets the following requirements:

### Android

- **Minimum SDK Version**: 21 (Android 5.0)
- **Target/Compile SDK Version**: The minimum required for Google Play compliance.
- **Permissions**: Add the following to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

---

### iOS

- **Minimum iOS Version**: 15.0+
- **Swift Version**: 5.0+
- **Permissions**: Add the following to your `Info.plist`:

```xml
<key>NSUserTrackingUsageDescription</key>
<string>Add your data usage description</string>
```

---

## 📦 Installation

```bash
npm install react-native-clickio-sdk
```

For iOS, install pods:

```bash
npx pod-install
```

---

## ⚙️ Setup

### iOS

1. Make sure your project uses at least `use_frameworks!` in your `ios/Podfile`.
2. In your iOS native app, ensure `Info.plist` includes appropriate permissions if your implementation uses tracking (e.g., `NSUserTrackingUsageDescription`).
3. Your iOS project must be configured for Swift (if it’s not, add a dummy `.swift` file to prompt Xcode to create a Bridging Header).

#### CocoaPods

Ensure your podspec includes necessary dependencies:

```ruby
s.dependency 'ClickioConsentSDK'
```

> Note: The WebView-based dialog shown by the SDK requires a valid `rootViewController`.

---

### Android

# Linking (React Native 0.59 and below)

If you are using React Native 0.59 or below, you need to link the native modules manually:

In your `android/build.gradle`:

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

In your `android/app/build.gradle`:

```gradle
dependencies {
    implementation 'com.clickio.consent:sdk:1.0.0'
}
```

---

### Initialization

```ts
import {
  initializeSDK,
  openDialog,
  setClickioLogging,
} from "react-native-clickio-sdk";

const initConsent = async () => {
  const result = await initializeSDK("your-site-id", "en");
  console.log(result); // ClickioConsentSDK initialized
};
```

### Show Consent Dialog

```ts
const showDialog = async () => {
  try {
    const result = await openDialog();
    console.log(result); // { status: 'success', message: 'Consent Dialog Opened' }
  } catch (err) {
    console.error(err);
  }
};
```

### Enable Logging

```ts
await setClickioLogging(true); // Enables verbose mode in native SDK logs
```

---

## Utility Methods

These native methods are available to get consent data and check vendor status:

| Method                             | Description                                       |
| ---------------------------------- | ------------------------------------------------- |
| `getConsentScope()`                | Returns current consent scope                     |
| `getConsentState()`                | Returns consent state                             |
| `getConsentForPurpose(id: number)` | Returns consent for a specific purpose ID         |
| `getConsentForVendor(id: number)`  | Returns consent for a specific vendor ID          |
| `getTCString()`                    | Returns IAB TCF string                            |
| `getACString()`                    | Returns AC string                                 |
| `getGPPString()`                   | Returns GPP string                                |
| `getGoogleConsentMode()`           | Returns Google Consent Mode                       |
| `getConsentedTCFVendors()`         | Returns all consented TCF vendors                 |
| `getConsentedTCFLiVendors()`       | Returns all consented legitimate interest vendors |
| `getConsentedTCFPurposes()`        | Returns all consented purposes                    |
| `getConsentedOtherVendors()`       | Returns non-TCF vendors                           |
| `isFirebaseAnalyticsAvailable()`   | Returns whether Firebase is linked in the app     |
| `isAdjustAvailable()`              | Checks for Adjust SDK                             |
| `isAirbridgeAvailable()`           | Checks for Airbridge SDK                          |
| `isAppsFlyerAvailable()`           | Checks for AppsFlyer SDK                          |

## 🤝 Integration with Third-Party Libraries for Google Consent Mode

### :rocket: Adjust, Airbridge, AppsFlyer

If your project includes any of these SDKs **(Adjust, Airbridge, AppsFlyer)**, `ClickioConsentSDK` will automatically send Google Consent flags to them if _Clickio Google Consent Mode_ integration is **enabled**.

#### :warning: Important:

- Interactions with `ClickioConsentSDK` should be performed **after initializing the third-party SDKs** since `ClickioConsentSDK` only transmits consent flags.
- **Ensure** that you have completed the required tracking setup for Adjust, Airbridge, or AppsFlyer before integrating `ClickioConsentSDK`. This includes proper initialization and configuration of the SDK according to the vendor’s documentation.
- If you're using **AppsFlyer** and need to support GDPR compliance via TCF, make sure to enable TCF data collection before SDK initialization: `enableTCFDataCollection(true)`. This allows AppsFlyer to automatically gather consent values (like `tcString`) from the CMP.
  After successfully transmitting the flags, a log message will be displayed **(if logging is enabled)** to confirm the successful transmission. In case of an error, an error message will appear in the logs.
  > :bulb: **Note:** Keep your **Adjust**, **Airbridge**, or **AppsFlyer SDK** updated to ensure compatibility

```ts
import {
  isFirebaseAvailable,
  isAdjustAvailable,
  isAirbridgeAvailable,
  isAppsFlyerAvailable,
} from "react-native-clickio-sdk";

const checkSDKs = async () => {
  const firebase = await isFirebaseAvailable();
  const adjust = await isAdjustAvailable();
  const airbridge = await isAirbridgeAvailable();
  const appsFlyer = await isAppsFlyerAvailable();

  console.log({ firebase, adjust, airbridge, appsFlyer });
};
```

The SDK will automatically set the correct consent mode values for each integration if available, ensuring compliance without additional configuration.

### Firebase Analytics Integration

If the **Firebase Analytics SDK** is present in the project, the Clickio SDK will automatically send Google Consent flags to Firebase **if Google Consent Mode integration is enabled**.

- Consent flags are sent:

  - Immediately after the user gives or updates consent (when `onConsentUpdated` is triggered).
  - During initialization if the consent has already been accepted.

- After successfully transmitting the flags:
  - A log message will appear (if logging is enabled).
  - If an error occurs, an error message will appear in the logs.

> 🔄 Make sure you're using a compatible version of Firebase Analytics. You may need to update to the latest version if issues arise.
