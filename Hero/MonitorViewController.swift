//
//  MonitorViewController.swift
//  Hero
//
//  Created by Nissan Tsafrir on 24.8.2016.
//  Copyright © 2016 Pix & Byte. All rights reserved.
//

import UIKit
import RZBluetooth
import CocoaLumberjack

class MonitorViewController: UIViewController {
    
    @IBOutlet weak var startScanButton: UIButton!
    
    @IBOutlet weak var measurmentLabel: UILabel!
    
    @IBOutlet weak var batteryPercentageLabel: UILabel!
    
    var bleManager: BleManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        bleManager.onMeasurementChange = { value in
            self.measurmentLabel.text = String(value)
        }
        
        startMonitorBattery()
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
            if let error = error  {
                return
            }
            self.batteryPercentageLabel.text = String(level)
            }) { (error) in
                DDLogError("battery observer error: \(error)")
        }
    }
    
}

