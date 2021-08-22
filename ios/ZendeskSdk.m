#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ZendeskSdk, NSObject)

RCT_EXTERN_METHOD(initialize:(NSDictionary *)options
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(setAnonymous:(NSString *)name
                  email:(NSString *)email
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(setIdentity:(NSDictionary *)user
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(showNativeHelpCenter:(nullable NSDictionary *)options)

RCT_EXTERN_METHOD(createTicket:(NSString *)title
                  body:(NSString *)body
                  tags:(NSArray *)tags
                  customFields:(NSArray *)customFields
                  )

@end

