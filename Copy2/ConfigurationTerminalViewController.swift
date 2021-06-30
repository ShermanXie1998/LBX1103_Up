//
//  ConfigurationTerminalViewController.swift
//  EADemo
//
//  Created by Farhad Rismanchian on 10/12/16.
//  Licence MIT
//


import UIKit
import ExternalAccessory
import McuManager
import CoreBluetooth

class ConfigurationTerminalViewController: UIViewController, McuMgrViewController{
    
   // let sessionController = SessionController.sharedController
    
    private var imageData: Data?
    
    enum commandTypes {
        case            string
        case            hexString
    }

  //  var sessionController:                              SessionController! //手柄对象
    var accessory:                                      EAAccessory?
    
    @IBOutlet var Select: UIButton!
    
    @IBOutlet var Name: UILabel!
    @IBOutlet var SIze: UILabel!
    @IBOutlet var Hash: UILabel!
    @IBOutlet var State: UILabel!
    @IBOutlet var StartBTN: UIButton!
    @IBOutlet var CancelBTN: UIButton!
    @IBOutlet var PauseBTN: UIButton!
    @IBOutlet var ResumeBTN: UIButton!
    @IBOutlet var Progress: UIProgressView!
    
    
    @IBOutlet var stringCommandTextField:               UITextField!
    @IBOutlet var hexStringCommandTextField:            UITextField!
    @IBOutlet var responseTextView:                     UITextView!
    @IBOutlet var hexResponseTextView:                  UITextView!
    
    @IBAction func selectFirmware(_ sender: UIButton) {
        let importMenu = UIDocumentMenuViewController(documentTypes: ["public.data", "public.content"],
                                                      in: .import)
        importMenu.delegate = self
        importMenu.popoverPresentationController?.sourceView = Select
        present(importMenu, animated: true, completion: nil)
       
    }
  
    @IBAction func start(_ sender: UIButton) {
        selectMode(for: imageData!)
        print(imageData)
    }
    @IBAction func pause(_ sender: UIButton) {
        dfuManager.pause()
        PauseBTN.isHidden = true
        ResumeBTN.isHidden = false
        State.text = "PAUSED"
    }
    @IBAction func resume(_ sender: UIButton) {
        dfuManager.resume()
        PauseBTN.isHidden = false
        ResumeBTN.isHidden = true
        State.text = "UPLOADING..."
    }
    @IBAction func cancel(_ sender: UIButton) {
        dfuManager.cancel()
    }
    
    let sharedController = SessionController()
 // var sessionController = SessionController.sharedController
   /* var EAper: SessionController! {
        didSet {
            let bleTransporter = McuMgrBleTransport(EAper.sharedController)
        }
    }*/
    let sessionController = SessionController.sharedController //初始化手柄
    
 //   let bleTransporter = McuMgrBleTransport(sessionController)
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
      // let controller = segue.destination as! BaseViewController
       // controller.peripheral = (sender as! EAAccessory)
    }
    
    private var dfuManager: FirmwareUpgradeManager!
 
    /*var transporter2 : McuMgrTransport!
    var bleTransporter : McuMgrBleTransport!
    
    var peripheral1: DiscoveredPeripheral! {
        didSet {
            bleTransporter = McuMgrBleTransport(peripheral1.basePeripheral)
            bleTransporter.logDelegate = UIApplication.shared.delegate as? McuMgrLogDelegate
            transporter2 = bleTransporter
        }
    }*/
    
    private func didsetFile(){
        dfuManager =  FirmwareUpgradeManager(transporter: transporter, delegate: self)
        dfuManager.logDelegate = UIApplication.shared.delegate as? McuMgrLogDelegate
        // nRF52840 requires ~ 10 seconds for swapping images.
        // Adjust this parameter for your device.
        dfuManager.estimatedSwapTime = 10.0
    }
    var transporter: McuMgrTransport! { //获取传输对象
        didSet {
            didsetFile()
        }
    }
    

    
    private func selectMode(for imageData: Data) {
        let alertController = UIAlertController(title: "Select mode", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Test and confirm", style: .default) {
            action in
            self.dfuManager!.mode = .testAndConfirm
           // if self.bleTransporter == nil {print("TTR")}
           
            self.startFirmwareUpgrade(imageData: imageData)
        })
        alertController.addAction(UIAlertAction(title: "Test only", style: .default) {
            action in
          //  self.transporter.getScheme()
            self.dfuManager!.mode = .testOnly
            self.startFirmwareUpgrade(imageData: imageData)
        })
        alertController.addAction(UIAlertAction(title: "Confirm only", style: .default) {
            action in
            self.dfuManager!.mode = .confirmOnly
            self.startFirmwareUpgrade(imageData: imageData)
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    
        // If the device is an ipad set the popover presentation controller
        if let presenter = alertController.popoverPresentationController {
        presenter.sourceView = self.view
        presenter.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        presenter.permittedArrowDirections = []
        }
        present(alertController, animated: true)
    }
    
    private func startFirmwareUpgrade(imageData: Data) {
        do {
            if dfuManager == nil
            {
                print("dfuManager == nil")
            }
            else
            {
                try dfuManager?.start(data: imageData)
            }
        } catch {
            print("Error reading hash: \(error)")
            State.textColor = .systemRed
            State.text = "ERROR"
            StartBTN.isEnabled = false
        }
    }
    override func viewDidLoad() {
       // let baseController = parent as! AccessoryDetectionTableViewController
    //    let transporter = baseController.transporter!
        
        //let transporter = AccessoryDetectionTableViewController.transporter!
        super.viewDidLoad()
        title = sessionController._accessory?.name
        // Do any additional setup after loading the view.
      //  transporter?.EAClose()
       
    }
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(sessionDataReceived), name: NSNotification.Name(rawValue: "BESessionDataReceivedNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(accessoryDidDisconnect), name: NSNotification.Name.EAAccessoryDidDisconnect, object: nil)
        
        var sessionController = SessionController.sharedController
        
        accessory = sessionController._accessory
        _ = sessionController.openSession()
        
        stringCommandTextField.addTarget(nil, action:#selector(ConfigurationTerminalViewController.firstResponderAction(_:)), for:.editingDidEndOnExit)
        hexStringCommandTextField.addTarget(nil, action:#selector(ConfigurationTerminalViewController.firstResponderAction(_:)), for:.editingDidEndOnExit)


        super.viewWillAppear(animated)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "BESessionDataReceivedNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.EAAccessoryDidDisconnect, object: nil)
        
        sessionController.closeSession()
        
        super.viewWillDisappear(animated)
    }

    
    func configureAccessoryWithString(string: String, stringType: commandTypes? = commandTypes.string ) {
        
        if stringType == commandTypes.string {
            let data = string.data(using: .utf8)
            sessionController.writeData(data: data!)
        } else {
            let data = string.dataFromHexString()
            sessionController.writeData(data: data!)
        }
    }
    
    // MARK: - Session Updates
    
    @objc func sessionDataReceived(notification: NSNotification) {
        
        if sessionController._dataAsString != nil {
            responseTextView.textStorage.beginEditing()
            responseTextView.textStorage.mutableString.append(sessionController._dataAsString!)
            responseTextView.textStorage.endEditing()
            responseTextView.scrollRangeToVisible(NSMakeRange(responseTextView.textStorage.length, 0))
            
            hexResponseTextView.textStorage.beginEditing()
            hexResponseTextView.textStorage.mutableString.append(sessionController._dataAsHexString!)
            hexResponseTextView.textStorage.endEditing()
            hexResponseTextView.scrollRangeToVisible(NSMakeRange(responseTextView.textStorage.length, 0))
        }
    }
    
    // MARK: - EAAccessory Disconnection
    
    @objc func accessoryDidDisconnect(notification: NSNotification) {
        
        if navigationController?.topViewController == self {
            let disconnectedAccessory = notification.userInfo![EAAccessoryKey]
            if (disconnectedAccessory as! EAAccessory).connectionID == accessory?.connectionID {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func firstResponderAction(_ sender: Any){
        stringCommandTextField.resignFirstResponder()
        hexStringCommandTextField.resignFirstResponder()

    }

    @IBAction func sendStringCommandButtonTapped(_ sender: Any) {
        
        configureAccessoryWithString(string: stringCommandTextField.text ?? "", stringType:   commandTypes.string)
    }
    
    
    @IBAction func sendHexStringCommandButtonTapped(_ sender: Any) {
        configureAccessoryWithString(string: hexStringCommandTextField.text ?? "", stringType: commandTypes.hexString)
    }
    

    @IBAction func clearButtonTapped(_ sender: Any) {
       // responseTextView.text =         ""
      //  hexResponseTextView.text =      ""
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ConfigurationTerminalViewController: FirmwareUpgradeDelegate {
    func upgradeDidStart(controller: FirmwareUpgradeController) {
        StartBTN.isHidden = true
        PauseBTN.isHidden = false
        CancelBTN.isHidden = false
        Select.isEnabled = false
    }
    
    func upgradeStateDidChange(from previousState: FirmwareUpgradeState, to newState: FirmwareUpgradeState) {
        State.textColor = .primary
        switch newState {
        case .validate:
            State.text = "VALIDATING..."
        case .upload:
            State.text = "UPLOADING..."
        case .test:
            State.text = "TESTING..."
        case .confirm:
            State.text = "CONFIRMING..."
        case .reset:
            State.text = "RESETTING..."
        case .success:
            State.text = "UPLOAD COMPLETE"
        default:
            State.text = ""
        }
    }
    
    func upgradeDidComplete() {
        Progress.setProgress(0, animated: false)
        PauseBTN.isHidden = true
        ResumeBTN.isHidden = true
        CancelBTN.isHidden = true
        StartBTN.isHidden = false
        StartBTN.isEnabled = false
        Select.isEnabled = true
        imageData = nil
    }
    
    func upgradeDidFail(inState state: FirmwareUpgradeState, with error: Error) {
        Progress.setProgress(0, animated: true)
        PauseBTN.isHidden = true
        ResumeBTN.isHidden = true
        CancelBTN.isHidden = true
        StartBTN.isHidden = false
        Select.isEnabled = true
        State.textColor = .systemRed
        State.text = "\(error.localizedDescription)"
    }
    
    func upgradeDidCancel(state: FirmwareUpgradeState) {
        Progress.setProgress(0, animated: true)
        PauseBTN.isHidden = true
        ResumeBTN.isHidden = true
        CancelBTN.isHidden = true
        StartBTN.isHidden = false
        Select.isEnabled = true
        State.textColor = .primary
        State.text = "CANCELLED"
    }
    
    func uploadProgressDidChange(bytesSent: Int, imageSize: Int, timestamp: Date) {
        Progress.setProgress(Float(bytesSent) / Float(imageSize), animated: true)
    }
}




extension ConfigurationTerminalViewController: UIDocumentMenuDelegate, UIDocumentPickerDelegate {
    
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if let data = dataFrom(url: url) {
            Name.text = url.lastPathComponent
            SIze.text = "\(data.count) bytes"
            
            do {
                let hash = try McuMgrImage(data: data).hash
                
                imageData = data
                Hash.text = hash.hexEncodedString(options: .upperCase)
             //   let newStr = String(data: imageData!, encoding: String.Encoding.      )
               // hexStringCommandTextField.text = newStr
                State.textColor = .primary
                State.text = "READY"
                StartBTN.isEnabled = true
            } catch {
                print("Error reading hash: \(error)")
                Hash.text = ""
                State.textColor = .systemRed
                State.text = "INVALID FILE"
                StartBTN.isEnabled = false
            }
        }
    }
    
    /// Get the image data from the document URL
    private func dataFrom(url: URL) -> Data? {
        do {
            return try Data(contentsOf: url)
        } catch {
            print("Error reading file: \(error)")
            State.textColor = .systemRed
            State.text = "COULD NOT OPEN FILE"
            return nil
        }
    }
}
