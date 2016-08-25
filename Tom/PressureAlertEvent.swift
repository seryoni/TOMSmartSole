//
//  PressureAlertEvent.swift
//  Tom
//
//  Created by Nissan Tsafrir on 25.8.2016.
//  Copyright © 2016 Pix & Byte. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack

struct EventsDataModel {
    static var nextAlertEventID = 1
    
    static func nextChecklistItemID() -> Int {
        let ret = nextAlertEventID
        nextAlertEventID += 1
        return ret
    }
}

class PressureAlertEvent: NSObject, NSCoding {
    var date = NSDate()
    var itemID: Int
    //var pressure: Int = 0
    
    override init() { //pressure: Int) {
        itemID = EventsDataModel.nextChecklistItemID()
        //self.pressure = pressure
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        date = aDecoder.decodeObjectForKey("Date") as! NSDate
        itemID = aDecoder.decodeIntegerForKey("ItemID")
        //pressure = aDecoder.decodeIntegerForKey("pressure")
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(date, forKey: "Date")
        aCoder.encodeInteger(itemID, forKey: "ItemID")
//        aCoder.encodeInteger(pressure, forKey: "pressure")
    }
    
    func scheduleNotification() {
        let existingNotification = notificationForThisItem()
        if let notification = existingNotification {
            DDLogInfo("Found an existing notification \(notification)")
            return
            //UIApplication.sharedApplication().cancelLocalNotification(notification)
        }
        
        let localNotification = UILocalNotification()
        //localNotification.fireDate = date
        //localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.alertTitle = "Pressure Alert"
        localNotification.alertBody = "Over pressure detected! take a break"
        localNotification.alertAction = "Open"
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.applicationIconBadgeNumber = 1
        localNotification.userInfo = ["ItemID": itemID, "PressureAlertEvent": true]
        UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
        DDLogInfo("Present notification \(localNotification) for itemID \(itemID) date:\(date)")
    }
    
    func notificationForThisItem() -> UILocalNotification? {
        let allNotifications = UIApplication.sharedApplication().scheduledLocalNotifications!
        for notification in allNotifications {
            if let number = notification.userInfo?["PressureAlertEvent"] as? Int where number == itemID {
                return notification
            }
        }
        return nil
    }
}
