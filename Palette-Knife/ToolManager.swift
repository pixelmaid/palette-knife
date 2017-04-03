//
//  ToolManager.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 11/25/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation


class ToolManager:UIViewController{
    
    static let lgPenDiameter = Float(10);
    static let smPenDiameter = Float(5);
    static let lgPenColor = Color(r:0,g:0,b:0,a:1);
    static let smPenColor = Color(r:144,g:215,b:240,a:1);
    static let defaultPenColor = Color(r:119,g:119,b:199,a:1);
    static let defaultPenDiameter = Float(2);
    static var defaultSelectedColor = Color(r:143,g:255,b:143,a:1);

    static let lgPenColorBake = Color(r:0,g:0,b:0,a:1);
    static let smPenColorBake = Color(r:144,g:215,b:240,a:1);
    
    static var mode = "draw";
    static var diameter = smPenDiameter;
    static var color = smPenColor;
    
    static var smPenXOffset = Float(0);
    static var lgPenXOffset = Float(0);
    
    //TODO  calculate actual offsets
    static var smPenYOffset =  Numerical.map(GCodeGenerator.rightOffset, istart:0, istop: GCodeGenerator.inY, ostart: 0, ostop: GCodeGenerator.pY)
    static var lgPenYOffset =  Numerical.map(GCodeGenerator.leftOffset, istart:0, istop: GCodeGenerator.inY, ostart: 0, ostop: GCodeGenerator.pY)
    
    static var bothActive = false;
    static var largeActive = false;
    static var smallActive = true;


   // var bluetoothManager = BluetoothManager();
    let bluetoothKey = NSUUID().UUIDString
    let toolbarKey = NSUUID().UUIDString
    
    static var brushEvent = Event<(String)>();
    
    private var selectedColor = UIColor(red:201.0/255,green:200.0/255,blue:191.0/255,alpha:1);
    
    private var standardColor = UIColor(red:104.0/255,green:104.0/255,blue:103.0/255,alpha:1);
    


    @IBOutlet weak var toolbarView: ToolbarView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var radialButton: UIButton!
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()

        //bluetoothManager.bluetoothEvent.addHandler(self,handler: ToolManager.bluetoothHandler, key:bluetoothKey)
        toolbarView.toolbarEvent.addHandler(self, handler: ToolManager.toolbarHandler, key: toolbarKey)
        
        drawButton.backgroundColor = selectedColor
        selectButton.backgroundColor = standardColor
        
       selectButton.addTarget(self, action: #selector(ToolManager.modeClicked(_:)), forControlEvents: .TouchUpInside)
         drawButton.addTarget(self, action: #selector(ToolManager.modeClicked(_:)), forControlEvents: .TouchUpInside)
             radialButton.addTarget(self, action: #selector(ToolManager.modeClicked(_:)), forControlEvents: .TouchUpInside)


    }
    
    
    func modeClicked(sender: AnyObject){
        if(sender as! NSObject == selectButton){
            ToolManager.mode = "select";
            selectButton.backgroundColor = selectedColor
            drawButton.backgroundColor = standardColor
            radialButton.backgroundColor = standardColor

        }
        else if(sender as! NSObject == drawButton){
            ToolManager.mode = "draw";
            drawButton.backgroundColor = selectedColor
            selectButton.backgroundColor = standardColor
            radialButton.backgroundColor = standardColor

            ToolManager.brushEvent.raise(("draw"));
        }
        
        else if(sender as! NSObject == radialButton){
            ToolManager.mode = "draw";
            radialButton.backgroundColor = selectedColor
            drawButton.backgroundColor = standardColor
            selectButton.backgroundColor = standardColor
            ToolManager.brushEvent.raise(("radial"));
        }
        
        
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
            if( ToolManager.smallActive == true &&  ToolManager.largeActive == false){
               // bluetoothManager.sendMessage("a");
            }
            else if( ToolManager.smallActive == false &&  ToolManager.largeActive == false){
                //bluetoothManager.sendMessage("e");

            }
            else if( ToolManager.smallActive == true &&  ToolManager.largeActive == true){
               // bluetoothManager.sendMessage("h");
               
            }

           ToolManager.largeActive = true;
            ToolManager.smallActive = false;
            ToolManager.bothActive = false;
            ToolManager.diameter = ToolManager.lgPenDiameter;
            ToolManager.color = ToolManager.lgPenColor;
           
            break;
            
        case "smallActive":
            
            if( ToolManager.smallActive == false &&  ToolManager.largeActive == true){
                //bluetoothManager.sendMessage("b");
            }
            else if( ToolManager.smallActive == false &&  ToolManager.largeActive == false){
                //bluetoothManager.sendMessage("f");
                
            }
            else if( ToolManager.smallActive == true &&  ToolManager.largeActive == true){
               // bluetoothManager.sendMessage("g");
                
            }
            ToolManager.largeActive = false;
            ToolManager.smallActive = true;
            ToolManager.bothActive = false;
            ToolManager.diameter = ToolManager.smPenDiameter;
            ToolManager.color = ToolManager.smPenColor;
            break;
    
        case "bothActive":
            if( ToolManager.smallActive == false &&  ToolManager.largeActive == true){
                //bluetoothManager.sendMessage("b");
            }
            else if( ToolManager.smallActive == false &&  ToolManager.largeActive == false){
                //bluetoothManager.sendMessage("c");
                
            }
            else if( ToolManager.smallActive == true &&  ToolManager.largeActive == false){
                //bluetoothManager.sendMessage("e");
                
            }
            
            ToolManager.largeActive = true;
            ToolManager.smallActive = true;
            ToolManager.bothActive = true;

            break;
        case "noneActive":
            
            if( ToolManager.smallActive == true &&  ToolManager.largeActive == true){
               // bluetoothManager.sendMessage("d");
            }
            else if( ToolManager.smallActive == false &&  ToolManager.largeActive == true){
              //  bluetoothManager.sendMessage("g");
                
            }
            else if( ToolManager.smallActive == true &&  ToolManager.largeActive == false){
               // bluetoothManager.sendMessage("h");
                
            }
            ToolManager.largeActive = false;
            ToolManager.smallActive = false;
            ToolManager.bothActive = false;
            
            break;
            
        default:
            break;
        }
        
        
        
    }
    
    
    
}
