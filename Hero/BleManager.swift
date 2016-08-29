//
//  BleManager.swift
//  Hero
//
//  Created by Nissan Tsafrir on 24.8.2016.
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
    
    var eventsStore = EventsStore()
    
    var centralManager: RZBCentralManager!
    
    var onMeasurementChange: ((value: Double) -> Void)?
    
    var onDidConnectToDevice: (() -> Void)?
    
    var onDidDisconnectedToDevice: (() -> Void)?
    
    var onErrorClosure: ((errorMessage: String) -> Void)?
    
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
            peripheral.connectWithCompletion({ [weak self] (error: NSError?) in
                guard let me = self else { return }
                if let error = error {
                    DDLogError("connectWithCompletion: \(error)")
                    me.notifyOnError("connection error: \(error.localizedDescription)")
                    me.scanForPeripherals()
                    return
                }
                
                // reconnect to known device
                me.handleConnectedToPeripheral(peripheral)
            })
        }
    }
    
    func scanForPeripherals() {
        DDLogInfo("BleManager: scanForPeripherals")
        let serviceUUID = PressureProfile.Service.cbUUID
        centralManager.scanForPeripheralsWithServices([serviceUUID], options: nil) { scanInfo, error in
            guard let peripheral: RZBPeripheral = scanInfo?.peripheral else {
                DDLogError("BleManager:scanForPeripherals: ERROR: \(error!)")
                self.notifyOnError("scanForPeripherals error: \(error?.localizedDescription ?? "")")
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
        notifyOnDidConnect()
        
        DDLogInfo("BleManager: startMonitor: PressureMeasurment")
        peripheral.maintainConnection = true
        
        self.peripheral = peripheral
        
        let pressurePeriphral = PressurePeripheral(peripheral: peripheral)
        self.pressurePeriphral = pressurePeriphral
        
        pressurePeriphral.addPressureObserver({ [weak self] (measurment: PressureMeasurment?, error: NSError?) in
            guard let me = self else { return }
            
            guard let pressure = measurment?.pressure else { return }
            DDLogInfo("BleManager: PressureMeasurment: \(pressure)")
            
            if let onMeasurementChange = me.onMeasurementChange {
                onMeasurementChange(value:Double(pressure))
            }
            
            let event = PressureAlertEvent() //(pressure: Int(pressure))
            DDLogInfo("ALERT: \(event)")
            event.scheduleNotification()
            me.eventsStore.addItem(event)
            
            }) { (error) in
                guard let error = error else { return }
                DDLogError("BleManager:startMonitor: ERROR: \(error)")
                self.reconnect()
        }
        
        peripheral.connectionDelegate = self
    }

    func reconnect() {
        if let _ = peripheral {
            disconnect(forgetDevice: false)
        }
    }
//
//    func startHRMMonitor(peripheral: RZBPeripheral) {
//        DDLogInfo("BleManager: startMonitor")
//        peripheral.maintainConnection = true
//        
//        peripheral.addHeartRateObserver({ measurement, error in
//            guard let heartRate = measurement?.heartRate else { return }
//            DDLogInfo("BleManager: HEART RATE: \(heartRate)")
//            if let onMeasurementChange = self.onMeasurementChange {
//                onMeasurementChange(value:Double(heartRate))
//            }
//            }, completion: { error in
//                guard let error = error else { return }
//                DDLogError("BleManager:startMonitor: ERROR: \(error)")
//        })
//    }
    
    func disconnect(forgetDevice forgetDevice: Bool = true) {
        if let currentDevice = CurrentDevice.currentDevice() where forgetDevice {
            DDLogInfo("restorationHandler: currentDevice \(currentDevice.UUID)")
            currentDevice.clear()
        }
        
        peripheral?.cancelConnectionWithCompletion({ (error: NSError?) in
            if let error = error {
                DDLogError("error: \(error)")
                self.notifyOnError("connection error: \(error.localizedDescription)")
                return
            }
            DDLogInfo("Disconnected successfully")
            self.notifyOnDisconnect()
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
            notifyOnDidConnect()
        case .ConnectFailure:
            DDLogInfo("ConnectFailure")
            //peripheral.
            notifyOnDisconnect()
        case .Disconnected:
            DDLogInfo("Disconnected")
            notifyOnDisconnect()
        }
    }
    
    func notifyOnDidConnect() {
        if let onDidConnectToDevice = onDidConnectToDevice {
            onDidConnectToDevice()
        }
    }
    
    func notifyOnDisconnect() {
        if let onDidDisconnectedToDevice = onDidDisconnectedToDevice {
            onDidDisconnectedToDevice()
        }
    }
    
    
    func notifyOnError(errorMessage: String) {
        if let onErrorClosure = onErrorClosure {
            onErrorClosure(errorMessage: errorMessage)
        }
    }
}
