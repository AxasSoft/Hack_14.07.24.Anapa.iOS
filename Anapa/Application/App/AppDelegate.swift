//
//  InitialController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 20.01.2023.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import UserNotifications
import FirebaseCore
import FBSDKCoreKit
import AppTrackingTransparency
import YandexMobileMetrica
import CoreLocation


@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // METRIKA
        let configuration = YMMYandexMetricaConfiguration.init(apiKey: "088897af-422d-42c9-8d4c-1a939568030b")
            YMMYandexMetrica.activate(with: configuration!)

        //keyboard lib
        IQKeyboardManager.shared.enable = true

        let arr = NSArray(objects: "ru_RU")
        UserDefaults.standard.set(arr, forKey: "AppleLanguages")
        
        if UserDefaults.standard.value(forKey: "isRegistered") == nil {
            UserDefaults.standard.set(0, forKey: "id")
            UserDefaults.standard.set(false, forKey: "isRegistered")
            UserDefaults.standard.set("", forKey: "email")
            UserDefaults.standard.set("", forKey: "tel")
            UserDefaults.standard.set("", forKey: "firstName")
            UserDefaults.standard.set("", forKey: "lastName")
            UserDefaults.standard.set("", forKey: "patronymic")
            UserDefaults.standard.set(0, forKey: "birthtime")
            UserDefaults.standard.set(nil, forKey: "gender")
            UserDefaults.standard.set("", forKey: "avatar")
            UserDefaults.standard.set(nil, forKey: "location")
            UserDefaults.standard.set(0.0, forKey: "rating")
            UserDefaults.standard.set(nil, forKey: "categoryId")
            UserDefaults.standard.set(Data(), forKey: "category")
            UserDefaults.standard.set(nil, forKey: "lastVisited")
            UserDefaults.standard.set("", forKey: "lastVisitedHuman")
            UserDefaults.standard.set(true, forKey: "isActive")
            UserDefaults.standard.set(false, forKey: "isSuperuser")

            UserDefaults.standard.set(0, forKey: "storiesCount")
            UserDefaults.standard.set(0, forKey: "hugsCount")
            UserDefaults.standard.set(true, forKey: "isOnline")
            UserDefaults.standard.set(false, forKey: "iBlock")
            UserDefaults.standard.set(false, forKey: "blockMe")
            
            UserDefaults.standard.set(0, forKey: "createdOrdersCount")
            UserDefaults.standard.set(0, forKey: "completedOrdersCount")
            UserDefaults.standard.set(0, forKey: "myOffersCount")
            
            UserDefaults.standard.set(0, forKey: "tg")
            
            UserDefaults.standard.set(false, forKey: "isServicer")
            UserDefaults.standard.set(false, forKey: "showTel")
            
            UserDefaults.standard.set("", forKey: "firebaseToken")
            UserDefaults.standard.set(0, forKey: "openChat")
            UserDefaults.standard.set(false, forKey: "inBlacklist")
            UserDefaults.standard.set(false, forKey: "inWhitelist")
            UserDefaults.standard.set(false, forKey: "isBusiness")
            UserDefaults.standard.set("", forKey: "companyInfo")
            UserDefaults.standard.set("", forKey: "site")
            UserDefaults.standard.set("", forKey: "experience")
            
            UserDefaults.standard.set(0.0, forKey: "latitude")
            UserDefaults.standard.set(0.0, forKey: "longitude")
            UserDefaults.standard.set("", forKey: "status")
            UserDefaults.standard.set(0, forKey: "subscribersCount")
            UserDefaults.standard.set(0, forKey: "subscriptionsCount")
            UserDefaults.standard.set("", forKey: "profileCover")
        }
        
        
        UserDefaults.standard.set(nil, forKey: "mapFilterCategory")
        
        UserDefaults.standard.set(nil, forKey: "filterCategoryId")
        UserDefaults.standard.set(nil, forKey: "filterSubcategoryId")
        UserDefaults.standard.set(nil, forKey: "filterTypeId")
        
        UserDefaults.standard.set(nil, forKey: "searchFilterLocation")
        UserDefaults.standard.set(nil, forKey: "searchFilterCategoryId")
        UserDefaults.standard.set(nil, forKey: "searchFilterSubcategoryId")
        UserDefaults.standard.set(nil, forKey: "searchFilterRaiting")
        UserDefaults.standard.set(nil, forKey: "filterPriceFrom")
        UserDefaults.standard.set(nil, forKey: "filterPriceTo")
        UserDefaults.standard.set(nil, forKey: "filterSort")
        
        UserDefaults.standard.set(0, forKey: "openChat")
        
//        UserDefaults.standard.set(nil, forKey: "deepLink")
        
        //notfications
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (_, error) in
                guard error == nil else{
                    print(error!.localizedDescription)
                    return
                }
            }
            
            
            
            //Solicit permission from the user to receive notifications
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (_, error) in
                guard error == nil else{
                    print(error!.localizedDescription)
                    return
                }
            }
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                UserDefaults.standard.set(token, forKey: "firebaseToken")
            }
        }
        
        
        application.registerForRemoteNotifications()
        
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        return true
    }
    

    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken)")
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingDelegate) {
        YMMYandexMetrica.reportEvent("OPEN INFO", parameters: ["remoteMessage": remoteMessage.description], onFailure: { (error) in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
        print("Received data message: \(remoteMessage.description)")
        
    }

    
    //MARK: DEEP LINK
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Deeplinker.handleDeeplink(url: url)
        
        YMMYandexMetrica.reportEvent("OPEN INFO", parameters: ["66":  ""], onFailure: { (error) in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
        return true
    }
    
    // MARK: Universal Links
    private func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        YMMYandexMetrica.reportEvent("OPEN INFO", parameters: ["Title": "55"], onFailure: { (error) in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                Deeplinker.handleDeeplink(url: url)
            }
        }
        return true
    }
    
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        YMMYandexMetrica.reportEvent("OPEN INFO", parameters: ["1": ""], onFailure: { (error) in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        YMMYandexMetrica.reportEvent("OPEN INFO", parameters: ["3": "" ], onFailure: { (error) in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }

    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        YMMYandexMetrica.reportEvent("OPEN INFO", parameters: ["2": ""], onFailure: { (error) in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
        
        let application = UIApplication.shared
        
        if(application.applicationState == .active){
            print("user tapped the notification bar when the app is in foreground")
            
        }
        


        let data = response.notification.request.content.userInfo
        if data["link"] != nil {
            let deepLink = DeeplinkParser.shared.parseDeepLink(URL(string: (data["link"] as! String))!)
            DeeplinkNavigator.shared.openVCFromDeepLink(linkInfo: deepLink!)
        }
        
        if(application.applicationState == .inactive)
        {
            print("user tapped the notification bar when the app is in background")
        }
        completionHandler()
    }
}

