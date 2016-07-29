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
        //DRIP BRUSH
       /*let dripBehavior = BehaviorDefinition()
        
        dripBehavior.addExpression("timeExpression", type:"add", emitter1: nil, operand1Name: "time", emitter2: nil, operand2Name: "y")
     dripBehavior.addExpression("timeWeightExpression",type:"logigrowth", emitter1: nil, operand1Name: "time", emitter2: nil, operand2Name: "weight")
    dripBehavior.addExpression("stylusYExpression", type:"add",emitter1: stylus, operand1Name: "y", emitter2: FloatEmitter(val:0), operand2Name: nil)
        dripBehavior.addExpression("stylusXExpression", type:"add",emitter1: stylus, operand1Name: "x", emitter2: FloatEmitter(val:0), operand2Name: nil)
        dripBehavior.addExpression("xExpression", type:"add",emitter1: nil, operand1Name: "x", emitter2: FloatEmitter(val:0), operand2Name: nil)



       dripBehavior.addState("drip")
      dripBehavior.addState("stop")
        
       dripBehavior.addMethod("default", targetMethod: "newStroke", arguments: nil)
      dripBehavior.addMethod("stop", targetMethod:"destroy", arguments: nil)
        
        dripBehavior.addTransition(nil, event: "STATE_COMPLETE", fromState: "default", toState: "drip")
       dripBehavior.addTransition(nil, event: "TIME_INCREMENT", fromState: "drip", toState: "stop")

        
       dripBehavior.addMapping(nil, referenceName:"stylusYExpression", relativePropertyName: "y",targetState: "default");
        dripBehavior.addMapping(nil, referenceName:"stylusXExpression", relativePropertyName: "x",targetState: "default");
        dripBehavior.addMapping(stylus.force, referenceName:nil, relativePropertyName: "weight",targetState: "default");

        dripBehavior.addMapping(nil, referenceName:"timeExpression", relativePropertyName: "y",targetState: "drip");
        

   dripBehavior.addMapping(nil, referenceName:"timeWeightExpression", relativePropertyName: "weight",targetState: "drip");
        


         let dripGeneratorBehavior = BehaviorDefinition()
        dripGeneratorBehavior.addState("spawnDrip")
        dripGeneratorBehavior.addState("initStroke")
        
        dripGeneratorBehavior.addMethod("initStroke", targetMethod: "newStroke",arguments: nil)
        dripGeneratorBehavior.addMethod("spawnDrip", targetMethod: "spawn", arguments:[dripBehavior,1])

        dripGeneratorBehavior.addTransition(stylus, event: "STYLUS_DOWN", fromState: "default", toState: "initStroke")
        dripGeneratorBehavior.addTransition(nil, event: "STATE_COMPLETE", fromState: "initStroke", toState: "default")
        dripGeneratorBehavior.addTransition(stylus, event: "STYLUS_MOVE", fromState: "default", toState: "spawnDrip")
        dripGeneratorBehavior.addTransition(nil, event: "STATE_COMPLETE", fromState: "spawnDrip", toState: "default")

        
        dripGeneratorBehavior.addMapping(stylus.position.y, referenceName:nil, relativePropertyName: "y",targetState: "default");
        dripGeneratorBehavior.addMapping(stylus.position.x, referenceName:nil, relativePropertyName: "x",targetState: "default");
        //dripGeneratorBehavior.addMapping(stylus.force, referenceName:nil, relativePropertyName: "weight",targetState: "default");


        var dripGenerator = Brush(behaviorDef: dripGeneratorBehavior, canvas:self.currentCanvas!)
        dripGenerator.name = "dripGenerator"
         dripGenerator.setCanvasTarget(self.currentCanvas!)*/
        
        //RADIAL BRUSH
        let radialGeneratorCount = 4;
        let radialCount = 7;
        let radialBehavior = BehaviorDefinition()
        let rotationMap = RangeVariable(min: 0,max: radialCount, start: 0,stop: 40)
        let rotationMap2 = RangeVariable(min: 0,max: radialGeneratorCount, start: 0,stop: 360)
        let xpositionMap = AlternateVariable(values:[0,-75,-150,-75]);
        let ypositionMap = AlternateVariable(values:[0,75,0,-75]);


        radialBehavior.addExpression("rotationAdd", type: "add", emitter1: rotationMap, operand1Name: nil, emitter2: nil, operand2Name: "angle", parentFlag: false)
        
        radialBehavior.addExpression("parentAdd", type: "add", emitter1: rotationMap, operand1Name: nil, emitter2: nil, operand2Name: "angle", parentFlag: true)
       radialBehavior.addExpression("xpositionAdd", type: "add", emitter1: stylus, operand1Name: "x", emitter2: nil, operand2Name: "x", parentFlag: true)
        radialBehavior.addExpression("ypositionAdd", type: "add", emitter1: stylus, operand1Name: "y", emitter2: nil, operand2Name: "y", parentFlag: true)

        radialBehavior.addState("stop")
        
        radialBehavior.addMethod("default", targetMethod: "newStroke",arguments: nil)
        radialBehavior.addMethod("stop", targetMethod: "destroy",arguments: nil)

        radialBehavior.addTransition(stylus, event: "STYLUS_UP", fromState: "default", toState: "stop")

        
        radialBehavior.addMapping(nil, referenceName:"parentAdd",relativePropertyName: "angle", targetState: "default")
        radialBehavior.addMapping(nil, referenceName:"ypositionAdd", relativePropertyName: "y",targetState: "default");
        radialBehavior.addMapping(nil, referenceName:"xpositionAdd", relativePropertyName: "x",targetState: "default");
        
       radialBehavior.addMapping(stylus.force, referenceName:nil, relativePropertyName: "weight",targetState: "default");

       
        
        let radialGenerator = BehaviorDefinition()
       
        radialGenerator.addState("stop")
        
       radialGenerator.addMethod("default", targetMethod: "spawn", arguments:[radialBehavior,radialCount])
        radialGenerator.addMethod("stop", targetMethod: "destroy",arguments: nil)

        radialGenerator.addTransition(nil, event: "STATE_COMPLETE", fromState: "default", toState: "stop")
        radialGenerator.addMapping(rotationMap2, referenceName:nil,relativePropertyName: "angle", targetState: "default")
        radialGenerator.addMapping(xpositionMap, referenceName:nil,relativePropertyName: "x", targetState: "default")
        radialGenerator.addMapping(ypositionMap, referenceName:nil,relativePropertyName: "y", targetState: "default")

        
        let multiWaveGenerator = BehaviorDefinition()
        multiWaveGenerator.addState("spawn")
        
        multiWaveGenerator.addMethod("spawn", targetMethod: "spawn", arguments:[radialGenerator,radialGeneratorCount])

        
        multiWaveGenerator.addTransition(stylus, event: "STYLUS_DOWN", fromState: "default", toState: "spawn")
        multiWaveGenerator.addTransition(nil, event: "STATE_COMPLETE", fromState: "spawn", toState: "default")

        
        //radialGenerator.addMapping(stylus.position.y, referenceName:nil, relativePropertyName: "y",targetState: "default");
        //radialGenerator.addMapping(stylus.position.x, referenceName:nil, relativePropertyName: "x",targetState: "default");
        //dripGeneratorBehavior.addMapping(stylus.force, referenceName:nil, relativePropertyName: "weight",targetState: "default");
        
        
        var multiWaveGeneratorBrush = Brush(behaviorDef: multiWaveGenerator, parent:nil, canvas:self.currentCanvas!)
        multiWaveGeneratorBrush.name = "multiwave"


        
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

