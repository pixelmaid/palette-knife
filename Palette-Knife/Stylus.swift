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
    static var force = Float(0)
    var prevForce: Float
    var angle: Float
    var prevAngle: Float
    var position = Point(x:0,y:0);
    var penDown = false;
    var distance = Float(0);

    init(x:Float,y:Float,angle:Float,force:Float){
        prevPosition = Point(x:x, y:y)
        Stylus.force = force
        self.prevForce = force
        self.angle = angle
        self.prevAngle = angle;
        super.init()
        position = Point(x:x, y:y)
        self.events =  ["STYLUS_UP","STYLUS_DOWN","STYLUS_MOVE"]
        self.createKeyStorage();
        
    }

    
    override func get(targetProp:String)->Any?{
        switch targetProp{
        case "force":
            return Stylus.force
            
        case "angle":
            return self.angle
            
            
        default:
            return nil
            
        }
        
    }

    func resetDistance(){
        self.distance=0;
    }
    
    func getDistance()->Float{
        return self.distance
    }
    
    func onStylusUp(){
        
        self.penDown = false
        for key in keyStorage["STYLUS_UP"]!  {
            if(key.1 != nil){
                let eventCondition = key.1;
                
            }
            else{
                NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0])
            }
        }
    }
    
    func onStylusDown(){
        
        self.penDown = true
        for key in keyStorage["STYLUS_DOWN"]!  {
            if(key.1 != nil){
                let eventCondition = key.1;
                eventCondition.validate(self)
            }
            else{
                NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0])
            }

        }
    }
    
    func onStylusMove(x:Float,y:Float,force:Float,angle:Float){
        
        self.prevPosition = position;
        self.position = Point(x:x, y:y)
        self.distance += prevPosition.dist(position)
        self.prevForce = Stylus.force
        Stylus.force = force
        self.prevAngle = self.angle;
        self.angle = angle
      
        for key in keyStorage["STYLUS_MOVE"]!  {
            if(key.1 != nil){
                let eventCondition = key.1;
                if(eventCondition.validate(self)){
                    NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0])

                }
                else{
                    print("EVALUATION FOR CONDITION FAILED")
                }
                
            }
            else{
                NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0])
            }
        }
    }

    
    
}