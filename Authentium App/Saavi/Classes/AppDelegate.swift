//
//  AppDelegate.swift
//  Saavi
//
//  Created by Sukhpreet Singh on 15/06/17.
//  Copyright © 2017 Saavi. All rights reserved.
// Sprint 5 Complete

import UIKit
import CoreData
import Firebase
import Stripe
import GooglePlaces

import UserNotifications

@UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate,MessagingDelegate {
    
    var window: UIWindow?
    
    //did finish launch
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        Thread.sleep(forTimeInterval: 1.0)
        // Override point for customization after application launch.
//        FirebaseApp.configure()
        IQKeyboardManager.sharedManager().enable = true
        //IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = 10.0
        IQKeyboardManager.sharedManager().previousNextDisplayMode = .alwaysHide
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        
//        Stripe.setDefaultPublishableKey("pk_test_evC3cXz7zJu0ABxeKrFF0oyw00gMTiVS8s");
//        GMSPlacesClient.provideAPIKey("AIzaSyD1SMGHFaBfV9bE2XiE7IpykbWJ2UmZEIE")
        
        if window == nil
        {
            window = UIWindow(frame: UIScreen.main.bounds)
        }
        
//        let navBackgroundImage:UIImage! = #imageLiteral(resourceName: "LINE")  //UIImage(named: "LINE")
//        UINavigationBar.appearance().setBackgroundImage(navBackgroundImage, for: .default)
        
//        self.registerForPushNotification(application: application)
//        Messaging.messaging().delegate = self
        
        let splachScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SplashViewController") as? SplashViewController
        self.window?.rootViewController = splachScreen
        self.window?.makeKeyAndVisible()
        return true
    }
    
    func registerForPushNotification(application:UIApplication)  {
        
        if #available(iOS 10.0, *) {
            
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                center.delegate = self
                // Enable or disable features based on authorization.
            }
            application.registerForRemoteNotifications()
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.absoluteString.contains("SunCoast://resetpassword")
        {
            let token =  url.absoluteString.replacingOccurrences(of: "SunCoast://resetpassword.abc.com?code=", with: "")
            if let changePasswordVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "changePasswordVCStoryboardID") as? ChangePasswordVC
            {
                changePasswordVC.token = token
                if ((self.window?.rootViewController) != nil)
                {
                    self.window?.rootViewController?.present(changePasswordVC, animated: true, completion: nil)
                }
            }
        }
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.ter
         */
        let container = NSPersistentContainer(name: "Saavi")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension AppDelegate{
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        UserDefaults.standard.set(fcmToken, forKey: "DeviceToken")

    }
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Messaging.messaging().apnsToken = deviceToken as Data
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        print(userInfo)
    }
    
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
      
        print(userInfo)
        
        completionHandler([.alert,.badge,.sound])
    }
  
}
