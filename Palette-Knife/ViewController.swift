//
//  ViewController.swift
//  Palette-Knife
//
//  Created by JENNIFER MARY JACOBS on 5/4/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import UIKit
import Starscream

let behaviorMapper = BehaviorMapper()
var stylus = Stylus(x: 0,y:0,angle:0,force:0)
class ViewController: UIViewController, WebSocketDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var canvasView: CanvasView!
   
    
    
    var brushes = [String:Brush]()
   
    var socket = WebSocket(url: NSURL(string: "ws://10.8.0.205:8080/")!, protocols: ["ipad_client"])
    var startTime:NSDate?
    override func viewDidLoad() {
        
        
        
        super.viewDidLoad()
        
        socket.delegate = self
        socket.connect()
        
        
        stylus["penDown"] = stylus.penDown
        stylus["position"] = stylus.position

        var brush = generateBrush("PathBrush");
        brush["penDown"] = brush.penDown
        brush["position"] = brush.position

        let stylusMoveConfig = (target:brush, action: "setHandler", emitter:stylus, eventType:"STYLUS_MOVE", eventCondition: nil, expression:"position:position") as BehaviorConfig
        let ec = stylusCondition(state: "MOVE_BY",value: Float(100))
        let spawnConfig = (target:brush, action:"spawnHandler", emitter:stylus, eventType:"STYLUS_MOVE",  eventCondition: ec, expression:"LeafBrush:2") as BehaviorConfig
        
        let arcConfig = (target:brush, action:"setChildHandler", emitter:brush, eventType:"SPAWN",  eventCondition: nil, expression:"position:parent.position|scalingAll:stylus.force|angle:parent.n1,n2") as BehaviorConfig
        
        let stylusUpConfig = (target:brush, action: "setHandler", emitter:stylus, eventType:"STYLUS_UP",  eventCondition: nil, expression:"penDown:penDown") as BehaviorConfig
        
        let flowerConfig = (target:brush, action: "spawnHandler", emitter:stylus, eventType:"STYLUS_UP",  eventCondition: nil, expression:"FlowerBrush:2") as BehaviorConfig

        let flowerSpawnConfig = (target:brush, action:"setChildHandler", emitter:brush, eventType:"SPAWN",  eventCondition:spawnCondition(state: "IS_TYPE",value: "FlowerBrush"), expression:"position:parent.position") as BehaviorConfig

        let stylusDownConfig = (target:brush, action: "setHandler", emitter:stylus, eventType:"STYLUS_DOWN", eventCondition: nil, expression:"penDown:penDown") as BehaviorConfig
        
         behaviorMapper.createMapping(stylusMoveConfig)
        behaviorMapper.createMapping(stylusUpConfig)
        behaviorMapper.createMapping(stylusDownConfig)
        behaviorMapper.createMapping(spawnConfig)
        behaviorMapper.createMapping(arcConfig)
        behaviorMapper.createMapping(flowerConfig)
        behaviorMapper.createMapping(flowerSpawnConfig)



       // stylus["position"] = stylus.position
        
        //stylus["position"] = stylus.position
        //
        canvasView.drawFlower(Point(x:100,y:100))
    }
    
    // MARK: Websocket Delegate Methods.
    
    func websocketDidConnect(ws: WebSocket) {
        print("websocket is connected")
        //send name of client
        socket.writeString("ipad")
    }
    
    func websocketDidDisconnect(ws: WebSocket, error: NSError?) {
        if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
        }
    }
    
    func websocketDidReceiveMessage(ws: WebSocket, text: String) {
        print("ifconfig text: \(text)")
    }
    
    func websocketDidReceiveData(ws: WebSocket, data: NSData) {
        print("Received data: \(data.length)")
    }
    
    // MARK: Write Text Action
    
    func sendStylusData(pressure:Float,position:Point,angle:Float,delta:Point,penDown:Bool) {
        let end = NSDate();
        let timeInterval = end.timeIntervalSinceDate(startTime!);
        var string = "{"
        string+="\"time\":"+String(timeInterval)+","
        string+="\"pressure\":"+String(pressure)+","
        string+="\"angle\":"+String(angle)+","
        string+="\"penDown\":"+String(penDown)+","
        string+="\"position\":{\"x\":"+String(position.x)+",\"y\":"+String(position.y)+"},"
        string+="\"delta\":{\"x\":"+String(delta.x)+",\"y\":"+String(delta.y)+"}"
        string+="}"
        print("message: \(string)")
        socket.writeString(string)
    }
    
    // MARK: Disconnect Action
    
    func disconnect() {
        if socket.isConnected {
           
            socket.disconnect()
        } else {
            socket.connect()
        }
    }
    
    func generateBrush(type:String)->Brush{
        let brush = Brush.create(type) as! Brush;
        if(brushes[type] != nil){
            print("overwriting existing brush on brush generated");
        }
        brush.geometryModified.addHandler(self,handler: ViewController.brushDrawHandler)
        brushes[type]=brush;
        return brush
        
    }
    
    func addBehavior(config:BehaviorConfig){
        behaviorMapper.createMapping(config)
    }
    
    
    
    func brushDrawHandler(data:(Geometry,String,String)){
        switch data.2{
            case "DRAW":
                switch data.1{
                    case "SEGMENT":
                        let seg = data.0 as! Segment
                
                        let prevSeg = seg.getPreviousSegment()
                        if(prevSeg != nil){
                           // print("draw segment called \(seg.point,prevSeg!.point)\n\n");

                            canvasView.drawPath(prevSeg!.point,tP: seg.point, w:10, c:Color(r:0,g:0,b:0))
                        }
                    break
                    case "ARC":
                        let arc = data.0 as! Arc
                        canvasView.drawArc(arc.center, radius: arc.radius, startAngle: arc.startAngle, endAngle: arc.endAngle, w: 10, c: Color(r:0,g:0,b:0))
                    break
                    
                    case "LINE":
                    let line = data.0 as! Line
                    print("draw line \(line.p.x,line.p.y,line.v.x,line.v.y)")

                    canvasView.drawPath(line.p, tP:line.v, w: 10, c: Color(r:0,g:0,b:0))
                    break
                    
                case "LEAF":
                    let leaf = data.0 as! StoredDrawing
                    
                    canvasView.drawLeaf(leaf.position, angle:leaf.angle, scale:leaf.scaling.x)
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
            
            let point = touch.locationInView(view);
            let x = Float(point.x)
            let y = Float(point.y)
            let force = Float(touch.force);
            let angle = Float(touch.azimuthAngleInView(view))
            stylus.onStylusUp()
            sendStylusData(force, position: stylus.position, angle: angle, delta: stylus.position.sub(stylus.prevPosition),penDown:stylus.penDown)

        }
        
    }
    
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(startTime == nil){
            startTime = NSDate();
        }
        if let touch = touches.first  {
            let point = touch.locationInView(view);
            let x = Float(point.x)
            let y = Float(point.y)
            let force = Float(touch.force);
            let angle = Float(touch.azimuthAngleInView(view))
            stylus.onStylusDown()
            sendStylusData(force, position: stylus.position, angle: angle, delta: stylus.position.sub(stylus.prevPosition),penDown:stylus.penDown)
            
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
            sendStylusData(force, position: stylus.position, angle: angle, delta: stylus.position.sub(stylus.prevPosition),penDown:stylus.penDown)

        }
    }
    


}

