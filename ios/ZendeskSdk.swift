import Foundation
import UIKit
import SupportSDK
import ZendeskCoreSDK
import SupportProvidersSDK
import CommonUISDK

@objc(ZendeskSdk)
class ZendeskSdk: NSObject {

    @objc static func requiresMainQueueSetup() -> Bool {
        return false
    }

    enum ZendeskSdkError: Error {
        case UnableToSetIdentity(String)
    }


    @objc(initialize:withResolver:withRejecter:)
    func initialize(options: NSDictionary, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {

        guard let configOptions = options as? [String: Any] else {
            return
        }

        if ((configOptions["appId"]) == nil || (configOptions["clientId"]) == nil || (configOptions["zendeskUrl"]) == nil) {

            reject("100", "Zendesk initialization failed - missing arguements", nil)

        }


        Zendesk.initialize(appId: configOptions["appId"] as! String, clientId: configOptions["clientId"] as! String, zendeskUrl: configOptions["zendeskUrl"] as! String)

        Support.initialize(withZendesk: Zendesk.instance)

        // Identify user if user info is passed
        if let user = options["user"] as? [String: Any] {
            guard let userToken = user["userToken"] as? String else {
                reject("100", "Wrong user parameters. Expected userId", nil)
                return
            }

            let identity = Identity.createJwt(token: userToken)

            Zendesk.instance?.setIdentity(identity)
        }

        // Register device if device info is passed
        if let device = options["device"] as? [String: Any] {
            guard let identifier = device["deviceId"] as? String,
                  let deviceLocale = device["locale"] as? String else {
                reject("100", "Wrong device parameters. Expected deviceId and locale instead", nil)
                return
            }

            registerDevice(identifier: identifier, locale: deviceLocale)
        }

        resolve("Zendesk SDK initiated")
    }

    @objc(setAnonymous:email:withResolver:withRejecter:)
    func setAnonymous(name: String, email: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let identity = Identity.createAnonymous(name: name, email: email)

        Zendesk.instance?.setIdentity(identity)
        print(identity)
        resolve(identity)
    }


    @objc(setIdentity:withResolver:withRejecter:)
    func setIdentity(user: NSDictionary, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {

        var identity: ZendeskCoreSDK.Identity? = nil

        if ((user["userId"]) != nil) {

            identity = Identity.createJwt(token: user["userId"] as! String)

        } else if ((user["email"] != nil) && (user["name"] != nil)) {

            identity = Identity.createAnonymous(name: user["name"] as! String, email: user["email"] as! String)

        } else {

            reject("error", "invalid arguments for setIdentity", nil)
        }

        Zendesk.instance?.setIdentity(identity!)

        resolve("Identity set")

    }

    @objc(showNativeHelpCenter:)
    func showNativeHelpCenter(options: NSDictionary?) {

        Support.instance?.helpCenterLocaleOverride = "en-us"


        if let locale = options?["locale"] as? String {
            Support.instance?.helpCenterLocaleOverride = locale
        }

        let hcConfig = HelpCenterUiConfiguration()

        let articleUiConfig = ArticleUiConfiguration()
        
        if let filterBy = options?["groupIds"] as? [NSString],
           let filterByType = options?["groupType"] as? String {

            if (filterBy.count > 0 && !filterByType.isEmpty) {
                hcConfig.groupType = filterByType == "category" ? .category : .section
                hcConfig.groupIds = convertStringArrayToNumber(stringArray: filterBy)
            }
        }

        if let labels = options?["lables"] as? [String] {
            hcConfig.labels = labels
        }

        if let ticketDisabled = options?["hideContactSupport"] as? Bool {
            hcConfig.showContactOptions = !ticketDisabled
            articleUiConfig.showContactOptions = !ticketDisabled
        }
        
        var requestConfig = RequestUiConfiguration()
        
        if(options?["hideContactSupport"] as? Bool == false || options?["hideContactSupport"] == nil){
            
            if let ticketRequest = options?["ticketRequest"] as? NSDictionary{

                setTicketCreationOptions(config: &requestConfig, ticketRequest: ticketRequest)
            }
        }
        
        DispatchQueue.main.async {

            var zendeskHelpCenter = HelpCenterUi.buildHelpCenterOverviewUi(withConfigs: [hcConfig, articleUiConfig, requestConfig])

            if let articleId = options?["articleId"] as? String {
                zendeskHelpCenter = HelpCenterUi.buildHelpCenterArticleUi(withArticleId: articleId, andConfigs: [])
            }

            let navigationController = UINavigationController.init(rootViewController: zendeskHelpCenter)

            navigationController.modalPresentationStyle = .fullScreen

            UIApplication.shared.keyWindow?.rootViewController?.present(navigationController, animated: true, completion: nil)
        }

    }

    @objc(createTicket:body:tags:customFields:)
    func createTicket(title: String, body: String, tags: [String], customFields: [[String: Any]]) {
        let request = ZDKCreateRequest()
        request.subject = title
        request.requestDescription = body
        request.tags = tags

        var ticketCustomFields = [CustomField]();
        if (customFields.count > 0) {

            customFields.forEach { customField in
                ticketCustomFields.append(CustomField(fieldId: customField["fieldId"] as! Int64, value: customField["value"] as! String))
            }

            request.customFields = ticketCustomFields
        }


        ZDKRequestProvider().createRequest(request, withCallback: { (result, error) in
            if ((error) != nil) {
                print("Error: \(String(describing: error))")
            } else {
                // Handle the success

            }
        })

    }
    
    
    @objc(showTicketList:)
    func showTicketList(options: NSDictionary? = nil){
        
        var config = RequestUiConfiguration()
        
        if let ticketRequest = options?["ticketRequest"] as? NSDictionary{
            setTicketCreationOptions(config: &config, ticketRequest: ticketRequest)
        }
        
        
        DispatchQueue.main.async {
            let viewController = RequestUi.buildRequestList(with: [config])
            
            let navigationController = UINavigationController.init(rootViewController: viewController)
            
            navigationController.modalPresentationStyle = .fullScreen
            
            UIApplication.shared.keyWindow?.rootViewController?.present(navigationController, animated: true, completion: nil)
            
        }
        
    }
    
    
    @objc(showNewTicketRequest:)
    func showNewTicketRequest(options: NSDictionary? = nil){
        
        var config = RequestUiConfiguration()
        
        if let ticketRequest = options?["ticketRequest"] as? NSDictionary{
            setTicketCreationOptions(config: &config, ticketRequest: ticketRequest)
        }
        
        DispatchQueue.main.async {
            
            let viewController = RequestUi.buildRequestUi(with: [config])
            
            let navigationController = UINavigationController.init(rootViewController: viewController)
            
            navigationController.modalPresentationStyle = .fullScreen
            
            UIApplication.shared.keyWindow?.rootViewController?.present(navigationController, animated: true, completion: nil)
            
        }
    }
    
    @objc(showTicket:)
    func showTicket(requestID: String) {
        
        DispatchQueue.main.async {
            
            let viewController = RequestUi.buildRequestUi(requestId: requestID)
            
            let navigationController = UINavigationController.init(rootViewController: viewController)
            
            navigationController.modalPresentationStyle = .fullScreen
            
            UIApplication.shared.keyWindow?.rootViewController?.present(navigationController, animated: true, completion: nil)
            
        }
    }


    // UTILITIES
    
    func setTicketCreationOptions(config: inout RequestUiConfiguration, ticketRequest: NSDictionary){
        
        if let ticketTitle = ticketRequest["ticketTitle"] as? String{
            config.subject = ticketTitle
        }
        
        if let ticketTags = ticketRequest["ticketTags"] as? [String]{
            config.tags = ticketTags
        }
        
        if let customFields = ticketRequest["ticketCustomFields"] as? [[String: Any]]{
            if (customFields.count > 0) {
                var ticketCustomFields = [CustomField]();
                customFields.forEach { customField in
                    ticketCustomFields.append(CustomField(fieldId:Int64(customField["fieldId"] as! String) ?? 0 , value: customField["value"]))
                }
                config.customFields = ticketCustomFields
            }
        }
    }

    func registerDevice(identifier: String, locale: String?) -> Void {

        ZDKPushProvider(zendesk: Zendesk.instance!).register(deviceIdentifier: identifier, locale: locale ?? "en") { (pushResponse, error) in
            print("Couldn't register device: \(identifier). Error: \(String(describing: error))")
        }
    }

    func convertStringArrayToNumber(stringArray: [NSString]) -> [NSNumber] {
        let numberFormatter = NumberFormatter()
        var returnArray: [NSNumber] = []

        for i in 0..<stringArray.count {
            let convertedNumber = numberFormatter.number(from: stringArray[i] as String)

            returnArray.append(convertedNumber ?? 0)
        }
        return returnArray
    }

    func hexStringToUIColor(hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue: UInt64 = 0

        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
        )
    }

}
