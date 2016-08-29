//
//  ServiceViewController.swift
//  Hero
//
//  Created by Nissan Tsafrir on 24/08/2016.
//

import UIKit

class ServiceViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var addDoneButton: Bool!
    
    var didShowSendLogs = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Send Logs"
        
        //TODO: add done button to nav bar
//        if (addDoneButton != nil) {
//        
//        }
        
        statusLabel.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !didShowSendLogs {
            let helper = SendLogsController()
            helper.sendLogs()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !didShowSendLogs {
            didShowSendLogs = true
            spinner.hidden = true
            statusLabel.hidden = false
        }
    }
    
    class func createSendLogsViewController(addDoneButton: Bool) -> UINavigationController {
        let vc = ServiceViewController(nibName: nil, bundle: nil)
        vc.addDoneButton = addDoneButton
        let nvc = UINavigationController(rootViewController: vc)
        return nvc
    }
}
