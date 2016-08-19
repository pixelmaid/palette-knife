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

class Point:Observable<(Float,Float)>,Geometry{
  
    var x = Observable<Float>(0)
    var y = Observable<Float>(0)
    var prevX = Float(0);
    var prevY = Float(0);
    var angle = Float(0);
    let xKey = NSUUID().UUIDString;
    let yKey = NSUUID().UUIDString;
    var storedValue = Float(0);
    
    init(x:Float,y:Float) {
        super.init((x, y))
        self.x.set(x);
        self.y.set(y);
        self.angle = atan2(y, x) * Float(180 / M_PI);

        self.x.name = "x"
        self.y.name = "y"
        self.name = "point"
        self.x.didChange.addHandler(self, handler: Point.coordinateChange,key:xKey)
        self.y.didChange.addHandler(self, handler: Point.coordinateChange,key:yKey)

    }
    
    func toJSON()->String{
        let string = "\"x\":"+String(self.x.get())+",\"y\":"+String(self.y.get())
        return string;
    }
    
    
    //coordinateChange
    //handler that only triggers when both x and y have been updated (assuming they're both constrained)
    func coordinateChange(data:(String, Float,Float),key:String){
        let name = data.0;
        let oldValue = data.1;
        _ = data.2;
        
        if(!x.constrained && !y.constrained){
            return;
        }
        else if(x.constrained && !y.constrained && name == "x"){
              didChange.raise((name, (oldValue,self.y.get()), (self.x.get(),self.y.get())))
        }
        else if(!x.constrained && y.constrained && name == "x"){
            didChange.raise((name, (self.x.get(),oldValue), (self.x.get(),self.y.get())))
        }
        else{
            // print("both constrained x:\(x.invalidated) y:\(y.invalidated)");
       
            if(self.x.invalidated && self.y.invalidated){
                // print("constraints validated x:\(x.invalidated) y:\(y.invalidated)");
                if(name == "x"){
                    didChange.raise((name, (oldValue,storedValue),(self.x.get(),self.y.get())));
                }
                else if(name == "y"){
                    didChange.raise((name, (storedValue,oldValue),(self.x.get(),self.y.get())));
                }
                
            }
            else{
                storedValue = oldValue;
            }
        }
    }
    
     func set(val:Point){
        let point = val 
        self.set(point.x.get(),y:point.y.get())
    }
    
    func set(x:Float,y:Float){
        self.x.set(x);
        self.y.set(y);
    }
    
    override func get()->(Float,Float){
        return (self.x.get(),self.y.get())
    }

    
    func clone()->Point{
        return Point(x:self.x.get(),y:self.y.get())
    }
    
    func add(point:Point)->Point{
        return Point(x:self.x.get()+point.x.get(),y:self.y.get()+point.y.get());
    }
    
    func sub(point:Point)->Point {
        return Point(x:self.x.get()-point.x.get(),y:self.y.get()-point.y.get());
    }
    
    func div(val:Float) ->Point{
        return Point(x: self.x.get() / val, y: self.y.get() / val);
    }
    
    func mul(val:Float)->Point {
        return Point(x: self.x.get() * val, y: self.y.get() * val);
    }
    
    func div(point:Point) ->Point{
        return Point(x:self.x.get() / point.x.get(), y: self.y.get() / point.y.get());
    }
    
    func mul(point:Point) ->Point{
        return Point(x:self.x.get() * point.x.get(), y:self.y.get() * point.y.get());
    }
    
    func dist(point:Point)->Float{
        return sqrtf(distanceSqrd(self,p2: point));
        
    }
    
    func distanceSqrd(p1:Point, p2:Point)->Float{
        return powf((p1.x.get()-p2.x.get()), 2.0)+powf((p1.y.get()-p2.y.get()), 2.0)
    }
    
    static func isCollinear(x1:Float, y1:Float, x2:Float, y2:Float)->Bool{

        return abs(x1 * y2 - y1 * x2) <= sqrt((x1 * x1 + y1 * y1) * (x2 * x2 + y2 * y2)) * Numerical.TRIGONOMETRIC_EPSILON;
        

    }
    
    static func isOrthoganal(x1:Float, y1:Float, x2:Float, y2:Float)->Bool{
        
        return abs(x1 * x2 + y1 * y2) <= sqrt((x1 * x1 + y1 * y1) * (x2 * x2 + y2 * y2)) * Numerical.TRIGONOMETRIC_EPSILON;
        
    }

    
    //Returns the length of a vector sqaured. Faster than Length(), but only marginally
    static func lengthSqrd(vec:Point)->Float {
    return pow(vec.x.get(), 2) + pow(vec.y.get(), 2);
    }
    
    //Returns the length of vector'
    func length()->Float {
    return sqrtf(Point.lengthSqrd(self));
    }
    
    //Returns a new vector that has the same direction as vec, but has a length of one.
    static func normalize(vec:Point)->Point {
    if (vec.x.get() == 0 && vec.y.get() == 0) {
        return vec;
    }
    
        return vec.div(vec.length());
    }
    
    //Computes the dot product of a and b'
    func dot(b:Point)->Float {
    return (self.x.get() * b.x.get()) + (self.y.get() * b.y.get());
    }
    
    func cross(point:Point)->Float {
        return self.x.get() * point.y.get() - self.y.get() * point.x.get();
    }
    
    static func projectOnto(v:Point, w:Point)->Point{
    //'Projects w onto v.'
    return v.mul(w.dot(v) / Point.lengthSqrd(v));
    }
    
    
    func pointAtDistance(d:Float,a:Float)->Point{
        let x = self.x.get() + (d * cos(a*Float(M_PI/180)))
        let y = self.y.get() + (d * sin(a*Float(M_PI/180)))
        return Point(x: x,y: y)
    }
    
    //returns new rotated point, original point is unaffected
    func rotate(angle:Float, origin:Point)->Point{
        let a = angle * Float(M_PI)/180;
        let centerX = origin.x.get();
        let centerY = origin.y.get();
        let x = self.x.get();
        let y = self.y.get();
        let newX = centerX + (x-centerX)*cos(a) - (y-centerY)*sin(a);
        
        let newY = centerY + (x-centerX)*sin(a) + (y-centerY)*cos(a);
        return Point(x:newX,y:newY)
    }
    

    
    
     
     func getDirectedAngle(point:Point)->Float {
     return atan2(self.cross(point), self.dot(point)) * 180 / Float(M_PI);
     }
     
     
    
    func toCGPoint()->CGPoint{
        return CGPoint(x:CGFloat(self.x.get()),y:CGFloat(self.y.get()))
    }
    
    
    
    
}
func ==(lhs: Point, rhs: Point) -> Bool {
    return lhs.x.get() == rhs.x.get() && lhs.y.get() == rhs.y.get()
}


