//
//  StartPage.swift
//  Copy2
//
//  Created by DashineNo2 on 2021/5/6.
//

import UIKit
import ExternalAccessory
import McuManager

class StartPage: UITableViewCell {
        
    private var peripheral: EAAccessory!
    
    public func setupViewWithPeripheral(_ aPeripheral: EAAccessory) {
        peripheral = aPeripheral

    }
    
    public func peripheralUpdatedAdvertisementData(_ aPeripheral: EAAccessory) {

        setupViewWithPeripheral(aPeripheral)

    }
}

