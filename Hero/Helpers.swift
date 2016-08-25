//
//  Helpers.swift
//  Hero
//
//  Created by Nissan Tsafrir on 25.8.2016.
//  Copyright © 2016 Pix & Byte. All rights reserved.
//

import Foundation

public struct Helpers {
    
    public static func delayToMainThread(delay:Double, closure:()->()) {
        dispatch_after (
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
}

public func detectDevelopmentEnvironment() -> Bool {
    var developmentEnvironment = false
    #if DEBUG || (arch(i386) || arch(x86_64)) && os(iOS)
        developmentEnvironment = true
    #endif
    return developmentEnvironment
}

