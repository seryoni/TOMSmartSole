//
//  PressurePeripheral.swift
//  Hero
//
//  Created by Nissan Tsafrir on 25.8.2016.
//  Copyright © 2016 Pix & Byte. All rights reserved.
//

import Foundation
import RZBluetooth
import CocoaLumberjack

typealias PressurePeripheralUpdateCompletion = (PressureMeasurment?, NSError?) -> Void
typealias PressurePeripheralErrorBlock = (NSError?) -> Void

enum PressureProfile: String {
    
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.temperature_measurement.xml
    
    //case Service = "2209" // Our Pressure profile
    case Service = "1809" // health thermometer
    case MeasurementCharacteristic = "2A1C"
    
    var cbUUID: CBUUID {
        return CBUUID(string: self.rawValue)
    }
}

class PressurePeripheral {
    
    let peripheral: RZBPeripheral
    
    init(peripheral: RZBPeripheral) {
        self.peripheral = peripheral
    }
    
    func addPressureObserver(update: PressurePeripheralUpdateCompletion, completion: PressurePeripheralErrorBlock?) {
        
        let serviceUUID = PressureProfile.Service.cbUUID
        peripheral.enableNotifyForCharacteristicUUID(PressureProfile.MeasurementCharacteristic.cbUUID,
                                          serviceUUID: serviceUUID,
                                          onUpdate: { (char: CBCharacteristic?, error: NSError?) in
                                            if let error = error {
                                                DDLogInfo("enableNotifyForCharacteristicUUID update. error:\(error)")
                                                update(nil, error)
                                                return
                                            }
                                            guard let
                                                char = char,
                                                value = char.value
                                                else { fatalError() }
                                            
                                            DDLogInfo("data: \(value)")
                                            let pressure = PressureMeasurment(data: value)
                                            update(pressure, error)
                                            
        }) { (char: CBCharacteristic?, error: NSError?) in
            DDLogInfo("enableNotifyForCharacteristicUUID completed. error:\(error)")
            if let completion = completion {
                completion(error)
            }
        }                
    }
    
    func removePressureObserver(completion: PressurePeripheralErrorBlock) {
        peripheral.clearNotifyBlockForCharacteristicUUID(PressureProfile.MeasurementCharacteristic.cbUUID, serviceUUID: PressureProfile.Service.cbUUID) { (char, error) in
            completion(error)
        }
    }
    
}

