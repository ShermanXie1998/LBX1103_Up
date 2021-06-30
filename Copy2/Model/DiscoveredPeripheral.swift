/*
 * Copyright (c) 2018 Nordic Semiconductor ASA.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import CoreBluetooth
import ExternalAccessory

class DiscoveredPeripheral: NSObject {
    //MARK: - Properties
    public private(set) var basePeripheral      : EAAccessory
    public private(set) var advertisedName      : String
    
    
    init(_ aPeripheral: EAAccessory) {
        basePeripheral = aPeripheral
        advertisedName = ""
        super.init()
    }
    
    /*func update(withAdvertisementData anAdvertisementDictionary: [String : Any], andRSSI anRSSI: NSNumber) {
        (advertisedName, advertisedServices) = parseAdvertisementData(anAdvertisementDictionary)
        
        if anRSSI.decimalValue != 127 {
            RSSI = anRSSI
        
            if RSSI.decimalValue > highestRSSI.decimalValue {
                highestRSSI = RSSI
            }
        }
    }*/
    
    private func parseAdvertisementData(_ anAdvertisementDictionary: [String : Any]) -> (String, [CBUUID]?) {
        var advertisedName: String
        var advertisedServices: [CBUUID]?
        
        if let name = anAdvertisementDictionary[CBAdvertisementDataLocalNameKey] as? String {
            advertisedName = name
        } else {
            advertisedName = "N/A"
        }
        if let services = anAdvertisementDictionary[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
            advertisedServices = services
        } else {
            advertisedServices = nil
        }
        
        return (advertisedName, advertisedServices)
    }
    
    //MARK: - NSObject protocols
    override func isEqual(_ object: Any?) -> Bool {
        if object is DiscoveredPeripheral {
            let peripheralObject = object as! DiscoveredPeripheral
            return peripheralObject.basePeripheral.connectionID == basePeripheral.connectionID
        } else if object is EAAccessory {
            let peripheralObject = object as! EAAccessory
            return peripheralObject.connectionID == basePeripheral.connectionID
        } else {
            return false
        }
    }
    
    /*override func isEqual(_ object: Any?) -> Bool {
        if object is DiscoveredPeripheral {
            let peripheralObject = object as! DiscoveredPeripheral
            return peripheralObject.basePeripheral._accessory?.connectionID == basePeripheral._accessory?.connectionID
        } else if object is SessionController {
            let peripheralObject = object as! SessionController
            return peripheralObject._accessory?.connectionID == basePeripheral._accessory?.connectionID
        } else {
            return false
        }
    }*/
}

