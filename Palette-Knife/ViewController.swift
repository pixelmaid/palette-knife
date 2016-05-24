//
//  ViewController.swift
//  Palette-Knife
//
//  Created by JENNIFER MARY JACOBS on 5/4/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var canvasView: CanvasView!
    
    var stylusUpEvent = Event<(Point,Float,Float)>()
    var stylusDownEvent = Event<(Point,Float,Float)>()
    var stylusMoveEvent = Event<(Point,Float,Float)>()
    
    var brushes = [String:Brush]();

    override func viewDidLoad() {
        super.viewDidLoad()
        var brush = Brush();
        var pathBrush = PathBrush()
        var pathBrushClone = pathBrush.clone();

        var brushClone = brush.clone();
        print(brushClone,pathBrushClone)
        // b.addEventActionPair(pathBrush, event:stylusMoveEvent, action:PathBrush.testHandler);
        //stylusMoveEvent.raise((Point(x:100,y:100),0.0,40.0));

        
        
        

    }
    
    func brushGenerated(type:String){
        let brush = Brush.create(type) as! Brush;
        if(brushes[type] != nil){
            print("overwriting existing brush on brush generated");
        }
        
        brushes[type]=brush;
        
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
            
            stylusUpEvent.raise(Point(x:x,y:y),force,angle);
            
        }
        
    }
    
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first  {
            
            let point = touch.locationInView(view);
            let x = Float(point.x)
            let y = Float(point.y)
            let force = Float(touch.force);
            let angle = Float(touch.azimuthAngleInView(view))
            
            stylusDownEvent.raise(Point(x:x,y:y),force,angle);

            
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first  {
           
            let point = touch.locationInView(view);
            
            let x = Float(point.x)
            let y = Float(point.y)
            let force = Float(touch.force);
            let angle = Float(touch.azimuthAngleInView(view))
            print("touches moved\(x,y,force,angle,stylusMoveEvent)")

            stylusMoveEvent.raise(Point(x:x,y:y),force,angle);
        
        }
    }
    


}

