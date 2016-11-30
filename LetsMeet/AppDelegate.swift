//
//  AppDelegate.swift
//  LetsMeet
//
//  Created by Shruti  on 28/05/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var landingViewController:LandingViewController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool
   {
    UITabBar.appearance().tintColor = themeColorforTabbar()
    
    let tabBarController = window!.rootViewController as! UITabBarController
    let navigationController = tabBarController.viewControllers![0] as! UINavigationController
    landingViewController = navigationController.topViewController as! LandingViewController
    
    //Regitser for push
    
//    let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
//    let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
//    application.registerUserNotificationSettings(pushNotificationSettings)
//    
//    application.registerForRemoteNotifications()
//    
//    if let options: NSDictionary = launchOptions as NSDictionary? {
//        let remoteNotification = options.object(
//            forKey: UIApplicationLaunchOptionsKey.remoteNotification) as?
//        NSDictionary
//        if let notification = remoteNotification {
//            self.application(application,
//                             didReceiveRemoteNotification: notification as! [AnyHashable: Any])
//        }
   // }
    
    return true
    }
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//
//        // Set tab bar appearance
//        UITabBar.appearance().tintColor = themeColorforTabbar()
//        
//        let tabBarController = window!.rootViewController as! UITabBarController
//        let navigationController = tabBarController.viewControllers![0] as! UINavigationController
//        landingViewController = navigationController.topViewController as! LandingViewController
//       
//        //Regitser for push
//        
//        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
//        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
//        application.registerUserNotificationSettings(pushNotificationSettings)
//
//        application.registerForRemoteNotifications()
//        
//        if let options: NSDictionary = launchOptions as NSDictionary? {
//            let remoteNotification = options.object(
//                forKey: UIApplicationLaunchOptionsKey.remoteNotification) as?
//            NSDictionary
//            if let notification = remoteNotification {
//                self.application(application,
//                    didReceiveRemoteNotification: notification as! [AnyHashable: Any])
//            }
//        }
//
//        return true
//    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        print(deviceToken)
    }
    
    // Handle push notification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        print(userInfo.description)
        
        let cloudkitNotification: CKNotification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
        let alertBody = cloudkitNotification.alertBody

        print(alertBody)
        
        if cloudkitNotification.notificationType == CKNotificationType.query {
            let queryNotification = cloudkitNotification as! CKQueryNotification
            CloudClient.sharedInstance().handleNotification(queryNotification)
        }
        
    }
    
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    

}

