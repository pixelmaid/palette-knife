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
        
        var brush = generateBrush("PathBrush");
        let stylusMoveConfig = (target:brush, action: "notificationHandler", emitter:stylus, eventType:"STYLUS_MOVE", expression:"") as BehaviorConfig
        
           let stylusUpConfig = (target:brush, action: "notificationHandler", emitter:stylus, eventType:"STYLUS_UP", expression:"") as BehaviorConfig
        
           let stylusDownConfig = (target:brush, action: "notificationHandler", emitter:stylus, eventType:"STYLUS_DOWN", expression:"") as BehaviorConfig
        
        self.addBehavior(stylusMoveConfig)
        self.addBehavior(stylusUpConfig)
        self.addBehavior(stylusDownConfig)

    }
    

    
    func generateBrush(type:String)->Brush{
        let brush = Brush.create(type) as! Brush;
        if(brushes[type] != nil){
            print("overwriting existing brush on brush generated");
        }
        brush.drawEvent.addHandler(self,handler: ViewController.brushDrawHandler)
        brushes[type]=brush;
        brush.drawEvent.raise((brush))
        return brush
        
    }
    
    func addBehavior(config:BehaviorConfig){
        behaviorMapper.createMapping(config)
    }
    
    
    
    func brushDrawHandler(data:(Brush)){
        print("draw handler called\(data)")
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
            canvasView.drawPath(stylus.prevPosition, tP:stylus.position, w:10, c:Color(r:0,g:0,b:0))

        
        }
    }
    


}

