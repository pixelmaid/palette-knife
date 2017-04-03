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
    
    
    
    var socketManager = SocketManager();
    var behaviorManager: BehaviorManager?
    var currentCanvas: Canvas?
    let socketKey = NSUUID().UUIDString
    let drawKey = NSUUID().UUIDString
    let brushEventKey = NSUUID().UUIDString

    
    var downInCanvas = false;
    
    var radialBrush:Brush?
    var bakeBrush:Brush?
    
    var brushes = [String:Brush]()
    
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

        canvasViewLg.alpha = 1;
        canvasViewSm.alpha = 0.25;
        
        
        self.fabricatorView.drawFabricatorPosition(Float(0), y: Float(0), z: Float(0))
        self.initCanvas()
       // self.initRadialBrush();
       // self.initBakeBrush();

        //radialBrush?.active = false;
        
        
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
            break;
        case "disconnected":
            break;
        case "connected":
            break
        case "data_request":
            socketManager.sendBehaviorData(behaviorManager!.getAllBehaviorJSON());
            break
        case "authoring_request":
            do{
            let attempt = try behaviorManager!.handleAuthoringRequest(data.1! as JSON);
                var jsonArg = "null";
                if(attempt.2 != nil){
                    jsonArg = (attempt.2?.rawString())!;
                }
                socketManager.sendData("{\"type\":\"authoring_response\",\"result\":\""+attempt.1+"\",\"authoring_type\":\""+attempt.0+"\",\"data\":"+jsonArg+"}");
            }
            catch{
                print("failed authoring request");
                socketManager.sendData("{\"type\":\"authoring_response\",\"result\":\"error thrown\"}");
            }
            
            break;
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
        behaviorManager = BehaviorManager(canvas: currentCanvas!);
        socketManager.initAction(currentCanvas!,type:"canvas_init");
        //socketManager.initAction(stylus);
        currentCanvas!.initDrawing();
        currentCanvas!.geometryModified.addHandler(self,handler: ViewController.canvasDrawHandler, key:drawKey)
        
        
    }
    
    
     //----------------------------------  HARDCODED BRUSHES ---------------------------------- //
    func initDripBrush(){
        let dripBehavior = behaviorManager?.initDripBehavior();
        let dripBrush = Brush(name:"parentBehavior",behaviorDef: dripBehavior, parent:nil, canvas:self.currentCanvas!)
        socketManager.initAction(dripBrush,type:"brush_init");

    }
    
    
    func initBakeBrush(){
        let bake_behavior = behaviorManager?.initBakeBehavior();
        bakeBrush = Brush(name:"bake_brush",behaviorDef: bake_behavior, parent:nil, canvas:self.currentCanvas!)
        socketManager.initAction(bakeBrush!,type:"brush_init");
    }
    
 
    func initRadialBrush(){
        let radial_behavior = behaviorManager?.initRadialBehavior();
        radialBrush = Brush(name:"radial",behaviorDef: radial_behavior, parent:nil, canvas:self.currentCanvas!)
        socketManager.initAction(radialBrush!,type:"brush_init");

    }
    
   func initFractalBrush(){
        let rootBehavior = behaviorManager?.initFractalBehavior();
        let rootBehaviorBrush = Brush(name:"rootBehaviorBrush",behaviorDef: rootBehavior, parent:nil, canvas:self.currentCanvas!)
        rootBehaviorBrush.strokeColor.b = 255;
        socketManager.initAction(rootBehaviorBrush,type:"brush_init");


    }
    
    //---------------------------------- END HARDCODED BRUSHES ---------------------------------- //

    
    
    func canvasDrawHandler(data:(Geometry,String,String), key:String){
        switch data.2{
            
        case "DRAW":
            switch data.1{
            case "SEGMENT":
                let seg = data.0 as! Segment
                
                let prevSeg = seg.getPreviousSegment()
                
                if(prevSeg != nil){
                    
                    canvasViewLg.drawIsolatedPath(prevSeg!.point,tP: seg.point, w:seg.diameter, c:seg.color)
                    
                    
                    
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


