import Foundation
import UIKit
import SupportSDK
import ZendeskCoreSDK
import SupportProvidersSDK
import CommonUISDK

@objc(ZendeskSdk)
class ZendeskSdk: NSObject {
    
    enum ZendeskSdkError: Error {
        case UnableToSetIdentity(String)
    }

    
    @objc(initialize:withResolver:withRejecter:)
    func initialize(options: NSDictionary, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        
        guard let configOptions = options as? [String: Any] else {
            return
        }
        
        if((configOptions["appId"]) == nil || (configOptions["clientId"]) == nil  || (configOptions["zendeskUrl"]) == nil ){
            
            reject("100", "Zendesk initialization failed - missing arguements", nil)
            
        }
        
        Zendesk.initialize(appId: configOptions["appId"] as! String, clientId: configOptions["clientId"] as! String, zendeskUrl: configOptions["zendeskUrl"] as! String)
        
        Support.initialize(withZendesk: Zendesk.instance)
        
        if let device = options["user"] as? [String: Any]{
            guard let identifier = device["userId"] as? String,
                  let deviceLocale = device["locale"] as? String else{
                reject("100", "Wrong user parameters. Expected userId and locale instead", nil)
                return
            }
            
            registerDevice(identifier: identifier, locale: deviceLocale)

        }
        
        resolve("Zendesk SDK initiated")
    
    }
    
    @objc(setAnonymous:email:withResolver:withRejecter:)
    func setAnonymous(name: String,email:String ,resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        let identity = Identity.createAnonymous(name: name, email: email)
        
        Zendesk.instance?.setIdentity(identity)
        print(identity)
        resolve(identity)
    }
    
    
    @objc(setIdentity:withResolver:withRejecter:)
    func setIdentity(user: NSDictionary, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        
        var identity: ZendeskCoreSDK.Identity? = nil
        
        if((user["userId"]) != nil){
            
            identity = Identity.createJwt(token: user["userId"] as! String)
            
        }else if((user["email"] != nil) && (user["name"] != nil)){
            
            identity = Identity.createAnonymous(name: user["name"] as! String, email: user["email"] as! String)

        }else{
            
            reject("error","invalid arguments for setIdentity", nil)
        }
        
        Zendesk.instance?.setIdentity(identity!)
        
        resolve("Identity set")
    
    }
    
    @objc(showNativeHelpCenter:)
    func showNativeHelpCenter(options: NSDictionary? ){
        
        Support.instance?.helpCenterLocaleOverride = "en-us"
        
        if let locale = options?["locale"] as? String {
            Support.instance?.helpCenterLocaleOverride = locale
        }
        
        let hcConfig = HelpCenterUiConfiguration()
        
        if let filterBy = options?["groupIds"] as? [NSNumber],
           let filterByType = options?["groupType"] as? String {
            
            if( filterBy.count > 0 && !filterByType.isEmpty){
                hcConfig.groupType = filterByType == "category" ? .category : .section
                hcConfig.groupIds = filterBy
            }
        }
    
        if let labels = options?["lables"] as? [String]{
            hcConfig.labels = labels
        }
        
//        if let ticketDisabled = options?["hideContactSupport"] as? Bool{
//            hcConfig.hideContactSupport = ticketDisabled
//        }
        
        
        DispatchQueue.main.async {
            var zendeskHelpCenter = HelpCenterUi.buildHelpCenterOverviewUi(withConfigs: [hcConfig])
            
            if let articleId = options?["articleId"] as? String{
                zendeskHelpCenter = HelpCenterUi.buildHelpCenterArticleUi(withArticleId: articleId, andConfigs: [])
            }
            
            let navigationController = UINavigationController.init(rootViewController: zendeskHelpCenter)
            
            navigationController.modalPresentationStyle = .fullScreen
        
            UIApplication.shared.keyWindow?.rootViewController?.present(navigationController, animated: true, completion: nil)
        }
                
    }
    
    @objc(createTicket:body:tags:customFields:)
    func createTicket(title: String, body: String, tags: [String], customFields: [[String:Any]]){
        let request = ZDKCreateRequest()
        request.subject = title
        request.requestDescription = body
        request.tags = tags
        
        var ticketCustomFields = [CustomField]();
        if(customFields.count > 0){
 
            customFields.forEach { customField in
                ticketCustomFields.append(CustomField(fieldId: customField["fieldId"] as! Int64, value: customField["value"] as! String))
            }
            
            request.customFields = ticketCustomFields
        }

        
        ZDKRequestProvider().createRequest(request, withCallback: {(result, error) in
            if ((error) != nil) {
                print("Error: \(error)")
            } else {
                // Handle the success
                
                print(result)
                
            }
        })
        
    }
    
    
    // UTILITIES
    
    func registerDevice(identifier: String, locale: String?) -> Void {
        
        ZDKPushProvider(zendesk: Zendesk.instance!).register(deviceIdentifier: identifier, locale: locale ?? "en") { (pushResponse, error) in
            print("Couldn't register device: \(identifier). Error: \(error)")
        }
    }
    
//    func presentHelpCenter() {
//        let helpCenterUiConfig = HelpCenterUiConfiguration()
//        helpCenterUiConfig.hideContactSupport = true
//
//        let articleUiConfig = ArticleUiConfiguration()
//        articleUiConfig.hideContactSupport = true   // hide in article screen
//
//        let helpCenterViewController = HelpCenterUi.buildHelpCenterOverviewUi(withConfigs: [helpCenterUiConfig, articleUiConfig])
//        self.navigationController?.pushViewController(helpCenterViewController, animated: true)
//    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler:
                   @escaping () -> Void) {
      let requestID = response.notification.request.content.userInfo["tid"]
    }
    

}
