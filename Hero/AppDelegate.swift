//
//  AppDelegate.swift
//  Hero
//
//  Created by Nissan Tsafrir on 24.8.2016.
//

import UIKit
import CocoaLumberjack
import RZBluetooth
import TSMessages

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var bleManager: BleManager!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        setupLogger()
        
        DDLogInfo("\n=====  App Launch ====\n")
        
        TSMessage.addCustomDesignFromFileWithName("TSMessagesDefaultDesign.json")
        
        bleManager = BleManager()
        
        guard
            let rootVC = window?.rootViewController as? MonitorViewController
            else
        {
            fatalError()
        }
        
        rootVC.bleManager = bleManager
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        DDLogInfo("applicationWillResignActive")
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        DDLogInfo("applicationDidEnterBackground")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        DDLogInfo("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        DDLogInfo("applicationDidBecomeActive")
        
        self.registerForNotifications()
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        DDLogInfo("applicationWillTerminate")
    }

    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        if let host = url.host where url.scheme == "hero" && host == "app" {
            // hero://app?sendlogs=1
            let comp = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
            if let q: NSURLQueryItem = comp?.queryItems?.first, value = q.value {
                if q.name == "sendlogs" && value == "1" {
                    showSendLogs()
                    return true
                }
            }
            return false
        }
        
        return true
    }
}

extension AppDelegate {
    
    private func setupLogger() {
        // :configuration = Debug
        // OTHER_SWIFT_FLAGS = -DDEBUG
        
        #if DEBUG
            defaultDebugLevel = DDLogLevel.Verbose
            DDLog.addLogger(DDASLLogger.sharedInstance())
            DDLog.addLogger(DDTTYLogger.sharedInstance())
        #else
            defaultDebugLevel = DDLogLevel.Info
        #endif
        
        let fileLogger = DDFileLogger(logFileManager: DDLogFileManagerDefault())
        DDLog.addLogger(fileLogger)
        SendLogsController.fileLogger = fileLogger
    }
    
    // to test, paste "hero://app?sendlogs=1" in Safari
    private func showSendLogs() {
        let vc = ServiceViewController.createSendLogsViewController(false)
        window?.rootViewController = vc
    }
}

// MARK: handle notifications registration

extension AppDelegate {
    func registerForNotifications() {
        let settings = UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        DDLogInfo("user notification regsitered")
        
        // Uncomment for handling remote push
        //UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        DDLogInfo("remote notification registered.")
        //Intercom.setDeviceToken(deviceToken)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        DDLogError("Failed to register for remote notifications. error: \(error.localizedDescription)");
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        DDLogInfo("didReceiveLocalNotification")
        
        let title = notification.alertTitle ?? ""
        let subtitle = notification.alertBody ?? ""
        
        TSMessage.dismissActiveNotification()
        TSMessage.showNotificationWithTitle(title, subtitle: subtitle, type: TSMessageNotificationType.Message)        
    }
}
