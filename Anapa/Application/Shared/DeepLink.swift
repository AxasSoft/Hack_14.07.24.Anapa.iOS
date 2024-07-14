//
//  DeepLink.swift
//  Anapa
//
//  Created by Сергей Майбродский on 02.09.2023.
//
//

import Foundation
import UIKit


let Deeplinker = DeepLinkManager()
class DeepLinkManager {
    fileprivate init() {}
    
    private var linkInfo: DeepLinkData?
    
    @discardableResult
    func handleDeeplink(url: URL) -> Bool {
        linkInfo = DeeplinkParser.shared.parseDeepLink(url)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(linkInfo), forKey: "deepLink")
        return linkInfo != nil
    }
    
    // check existing deepling and perform action
    func checkDeepLink() {
        guard let linkInfo = linkInfo else {
            return
        }
        
        DeeplinkNavigator.shared.openVCFromDeepLink(linkInfo: linkInfo)
        
        // reset deeplink after handling
        self.linkInfo = nil
    }
}

extension UIApplication {
    var keyWindow: UIWindow? {
        return UIApplication.shared
            .connectedScenes
            .first(where: { $0 is UIWindowScene })
            .flatMap { $0 as? UIWindowScene }?.windows
            .first(where: \.isKeyWindow)
    }
}


class DeeplinkNavigator {
    
    static let shared = DeeplinkNavigator()
    private init() { }
    
    func openVCFromDeepLink(linkInfo: DeepLinkData) {
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(linkInfo), forKey: "deepLink")
        
        guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
            return
        }
        
        rootViewController.tabBarController?.selectedIndex = 0
        
        if linkInfo.linkType == .user {
            
            print("got active scene")
            
            let storyboard = UIStoryboard(name: "Profile", bundle: .main)
            if  let userVC = storyboard.instantiateViewController(withIdentifier: "UserVC") as? UserController,
                let tabBarVC = rootViewController as? UITabBarController,
                let navVC = tabBarVC.selectedViewController as? UINavigationController {
                
                tabBarVC.selectedIndex = 0
                // we can modify variable of the view controller using notification data
                // (eg: title of notification)
                // response.notification.request.content.userInfo
                userVC.userId = linkInfo.id
                userVC.modalPresentationStyle = .fullScreen
                navVC.show(userVC, sender: nil)
            }
        } else {
            let storyboard = UIStoryboard(name: "Info", bundle: .main)
            if let infoVC = storyboard.instantiateViewController(withIdentifier: "OneInfoVC") as? OneInfoController,
               var tabBarVC = rootViewController as? UITabBarController,
               var navVC = tabBarVC.selectedViewController as? UINavigationController {
                
                tabBarVC.selectedIndex = 0
                // we can modify variable of the view controller using notification data
                // (eg: title of notification)
                // response.notification.request.content.userInfo
                infoVC.infoId = linkInfo.id
                infoVC.modalPresentationStyle = .fullScreen
                navVC.show(infoVC, sender: nil)
            }
        }
        
    }
}


class DeeplinkParser {
    static let shared = DeeplinkParser()
    private init() { }
    
    var linkInfo: DeepLinkData?
    
    func parseDeepLink(_ url: URL) -> DeepLinkData? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true), let host = components.host else {
            return nil
        }
        let linkData = url.absoluteString.split(separator: "&")
        print(linkData)
        
        let id = Int(components.queryItems![0].value ?? "0")!
        
        if host == DeepLinkTypes.user.rawValue {
            
            return DeepLinkData(linkType: .user, id: id)
        } else {
            return DeepLinkData(linkType: .info, id: id)
        }
    }
}


struct DeepLinkData: Codable {
    let linkType: DeepLinkTypes
    let id: Int
}

enum DeepLinkTypes: String, Codable  {
    case user = "user"
    case info = "info"
}
