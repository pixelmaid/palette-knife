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
    
    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var new_canvas: UIButton!
    @IBOutlet weak var new_drawing: UIButton!
    @IBOutlet weak var clearAll: UIButton!
    
    
    
    var brushes = [String:Brush]()
    var socketManager = SocketManager();
    var currentCanvas: Canvas?

    override func viewDidLoad() {
        
        
        
        super.viewDidLoad()

        
       clearAll.addTarget(self, action: #selector(ViewController.clearClicked(_:)), forControlEvents: .TouchUpInside)

        
        


        socketManager.socketEvent.addHandler(self,handler: ViewController.socketHandler)
        socketManager.connect();
        
        self.initCanvas();
        self.initTestBrushes();
        
    }
    
    //event handler for socket connections
    func socketHandler(data:(String)){
        switch(data){
            case "first_connection":
                //self.initCanvas();
                //self.initTestBrushes();
                break;
            case "disconnected":
                break;
            case "connected":
            break
        default:
            break
        }
        
    }
    
    func clearClicked(sender: AnyObject?) {
        canvasView.clear()
    }
    
    func newCanvasClicked(sender: AnyObject?){
        self.initCanvas();
    }
    
    func newDrawingClicked(sender: AnyObject){
        currentCanvas?.initDrawing();
    }
    
    func initCanvas(){
        currentCanvas = Canvas();
        socketManager.initAction(currentCanvas!);
        socketManager.initAction(stylus);
        currentCanvas!.initDrawing();
        currentCanvas!.geometryModified.addHandler(self,handler: ViewController.canvasDrawHandler)

    }
    
    func initTestBrushes(){
   /* stylus["penDown"] = stylus.penDown
    stylus["position"] = stylus.position
    stylus["force"] = stylus.force*/

    
    /*var brush = generateBrush("PathBrush");
    brush["penDown"] = brush.penDown
    brush["position"] = brush.position
        
    
    
    let stylusMoveConfig = (target:brush, action: "setHandler", emitter:stylus, eventType:"STYLUS_MOVE", eventCondition: nil, expression:"position:position|force:weight") as BehaviorConfig
    //let ec = stylusCondition(state: "MOVE_BY",value: Float(100))
    /*let spawnConfig = (target:brush, action:"spawnHandler", emitter:stylus, eventType:"STYLUS_MOVE",  eventCondition: ec, expression:"LeafBrush:2") as BehaviorConfig
    
    let arcConfig = (target:brush, action:"setChildHandler", emitter:brush, eventType:"SPAWN",  eventCondition: nil, expression:"position:parent.position|scalingAll:stylus.force|angle:parent.n1,n2") as BehaviorConfig*/
    
    let stylusUpConfig = (target:brush, action: "setHandler", emitter:stylus, eventType:"STYLUS_UP",  eventCondition: nil, expression:"penDown:penDown") as BehaviorConfig
    
    /*let flowerConfig = (target:brush, action: "spawnHandler", emitter:stylus, eventType:"STYLUS_UP",  eventCondition: nil, expression:"FlowerBrush:2") as BehaviorConfig
    
    let flowerSpawnConfig = (target:brush, action:"setChildHandler", emitter:brush, eventType:"SPAWN",  eventCondition:spawnCondition(state: "IS_TYPE",value: "FlowerBrush"), expression:"position:parent.position") as BehaviorConfig*/
    
    let stylusDownConfig = (target:brush, action: "setHandler", emitter:stylus, eventType:"STYLUS_DOWN", eventCondition: nil, expression:"penDown:penDown") as BehaviorConfig
    
    behaviorMapper.createMapping(stylusMoveConfig)
    behaviorMapper.createMapping(stylusUpConfig)
    behaviorMapper.createMapping(stylusDownConfig)
    //behaviorMapper.createMapping(spawnConfig)
    ////behaviorMapper.createMapping(arcConfig)
   // behaviorMapper.createMapping(flowerConfig)
   // behaviorMapper.createMapping(flowerSpawnConfig)*/
        
        
        var dripBrush = generateBrush("PathBrush");
        dripBrush["penDown"] = dripBrush.penDown
        dripBrush["position"] = dripBrush.position
        dripBrush["weight"] = dripBrush.weight;
        dripBrush["y"] = dripBrush.position.y;
        dripBrush["x"] = dripBrush.position.x;

        let weightExpression = AddExpression(operand1: FloatEmitter(val: 1),operand2: stylus.force)
        let timeExpression = AddExpression(operand1: dripBrush.time,operand2: dripBrush.position.y)
        let timeWeightExpression = AddExpression(operand1: dripBrush.time,operand2: dripBrush.weight)


        behaviorMapper.createState(dripBrush,stateName:"drip")
        behaviorMapper.addMethod(dripBrush,state:"drip",methodName:"newStroke");
        
        behaviorMapper.createMapping(timeExpression, relative: dripBrush, relativeProperty: dripBrush.position.y, targetState: "drip")
          behaviorMapper.createMapping(timeWeightExpression, relative: dripBrush, relativeProperty: dripBrush.weight, targetState: "drip")

        
       // var timeCondition = new
        behaviorMapper.createMapping(stylus.position.y, relative: dripBrush, relativeProperty: dripBrush.position.y, targetState: "default")
        behaviorMapper.createMapping(stylus.position.x, relative: dripBrush, relativeProperty: dripBrush.position.x, targetState: "default")
        behaviorMapper.createMapping(weightExpression, relative: dripBrush, relativeProperty: dripBrush.weight, targetState: "default")

     
        behaviorMapper.createState(dripBrush,stateName:"stop")
        behaviorMapper.addMethod(dripBrush,state:"stop",methodName:"destroy");


        behaviorMapper.createStateTransition(stylus, relative: dripBrush, eventName: "STYLUS_UP", fromState:"default",toState: "drip", condition: nil)
        behaviorMapper.createStateTransition(dripBrush, relative: dripBrush, eventName: "TIME_INCREMENT", fromState:"drip",toState: "stop", condition: nil)
         behaviorMapper.createStateTransition(dripBrush, relative: dripBrush, eventName: "STATE_COMPLETE", fromState:"stop",toState: "default", condition: nil)

    }
    
    func generateBrush(type:String)->Brush{
        let brush = Brush.create(type) as! Brush;
        if(brushes[type] != nil){
            print("overwriting existing brush on brush generated");
        }
        //brush.geometryModified.addHandler(self,handler: ViewController.brushDrawHandler)
        brushes[type]=brush;
        brush.setCanvasTarget(self.currentCanvas!)
        return brush
        
    }

    
    func canvasDrawHandler(data:(Geometry,String,String)){
        switch data.2{
            case "DRAW":
                switch data.1{
                    case "SEGMENT":
                        let seg = data.0 as! Segment
                
                        let prevSeg = seg.getPreviousSegment()
                        if(prevSeg != nil){

                            canvasView.drawPath(prevSeg!.point,tP: seg.point, w:seg.diameter, c:Color(r:0,g:0,b:0))
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
                    
                    canvasView.drawLeaf(leaf.position, angle:leaf.angle, scale:leaf.scaling.x.get())
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

