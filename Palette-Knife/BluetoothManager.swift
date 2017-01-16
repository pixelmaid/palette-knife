//
//  BluetoothManager.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 11/19/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation
import UIColor_Hex
import CoreBluetooth


class BluetoothManager:NSObject {
    
    private var peripheralList: PeripheralList!
    private let uartData = UartModuleManager()
    private var txColor = Preferences.uartSentDataColor
    private var rxColor = Preferences.uartReceveivedDataColor
    private var textCachedBuffer = NSMutableAttributedString()
    private var tableCachedDataBuffer: [UartDataChunk]?
    private var cachedNumOfTableItems = 0
    private var selectedPeripheralIdentifier: String?
    
    
    var bluetoothEvent = Event<(String)>();

    override init(){
        super.init();
        // Peripheral should be connected
        
        peripheralList = PeripheralList()                  // Initialize here to wait for Preferences.registerDefaults to be executed
        
        
        // Subscribe to Ble Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didDiscoverPeripheral(_:)), name: BleManager.BleNotifications.DidDiscoverPeripheral.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didDiscoverPeripheral(_:)), name: BleManager.BleNotifications.DidUnDiscoverPeripheral.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didDisconnectFromPeripheral(_:)), name: BleManager.BleNotifications.DidDisconnectFromPeripheral.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didConnectToPeripheral(_:)), name: BleManager.BleNotifications.DidConnectToPeripheral.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(willConnectToPeripheral(_:)), name: BleManager.BleNotifications.WillConnectToPeripheral.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didUpdateBleState(_:)), name: BleManager.BleNotifications.DidUpdateBleState.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector (didRecieveData(_:)), name: UartManager.UartNotifications.DidReceiveData.rawValue, object: nil)
        BleManager.sharedInstance.startScan()
        
        uartData.delegate = self
        

    }
    
    
    @objc func didRecieveData(notification: NSNotification){
        print("recieved data \(notification)");
    }
    
    // MARK: - Notifications
    @objc func didDiscoverPeripheral(notification: NSNotification) {
        //print("discovered peripheral\(notification)");
        let bleManager = BleManager.sharedInstance
        let blePeripheralsFound = bleManager.blePeripherals()
        let filteredPeripherals =  bleManager.blePeripherals(); //peripheralList.filteredPeripherals(false)
       // print ("filtered count = \(filteredPeripherals.count,filteredPeripherals)");
        for var blePeripheral in filteredPeripherals {      // To avoid problems with peripherals disconnecting
            let localizationManager = LocalizationManager.sharedInstance
            
            var  name = blePeripheral.1.name ?? localizationManager.localizedString("peripherallist_unnamed")
            //print("peripheral name\(name)")
            
            if(name == "Adafruit Bluefruit LE"){
                print("found bluetooth")
                connectToPeripheral(notification.userInfo!["uuid"] as! String)
                //BleManager.sharedInstance.connect(blePeripheral.1)
                BleManager.sharedInstance.stopScan()
                
            }
            
        }
        
    }
    
    func connectToPeripheral(identifier: String?) {
        let bleManager = BleManager.sharedInstance
        
        if (identifier != bleManager.blePeripheralConnected?.peripheral.identifier.UUIDString || identifier == nil) {
            
            //
            let blePeripheralsFound = bleManager.blePeripherals()
            
            // Disconnect from previous
            //BleManager.sharedInstance.disconnect(blePeripheral)
            
            
            
            // Connect to new peripheral
            if let selectedBlePeripheralIdentifier = identifier {
                
                let blePeripheral = blePeripheralsFound[selectedBlePeripheralIdentifier]!
                if (BleManager.sharedInstance.blePeripheralConnected?.peripheral.identifier != selectedBlePeripheralIdentifier) {
                    // DLog("connect to new peripheral: \(selectedPeripheralIdentifier)")
                    
                    BleManager.sharedInstance.connect(blePeripheral)
                    
                    selectedPeripheralIdentifier = selectedBlePeripheralIdentifier
                }
            }
            else {
                //DLog("Peripheral selected row: -1")
                selectedPeripheralIdentifier = nil;
            }
        }
    }
    
    func sendMessage(text:String){
             uartData.sendMessageToUart(text)
        
    }

    
    
    @objc func willConnectToPeripheral(notification: NSNotification) {
        
        if let peripheral = BleManager.sharedInstance.blePeripheralConnecting {
            BleManager.sharedInstance.disconnect(peripheral)
        }
        else if let peripheral = BleManager.sharedInstance.blePeripheralConnected {
            BleManager.sharedInstance.disconnect(peripheral)
        }
        
    }
    
    @objc func didConnectToPeripheral(notification: NSNotification) {
        
        print("connection to bluetooth made");
        self.bluetoothEvent.raise(("connected"));
        if BleManager.sharedInstance.blePeripheralConnected != nil {
            
            
            uartData.blePeripheral = BleManager.sharedInstance.blePeripheralConnected       // Note: this will start the service discovery
            guard uartData.blePeripheral != nil else {
                print("Error: Uart: blePeripheral is nil")
                return
            }
            print("peripheral\( BleManager.sharedInstance.blePeripheralConnected?.name,BleManager.sharedInstance.blePeripheralConnected?.hasUart())");
            
            let blePeripheral = BleManager.sharedInstance.blePeripheralConnected!
            blePeripheral.peripheral.delegate = self
            
            // Notifications
            print("has uart? \(BleManager.sharedInstance.blePeripheralConnected?.hasUart())")
            
            let notificationCenter =  NSNotificationCenter.defaultCenter()
            if !uartData.isReady() {
                print ("unart not ready yet");
                notificationCenter.addObserver(self, selector: #selector(uartIsReady(_:)), name: UartManager.UartNotifications.DidBecomeReady.rawValue, object: nil)
            }
            else {
                // delegate?.onControllerUartIsReady()
                startUpdatingData()
            }
            
            
        }
        else {
            DLog("cancel push detail because peripheral was disconnected")
        }
        
        
    }
    
    @objc func uartIsReady(notification: NSNotification) {
        self.bluetoothEvent.raise(("ready"));

        print("Uart is ready")
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UartManager.UartNotifications.DidBecomeReady.rawValue, object: nil)
        
        //delegate?.onControllerUartIsReady()
        //startUpdatingData()
    }
    
    
    // MARK: -
    private func startUpdatingData() {
        let text = "foo bar"
        
        var newText = text
        // Eol
        if (Preferences.uartIsAutomaticEolEnabled)  {
            newText += "\n"
        }
        
        uartData.sendMessageToUart(newText)
        
        //pollTimer = MSWeakTimer.scheduledTimerWithTimeInterval(pollInterval, target: self, selector: #selector(updateSensors), userInfo: nil, repeats: true, dispatchQueue: dispatch_get_main_queue())
    }
    
    
    @objc func didUpdateBleState(notification: NSNotification?) {
        guard let state = BleManager.sharedInstance.centralManager?.state else {
            return
        }
        
        print("update\(notification)");
        
        // Check if there is any error
        var errorMessage: String?
        switch state {
        case .Unsupported:
            errorMessage = "This device doesn't support Bluetooth Low Energy"
        case .Unauthorized:
            errorMessage = "This app is not authorized to use the Bluetooth Low Energy"
        case.PoweredOff:
            errorMessage = "Bluetooth is currently powered off"
            
        default:
            errorMessage = nil
        }
        
        // Show alert if error found
       /* if let errorMessage = errorMessage {
            let localizationManager = LocalizationManager.sharedInstance
            let alertController = UIAlertController(title: localizationManager.localizedString("dialog_error"), message: errorMessage, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: localizationManager.localizedString("dialog_ok"), style: .Default, handler: { (_) -> Void in
                if let navController = self.splitViewController?.viewControllers[0] as? UINavigationController {
                    navController.popViewControllerAnimated(true)
                }
            })
            
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }*/
    }

    
    
    @objc func didDisconnectFromPeripheral(notification : NSNotification) {
        self.bluetoothEvent.raise(("disconnected"));

        
    }
     

    
    private func showPeripheralDisconnectedDialog() {
        
    
    }
    
    
}

// MARK: - UartModuleDelegate
extension BluetoothManager: UartModuleDelegate {
    
    func addChunkToUI(dataChunk : UartDataChunk) {
        // Check that the view has been initialized before updating UI
               
        let displayMode = Preferences.uartIsDisplayModeTimestamp ? UartModuleManager.DisplayMode.Table : UartModuleManager.DisplayMode.Text
        
        switch(displayMode) {
        case .Text:
            addChunkToUIText(dataChunk)
            //self.enh_throttledReloadData()      // it will call self.reloadData without overloading the main thread with calls
            
        case .Table:
            //self.enh_throttledReloadData()      // it will call self.reloadData without overloading //the main thread with calls
            break;

        }
        
        //updateBytesUI()
    }
    
    func reloadData() {
        let displayMode = Preferences.uartIsDisplayModeTimestamp ? UartModuleManager.DisplayMode.Table : UartModuleManager.DisplayMode.Text
        switch(displayMode) {
        case .Text:
            //baseTextView.attributedText = textCachedBuffer
            
            let textLength = textCachedBuffer.length
            if textLength > 0 {
                let range = NSMakeRange(textLength - 1, 1);
                //baseTextView.scrollRangeToVisible(range);
            }
            
        case .Table:
            //baseTableView.reloadData()
            if let tableCachedDataBuffer = tableCachedDataBuffer {
                if tableCachedDataBuffer.count > 0 {
                    let lastIndex = NSIndexPath(forRow: tableCachedDataBuffer.count-1, inSection: 0)
                    //baseTableView.scrollToRowAtIndexPath(lastIndex, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                }
            }
        }
    }
    
    func mqttUpdateStatusUI(){
        
    }

    
    private func addChunkToUIText(dataChunk : UartDataChunk) {
        
        /*if (Preferences.uartIsEchoEnabled || dataChunk.mode == .RX) {
         let color = dataChunk.mode == .TX ? txColor : rxColor
         
         if let attributedString = UartModuleManager.attributeTextFromData(dataChunk.data, useHexMode: Preferences.uartIsInHexMode, color: color, font: UartModuleViewController.dataFont) {
         textCachedBuffer.appendAttributedString(attributedString)
         }
         }*/
    }
    
        func mqttError(message: String, isConnectionError: Bool) {
        /*  let localizationManager = LocalizationManager.sharedInstance
         
         let alertMessage = isConnectionError ? localizationManager.localizedString("uart_mqtt_connectionerror_title"): message
         let alertController = UIAlertController(title: nil, message: alertMessage, preferredStyle: .Alert)
         
         let okAction = UIAlertAction(title: localizationManager.localizedString("dialog_ok"), style: .Default, handler:nil)
         alertController.addAction(okAction)
         self.presentViewController(alertController, animated: true, completion: nil)*/
    }
}

// MARK: - CBPeripheralDelegate
extension BluetoothManager: CBPeripheralDelegate {
    // Pass peripheral callbacks to UartData
    
    func peripheral(peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        uartData.peripheral(peripheral, didModifyServices: invalidatedServices)
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        uartData.peripheral(peripheral, didDiscoverServices:error)
    }
    
     func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        uartData.peripheral(peripheral, didDiscoverCharacteristicsForService: service, error: error)
        
        // Check if ready
        if uartData.isReady() {
            print ("ready");
            // Enable input
            /*   dispatch_async(dispatch_get_main_queue(), { [unowned self] in
             if self.inputTextField != nil {     // could be nil if the viewdidload has not been executed yet
             self.inputTextField.enabled = true
             self.inputTextField.backgroundColor = UIColor.whiteColor()
             }
             });*/
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        uartData.peripheral(peripheral, didUpdateValueForCharacteristic: characteristic, error: error)
    }

    
}
