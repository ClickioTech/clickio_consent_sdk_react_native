
#import <React/RCTLog.h>
#import <React/RCTBridgeModule.h>




@interface RCT_EXTERN_MODULE(ClickioConsentManagerModule, NSObject)

RCT_EXTERN_METHOD(testConnection:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(initializeConsentSDK:(NSDictionary *)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(openDialog:(RCTResponseSenderBlock)callback)
RCT_EXTERN_METHOD(getConsentData:(RCTResponseSenderBlock)callback)
RCT_EXTERN_METHOD(requestATTPermission:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getGoogleConsentFlags:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(sendManualConsentToFirebase)
RCT_EXTERN_METHOD(checkAndSetConsentFlags)
RCT_EXTERN_METHOD(isFirebaseAvailable:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(isAdjustAvailable:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(isAirbridgeAvailable:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(isAppsFlyerAvailable:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(setClickioLogging:(BOOL)isEnabled)

@end
