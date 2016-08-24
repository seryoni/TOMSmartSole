//
//  BleManager.swift
//  Tom
//
//  Created by Nissan Tsafrir on 24.8.2016.
//  Copyright © 2016 Pix & Byte. All rights reserved.
//

import Foundation
import RZBluetooth
import CocoaLumberjack

class BleManager {
    var centralManager: RZBCentralManager!
    
    init () {
        centralManager = RZBCentralManager(identifier: "tom", queue: nil)
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
        centralManager.scanForPeripheralsWithServices([CBUUID.rzb_UUIDForHeartRateService()], options: nil) { scanInfo, error in
            guard let peripheral = scanInfo?.peripheral else {
                DDLogError("BleManager:scanForPeripherals: ERROR: \(error!)")
                return
            }
            self.centralManager.stopScan()
            self.startMonitor(peripheral)
        }
    }
    
    func startMonitor(peripheral: RZBPeripheral) {
        DDLogInfo("BleManager: startMonitor")
        peripheral.maintainConnection = true
        
        peripheral.addHeartRateObserver({ measurement, error in
            guard let heartRate = measurement?.heartRate else { return }
            DDLogInfo("BleManager: HEART RATE: \(heartRate)")
            }, completion: { error in
                guard let error = error else { return }
                DDLogError("BleManager:startMonitor: ERROR: \(error)")
        })
    }
}
