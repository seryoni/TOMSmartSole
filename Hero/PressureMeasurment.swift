//
//  PressureMeasurment.swift
//  Hero
//
//  Created by Nissan Tsafrir on 25.8.2016.
//  Copyright © 2016 Pix & Byte. All rights reserved.
//

import Foundation
import CocoaLumberjack

struct PressureMeasurment {
    let pressure: UInt16
    
    init(data: NSData) {
        var value: UInt16 = 0
        var flags: Int8 = 0
        data.getBytes(&flags, range:NSMakeRange(0, 1))
        data.getBytes(&value, range:NSMakeRange(1, 2))
        
        // since we use the HTS profile
        let floatValue = Float(value)
        DDLogInfo("PressureMeasurment: floatValue: \(floatValue)")
        pressure = UInt16(floatValue)
        
        // CFSwapInt16LittleToHost(start);
        
//        int flags = [CharacteristicReader readUInt8Value:&array];
//        BOOL tempInFahrenheit = (flags & 0x01) > 0;
//        BOOL timestampPresent = (flags & 0x02) > 0;
//        BOOL typePresent = (flags & 0x04) > 0;
//        
//        float tempValue = [CharacteristicReader readFloatValue:&array];
//        if (!tempInFahrenheit && fahrenheit)
//        tempValue = tempValue * 9.0f / 5.0f + 32.0f;
//        if (tempInFahrenheit && !fahrenheit)
//        tempValue = (tempValue - 32.0f) * 5.0f / 9.0f;
//        temperatureValue = tempValue;
//        self.temperature.text = [NSString stringWithFormat:@"%.2f", tempValue];
    }
}
