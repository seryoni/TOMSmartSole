//
//  MonitorViewController.swift
//  Hero
//
//  Created by Nissan Tsafrir on 24.8.2016.
//

import UIKit
import RZBluetooth
import CocoaLumberjack
import TSMessages
import GradientView

class MonitorViewController: UIViewController {
    
    var eventsStore: EventsStore!
    
    @IBOutlet weak var startScanButton: UIButton!
    
    @IBOutlet weak var disconnectButton: UIButton!
    
    @IBOutlet weak var measurmentLabel: UILabel!
    
    @IBOutlet weak var alertLabel: UILabel!
    
    @IBOutlet weak var batteryPercentageLabel: UILabel!
    
    var alertDate: NSDate?
    
    var bleManager: BleManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        measurmentLabel.text = ""
        
        eventsStore = bleManager.eventsStore
        eventsStore.onDidAddEvent = {
            DDLogInfo("monitorVC: onDidAddEvent")
        }
        
        bleManager.onMeasurementChange = { value in
            if (value != 1) {
                //self.measurmentLabel.text = String(value)
            }
            
            self.showAlert()
        }
        
        bleManager.onDidConnectToDevice = {
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            TSMessage.dismissActiveNotification()
            TSMessage.showNotificationWithTitle("Device Connected", type: TSMessageNotificationType.Success)
            self.updateConnectButton()
            self.showMessage("Connected")
        }
        
        bleManager.onDidDisconnectedToDevice = {
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            TSMessage.dismissActiveNotification()
            TSMessage.showNotificationWithTitle("Device Disconnected", type: TSMessageNotificationType.Warning)
            self.updateConnectButton()
            self.alertLabel.text = ""
        }
        
        bleManager.onErrorClosure = { msg in
            TSMessage.dismissActiveNotification()
            TSMessage.showNotificationWithTitle(msg, type: TSMessageNotificationType.Error)
            self.updateConnectButton()
            self.alertLabel.text = ""
        }
        
        startMonitorBattery()
        
        updateConnectButton()
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil) { (notif: NSNotification) in
            self.appDidBecomeActive()
        }
        
        let gradientView = GradientView(frame: view.bounds)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set the gradient colors
        gradientView.colors = [StyleKit.blue1, StyleKit.blue2]
        
        view.insertSubview(gradientView, atIndex: 0)
        NSLayoutConstraint.activateConstraints([
            gradientView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
            gradientView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
            gradientView.topAnchor.constraintEqualToAnchor(view.topAnchor),
            gradientView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
            ])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startScanAction(sender: AnyObject) {
        bleManager.scanForPeripherals()
    }
    
    func startMonitorBattery() {
        guard let periphral = bleManager.peripheral else { return }
        periphral.addBatteryLevelObserver({ (level: UInt, error: NSError?) in
            if let _ = error  {
                return
            }
            self.updateBatteryState(level)
            }, completion: { DDLogError("battery observer error: \($0)") })
    }
    
    private func updateBatteryState(level: UInt) {
        self.batteryPercentageLabel.text = "\(String(level))%"
    }
    
    func appDidBecomeActive() {
        updateConnectButton()
    }
    
    func updateConnectButton() {
        Helpers.delayToMainThread(0.5) {
            self._updateConnectButton()
        }
    }
    
    func _updateConnectButton() {
        var disconnectButtonHidden = true
        var connectButtonHidden = false
        
        if let peripheral = bleManager.peripheral{
            if peripheral.state == .Connected {
                connectButtonHidden = true
                disconnectButtonHidden = false
            }
        }
        
        startScanButton.hidden = connectButtonHidden
        disconnectButton.hidden = disconnectButtonHidden
    }
    
    @IBAction func disconnectAction(sender: AnyObject) {
        alertLabel.text = ""
        bleManager.disconnect()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    func showAlert() {
        showMessage("Over pressure detected! take a break")
    }
    
    func showMessage(text: String) {
        self.alertLabel.text = text
        let alertDate = NSDate()
        self.alertDate = alertDate
        
        Helpers.delayToMainThread(10) {
            if self.alertDate == alertDate {
                self.alertLabel.text = ""
            }
        }
    }
}

