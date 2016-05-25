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
    var position: Point
    var prevPosition: Point
    var force: Float
    var prevForce: Float
    var angle: Float
    var prevAngle: Float
    var pen = false
    
    init(x:Float,y:Float,angle:Float,force:Float){
        
        position = Point(x:x, y:y)
        prevPosition = Point(x:x, y:y)
        self.force = force
        self.prevForce = force
        self.angle = angle
        self.prevAngle = angle;
        super.init()
        self.events =  ["STYLUS_UP","STYLUS_DOWN","STYLUS_MOVE"]
        self.createKeyStorage();
    }

    
    func onStylusUp(){
        
        self.pen = false
        print("on stylus up")
        for key in keyStorage["STYLUS_UP"]!  {
            NSNotificationCenter.defaultCenter().postNotificationName(key, object: self, userInfo: ["emitter":self])
        }
    }
    
    func onStylusDown(){
        
        self.pen = true
        print("on stylus down")
        for key in keyStorage["STYLUS_DOWN"]!  {
            NSNotificationCenter.defaultCenter().postNotificationName(key, object: self, userInfo: ["emitter":self])
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
            NSNotificationCenter.defaultCenter().postNotificationName(key, object: self, userInfo: ["emitter":self])
        }
    }

    
    
}