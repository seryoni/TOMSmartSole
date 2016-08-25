//
//  CurrentDevice.swift
//  Hero
//
//  Created by Nissan Tsafrir on 25.8.2016.
//  Copyright © 2016 Pix & Byte. All rights reserved.
//

import Foundation

struct CurrentDevice {
    
    let UUID: String
    
    static func currentDevice() -> CurrentDevice? {
        if let UUID = NSUserDefaults.standardUserDefaults().stringForKey("CurrentDevice") {
            return CurrentDevice(UUID: UUID)
        }
        return nil
    }
    
    func save() {
        NSUserDefaults.standardUserDefaults().setObject(UUID, forKey: "CurrentDevice")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func clear() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("CurrentDevice")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}