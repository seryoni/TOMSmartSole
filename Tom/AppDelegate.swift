//
//  AppDelegate.swift
//  Tom
//
//  Created by Nissan Tsafrir on 24.8.2016.
//  Copyright © 2016 Pix & Byte. All rights reserved.
//

import UIKit
import CocoaLumberjack
import RZBluetooth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var bleManager: BleManager!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        setupLogger()
        
        DDLogInfo("\n=====  App Launch ====\n")
        print("aaa")
        
        bleManager = BleManager()
        
        guard
            let rootVC = window?.rootViewController as? ViewController
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
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        DDLogInfo("applicationWillTerminate")
    }


}

extension AppDelegate {
    
    func setupLogger() {
        
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
        //SendLogsController.fileLogger = fileLogger
    }
}
