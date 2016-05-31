//
//  ViewController.swift
//  Palette-Knife
//
//  Created by JENNIFER MARY JACOBS on 5/4/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import UIKit
let behaviorMapper = BehaviorMapper()

class ViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var canvasView: CanvasView!
   
    
    
    var brushes = [String:Brush]()
    var stylus = Stylus(x: 0,y:0,angle:0,force:0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stylus["penDown"] = stylus.penDown
        stylus["position"] = stylus.position

        var brush = generateBrush("PathBrush");
        brush["penDown"] = brush.penDown
        brush["position"] = brush.position

        let stylusMoveConfig = (target:brush, action: "setHandler", emitter:stylus, eventType:"STYLUS_MOVE", expression:"position:position") as BehaviorConfig
        
        let spawnConfig = (target:brush, action:"spawnHandler", emitter:stylus, eventType:"STYLUS_MOVE", expression:"ArcBrush") as BehaviorConfig
        
        let arcConfig = (target:brush, action:"setChildHandler", emitter:brush, eventType:"SPAWN", expression:"") as BehaviorConfig
        
        let stylusUpConfig = (target:brush, action: "setHandler", emitter:stylus, eventType:"STYLUS_UP", expression:"penDown:penDown") as BehaviorConfig
        
        let stylusDownConfig = (target:brush, action: "setHandler", emitter:stylus, eventType:"STYLUS_DOWN", expression:"penDown:penDown") as BehaviorConfig
        
        self.addBehavior(stylusMoveConfig)
        self.addBehavior(stylusUpConfig)
        self.addBehavior(stylusDownConfig)
        self.addBehavior(spawnConfig)
        self.addBehavior(arcConfig)


       // stylus["position"] = stylus.position
        
        //stylus["position"] = stylus.position

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
        //print("draw handler called\(data)")
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
            
        }
        
    }
    
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        if let touch = touches.first  {
            let point = touch.locationInView(view);
            let x = Float(point.x)
            let y = Float(point.y)
            let force = Float(touch.force);
            let angle = Float(touch.azimuthAngleInView(view))
            stylus.onStylusDown()

            
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

        
        }
    }
    


}

