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
import CoreBluetooth

extension CBCentralManagerState {

    var name: String {
        switch self {
        case Unknown: return "Unknown"
        case Resetting: return "Resetting"
        case Unsupported: return "Unsupported"
        case Unauthorized: return "Unauthorized"
        case PoweredOff: return "PoweredOff"
        case PoweredOn: return "PoweredOn"
        }
    }
    
}

extension RZBPeripheralStateEvent {
    var name: String {
        switch self {
        case ConnectSuccess: return "ConnectSuccess"
        case ConnectFailure: return "ConnectFailure"
        case Disconnected: return "Disconnected"
        }
    }
}

class BleManager: NSObject {
    
    var centralManager: RZBCentralManager!
    
    var onMeasurementChange: ((value: Double) -> Void)?
    
    weak var peripheral: RZBPeripheral?
    
    weak var pressurePeriphral: PressurePeripheral?
    
    override init () {
        centralManager = RZBCentralManager(identifier: "Hero", queue: nil)
        super.init()
        self.setup()
    }
    
    func setup() {
        DDLogInfo("BleManager: setup")
        centralManager.restorationHandler = { (peripherals: [RZBPeripheral]) in
            DDLogInfo("restorationHandler: peripherals: \(peripherals)")
            guard let peripheral = peripherals.first else {
                DDLogInfo("restorationHandler: no peripherals restored")
                return
            }
            
            DDLogInfo("restorationHandler: \(peripheral.identifier.UUIDString)")
            if let currentDevice = CurrentDevice.currentDevice() {
                DDLogInfo("restorationHandler: currentDevice \(currentDevice.UUID)")
            }
            
            self.startMonitor(peripheral)
        }
        
        centralManager.centralStateHandler = handleCentralStateChange
    }
    
    func handleCentralStateChange(state: CBCentralManagerState) -> Void {
        DDLogInfo("handleCentralStateChange: state:\(state.name)(\(state))")
        
        if state == .PoweredOn {
            handlePowerOn()
        }
    }
    
    func handlePowerOn() {
        if peripheral != nil {
            return
        }
        
        if let device = CurrentDevice.currentDevice(),
            nsUUID = NSUUID(UUIDString: device.UUID) {
            
            let peripheral = centralManager.peripheralForUUID(nsUUID)
            peripheral.connectWithCompletion({ (error: NSError?) in
                if let error = error {
                    DDLogError("connectWithCompletion: \(error)")
                    self.scanForPeripherals()
                    return
                }
                
                // reconnect to known device
                self.handleConnectedToPeripheral(peripheral)
            })
        }
    }
    
    func scanForPeripherals() {
        DDLogInfo("BleManager: scanForPeripherals")
        let serviceUUID = PressureProfile.Service.cbUUID
        centralManager.scanForPeripheralsWithServices([serviceUUID], options: nil) { scanInfo, error in
            guard let peripheral: RZBPeripheral = scanInfo?.peripheral else {
                DDLogError("BleManager:scanForPeripherals: ERROR: \(error!)")
                return
            }
            
            let device = CurrentDevice(UUID: peripheral.identifier.UUIDString)
            device.save()
            
            self.handleConnectedToPeripheral(peripheral)
        }
    }
    
    func handleConnectedToPeripheral(peripheral: RZBPeripheral) {
        self.centralManager.stopScan()
        self.startMonitor(peripheral)
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
        
        peripheral.connectionDelegate = self
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

extension BleManager: RZBPeripheralConnectionDelegate {
    func peripheral(peripheral: RZBPeripheral, connectionEvent event: RZBPeripheralStateEvent, error: NSError?) {
        if let error = error {
            DDLogError("peripheral: connectionEvent - error:\(error)")
            
            return
        }
        
        DDLogInfo("peripheral: connectionEvent: \(event.name)(\(event.rawValue))")
        
        switch event {
        case .ConnectSuccess:
            DDLogInfo("ConnectSuccess")
        case .ConnectFailure:
            DDLogInfo("ConnectFailure")
            //peripheral.
        case .Disconnected:
            DDLogInfo("Disconnected")
        }
    }
}
