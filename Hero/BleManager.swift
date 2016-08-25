//
//  BleManager.swift
//  Hero
//
//  Created by Nissan Tsafrir on 24.8.2016.
//  Copyright © 2016 Pix & Byte. All rights reserved.
//

import Foundation
import RZBluetooth
import CocoaLumberjack

class BleManager {
    var centralManager: RZBCentralManager!
    
    var onMeasurementChange: ((value: Double) -> Void)?
    
    weak var peripheral: RZBPeripheral?
    
    weak var pressurePeriphral: PressurePeripheral?
    
    init () {
        centralManager = RZBCentralManager(identifier: "Hero", queue: nil)
        setup()
    }
    
    func setup() {
        DDLogInfo("BleManager: setup")
        centralManager.restorationHandler = { (peripherals: [RZBPeripheral]) in
            DDLogInfo("restorationHandler: peripherals: \(peripherals)")
            guard let peripheral = peripherals.first else {
                DDLogInfo("restorationHandler: no peripherals restored")
                return
            }
            
            self.startMonitor(peripheral)
        }
    }
    
    func scanForPeripherals() {
        DDLogInfo("BleManager: scanForPeripherals")
        let serviceUUID = PressureProfile.Service.cbUUID
        centralManager.scanForPeripheralsWithServices([serviceUUID], options: nil) { scanInfo, error in
            guard let peripheral = scanInfo?.peripheral else {
                DDLogError("BleManager:scanForPeripherals: ERROR: \(error!)")
                return
            }
            self.centralManager.stopScan()
            self.startMonitor(peripheral)
        }
    }
    
    func startMonitor(peripheral: RZBPeripheral) {
        DDLogInfo("BleManager: startMonitor: PressureMeasurment")
        peripheral.maintainConnection = true
        
        self.peripheral = peripheral
        
        let pressurePeriphral = PressurePeripheral(peripheral: peripheral)
        self.pressurePeriphral = pressurePeriphral
        
        pressurePeriphral.addPressureObserver({ (measurment: PressureMeasurment?, error: NSError?) in
            guard let pressure = measurment?.pressure else { return }
            DDLogInfo("BleManager: PressureMeasurment: \(pressure)")
            
            if let onMeasurementChange = self.onMeasurementChange {
                onMeasurementChange(value:Double(pressure))
            }
            
            let event = PressureAlertEvent() //(pressure: Int(pressure))
            DDLogInfo("ALERT: \(event)")
            event.scheduleNotification()
            
            }) { (error) in
                guard let error = error else { return }
                DDLogError("BleManager:startMonitor: ERROR: \(error)")
        }
    }
    
    func startHRMMonitor(peripheral: RZBPeripheral) {
        DDLogInfo("BleManager: startMonitor")
        peripheral.maintainConnection = true
        
        peripheral.addHeartRateObserver({ measurement, error in
            guard let heartRate = measurement?.heartRate else { return }
            DDLogInfo("BleManager: HEART RATE: \(heartRate)")
            if let onMeasurementChange = self.onMeasurementChange {
                onMeasurementChange(value:Double(heartRate))
            }
            }, completion: { error in
                guard let error = error else { return }
                DDLogError("BleManager:startMonitor: ERROR: \(error)")
        })
    }
}
