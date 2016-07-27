//
//  Point.swift
//  Palette-Knife
//
//  Created by JENNIFER MARY JACOBS on 5/5/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation
import UIKit

import SwiftKVC

class PointEmitter: Emitter, Geometry{
  
    var x = FloatEmitter(val: 0);
    var y = FloatEmitter(val: 0);
    var prevX = Float(0);
    var prevY = Float(0);
    var angle = Float(0);
    let xKey = NSUUID().UUIDString;
    let yKey = NSUUID().UUIDString;
    
    
    init(x:Float,y:Float) {
        super.init()
        self.x.set(x);
        self.y.set(y);
        self.events =  ["CHANGE","INVALIDATED"]
        self.createKeyStorage();
        self.angle = atan2(y, x) * Float(180 / M_PI);
        let selector = Selector("propertyInvalidated"+":");

       NSNotificationCenter.defaultCenter().addObserver(self, selector:selector, name:xKey, object: self.x)
        self.x.assignKey("INVALIDATED",key:xKey,eventCondition: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:selector, name:yKey, object: self.y)
        self.y.assignKey("INVALIDATED",key:yKey,eventCondition: nil);
        
        self.x.name = "x"
        self.y.name = "y"

    }
    
    func toJSON()->String{
        let string = "\"x\":"+String(self.x.get())+",\"y\":"+String(self.y.get())
        return string;
    }
    
    override func set(val:Emitter){
        let point = val as! PointEmitter
        self.set(point.x.get(),y:point.y.get())
    }
    
    
    override dynamic func propertyInvalidated(notification: NSNotification) {
       /* super.propertyInvalidated(notification)
        let reference = notification.userInfo?["emitter"] as! FloatEmitter
        print("invalidate,\(x.constrained,y.constrained)")
        if(!x.constrained && !y.constrained){
            return;
        }
        else if(x.constrained && !y.constrained && reference == self.x){
            self.set(self.x.get(),y:self.y.get());
        }
        else if(!x.constrained && y.constrained && reference == self.y){
            self.set(self.x.get(),y:self.y.get());
        }
        else{
             print("both constrained x:\(x.invalidated) y:\(y.invalidated)");
            if(self.x.invalidated && self.y.invalidated){
               
                self.set(self.x.get(),y:self.y.get());

            }
        }*/
        self.set(self.x.get(),y:self.y.get());
    }
    
     func get()->(Float,Float){
       super.get()
        return (self.x.get(),self.y.get())
    }
    
    
    func set(x:Float, y:Float){
        prevX = self.x.get();
        prevY = self.y.get();
        self.x.set(x);
        self.y.set(y);
        for i in 0..<events.count{
let event = events[i]
        for key in keyStorage[event]!  {
                NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0])
        
        }
        }
    }
    
    func clone()->PointEmitter{
        return PointEmitter(x:self.x.get(),y:self.y.get())
    }
    
    func add(point:PointEmitter)->PointEmitter{
        return PointEmitter(x:self.x.get()+point.x.get(),y:self.y.get()+point.y.get());
    }
    
    func sub(point:PointEmitter)->PointEmitter {
        return PointEmitter(x:self.x.get()-point.x.get(),y:self.y.get()-point.y.get());
    }
    
    func div(val:Float) ->PointEmitter{
        return PointEmitter(x: self.x.get() / val, y: self.y.get() / val);
    }
    
    func mul(val:Float)->PointEmitter {
        return PointEmitter(x: self.x.get() * val, y: self.y.get() * val);
    }
    
    func div(point:PointEmitter) ->PointEmitter{
        return PointEmitter(x:self.x.get() / point.x.get(), y: self.y.get() / point.y.get());
    }
    
    func mul(point:PointEmitter) ->PointEmitter{
        return PointEmitter(x:self.x.get() * point.x.get(), y:self.y.get() * point.y.get());
    }
    
    func dist(point:PointEmitter)->Float{
        return sqrtf(distanceSqrd(self,p2: point));
        
    }
    
    func distanceSqrd(p1:PointEmitter, p2:PointEmitter)->Float{
        return powf((p1.x.get()-p2.x.get()), 2.0)+powf((p1.y.get()-p2.y.get()), 2.0)
    }
    
    static func isCollinear(x1:Float, y1:Float, x2:Float, y2:Float)->Bool{

        return abs(x1 * y2 - y1 * x2) <= sqrt((x1 * x1 + y1 * y1) * (x2 * x2 + y2 * y2)) * Numerical.TRIGONOMETRIC_EPSILON;
        

    }
    
    static func isOrthoganal(x1:Float, y1:Float, x2:Float, y2:Float)->Bool{
        
        return abs(x1 * x2 + y1 * y2) <= sqrt((x1 * x1 + y1 * y1) * (x2 * x2 + y2 * y2)) * Numerical.TRIGONOMETRIC_EPSILON;
        
    }

    
    //Returns the length of a vector sqaured. Faster than Length(), but only marginally
    static func lengthSqrd(vec:PointEmitter)->Float {
    return pow(vec.x.get(), 2) + pow(vec.y.get(), 2);
    }
    
    //Returns the length of vector'
    func length()->Float {
    return sqrtf(PointEmitter.lengthSqrd(self));
    }
    
    //Returns a new vector that has the same direction as vec, but has a length of one.
    static func normalize(vec:PointEmitter)->PointEmitter {
    if (vec.x.get() == 0 && vec.y.get() == 0) {
        return vec;
    }
    
        return vec.div(vec.length());
    }
    
    //Computes the dot product of a and b'
    func dot(b:PointEmitter)->Float {
    return (self.x.get() * b.x.get()) + (self.y.get() * b.y.get());
    }
    
    func cross(point:PointEmitter)->Float {
        return self.x.get() * point.y.get() - self.y.get() * point.x.get();
    }
    
    static func projectOnto(v:PointEmitter, w:PointEmitter)->PointEmitter{
    //'Projects w onto v.'
    return v.mul(w.dot(v) / PointEmitter.lengthSqrd(v));
    }
    
    
    func pointAtDistance(d:Float,a:Float)->PointEmitter{
        let x = self.x.get() + (d * cos(a*Float(M_PI/180)))
        let y = self.y.get() + (d * sin(a*Float(M_PI/180)))
        return PointEmitter(x: x,y: y)
    }
    
    func rotate(angle:Float)->PointEmitter{
        let l = self.length();
        return PointEmitter(x:0,y:0).pointAtDistance(l,a:angle);
    }
     
     
     func getDirectedAngle(point:PointEmitter)->Float {
     return atan2(self.cross(point), self.dot(point)) * 180 / Float(M_PI);
     }
     
     
    
    func toCGPoint()->CGPoint{
        return CGPoint(x:CGFloat(self.x.get()),y:CGFloat(self.y.get()))
    }
    
    
    
    
}
func ==(lhs: PointEmitter, rhs: PointEmitter) -> Bool {
    return lhs.x.get() == rhs.x.get() && lhs.y.get() == rhs.y.get()
}


/*struct Point:Equatable, Geometry{
        
        var x = Float(0);
        var y = Float(0);
    
        init(x:Float,y:Float) {
            self.x = x
            self.y = y
           
        }
        
        func toJSON()->String{
            let string = "\"x\":"+String(self.x)+",\"y\":"+String(self.y)
            return string;
        }
    
    func dist(point:Point)->Float{
        return sqrtf(distanceSqrd(self,p2: point));
        
    }
    
    func distanceSqrd(p1:Point, p2:Point)->Float{
        return powf((p1.x-p2.x), 2.0)+powf((p1.y-p2.y), 2.0)
    }
    
}

func ==(lhs: Point, rhs: Point) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}*/



