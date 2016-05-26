//
//  Stylus.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 5/25/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation


// manages stylus data, notifies behaviors of stylus events
class Stylus: Emitter {
    var prevPosition: Point
    var force: Float
    var prevForce: Float
    var angle: Float
    var prevAngle: Float
    var position = Point(x:0,y:0);
    var penDown = false;

    init(x:Float,y:Float,angle:Float,force:Float){
        prevPosition = Point(x:x, y:y)
        self.force = force
        self.prevForce = force
        self.angle = angle
        self.prevAngle = angle;
        super.init()
        position = Point(x:x, y:y)
        self.events =  ["STYLUS_UP","STYLUS_DOWN","STYLUS_MOVE"]
        self.createKeyStorage();
        
    }

    
    func onStylusUp(){
        
        self.penDown = false
        for key in keyStorage["STYLUS_UP"]!  {
            NSNotificationCenter.defaultCenter().postNotificationName(key, object: self, userInfo: ["emitter":self,"key":key])
        }
    }
    
    func onStylusDown(){
        
        self.penDown = true
        for key in keyStorage["STYLUS_DOWN"]!  {
            NSNotificationCenter.defaultCenter().postNotificationName(key, object: self, userInfo: ["emitter":self,"key":key])
        }
    }
    
    func onStylusMove(x:Float,y:Float,force:Float,angle:Float){
        
        self.prevPosition = position;
        self.position = Point(x:x, y:y)
        self.prevForce = self.force
        self.force = force
        self.prevAngle = self.angle;
        self.angle = angle
      
        //print("on stylus move")
        for key in keyStorage["STYLUS_MOVE"]!  {
            NSNotificationCenter.defaultCenter().postNotificationName(key, object: self, userInfo: ["emitter":self,"key":key])
        }
    }

    
    
}