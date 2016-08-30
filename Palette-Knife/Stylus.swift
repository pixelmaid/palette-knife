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
    var prevPosition: Point
    var force = Observable<Float>(0)
    var prevForce: Float
    var angle = Observable<Float>(0)
    var speed = Float(0)
    var prevAngle: Float
    var position = Point(x:0,y:0);
    var origin = Point(x:0,y:0);
    var delta = Point(x:0,y:0);
    var deltaChangeBuffer = [Point]();
    var x:Observable<Float>
    var y:Observable<Float>
    var dx:Observable<Float>
    var dy:Observable<Float>
    var prevTime = Float(0);
    var penDown = false;
    var distance = Float(0);
    var forceSub = Float(1);
    var id = NSUUID().UUIDString;
    var transmitEvent = Event<(String)>()
    var constraintTransmitComplete = true;
    var time = Observable<Float>(0)
    var moveDist = Float(0);
    var moveLimit = Float(20);
    // var testCount = 4;
    init(x:Float,y:Float,angle:Float,force:Float){
        prevPosition = Point(x:0, y:0)
        self.force.set(force);
        self.prevForce = force
        self.angle.set(angle)
        self.prevAngle = angle;
        self.x = position.x;
        self.y = position.y
        self.dx = delta.x;
        self.dy = delta.y
        super.init()
        self.name = "stylus"
        self.time = self.timerTime
        
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
        //print("stylus up transitions \(self.keyStorage["STYLUS_UP"]!.count)")
        
        for key in keyStorage["STYLUS_UP"]!  {
            if(key.1 != nil){
                let eventCondition = key.1;
            }
            else{
                NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0,"event":"STYLUS_UP"])
                
            }
        }
        
        self.penDown = false
        self.speed = 0;
        self.transmitData();
        
    }
    
    func onStylusDown(x:Float,y:Float,force:Float,angle:Float){
        //TODO: silent set, need to make more robust/ readable
        self.position.x.setSilent(x)
        self.position.y.setSilent(y)

        for key in self.keyStorage["STYLUS_DOWN"]!  {
            if(key.1 != nil){
                let eventCondition = key.1;
                eventCondition.evaluate()
            }
            else{
                NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0,"event":"STYLUS_DOWN"])
            }
            
        }
        self.delta.set(0,y:0)
        self.penDown = true
        self.prevTime = self.getTimeElapsed();
        self.speed = 0;
        self.transmitData();
        
    }
    
    func onStylusMove(x:Float,y:Float,force:Float,angle:Float){
        print("stylus position moving to:\(x,y)")
        for key in keyStorage["STYLUS_MOVE"]!  {
            if(key.1 != nil){
                let eventCondition = key.1;
                if(eventCondition.evaluate()){
                    NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0,"event":"STYLUS_MOVE"])
                    
                }
                else{
                    //print("EVALUATION FOR CONDITION FAILED")
                }
                
            }
            else{
                //print("move limit: \(moveDist)")
                
               
                    //print("move limit reached \(moveDist)")
                    moveDist = 0;
                    moveLimit = Float(arc4random_uniform(10) + 60)
                    NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0,"event":"STYLUS_MOVE"])
                
            }
        }
        self.prevPosition.set(position);
        
        self.position.set(x,y:y)
        print("setting stylus position to:\(x,y)")
        self.delta.set(self.position.sub(self.prevPosition))

        deltaChangeBuffer.append(self.position.sub(self.prevPosition));
        print("stylus position currently is \(x,y)")
        self.distance += prevPosition.dist(position)
        moveDist += prevPosition.dist(position)
        self.prevForce = self.force.get()
        self.force.set(force*10)
        print("force = \(self.force.get())")
        self.prevAngle = self.angle.get();
        self.angle.set(angle)
        let currentTime = self.getTimeElapsed();
        self.speed = prevPosition.dist(position)/(currentTime-prevTime)
        self.prevTime = currentTime;
        
    }
    
    
    func shiftDeltaBuffer(){
        self.delta.set(self.position.sub(self.prevPosition))

    }
    
    
    
    
}
