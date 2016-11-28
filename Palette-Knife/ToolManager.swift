//
//  ToolManager.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 11/25/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation


class ToolManager:UIViewController{
    
    static let lgPenDiameter = Float(20);
    static let smPenDiameter = Float(10);
    static let lgPenColor = Color(r:0,g:0,b:0);
    static let smPenColor = Color(r:144,g:215,b:240);
    
    
    static var diameter = lgPenDiameter;
    static var color = smPenColor;
    
    static var smPenXOffset = Float(0);
    static var lgPenXOffset = Float(0);
    
    //TODO  calculate actual offsets
    static var smPenYOffset = Float(10);
    static var lgPenYOffset = Float(-10);
    
    static var bothActive = false;

    var bluetoothManager = BluetoothManager();
    let bluetoothKey = NSUUID().UUIDString
    let toolbarKey = NSUUID().UUIDString

    @IBOutlet weak var toolbarView: ToolbarView!
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()

        bluetoothManager.bluetoothEvent.addHandler(self,handler: ToolManager.bluetoothHandler, key:bluetoothKey)

        toolbarView.toolbarEvent.addHandler(self, handler: ToolManager.toolbarHandler, key: toolbarKey)

    }
    
    
    //event handler for bluetooth status
    func bluetoothHandler(data:(String),key:String){
        print("bluetooth event triggered \(data)");
        switch(data){
        case "ready":
            toolbarView.enableButtons();
            break;
            
        case "disconnected":
            break;
            
        case "connected":
            
            break;
            
        default:
            break;
            
        }
        
    }

    
    
    func toolbarHandler(data:(String),key:String){
        switch(data){
        case "largeActive":
            ToolManager.bothActive = false;
            ToolManager.diameter = ToolManager.lgPenDiameter;
            ToolManager.color = ToolManager.lgPenColor;
            bluetoothManager.sendMessage("a");
            break;
            
        case "smallActive":
            ToolManager.bothActive = false;
            ToolManager.diameter = ToolManager.smPenDiameter;
            ToolManager.color = ToolManager.smPenColor;
            bluetoothManager.sendMessage("b");
            break;
    
        case "bothActive":
            ToolManager.bothActive = true;
            bluetoothManager.sendMessage("c");

            break;
        case "noneActive":
            ToolManager.bothActive = false;
            bluetoothManager.sendMessage("d");
            
            break;
            
        default:
            break;
        }
        
        
        
    }
    
    
    
}
