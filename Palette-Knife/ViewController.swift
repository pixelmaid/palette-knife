//
//  ViewController.swift
//  Palette-Knife
//
//  Created by JENNIFER MARY JACOBS on 5/4/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import UIKit

let behaviorMapper = BehaviorMapper()
var stylus = Stylus(x: 0,y:0,angle:0,force:0)

class ViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var dualBrushButton: UIButton!
    @IBOutlet weak var largeBrushButton: UIButton!
    @IBOutlet weak var smallBrushButton: UIButton!
    var canvasViewSm:CanvasView
    var canvasViewLg:CanvasView
    var bakeViewSm:CanvasView
    
    var bakeViewLg:CanvasView
    var backView:UIImageView
    var fabricatorView = FabricatorView();
    // var canvasViewBakeSm:CanvasView;
    // var canvasViewBakeLg:CanvasView;
    
    
    @IBOutlet weak var xOutput: UITextField!
    
    @IBOutlet weak var yOutput: UITextField!
    
    @IBOutlet weak var zOutput: UITextField!
    
    @IBOutlet weak var statusOutput: UITextField!
    
    
    
    var brushes = [String:Brush]()
    var socketManager = SocketManager();
    var currentCanvas: Canvas?
    let socketKey = NSUUID().UUIDString
    let drawKey = NSUUID().UUIDString
    let brushEventKey = NSUUID().UUIDString

    
    var downInCanvas = false;
    
    var radialBrush:Brush?
    var bakeBrush:Brush?
    
    required init?(coder: NSCoder) {
       
        
        
        
        let screenSize = UIScreen.mainScreen().bounds
        let sX = (screenSize.width-CGFloat(GCodeGenerator.pX))/2.0
        let sY = (screenSize.height-CGFloat(GCodeGenerator.pY))/2.0
        
        GCodeGenerator.setCanvasOffset(Float(sX),y:Float(sY));
         canvasViewSm = CanvasView(frame: CGRectMake(sX, sY, CGFloat(GCodeGenerator.pX), CGFloat(GCodeGenerator.pY)))
        
         canvasViewLg = CanvasView(frame: CGRectMake(sX, sY, CGFloat(GCodeGenerator.pX), CGFloat(GCodeGenerator.pY)))
        
        bakeViewSm = CanvasView(frame: CGRectMake(sX, sY, CGFloat(GCodeGenerator.pX), CGFloat(GCodeGenerator.pY)))
        
         bakeViewLg = CanvasView(frame: CGRectMake(sX, sY, CGFloat(GCodeGenerator.pX), CGFloat(GCodeGenerator.pY)))
         backView = UIImageView(frame: CGRectMake(sX, sY, CGFloat(GCodeGenerator.pX), CGFloat(GCodeGenerator.pY)))
 
        
        super.init(coder: coder);
        
    }
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
              socketManager.socketEvent.addHandler(self,handler: ViewController.socketHandler, key:socketKey)
        //toolbarView.toolbarEvent.addHandler(self,handler:ViewController.)
        socketManager.connect();
        
        ToolManager.brushEvent.addHandler(self,handler:ViewController.brushToggleHandler,key:brushEventKey);

        
        canvasViewSm.backgroundColor=UIColor.whiteColor()
        self.view.addSubview(canvasViewSm)
        
        canvasViewLg.backgroundColor=UIColor.clearColor()
        self.view.addSubview(canvasViewLg)
        
        
        bakeViewLg.backgroundColor=UIColor.clearColor()
        self.view.addSubview(bakeViewLg)
        
        bakeViewSm.backgroundColor=UIColor.clearColor()
        self.view.addSubview(bakeViewSm)
        
        backView.backgroundColor=UIColor.whiteColor()
        self.view.addSubview(backView)
        
        fabricatorView.frame = CGRectMake(0, 0, CGFloat(GCodeGenerator.pX), CGFloat(GCodeGenerator.pY));
        fabricatorView.backgroundColor = UIColor.clearColor();
        self.view.addSubview(fabricatorView);
        self.view.sendSubviewToBack(fabricatorView)
        self.view.sendSubviewToBack(bakeViewLg)
        self.view.sendSubviewToBack(bakeViewSm)

        self.view.sendSubviewToBack(canvasViewLg)
        self.view.sendSubviewToBack(canvasViewSm)
        self.view.sendSubviewToBack(backView)

        canvasViewLg.alpha = 0.25;
        canvasViewSm.alpha = 0.25;
        
        
        self.fabricatorView.drawFabricatorPosition(Float(0), y: Float(0), z: Float(0))
        self.initCanvas()
        self.initRadialBrush();
        self.initBakeBrush();

        radialBrush?.active = false;
        
        
    }
    
    
    func brushToggleHandler(data:(String),key:String){
        switch(data){
            case "draw":
                radialBrush!.active = false;
                bakeBrush!.active = true;
                break;
        case "radial":
            radialBrush!.active = true;
            bakeBrush!.active = false;

            break;
        default:
            break;
        }
    }
    
    
    //event handler for socket connections
    func socketHandler(data:(String,JSON?), key:String){
        switch(data.0){
        case "first_connection":
            //self.initCanvas();
            //self.initStandardBrush();
            //self.initTestBrushes();
               //self.initFractalBrush();
            //self.initBakeBrush();
            //self.initRadialBrush();
            
            //self.initDripBrush();
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
            
            let _x = Numerical.map(Float(x)!, istart:0, istop: GCodeGenerator.inX, ostart: 0, ostop: GCodeGenerator.pX)
            
            let _y = Numerical.map(Float(y)!, istart:0, istop:GCodeGenerator.inY, ostart:  GCodeGenerator.pY, ostop: 0 )
            var _z = Numerical.map(Float(z)!, istart: 0.2, istop: GCodeGenerator.depthLimit, ostart: 0.2, ostop: 42)


            if(Float(status)! == 33 && Float(z) <= 0){
                currentCanvas?.currentDrawing!.checkBake(_x,y:_y,z:_z);
            }
            
            break;
        default:
            break
        }
        
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
        //b1.addMethod("stylusUpT", methodId:NSUUID().UUIDString, targetMethod: "liftUp", arguments: nil)
        
        b1.addMethod("stylusDownTransition",methodId:NSUUID().UUIDString,targetMethod: "jogTo", arguments: [stylus.position])
        
        bakeBrush = Brush(name:"b1",behaviorDef: b1, parent:nil, canvas:self.currentCanvas!)
        
        
        self.socketManager.sendBehaviorData(b1.toJSON());
        
        socketManager.initAction(bakeBrush!,type:"brush_init");
        
        
        
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
    
    func initRadialBrush(){
       
        let radial_spawnBehavior = initSpawnTemplate("radial_spawn_behavior");
       radial_spawnBehavior.addExpression("angle_expression", emitter1: nil, operand1Names: ["index"], emitter2: Observable<Float>(60), operand2Names: nil, type: "mult")
        
        radial_spawnBehavior.addMapping(NSUUID().UUIDString, referenceProperty: nil, referenceNames: ["angle_expression"], relativePropertyName: "angle", targetState: "start")
        
        radial_spawnBehavior.addMapping(NSUUID().UUIDString, referenceProperty:stylus, referenceNames: ["dx"], relativePropertyName: "dx", targetState: "default")
        radial_spawnBehavior.addMapping(NSUUID().UUIDString, referenceProperty:stylus, referenceNames: ["dy"], relativePropertyName: "dy", targetState: "default")
        
        
        radial_spawnBehavior.addState(NSUUID().UUIDString,stateName:"die")

       radial_spawnBehavior.addTransition(NSUUID().UUIDString, name: "dieTransition", eventEmitter: stylus, parentFlag: false, event: "STYLUS_UP", fromStateName: "default", toStateName: "die", condition: nil)
        
          radial_spawnBehavior.addMethod("dieTransition", methodId:NSUUID().UUIDString, targetMethod: "jogAndBake", arguments: nil)

        let radial_behavior = BehaviorDefinition(id:NSUUID().UUIDString, name:"radial_behavior")
        
        
        defaultSetup(radial_behavior);
        
        radial_behavior.addTransition(NSUUID().UUIDString, name:"stylusDownTransition", eventEmitter: stylus, parentFlag:false, event: "STYLUS_DOWN", fromStateName: "default", toStateName: "default", condition:nil)
        radial_behavior.addTransition(NSUUID().UUIDString, name:"stylusUpTransition", eventEmitter: stylus, parentFlag:false, event: "STYLUS_UP", fromStateName: "default", toStateName: "default", condition:nil)
        
        radial_behavior.addMethod("stylusDownTransition", methodId:NSUUID().UUIDString, targetMethod: "setOrigin", arguments: [stylus.position])
        radial_behavior.addMethod("stylusDownTransition", methodId:NSUUID().UUIDString, targetMethod: "startInterval", arguments: nil)
        radial_behavior.addMethod("stylusUpTransition", methodId:NSUUID().UUIDString, targetMethod: "stopInterval", arguments: nil)
        
        
        
        
        radial_behavior.addMethod("stylusDownTransition", methodId:NSUUID().UUIDString, targetMethod: "spawn", arguments: ["radial_spawn_behavior",radial_spawnBehavior,6])
         radial_behavior.addMethod("stylusDownTransition",methodId:NSUUID().UUIDString,targetMethod: "jogTo", arguments: [stylus.position])
        radialBrush = Brush(name:"radial",behaviorDef: radial_behavior, parent:nil, canvas:self.currentCanvas!)
        
        self.socketManager.sendBehaviorData(radial_behavior.toJSON());
        
        socketManager.initAction(radialBrush!,type:"brush_init");


    }
    
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
            
        case "BAKE_DRAW":
            switch data.1{
            case "SEGMENT":
                
                let seg = data.0 as! Segment
                
                let prevSeg = seg.getPreviousSegment()
                
                if(prevSeg != nil){
                    
                    if(ToolManager.bothActive){
                        bakeViewLg.drawPath(prevSeg!.point.add(Point(x:ToolManager.lgPenXOffset,y:ToolManager.lgPenYOffset)),tP: seg.point.add(Point(x:ToolManager.lgPenXOffset,y:ToolManager.lgPenYOffset)), w:ToolManager.lgPenDiameter, c:ToolManager.lgPenColor)
                        bakeViewSm.drawPath(prevSeg!.point.add(Point(x:ToolManager.smPenXOffset,y:ToolManager.smPenYOffset)),tP: seg.point.add(Point(x:ToolManager.smPenXOffset,y:ToolManager.smPenYOffset)), w:ToolManager.smPenDiameter, c:ToolManager.smPenColor)
                        
                    }
                    else{
                        if(ToolManager.smallActive){
                             bakeViewSm.drawPath(prevSeg!.point.add(Point(x:ToolManager.smPenXOffset,y:ToolManager.smPenYOffset)),tP: seg.point.add(Point(x:ToolManager.smPenXOffset,y:ToolManager.smPenYOffset)), w:ToolManager.smPenDiameter, c:ToolManager.smPenColor)
                        }
                        else{
 bakeViewLg.drawPath(prevSeg!.point.add(Point(x:ToolManager.lgPenXOffset,y:ToolManager.lgPenYOffset)),tP: seg.point.add(Point(x:ToolManager.lgPenXOffset,y:ToolManager.lgPenYOffset)), w:ToolManager.lgPenDiameter, c:ToolManager.lgPenColor)
                        }
                    }
                }

                break
            default:
                break;
            }
            break;
        case "DRAW":
            switch data.1{
            case "SEGMENT":
                let seg = data.0 as! Segment
                
                let prevSeg = seg.getPreviousSegment()
                
                if(prevSeg != nil){
                    
                        canvasViewLg.drawPath(prevSeg!.point,tP: seg.point, w:ToolManager.defaultPenDiameter, c:ToolManager.defaultPenColor)
                            
                    
                    
                }
                
                break
                /*case "ARC":
                 let arc = data.0 as! Arc
                 canvasView.drawArc(arc.center, radius: arc.radius, startAngle: arc.startAngle, endAngle: arc.endAngle, w: 10, c: Color(r:0,g:0,b:0))
                 break*/
                
            case "LINE":
                let line = data.0 as! Line
                
                break
                
            case "LEAF":
                let leaf = data.0 as! StoredDrawing
                
                break
                
            case "FLOWER":
                let flower = data.0 as! StoredDrawing
                
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
        if(ToolManager.mode == "draw"){
            
            if let touch = touches.first  {
                
                _ = touch.locationInView(canvasViewSm);
                let force = Float(touch.force);
                let angle = Float(touch.azimuthAngleInView(canvasViewSm))
                if(downInCanvas){
                stylus.onStylusUp()
                downInCanvas = false
                }
                // socketManager.sendStylusData(force, position: stylus.position, angle: angle, delta: stylus.position.sub(stylus.prevPosition),penDown:stylus.penDown)
                //socketManager.sendStylusData();
                
            }
            
        }
        
    }
    
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first  {
            let point = touch.locationInView(canvasViewSm)
            print(point);
            let x = Float(point.x)
            let y = Float(point.y)
            ;
            let force = Float(touch.force);
            let angle = Float(touch.azimuthAngleInView(canvasViewSm))
            if(ToolManager.mode == "draw"){
                if(x>=0 && y>=0 && x<=GCodeGenerator.pX && y<=GCodeGenerator.pY){
                stylus.onStylusDown(x, y:y, force:force, angle:angle)
                    downInCanvas = true;
                }
                // socketManager.sendStylusData(force, position: stylus.position, angle: angle, delta: stylus.position.sub(stylus.prevPosition),penDown:stylus.penDown)
                // socketManager.sendStylusData();
                
            }
            else{
                currentCanvas!.hitTest(Point(x:x,y:y),threshold:20);
            }
        }
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(ToolManager.mode == "draw"){
            
            if let touch = touches.first  {
                
                let point = touch.locationInView(canvasViewSm);
                let x = Float(point.x)
                let y = Float(point.y)
                let force = Float(touch.force);
                let angle = Float(touch.azimuthAngleInView(canvasViewSm))
                if(x>=0 && y>=0 && x<=GCodeGenerator.pX && y<=GCodeGenerator.pY){

                stylus.onStylusMove(x, y:y, force:force, angle:angle)
                    downInCanvas = true;

                }
                // socketManager.sendStylusData(force, position: stylus.position, angle: angle, delta: stylus.position.sub(stylus.prevPosition),penDown:stylus.penDown)
                // socketManager.sendStylusData();
            }
        }
    }
    
    
}


