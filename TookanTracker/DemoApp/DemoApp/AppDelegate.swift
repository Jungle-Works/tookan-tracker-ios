//
//  AppDelegate.swift
//  DemoApp
//
//  Created by CL-Macmini-110 on 11/24/17.
//  Copyright © 2017 CL-Macmini-110. All rights reserved.
//

import UIKit
import UserNotifications
import TookanTracker

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if UserDefaults.standard.value(forKey: USER_DEFAULT.isSessionExpire) == nil {
            UserDefaults.standard.set(true, forKey: USER_DEFAULT.isSessionExpire)
        }
        
        /*=========== Register Push Notification =============*/
//        if #available(iOS 10.0, *) {
//            // request permissions
//            UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) {
//                (granted, error) in
//                if (granted) {
//                    DispatchQueue.main.async {
//                        UIApplication.shared.registerForRemoteNotifications()
//                    }
//                }
//            }
//        } else { // Fallback on earlier versions
//            DispatchQueue.main.async {
//                let pushSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound],categories: nil)
//                UIApplication.shared.registerUserNotificationSettings(pushSettings)
//                application.registerUserNotificationSettings(pushSettings)
//                application.registerForRemoteNotifications()
//            }
//        }
        
        self.window?.makeKeyAndVisible()
        
        return true
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
        
        if UserDefaults.standard.value(forKey: USER_DEFAULT.isSessionExpire) != nil {
            if UserDefaults.standard.bool(forKey: USER_DEFAULT.isSessionExpire) == false {
                if let rootNavigation = (window?.rootViewController?.navigationController) {
                    TookanTracker.shared.createSession(userID: userID, apiKey: apiKey, navigationController: rootNavigation)
                }
                
            }
        }
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}
