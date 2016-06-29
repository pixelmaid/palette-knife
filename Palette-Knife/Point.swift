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

struct Point: Property{
  
    var x = Float(0);
    var y = Float(0);
    var angle = Float(0);
    var diameter = Float(0);
    var color = Color(r:0,g:0,b:0);
    
    init(x:Float,y:Float) {
        self.x=x;
        self.y=y;
        self.angle = atan2(y, x) * Float(180 / M_PI);
    }
    
    func toJSON()->String{
        let string = "\"x\":"+String(self.x)+",\"y\":"+String(self.y)
        return string;
    }
    
    func add(point:Point)->Point{
        return Point(x:self.x+point.x,y:self.y+point.y);
    }
    
    func sub(val:Point)->Point {
    return Point(x: self.x - val.x, y: self.y - val.y);
    }
    
    func div(val:Float) ->Point{
        return Point(x: self.x / val, y: self.y / val);
    }
    
    func mul(val:Float)->Point {
        return Point(x: self.x * val, y: self.y * val);
    }
    
    func div(point:Point) ->Point{
        return Point(x:self.x / point.x, y: self.y / point.y);
    }
    
    func mul(point:Point) ->Point{
        return Point(x:self.x * point.x, y:self.y * point.y);
    }
    
    func dist(point:Point)->Float{
        return sqrtf(distanceSqrd(self,p2: point));
        
    }
    
    func distanceSqrd(p1:Point, p2:Point)->Float{
        return powf((p1.x-p2.x), 2.0)+powf((p1.y-p2.y), 2.0)
    }
    
    static func isCollinear(x1:Float, y1:Float, x2:Float, y2:Float)->Bool{

        return abs(x1 * y2 - y1 * x2) <= sqrt((x1 * x1 + y1 * y1) * (x2 * x2 + y2 * y2)) * Numerical.TRIGONOMETRIC_EPSILON;
        

    }
    
    static func isOrthoganal(x1:Float, y1:Float, x2:Float, y2:Float)->Bool{
        
        return abs(x1 * x2 + y1 * y2) <= sqrt((x1 * x1 + y1 * y1) * (x2 * x2 + y2 * y2)) * Numerical.TRIGONOMETRIC_EPSILON;
        
    }

    
    //Returns the length of a vector sqaured. Faster than Length(), but only marginally
    static func lengthSqrd(vec:Point)->Float {
    return pow(vec.x, 2) + pow(vec.y, 2);
    }
    
    //Returns the length of vector'
    func length()->Float {
    return sqrtf(Point.lengthSqrd(self));
    }
    
    //Returns a new vector that has the same direction as vec, but has a length of one.
    static func normalize(vec:Point)->Point {
    if (vec.x == 0 && vec.y == 0) {
        return vec;
    }
    
        return vec.div(vec.length());
    }
    
    //Computes the dot product of a and b'
    func dot(b:Point)->Float {
    return (self.x * b.x) + (self.y * b.y);
    }
    
    func cross(point:Point)->Float {
        return self.x * point.y - self.y * point.x;
    }
    
    static func projectOnto(v:Point, w:Point)->Point{
    //'Projects w onto v.'
    return v.mul(w.dot(v) / Point.lengthSqrd(v));
    }
    
    
    func pointAtDistance(d:Float,a:Float)->Point{
        let x = self.x + (d * cos(a*Float(M_PI/180)))
        let y = self.y + (d * sin(a*Float(M_PI/180)))
        return Point(x: x,y: y)
    }
    
    func rotate(angle:Float)->Point{
        let l = self.length();
        return Point(x:0,y:0).pointAtDistance(l,a:angle);
    }
    
    mutating func setValue(value:Point){
        x = value.x;
        y = value.y;
    }
    
    func toCGPoint()->CGPoint{
        return CGPoint(x:CGFloat(self.x),y:CGFloat(self.y))
    }
    
    func getDirectedAngle(point:Point)->Float {
    return atan2(self.cross(point), self.dot(point)) * 180 / Float(M_PI);
    }
    
    
    
}



