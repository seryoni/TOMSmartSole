//
//  ViewController.swift
//  Tom
//
//  Created by Nissan Tsafrir on 24.8.2016.
//  Copyright © 2016 Pix & Byte. All rights reserved.
//

import UIKit
import RZBluetooth

class ViewController: UIViewController {

    @IBOutlet weak var startScanButton: UIButton!
    
    var bleManager: BleManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startScanAction(sender: AnyObject) {
        bleManager.scanForPeripherals()
    }
}

