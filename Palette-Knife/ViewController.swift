//
//  ViewController.swift
//  Palette-Knife
//
//  Created by JENNIFER MARY JACOBS on 5/4/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import UIKit
import MessageUI

let behaviorMapper = BehaviorMapper()
var stylus = Stylus(x: 0,y:0,angle:0,force:0)

class ViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    // MARK: Properties
    
    
    @IBOutlet weak var fabricatorView: FabricatorView!
    @IBOutlet weak var canvasView: CanvasView!
    //@IBOutlet weak var new_canvas: UIButton!
    //@IBOutlet weak var new_drawing: UIButton!
    @IBOutlet weak var clearAll: UIButton!
    //@IBOutlet weak var gcodeExport: UIButton!
    
    @IBOutlet weak var xOutput: UITextField!
    
    @IBOutlet weak var yOutput: UITextField!
    
    @IBOutlet weak var zOutput: UITextField!
    
    @IBOutlet weak var statusOutput: UITextField!
    
    var brushes = [String:Brush]()
    var socketManager = SocketManager();
    var currentCanvas: Canvas?
    let socketKey = NSUUID().UUIDString
    let drawKey = NSUUID().UUIDString
    
    override func viewDidLoad() {
        
        
        
        super.viewDidLoad()
        
        
        clearAll.addTarget(self, action: #selector(ViewController.clearClicked(_:)), forControlEvents: .TouchUpInside)
        
        
        //gcodeExport.addTarget(self, action: #selector(ViewController.gcodeExportClicked(_:)), forControlEvents: .TouchUpInside)
        
        
        
        socketManager.socketEvent.addHandler(self,handler: ViewController.socketHandler, key:socketKey)
        socketManager.connect();
        
        

        
    }
    
    //event handler for socket connections
    func socketHandler(data:(String,JSON?), key:String){
        switch(data.0){
        case "first_connection":
              self.initCanvas();
            //self.initStandardBrush();
            //self.initTestBrushes();
            //   self.initFractalBrush();
            //self.initBakeBrush();
            self.initDripBrush();
            break;
        case "disconnected":
            break;
        case "connected":
            break
        case "fabricator_data":
            let json = data.1! as JSON;
            let x = json["x"].stringValue;
            let y = json["y"].stringValue;
            
            let z = json["z"].stringValue;
            
            let status = json["status"].stringValue;
            
            self.xOutput.text = x;
            self.yOutput.text = y;
            self.zOutput.text = z;
            self.statusOutput.text = status;
            self.fabricatorView.drawFabricatorPosition(Float(x)!, y: Float(y)!, z: Float(z)!)
            
            GCodeGenerator.fabricatorX = Float(x);
            GCodeGenerator.fabricatorY = Float(y);
            GCodeGenerator.fabricatorZ = Float(z);
            GCodeGenerator.fabricatorStatus.set(Float(status)!);
            
            
            break;
        default:
            break
        }
        
    }
    
    
    func clearClicked(sender: AnyObject?) {
        canvasView.clear()
    }
    
    func gcodeExportClicked(sender: AnyObject?){
        let gcode = (currentCanvas?.currentDrawing?.getGcode())! as NSString;
        let gcode_data = gcode.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let svg = (currentCanvas?.currentDrawing?.getSVG())! as NSString;
        let svg_data = svg.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let mailComposeViewController = configuredMailComposeViewController()
        mailComposeViewController.addAttachmentData(gcode_data, mimeType:"sbp" , fileName: "drawing.sbp")
        
        mailComposeViewController.addAttachmentData(svg_data, mimeType:"svg" , fileName: "drawing.svg")
        
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["jenniferj.net@gmail.com"])
        mailComposerVC.setSubject("GCODE")
        mailComposerVC.setMessageBody("gcode", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    func newCanvasClicked(sender: AnyObject?){
        self.initCanvas();
    }
    
    func newDrawingClicked(sender: AnyObject){
        currentCanvas?.initDrawing();
    }
    
    func initCanvas(){
        currentCanvas = Canvas();
        socketManager.initAction(currentCanvas!,type:"canvas_init");
        //socketManager.initAction(stylus);
        currentCanvas!.initDrawing();
        currentCanvas!.geometryModified.addHandler(self,handler: ViewController.canvasDrawHandler, key:drawKey)
        
        
    }
    
    func initStandardTemplate(name:String)->BehaviorDefinition{
        let b = BehaviorDefinition(id:NSUUID().UUIDString, name:name)
        
        defaultSetup(b);
        
        b.addTransition(NSUUID().UUIDString, name:"stylusDownTransition", eventEmitter: stylus, parentFlag:false, event: "STYLUS_DOWN", fromStateName: "default", toStateName: "default", condition:nil)
        b.addTransition(NSUUID().UUIDString, name:"stylusUpTransition", eventEmitter: stylus, parentFlag:false, event: "STYLUS_UP", fromStateName: "default", toStateName: "default", condition:nil)
        
        b.addMethod("stylusDownTransition", methodId:NSUUID().UUIDString, targetMethod: "setOrigin", arguments: [stylus.position])
        b.addMethod("stylusDownTransition", methodId:NSUUID().UUIDString, targetMethod: "newStroke", arguments: nil)
        b.addMethod("stylusDownTransition", methodId:NSUUID().UUIDString, targetMethod: "startInterval", arguments: nil)
        b.addMethod("stylusUpTransition", methodId:NSUUID().UUIDString, targetMethod: "stopInterval", arguments: nil)
        
        
        b.addMapping(NSUUID().UUIDString, referenceProperty:stylus, referenceNames: ["dx"], relativePropertyName: "dx", targetState: "default")
        b.addMapping(NSUUID().UUIDString, referenceProperty:stylus, referenceNames: ["dy"], relativePropertyName: "dy", targetState: "default")
      // b.addMapping(NSUUID().UUIDString, referenceProperty:stylus, referenceNames: ["force"], relativePropertyName: "weight", targetState: "default")
        
        return b;
        
    }
    
    func initSpawnTemplate(name:String)->BehaviorDefinition{
        let b = BehaviorDefinition(id:NSUUID().UUIDString,name: name)
        defaultSetup(b);
        
        b.addMethod("setup", methodId:NSUUID().UUIDString, targetMethod: "newStroke", arguments:nil)
        b.addMethod("setup", methodId:NSUUID().UUIDString, targetMethod: "setOrigin", arguments: ["parent"])
        b.addMethod("setup", methodId: NSUUID().UUIDString, targetMethod: "startInterval", arguments: nil);
        return b;
    }
    
    
    func initDripBrush(){
        let dripBehavior = initSpawnTemplate("dripBehavior");
        
        dripBehavior.addLogiGrowthGenerator("weightGenerator", a:10,b:15,k:0.36);
        dripBehavior.addExpression("weightExpression", emitter1: nil, operand1Names:["weight"], emitter2: nil, operand2Names: ["weightGenerator"], type: "add")
        dripBehavior.addRandomGenerator("randomTimeGenerator", min:50, max: 100)
        dripBehavior.addCondition("lengthCondition", reference: nil, referenceNames: ["distance"], relative: nil, relativeNames: ["randomTimeGenerator"], relational: ">")
        dripBehavior.addState(NSUUID().UUIDString, stateName: "die");
        
        dripBehavior.addTransition(NSUUID().UUIDString, name: "tickTransition", eventEmitter: nil, parentFlag: false, event: "TICK", fromStateName: "default", toStateName: "default", condition: nil)
        dripBehavior.addMapping(NSUUID().UUIDString, referenceProperty: Observable<Float>(2), referenceNames: nil, relativePropertyName: "dy", targetState: "default")
        
      dripBehavior.addMapping(NSUUID().UUIDString, referenceProperty: nil, referenceNames: ["weightExpression"], relativePropertyName: "weight", targetState: "default")
 

        
        dripBehavior.addTransition(NSUUID().UUIDString, name: "dieTransition", eventEmitter: nil, parentFlag: false, event: "TICK", fromStateName: "default", toStateName: "die", condition: "lengthCondition")
        
        
        let parentBehavior = initStandardTemplate("parentBehavior");
        parentBehavior.addInterval("lengthInterval", inc: 100, times: nil)
        parentBehavior.addCondition("lengthCondition", reference: nil, referenceNames: ["distance"], relative: nil, relativeNames: ["lengthInterval"], relational: "within")
        parentBehavior.addTransition(NSUUID().UUIDString, name: "lengthTransition", eventEmitter: nil, parentFlag: false, event: "TICK", fromStateName: "default", toStateName: "default", condition: "lengthCondition")
        parentBehavior.addMethod("lengthTransition", methodId: NSUUID().UUIDString, targetMethod: "spawn", arguments: ["dripBehavior",dripBehavior,1]);
        
        self.socketManager.sendBehaviorData(parentBehavior.toJSON());
        self.socketManager.sendBehaviorData(dripBehavior.toJSON());
        
        let dripBrush = Brush(name:"parentBehavior",behaviorDef: parentBehavior, parent:nil, canvas:self.currentCanvas!)
        
        socketManager.initAction(dripBrush,type:"brush_init");
        
    }
    
    
    func initBakeBrush(){
        let b1 = initStandardTemplate("b1");
        
        
        b1.addTransition(NSUUID().UUIDString, name:"stylusUpT", eventEmitter: stylus, parentFlag:false, event: "STYLUS_UP", fromStateName: "default", toStateName: "default", condition:nil)
        
        
        b1.addMethod("stylusUpT", methodId:NSUUID().UUIDString, targetMethod: "bake", arguments: nil)
        b1.addMethod("stylusUpT", methodId:NSUUID().UUIDString, targetMethod: "liftUp", arguments: nil)
        
        b1.addMethod("stylusDownT",methodId:NSUUID().UUIDString,targetMethod: "jogTo", arguments: [stylus.position])
        
        let b1_brush = Brush(name:"b1",behaviorDef: b1, parent:nil, canvas:self.currentCanvas!)
        
        
        self.socketManager.sendBehaviorData(b1.toJSON());
        
        socketManager.initAction(b1_brush,type:"brush_init");
        
        
        
    }
    
    /*func initDripBrush(){
     let b1 = initStandardTemplate("b1");
     
     b1.addInterval("timeInterval",inc:1,times:nil)
     b1.addTransition(NSUUID().UUIDString, name:"spawnTransition", eventEmitter: stylus, parentFlag:false, event: "TICK", fromStateName: "default", toStateName: "default", condition:"nil")
     
     var b2 = initSpawnTemplate("b2");
     
     let b1_brush = Brush(name:"b1",behaviorDef: b1, parent:nil, canvas:self.currentCanvas!)
     
     
     self.socketManager.sendBehaviorData(b1.toJSON());
     self.socketManager.sendBehaviorData(b2.toJSON());
     
     socketManager.initAction(b1_brush,type:"brush_init");
     
     }*/
    
    func initFractalBrush(){
        
        let branchBehavior = BehaviorDefinition(id:NSUUID().UUIDString,name:"branch")
        defaultSetup(branchBehavior);
        
        
        branchBehavior.addRandomGenerator("random1", min: 2 , max: 5)
        branchBehavior.addState(NSUUID().UUIDString,stateName:"spawnEnd");
        
        
        branchBehavior.addCondition("spawnCondition", reference: nil, referenceNames: ["ancestors"], relative: Observable<Float>(2), relativeNames: nil, relational: "<")
        branchBehavior.addCondition("noSpawnCondition", reference: nil, referenceNames: ["ancestors"], relative: Observable<Float>(1), relativeNames: nil, relational: ">")
        
        
        branchBehavior.addState(NSUUID().UUIDString,stateName: "die");
        
        branchBehavior.addCondition("timeLimitCondition", reference: nil, referenceNames: ["time"], relative: nil, relativeNames: ["random1"], relational: ">")
        
        branchBehavior.addCondition("offCanvasCondition", reference: nil, referenceNames: ["offCanvas"], relative: Observable<Float>(1), relativeNames: nil, relational: "==")
        
        
        branchBehavior.addTransition(NSUUID().UUIDString, name: "destroyTransition", eventEmitter: nil, parentFlag: false, event: "TICK", fromStateName: "default", toStateName: "die", condition: "timeLimitCondition")
        
        branchBehavior.addTransition(NSUUID().UUIDString, name: "offCanvasTransition", eventEmitter: nil, parentFlag: false, event: "STATE_COMPLETE", fromStateName: "default", toStateName: "die", condition: "offCanvasCondition")
        
        branchBehavior.addMethod("destroyTransition",methodId:NSUUID().UUIDString,targetMethod: "jogAndBake", arguments: nil)
        branchBehavior.addMethod("offCanvasTransition",methodId:NSUUID().UUIDString,targetMethod: "jogAndBake", arguments: nil)
        
        
        // branchBehavior.addMethod("destroyTransition", methodId: NSUUID().UUIDString, targetMethod: "destroy", arguments: nil)
        
        // branchBehavior.addMethod("defaultdestroyTransition", methodId: NSUUID().UUIDString, targetMethod: "destroy", arguments: nil)
        
        
        branchBehavior.addTransition(NSUUID().UUIDString, name:"spawnTransition" , eventEmitter: nil, parentFlag: false, event: "STATE_COMPLETE", fromStateName: "die", toStateName: "spawnEnd", condition: "spawnCondition")
        
        // branchBehavior.addMethod("spawnTransition", methodId: NSUUID().UUIDString, targetMethod: "spawn", arguments: ["branchBehavior",branchBehavior,2])
        
        branchBehavior.addMethod("setup", methodId:NSUUID().UUIDString, targetMethod: "newStroke", arguments:nil)
        branchBehavior.addMethod("setup", methodId:NSUUID().UUIDString, targetMethod: "setOrigin", arguments: ["parent"])
        branchBehavior.addMethod("setup", methodId:NSUUID().UUIDString, targetMethod: "startInterval", arguments:nil)
        branchBehavior.addMethod("spawnEnd",  methodId:NSUUID().UUIDString, targetMethod: "destroy", arguments:nil)
        
        branchBehavior.addExpression("xDeltaExp", emitter1: nil, operand1Names: ["parent","currentStroke","xBuffer"],emitter2: Observable<Float>(0.65), operand2Names: nil, type: "mult")
        
        
        branchBehavior.addExpression("yDeltaExp", emitter1: nil, operand1Names: ["parent","currentStroke","yBuffer"], emitter2: Observable<Float>(0.65), operand2Names: nil, type: "mult")
        
        branchBehavior.addExpression("weightDeltaExp", emitter1: nil, operand1Names: ["parent","currentStroke","weightBuffer"],  emitter2: Observable<Float>(0.45), operand2Names: nil,type: "mult")
        
        
        branchBehavior.addMapping(NSUUID().UUIDString, referenceProperty:nil, referenceNames: ["xDeltaExp"], relativePropertyName: "dx", targetState: "default")
        branchBehavior.addMapping(NSUUID().UUIDString, referenceProperty:nil, referenceNames: ["yDeltaExp"], relativePropertyName: "dy", targetState: "default")
        
        branchBehavior.addMapping(NSUUID().UUIDString, referenceProperty:nil, referenceNames:["weightDeltaExp"], relativePropertyName: "weight", targetState: "default")
        
        
        branchBehavior.addTransition(NSUUID().UUIDString, name: "tickTransition", eventEmitter: nil, parentFlag: false, event: "TICK", fromStateName: "default", toStateName: "default", condition: nil)
        
        
        let rootBehavior = BehaviorDefinition(id:NSUUID().UUIDString,name:"root");
        defaultSetup(rootBehavior);
        
        rootBehavior.addInterval("timeInterval",inc:1,times:nil)
        
        
        rootBehavior.addCondition("stylusDownCondition", reference:stylus, referenceNames: ["penDown"], relative:Observable<Float>(1), relativeNames:nil, relational: "==")
        
        rootBehavior.addCondition("incrementCondition", reference: nil, referenceNames: ["time"], relative:nil, relativeNames: ["timeInterval"], relational: "within")
        
        rootBehavior.addCondition("stylusANDIncrement",reference: nil, referenceNames: ["stylusDownCondition"], relative:nil, relativeNames: ["incrementCondition"], relational: "&&");
        
        rootBehavior.addTransition(NSUUID().UUIDString, name:"stylusDownT", eventEmitter: stylus, parentFlag:false, event: "STYLUS_DOWN", fromStateName: "default", toStateName: "default", condition:nil)
        
        rootBehavior.addMethod("stylusDownT", methodId:NSUUID().UUIDString, targetMethod: "setOrigin", arguments: [stylus.position])
        rootBehavior.addMethod("stylusDownT", methodId:NSUUID().UUIDString, targetMethod: "newStroke", arguments: nil)
        rootBehavior.addMethod("stylusDownT", methodId:NSUUID().UUIDString, targetMethod: "startInterval", arguments: nil)
        
        rootBehavior.addMapping(NSUUID().UUIDString, referenceProperty:stylus, referenceNames: ["dx"], relativePropertyName: "dx", targetState: "default")
        
        rootBehavior.addMapping(NSUUID().UUIDString, referenceProperty:stylus,  referenceNames: ["dy"], relativePropertyName: "dy", targetState: "default")
        
        rootBehavior.addMapping(NSUUID().UUIDString, referenceProperty:stylus,  referenceNames: ["force"], relativePropertyName: "weight", targetState: "default")
        
        
        rootBehavior.addTransition(NSUUID().UUIDString, name: "spawnTransition", eventEmitter: nil, parentFlag: false, event: "TICK", fromStateName: "default", toStateName: "default", condition: "stylusANDIncrement")
        rootBehavior.addTransition(NSUUID().UUIDString, name:"stylusUpT", eventEmitter: stylus, parentFlag:false, event: "STYLUS_UP", fromStateName: "default", toStateName: "default", condition:nil)
        
        rootBehavior.addMethod("spawnTransition", methodId: NSUUID().UUIDString, targetMethod: "spawn", arguments: ["branchBehavior",branchBehavior,2])
        
        //rootBehavior.addMethod("stylusUpT", methodId:NSUUID().UUIDString, targetMethod: "bake", arguments: nil)
        rootBehavior.addMethod("stylusUpT", methodId:NSUUID().UUIDString, targetMethod: "jogAndBake", arguments: nil)
        
        //  rootBehavior.addMethod("stylusDownT",methodId:NSUUID().UUIDString,targetMethod: "jogTo", arguments: nil)
        
        let rootBehaviorBrush = Brush(name:"rootBehaviorBrush",behaviorDef: rootBehavior, parent:nil, canvas:self.currentCanvas!)
        
        rootBehaviorBrush.strokeColor.b = 255;
        
        self.socketManager.sendBehaviorData(branchBehavior.toJSON());
        self.socketManager.sendBehaviorData(rootBehavior.toJSON());
        
        socketManager.initAction(rootBehaviorBrush,type:"brush_init");
        
        
    }
    
    func defaultSetup(behavior:BehaviorDefinition){
        
        behavior.addState(NSUUID().UUIDString,stateName:"start")
        behavior.addState(NSUUID().UUIDString,stateName:"default")
        
        behavior.addTransition(NSUUID().UUIDString, name: "setup", eventEmitter: nil, parentFlag: false, event: "STATE_COMPLETE", fromStateName: "start", toStateName:"default", condition: nil)
        
    }
    
    func initTestBrushes(){
        let num = 60
        
        let falseConstant = Observable<Float>(0)
        let angleRange = Range(min: 0, max: num, start: -4, stop: 0)
        let reflectConstant = Observable<Float>(1)
        reflectConstant.name = "reflectConstant";
        let b2 = BehaviorDefinition(id:NSUUID().UUIDString,name:"b2")
        
        //start state should be invisible to user
        b2.addState(NSUUID().UUIDString,stateName:"start")
        b2.addState(NSUUID().UUIDString,stateName:"default")
        b2.addState(NSUUID().UUIDString,stateName:"delay")
        b2.addState(NSUUID().UUIDString,stateName:"grow")
        b2.addState(NSUUID().UUIDString,stateName:"spawn")
        b2.addState(NSUUID().UUIDString,stateName:"die")
        b2.addState(NSUUID().UUIDString,stateName:"reflect")
        
        b2.addTransition(NSUUID().UUIDString, name: "setup", eventEmitter: nil, parentFlag: false, event: "STATE_COMPLETE", fromStateName: "start", toStateName:"default", condition: nil)
        
        b2.addInterval("timeInterval",inc:0.005,times:nil)
        
        b2.addMethod("setup", methodId:NSUUID().UUIDString, targetMethod: "newStroke", arguments: nil)
        b2.addMapping(NSUUID().UUIDString, referenceProperty:nil, referenceNames: ["parent","ox"], relativePropertyName: "ox", targetState: "default")
        b2.addMapping(NSUUID().UUIDString, referenceProperty:nil, referenceNames: ["parent","oy"], relativePropertyName: "oy", targetState: "default")
        b2.addMapping(NSUUID().UUIDString, referenceProperty:nil, referenceNames: ["parent","ox"], relativePropertyName: "x", targetState: "default")
        b2.addMapping(NSUUID().UUIDString, referenceProperty:nil, referenceNames: ["parent","oy"], relativePropertyName: "y", targetState: "default")
        
        
        
        b2.addCondition("indexCondition", reference: angleRange, referenceNames: ["index"], relative: Observable<Float>(Float(num/2)), relativeNames: nil, relational: "==")
        
        b2.addTransition(NSUUID().UUIDString, name:"defaultDelayTransition", eventEmitter: nil, parentFlag:false, event:"STATE_COMPLETE", fromStateName: "default", toStateName: "delay", condition: nil)
        
        b2.addTransition(NSUUID().UUIDString, name:"reflectTransition", eventEmitter: nil, parentFlag:false, event:"STATE_COMPLETE", fromStateName: "default", toStateName: "reflect", condition: "indexCondition")
        
        
        b2.addMapping(NSUUID().UUIDString, referenceProperty:reflectConstant, referenceNames: nil, relativePropertyName: "reflectX", targetState: "default")
        
        b2.addTransition(NSUUID().UUIDString, name:"reflectEndTransition", eventEmitter: nil, parentFlag:false, event:
            "STATE_COMPLETE", fromStateName: "reflect", toStateName: "default", condition: nil)
        
        b2.addIncrement("angleIncrememt", inc:angleRange, start:Observable<Float>(-1))
        
        b2.addMapping(NSUUID().UUIDString, referenceProperty:nil, referenceNames: ["parent","xBuffer"], relativePropertyName: "dx", targetState: "grow")
        b2.addMapping(NSUUID().UUIDString, referenceProperty:nil, referenceNames: ["parent","yBuffer"], relativePropertyName: "dy", targetState: "grow")
        // b2.addMapping(NSUUID().UUIDString, referenceProperty:nil, referenceName: "weightBuffer", parentFlag: true, relativePropertyName: "weight", targetState: "grow")
        
        b2.addMapping(NSUUID().UUIDString, referenceProperty:nil, referenceNames: ["angleIncrememt"], relativePropertyName: "angle", targetState: "grow")
        
        b2.addCondition("incrementCondition", reference: nil, referenceNames: ["time"], relative:nil, relativeNames: ["timeInterval"], relational: "within")
        
        b2.addTransition(NSUUID().UUIDString, name:"intervalTransition", eventEmitter: nil, parentFlag:false, event:
            "TICK", fromStateName: "delay", toStateName: "grow", condition: "incrementCondition")
        
        b2.addCondition("growCompleteCondition", reference: nil, referenceNames: ["parent","bufferLimitX"], relative: falseConstant, relativeNames:nil, relational: "==")
        
        b2.addCondition("growSpawnCondition", reference: nil, referenceNames: ["parent","bufferLimitX"], relative: falseConstant, relativeNames:nil, relational: "!=")
        
        b2.addCondition("limitCondition", reference: angleRange, referenceNames: ["index"], relative: Observable<Float>(Float(num-1)), relativeNames: nil, relational: "<")
        
        b2.addTransition(NSUUID().UUIDString, name:"growEndTransition", eventEmitter: nil, parentFlag:false, event:
            "STATE_COMPLETE", fromStateName: "grow", toStateName: "delay", condition: "growCompleteCondition")
        
        b2.addTransition(NSUUID().UUIDString, name:"startSpawnTransition", eventEmitter: nil, parentFlag:false, event:
            "STATE_COMPLETE", fromStateName: "grow", toStateName: "spawn", condition: "limitCondition")
        
        b2.addTransition(NSUUID().UUIDString, name:"growSpawnTransition", eventEmitter: nil, parentFlag:false, event:
            "STATE_COMPLETE", fromStateName: "spawn", toStateName: "die", condition: "growSpawnCondition")
        
        
        b2.addMethod("growSpawnTransition", methodId:NSUUID().UUIDString, targetMethod: "spawn", arguments: ["b3",b2,1])
        b2.addMethod("growSpawnTransition", methodId:NSUUID().UUIDString, targetMethod: "destroy", arguments: nil)
        
        self.socketManager.sendBehaviorData(b2.toJSON());
        
        
        let b1 = BehaviorDefinition(id:NSUUID().UUIDString, name:"b1")
        
        b1.addState(NSUUID().UUIDString,stateName:"start")
        b1.addState(NSUUID().UUIDString,stateName:"default")
        
        b1.addTransition(NSUUID().UUIDString, name: "setup", eventEmitter: nil, parentFlag: false, event: "STATE_COMPLETE", fromStateName: "start", toStateName:"default", condition: nil)
        
        b1.addTransition(NSUUID().UUIDString, name:"stylusDownT", eventEmitter: stylus, parentFlag:false, event: "STYLUS_DOWN", fromStateName: "default", toStateName: "default", condition:nil)
        b1.addMethod("stylusDownT", methodId:NSUUID().UUIDString, targetMethod: "setOrigin", arguments: [stylus.position])
        b1.addMethod("stylusDownT", methodId:NSUUID().UUIDString, targetMethod: "newStroke", arguments: nil)
        
        b1.addMapping(NSUUID().UUIDString, referenceProperty:stylus, referenceNames: ["dx"], relativePropertyName: "dx", targetState: "default")
        b1.addMapping(NSUUID().UUIDString, referenceProperty:stylus, referenceNames: ["dy"], relativePropertyName: "dy", targetState: "default")
        //   b1.addMapping(NSUUID().UUIDString, referenceProperty:stylus, referenceName: "force", parentFlag: false, relativePropertyName: "weight", targetState: "default")
        
        b1.addTransition(NSUUID().UUIDString, name:"stylusUpT", eventEmitter: stylus, parentFlag:false, event: "STYLUS_UP", fromStateName: "default", toStateName: "default", condition:nil)
        
        
        b1.addMethod("stylusUpT", methodId:NSUUID().UUIDString, targetMethod: "spawn", arguments: ["b2",b2,1])
        
        self.socketManager.sendBehaviorData(b1.toJSON());
        
        
        let b1_brush = Brush(name:"b1",behaviorDef: b1, parent:nil, canvas:self.currentCanvas!)
    }
    
    
    
    func canvasDrawHandler(data:(Geometry,String,String), key:String){
        switch data.2{
        case "DRAW":
            switch data.1{
            case "SEGMENT":
                let seg = data.0 as! Segment
                
                let prevSeg = seg.getPreviousSegment()
                
                if(prevSeg != nil){
                    canvasView.drawPath(prevSeg!.point,tP: seg.point, w:seg.diameter, c:seg.color)
                }
                
                break
                /*case "ARC":
                 let arc = data.0 as! Arc
                 canvasView.drawArc(arc.center, radius: arc.radius, startAngle: arc.startAngle, endAngle: arc.endAngle, w: 10, c: Color(r:0,g:0,b:0))
                 break*/
                
            case "LINE":
                let line = data.0 as! Line
                
                canvasView.drawPath(line.p, tP:line.v, w: 10, c: Color(r:0,g:0,b:0))
                break
                
            case "LEAF":
                let leaf = data.0 as! StoredDrawing
                
                canvasView.drawLeaf(leaf.position, angle:leaf.angle, scale:leaf.scaling.x.get(nil))
                break
                
            case "FLOWER":
                let flower = data.0 as! StoredDrawing
                canvasView.drawFlower(flower.position)
                
                break
                
            case "POLYGON":
                //canvasView.drawPath(stylus.prevPosition, tP:stylus.position, w:10, c:Color(r:0,g:0,b:0))
                break
            default:
                break
                
            }
            break
        case "DELETE":
            
            break
        default : break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first  {
            
            _ = touch.locationInView(view);
            let force = Float(touch.force);
            let angle = Float(touch.azimuthAngleInView(view))
            stylus.onStylusUp()
            // socketManager.sendStylusData(force, position: stylus.position, angle: angle, delta: stylus.position.sub(stylus.prevPosition),penDown:stylus.penDown)
            //socketManager.sendStylusData();
            
        }
        
    }
    
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first  {
            let point = touch.locationInView(view)
            let x = Float(point.x)
            let y = Float(point.y)
            ;
            let force = Float(touch.force);
            let angle = Float(touch.azimuthAngleInView(view))
            stylus.onStylusDown(x, y:y, force:force, angle:angle)
            // socketManager.sendStylusData(force, position: stylus.position, angle: angle, delta: stylus.position.sub(stylus.prevPosition),penDown:stylus.penDown)
            // socketManager.sendStylusData();
            
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first  {
            
            let point = touch.locationInView(view);
            let x = Float(point.x)
            let y = Float(point.y)
            let force = Float(touch.force);
            let angle = Float(touch.azimuthAngleInView(view))
            stylus.onStylusMove(x, y:y, force:force, angle:angle)
            // socketManager.sendStylusData(force, position: stylus.position, angle: angle, delta: stylus.position.sub(stylus.prevPosition),penDown:stylus.penDown)
            // socketManager.sendStylusData();
        }
    }
    
    
    
    
}
