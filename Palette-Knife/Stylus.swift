//
//  Stylus.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 5/25/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation


// manages stylus data, notifies behaviors of stylus events
class Stylus: TimeSeries, WebTransmitter {
    var prevPosition: PointEmitter
    var force = Float(0)
    var prevForce: Float
    var angle: Float
    var speed = Float(0)
    var prevAngle: Float
    var position = PointEmitter(x:0,y:0);
    var prevTime = Float(0);
    var penDown = false;
    var distance = Float(0);
    var forceSub = Float(1);
    var id = NSUUID().UUIDString;
    var name = "stylus"
    var transmitEvent = Event<(String)>()

    init(x:Float,y:Float,angle:Float,force:Float){
        prevPosition = PointEmitter(x:x, y:y)
        self.force = force
        self.prevForce = force
        self.angle = angle
        self.prevAngle = angle;
        super.init()
        position.set(x, y:y)
        self.events =  ["STYLUS_UP","STYLUS_DOWN","STYLUS_MOVE"]
        self.createKeyStorage();

        //self.startInterval();
        
    }
    @objc override func timerIntervalCallback()
    {
        self.transmitData();
    }

    func transmitData(){
        var string = "{\"type\":\"stylus_data\",\"canvas_id\":\""+self.id;
        string += "\",\"stylusData\":{"
        string+="\"time\":"+String(self.getTimeElapsed())+","
        string+="\"pressure\":"+String(self.force)+","
        string+="\"angle\":"+String(self.angle)+","
        string+="\"penDown\":"+String(self.penDown)+","
        string+="\"speed\":"+String(self.speed)+","
        string+="\"position\":{\"x\":"+String(self.position.x)+",\"y\":"+String(self.position.y)+"}"
        // string+="\"delta\":{\"x\":"+String(delta.x)+",\"y\":"+String(delta.y)+"}"
        string+="}}"

        transmitEvent.raise(string)
    }
    
     func get(targetProp:String)->Any?{
        switch targetProp{
        case "force":
            return force
            
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
        for key in keyStorage["STYLUS_UP"]!  {
            if(key.1 != nil){
                let eventCondition = key.1;
            }
            else{
                NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0])
            }
        }

        self.penDown = false
        self.speed = 0;
        self.transmitData();

    }
    
    func onStylusDown(x:Float,y:Float,force:Float,angle:Float){
        for key in self.keyStorage["STYLUS_DOWN"]!  {
            if(key.1 != nil){
                let eventCondition = key.1;
                eventCondition.validate(self)
            }
            else{
                NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0])
            }
            
        }
        self.position.set(x, y:y)
        self.penDown = true
        self.prevTime = self.getTimeElapsed();
        self.speed = 0;
                self.transmitData();

    }
    
    func onStylusMove(x:Float,y:Float,force:Float,angle:Float){
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
        print("stylus change\(x,y)")

        self.prevPosition.set(position);
        self.position.x.set(x)
        self.position.y.set(y)
        self.distance += prevPosition.dist(position)
        self.prevForce = self.force
        self.force = force
        self.prevAngle = self.angle;
        self.angle = angle
        let currentTime = self.getTimeElapsed();
        self.speed = prevPosition.dist(position)/(currentTime-prevTime)
        self.prevTime = currentTime;
       
    }

    
    
}
