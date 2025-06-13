import Foundation
import React
import ClickioConsentSDKManager 
import AppTrackingTransparency
import AdSupport

public enum ConsentStatus {
    case granted
    case denied
}

public enum ConsentType {
    case adStorage
    case adUserData
    case adPersonalization
    case analyticsStorage
}

@objc(ClickioConsentManagerModule)
class ClickioConsentManagerModule: NSObject {
   @objc static func moduleName() -> String {
    return "ClickioConsentManagerModule"
  }
   @objc
  static func requiresMainQueueSetup() -> Bool {
    return true
  }

  @objc
    func requestATTPermission(_ resolve: @escaping RCTPromiseResolveBlock,
                              rejecter reject: @escaping RCTPromiseRejectBlock) {
      if #available(iOS 14, *) {
        ATTrackingManager.requestTrackingAuthorization { status in
          resolve(status.rawValue)
        }
      } else {
        resolve("not_required")
      }
    }

  
   @objc
   func setClickioLogging(_ isEnabled: Bool) {
     let mode: EventLogger.Mode = isEnabled ? .verbose : .disabled
     ClickioConsentSDK.shared.setLogsMode(mode)
   }
  
  
@objc
func initializeConsentSDK(_ options: NSDictionary,
                          resolve: @escaping RCTPromiseResolveBlock,
                          reject: @escaping RCTPromiseRejectBlock) {
  guard let siteId = options["siteId"] as? String else {
    reject("E_MISSING_SITE_ID", "Missing required siteId", nil)
    return
  }

  let appLanguage = options["appLanguage"] as? String ?? "en"
  let config = ClickioConsentSDK.Config(siteId: siteId, appLanguage: appLanguage)

  setClickioLogging(true)

  DispatchQueue.main.async {
    Task {
      await ClickioConsentSDK.shared.initialize(configuration: config)
      resolve("ClickioConsentSDK initialized with siteId: \(siteId) and language: \(appLanguage)")
    }
  }
}


 @objc func openDialog(_ options: NSDictionary,
                          resolve: @escaping RCTPromiseResolveBlock,
                          reject: @escaping RCTPromiseRejectBlock) {
  DispatchQueue.main.async {
    if let rootViewController = UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .flatMap({ $0.windows })
        .first(where: { $0.isKeyWindow })?
        .rootViewController {

 let modeString = (options["mode"] as? String ?? "default").lowercased()
      let dialogMode: ClickioConsentSDK.DialogMode = (modeString == "resurface") ? .resurface : .default
    
      ClickioConsentSDK.shared.openDialog(
        mode:dialogMode,
        in: rootViewController,
        attNeeded: true
      )

          resolve(["status": "success", "message": "Consent Dialog Opened"])

    } else {
            reject("NO_ROOT_VIEW", "Failed to find root view controller", nil)

    }
  }
}


  
  
 
  @MainActor @objc func getConsentData(_ callback: @escaping RCTResponseSenderBlock) {
    let exportDataPrivate = ClickioConsentSDKManager.ExportData()
   let consentData: [String: Any] = [
    "consentScope": ClickioConsentSDK.shared.checkConsentScope()?.description ?? "Unknown",
       "consentState": ClickioConsentSDK.shared.checkConsentState()?.rawValue ?? "Unknown",
     "tcString":  exportDataPrivate.getTCString() ?? "Unknown",
     "acString":exportDataPrivate.getACString() ?? "Unknown",
     "gppString": exportDataPrivate.getGPPString() ?? "Unknown",
    "consentedTCFVendors": exportDataPrivate.getConsentedTCFVendors()?.description ?? "Unknown",
    "consentedTCFLiVendors": exportDataPrivate.getConsentedTCFLiVendors()?.description ?? "Unknown",
    "consentedTCPurposes": exportDataPrivate.getConsentedTCFPurposes()?.description ?? "Unknown",
    "consentedTCFLiPurposes": exportDataPrivate.getConsentedTCFLiPurposes()?.description ?? "Unknown",
    "consentedGoogleVendors": exportDataPrivate.getConsentedGoogleVendors()?.description ?? "Unknown",
    "consentedOtherGoogleVendors": exportDataPrivate.getConsentedOtherVendors()?.description ?? "Unknown",
    "consentedOtherLiVendors": exportDataPrivate.getConsentedOtherLiVendors()?.description ?? "Unknown",
    "consentedNonTcfPurposes": exportDataPrivate.getConsentedNonTcfPurposes()?.description ?? "Unknown",
    "googleConsentStatus": exportDataPrivate.getGoogleConsentMode()?.adPersonalizationGranted ?? false,
    "consentedTCFPurposes":exportDataPrivate.getConsentedTCFPurposes()  ?? "Unknown",
    
    ]
    callback([["status": "success", "data": consentData]])
   }
  
  @objc
  func getGoogleConsentFlags(_ resolve: @escaping RCTPromiseResolveBlock,
                              rejecter reject: @escaping RCTPromiseRejectBlock) {
    let exportData = ExportData()
    if let flags = exportData.getGoogleConsentMode() {
      let result: [String: Bool] = [
        "adStorage": flags.adStorageGranted,
        "analyticsStorage": flags.analyticsStorageGranted,
        "adUserData": flags.adUserDataGranted,
        "adPersonalization": flags.adPersonalizationGranted
      ]
      resolve(result)
    } else {
      resolve(["status": "unavailable"])
    }
  }

  
  @objc func checkAndSetConsentFlags(_ callback: @escaping RCTResponseSenderBlock) {
    let purpose1 = ClickioConsentSDK.shared.checkConsentForPurpose(purposeId: 1) ?? false
         let purpose3 = ClickioConsentSDK.shared.checkConsentForPurpose(purposeId: 3) ?? false
         let purpose4 = ClickioConsentSDK.shared.checkConsentForPurpose(purposeId: 4)
         let purpose7 = ClickioConsentSDK.shared.checkConsentForPurpose(purposeId: 7)
         let purpose8 = ClickioConsentSDK.shared.checkConsentForPurpose(purposeId: 8) ?? false
         let purpose9 = ClickioConsentSDK.shared.checkConsentForPurpose(purposeId: 9)

         let adStorageGranted = purpose1
         let adUserDataGranted = purpose1 && (purpose7 != nil)
         let adPersonalizationGranted = purpose3 && (purpose4 != nil)
         let analyticsStorageGranted = purpose8 && (purpose9 != nil)

         let flags = [
           adStorageGranted,
           adUserDataGranted,
           adPersonalizationGranted,
           analyticsStorageGranted
         ]
    let isGoogleConsentModeEnabled = flags.contains(true)

         if isGoogleConsentModeEnabled {
           print("Google Consent Mode is enabled — no manual flags needed.")
           return
         }

       
         print("Google Consent Mode is disabled — sending flags manually.")
        //   add your Analytics set consent here
    
  }
  
  @objc
   func isFirebaseAvailable(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
     let available = NSClassFromString("FIRApp") != nil
  resolve(available)
   }
   
  @objc
   func isAdjustAvailable(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
     let available = NSClassFromString("com.adjust.sdk.Adjust") != nil
  resolve(available)
  
   }
   
  
  @objc
    func isAirbridgeAvailable(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock){
     let available = NSClassFromString("com.airbridge.sdk.Airbridge") != nil
  resolve(available)

    }
    
  @objc
   func isAppsFlyerAvailable(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
       let available = NSClassFromString("com.appsFlyer.sdk.AppsFlyerLib") != nil
  resolve(available)
     
   }
   @objc
  func getGoogleConsentMode(_ resolve: @escaping RCTPromiseResolveBlock,
                                   rejecter reject: @escaping RCTPromiseRejectBlock) {
  let exportDataPrivate = ClickioConsentSDKManager.ExportData()
  let googleConsent = exportDataPrivate.getGoogleConsentMode()
  let formatted = """
    Analytics Storage: \(googleConsent?.analyticsStorageGranted ?? false),
    Ad Storage: \(googleConsent?.adStorageGranted ?? false),
    Ad User Data: \(googleConsent?.adUserDataGranted ?? false),
    Ad Personalization: \(googleConsent?.adPersonalizationGranted ?? false)
    """
  resolve(formatted)
}

 @objc(resetData:reject:)
func resetData(resolve: @escaping RCTPromiseResolveBlock,
               reject: @escaping RCTPromiseRejectBlock) {
  DispatchQueue.main.async {
    let userDefaults = UserDefaults.standard

    userDefaults.removeObject(forKey: "clickio_consent_status")
    userDefaults.removeObject(forKey: "clickio_user_preference")

    userDefaults.synchronize()
    resolve(["status": "success", "message": "React Native cache cleared"])
  }
}

}
