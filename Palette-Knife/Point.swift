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
    var parentName = "stylus"
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
        let string = "\"x\":"+String(self.x.get(nil))+",\"y\":"+String(self.y.get(nil))
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
              didChange.raise((name, (oldValue,self.y.get(nil)), (self.x.get(nil),self.y.get(nil))))
        }
        else if(!x.constrained && y.constrained && name == "y"){
            didChange.raise((name, (self.x.get(nil),oldValue), (self.x.get(nil),self.y.get(nil))))
        }
        else{
       
            if(self.x.invalidated && self.y.invalidated){
                if(name == "x"){
                    didChange.raise((name, (oldValue,storedValue),(self.x.get(nil),self.y.get(nil))));
                }
                else if(name == "y"){
                    didChange.raise((name, (storedValue,oldValue),(self.x.get(nil),self.y.get(nil))));
                }
                
            }
            else{
                storedValue = oldValue;
            }
        }
    }
    
     func set(val:Point){
        let point = val 
        self.set(point.x.get(nil),y:point.y.get(nil))
    }
    
    func set(x:Float,y:Float){
        self.x.set(x);
        self.y.set(y);
    }
    
    override func get(id:String?)->(Float,Float){
        return (self.x.get(nil),self.y.get(nil))
    }

    
    func clone()->Point{
        return Point(x:self.x.get(nil),y:self.y.get(nil))
    }
    
    func add(point:Point)->Point{
        return Point(x:self.x.get(nil)+point.x.get(nil),y:self.y.get(nil)+point.y.get(nil));
    }
    
    func sub(point:Point)->Point {
        return Point(x:self.x.get(nil)-point.x.get(nil),y:self.y.get(nil)-point.y.get(nil));
    }
    
    func div(val:Float) ->Point{
        return Point(x: self.x.get(nil) / val, y: self.y.get(nil) / val);
    }
    
    func mul(val:Float)->Point {
        return Point(x: self.x.get(nil) * val, y: self.y.get(nil) * val);
    }
    
    func div(point:Point) ->Point{
        return Point(x:self.x.get(nil) / point.x.get(nil), y: self.y.get(nil) / point.y.get(nil));
    }
    
    func mul(point:Point) ->Point{
        return Point(x:self.x.get(nil) * point.x.get(nil), y:self.y.get(nil) * point.y.get(nil));
    }
    
    func dist(point:Point)->Float{
        return sqrtf(distanceSqrd(self,p2: point));
        
    }
    
    func distanceSqrd(p1:Point, p2:Point)->Float{
        return powf((p1.x.get(nil)-p2.x.get(nil)), 2.0)+powf((p1.y.get(nil)-p2.y.get(nil)), 2.0)
    }
    
    static func isCollinear(x1:Float, y1:Float, x2:Float, y2:Float)->Bool{

        return abs(x1 * y2 - y1 * x2) <= sqrt((x1 * x1 + y1 * y1) * (x2 * x2 + y2 * y2)) * Numerical.TRIGONOMETRIC_EPSILON;
        

    }
    
    static func isOrthoganal(x1:Float, y1:Float, x2:Float, y2:Float)->Bool{
        
        return abs(x1 * x2 + y1 * y2) <= sqrt((x1 * x1 + y1 * y1) * (x2 * x2 + y2 * y2)) * Numerical.TRIGONOMETRIC_EPSILON;
        
    }

    
    //Returns the length of a vector sqaured. Faster than Length(), but only marginally
    static func lengthSqrd(vec:Point)->Float {
    return pow(vec.x.get(nil), 2) + pow(vec.y.get(nil), 2);
    }
    
    //Returns the length of vector'
    func length()->Float {
    return sqrtf(Point.lengthSqrd(self));
    }
    
    //Returns a new vector that has the same direction as vec, but has a length of one.
    static func normalize(vec:Point)->Point {
    if (vec.x.get(nil) == 0 && vec.y.get(nil) == 0) {
        return vec;
    }
    
        return vec.div(vec.length());
    }
    
    //Computes the dot product of a and b'
    func dot(b:Point)->Float {
    return (self.x.get(nil) * b.x.get(nil)) + (self.y.get(nil) * b.y.get(nil));
    }
    
    func cross(point:Point)->Float {
        return self.x.get(nil) * point.y.get(nil) - self.y.get(nil) * point.x.get(nil);
    }
    
    static func projectOnto(v:Point, w:Point)->Point{
    //'Projects w onto v.'
    return v.mul(w.dot(v) / Point.lengthSqrd(v));
    }
    
    
    func pointAtDistance(d:Float,a:Float)->Point{
        let x = self.x.get(nil) + (d * cos(a*Float(M_PI/180)))
        let y = self.y.get(nil) + (d * sin(a*Float(M_PI/180)))
        return Point(x: x,y: y)
    }
    
    //returns new rotated point, original point is unaffected
    func rotate(angle:Float, origin:Point)->Point{
        let a = angle * Float(M_PI)/180;
        let centerX = origin.x.get(nil);
        let centerY = origin.y.get(nil);
        let x = self.x.get(nil);
        let y = self.y.get(nil);
        let newX = centerX + (x-centerX)*cos(a) - (y-centerY)*sin(a);
        
        let newY = centerY + (x-centerX)*sin(a) + (y-centerY)*cos(a);
        return Point(x:newX,y:newY)
    }
    

    
    
     
     func getDirectedAngle(point:Point)->Float {
     return atan2(self.cross(point), self.dot(point)) * 180 / Float(M_PI);
     }
     
     
    
    func toCGPoint()->CGPoint{
        return CGPoint(x:CGFloat(self.x.get(nil)),y:CGFloat(self.y.get(nil)))
    }
    
    
    
    
}
func ==(lhs: Point, rhs: Point) -> Bool {
    return lhs.x.get(nil) == rhs.x.get(nil) && lhs.y.get(nil) == rhs.y.get(nil)
}


