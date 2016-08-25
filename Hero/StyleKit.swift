//
//  StyleKit.swift
//  Hero
//
//  Created by Nissan Tsafrir on 25.8.2016.
//  Copyright © 2016 Pix & Byte. All rights reserved.
//

import UIKit

public class StyleKit : NSObject {
    
    //// Cache
    
    private struct Cache {
        static let blue1: UIColor = UIColor(red: 0.282, green: 0.443, blue: 0.992, alpha: 1.000)
        static let blue2: UIColor = UIColor(red: 0.729, green: 0.784, blue: 1.000, alpha: 1.000)
    }
    
    //// Colors
    
    public class var blue1: UIColor { return Cache.blue1 }
    public class var blue2: UIColor { return Cache.blue2 }
    
    //// Drawing Methods
    
    public class func drawCanvas1() {
    }
    
}

