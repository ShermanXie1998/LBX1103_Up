//
//  BaseViewController.swift
//  Copy2
//
//  Created by DashineNo2 on 2021/6/16.
//

import UIKit
import ExternalAccessory
import McuManager

class BaseViewController: UITabBarController {

    var bleTransporter : McuMgrBleTransport!
    var transporter: McuMgrTransport!
    
    var peripheral: EAAccessory! {
        didSet {
            bleTransporter = McuMgrBleTransport(target: peripheral)
            bleTransporter.logDelegate = UIApplication.shared.delegate as? McuMgrLogDelegate
            transporter = bleTransporter
        }
    }
    
    override func viewDidLoad() {
        title = peripheral?.name
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    var Test:String = "123"
}
