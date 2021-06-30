//
//  AccessoryDetectionTableViewController.swift
//  EADemo
//
//  Created by Farhad Rismanchian on 10/12/16.
//  Licence MIT
//


import UIKit
import ExternalAccessory
import McuManager

class AccessoryDetectionTableViewController: UITableViewController {
    
    var sessionController:              SessionController!
    var accessoryList:                  [EAAccessory]?
    var selectedAccessory:              EAAccessory?
    
    @IBOutlet weak var button1: UIButton!
    /*  var peripheral: DiscoveredPeripheral! {
        didSet {
            let bleTransporter = McuMgrBleTransport(peripheral.EAbasePeripheral)
            bleTransporter.logDelegate = UIApplication.shared.delegate as? McuMgrLogDelegate
            transporter = bleTransporter
        }
    }*/
    
    private var peripheral: EAAccessory!

    
    var bleTransporter : McuMgrBleTransport!
    var transporter : McuMgrTransport!
    
    public func setupViewWithPeripheral(_ aPeripheral: EAAccessory) {
        peripheral = aPeripheral
    }
    
    @IBAction func click2(_ sender: Any, _ aPeripheral: EAAccessory) {
        setupViewWithPeripheral(aPeripheral)
    }
    @IBAction func Click(_ sender: Any, _ aPeripheral: EAAccessory
    ) {
        setupViewWithPeripheral(aPeripheral)
    }
    
    
  
    
    private var defaultManager: DefaultManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        /*let transporter: McuMgrBleTransport!
        
        var peripheral1: SessionController! {
            didSet {
                let bleTransporter = McuMgrBleTransport(peripheral1)
                transporter = bleTransporter
            }
        }*/
        
   
    }

    override func viewWillDisappear(_ animated: Bool) {
        peripheral = sessionController._accessory
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(accessoryDidConnect), name: NSNotification.Name.EAAccessoryDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(accessoryDidDisconnect), name: NSNotification.Name.EAAccessoryDidDisconnect, object: nil)
        EAAccessoryManager.shared().registerForLocalNotifications() //发布连接到的设备消息
        
        sessionController = SessionController.sharedController //初始化
       
        accessoryList = EAAccessoryManager.shared().connectedAccessories //已连接的controller
     
        //var transporter: McuMgrTransport!
     /*  var peripheral: DiscoveredPeripheral! {
             didSet {
                let bleTransporter = McuMgrBleTransport(peripheral.EAbasePeripheral)
                bleTransporter.logDelegate = UIApplication.shared.delegate as? McuMgrLogDelegate
                transporter = bleTransporter
            }
        }*/
    
        
        
        
    }
    
    // MARK: - EAAccessoryNotification Handlers
    
    @objc func accessoryDidConnect(notificaton: NSNotification) { //列表上增加或减少设备信息
        
        let connectedAccessory =        notificaton.userInfo![EAAccessoryKey]
        accessoryList?.append(connectedAccessory as! EAAccessory)
        let indexPath =                 IndexPath(row: (accessoryList?.count)! - 1 , section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    
    @objc func accessoryDidDisconnect(notification: NSNotification) {
        
        let disconnectedAccessory =             notification.userInfo![EAAccessoryKey]
        var disconnectedAccessoryIndex =        0
        for accessory in accessoryList! {
            if (disconnectedAccessory as! EAAccessory).connectionID == accessory.connectionID {
                break
            }
            disconnectedAccessoryIndex += 1
        }
        
        if disconnectedAccessoryIndex < (accessoryList?.count)! {
            accessoryList?.remove(at: disconnectedAccessoryIndex)
            let indexPath = IndexPath(row: disconnectedAccessoryIndex, section: 0)
            tableView.deleteRows(at: [indexPath], with: .right)
        } else {
            print("Could not find disconnected accessories in list")
        }
    }
    
    

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (accessoryList?.count)!
    }
    
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "AccessoryCell", for: indexPath)
     
     // Configure the cell...
        var accessoryName = accessoryList?[indexPath.row].name
        if accessoryName == nil  || accessoryName == "" {
            accessoryName = "Unknown Accessory"
        }
        
        cell.textLabel?.text = accessoryName
     
     return cell
     }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedAccessory = accessoryList?[indexPath.row]
        sessionController.setupController(forAccessory: selectedAccessory!, withProtocolString: (selectedAccessory?.protocolStrings[0])!) //调用协议初始化Opensession
        performSegue(withIdentifier: "Connect", sender: accessoryList?[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
       let controller = segue.destination as! BaseViewController
        controller.peripheral = (sender as! EAAccessory)
    }
 

}
