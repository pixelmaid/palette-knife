//
//  Line.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 5/26/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation
class Line: Geometry{
    
    var p: Point
    var v: Point
    
    init(px:Float,py:Float,vx:Float,vy:Float, asVector:Bool) {
        
        self.p = Point(x:px,y:py)
        self.v = Point(x:vx,y:vy)
    
        if (!asVector) {
            self.v = self.v.sub(self.p)
        }
    }
    
    init(p:Point,v:Point, asVector:Bool) {
        
        self.p = p
        self.v = v
        
        if (asVector) {
            self.v = self.v.sub(self.p)
        }
    }
    
    init(p:Point,length:Float,angle:Float, asVector:Bool) {
        
        self.p = p;
        self.v = p.pointAtDistance(length, a: angle)
        if (asVector) {
            self.v = self.v.sub(self.p)
        }
    }
    func toJSON()->String{
        let string = "\"p\":{"+self.p.toJSON()+"},\"v\":{"+self.v.toJSON()+"}"
        return string
    }


    
    /**
     * The starting point of the line.
     */
    func getPoint()->Point{
        return self.p
    }
    
    /**
     * The direction of the line as a vector.
     */
    func getVector()->Point {
        return self.v
    }
    
    /**
     * The length of the line.
     *
     */
    func getLength()->Float {
        return (self.getVector().length());
    }
    
    /**
     * @return {Point} the intersection point of the lines, `undefined` if the
     *     two lines are collinear, or `null` if they don't intersect.
     */
    func intersect(line:Line,  isInfinite:Bool)->Point?{
        return Line.intersect(self.p.x.get(), p1y: self.p.y.get(), v1x: self.v.x.get(), v1y: self.v.y.get(),p2x: line.p.x.get(), p2y: line.p.y.get(), v2x: line.v.x.get(), v2y: line.v.y.get(), asVector:true, isInfinite: isInfinite);
    }
    
    
    /**
     * @return {Number}
     */
    func getSide(point:Point, isInfinite:Bool)->Int? {
        return Line.getSide(self.p.x.get(), py: self.p.y.get(), vx: self.v.x.get(), vy: self.v.y.get(), x: point.x.get(), y: point.y.get(), isInfinite: isInfinite);
    }
    
       /**
     * @param {Point} point
     * @return {Number}
     */
    func getDistance(point:Point)->Float {
        return abs(Line.getSignedDistance(self.p.x.get(), py: self.p.y.get(), vx: self.v.x.get(), vy: self.v.y.get(), x: point.x.get(), y: point.y.get()));
    }
    
    func isCollinear(line:Line)->Bool {
        return Point.isCollinear(self.v.x.get(), y1: self.v.y.get(), x2: line.v.x.get(), y2: line.v.y.get());
    }
    
    func isOrthogonal(line:Line)->Bool {
        return Point.isOrthoganal(self.v.x.get(), y1: self.v.y.get(), x2: line.v.x.get(), y2: line.v.y.get());
    }
    
    func getSlope()->Float{
        return (v.y.get()-p.y.get())/(v.x.get()-p.x.get())
    }
    
    func getYIntercept()->Float{
        return -getSlope()*p.x.get()+p.y.get()
    }
    
    func getMidpoint()->Point{
        return Point(x:(p.x.get()+v.x.get())/2,y:(p.y.get()+v.y.get())/2)
    }
    
    
    
    //statics: /** @lends Line */{
    static func intersect(p1x:Float, p1y:Float, var v1x:Float, var v1y:Float, p2x:Float, p2y:Float, var v2x:Float, var v2y:Float, asVector:Bool, isInfinite:Bool)->Point? {
           
        if (!asVector) {
            v1x -= p1x;
            v1y -= p1y;
            v2x -= p2x;
            v2y -= p2y;
        }
       let cross = v1x * v2y - v1y * v2x;

           // Avoid divisions by 0, and errors when getting too close to 0
            if (!Numerical.isZero(cross)) {
                var dx = p1x - p2x,
                dy = p1y - p2y,
                u1 = (v2x * dy - v2y * dx) / cross,
                u2 = (v1x * dy - v1y * dx) / cross,
                // Check the ranges of the u parameters if the line is not
                // allowed to extend beyond the definition points, but
                // compare with EPSILON tolerance over the [0, 1] bounds.
                epsilon = Numerical.EPSILON,
                uMin = -epsilon,
                uMax = 1 + epsilon;
                if (isInfinite || uMin < u1 && u1 < uMax && uMin < u2 && u2 < uMax) {
                    if (!isInfinite) {
                        // Address the tolerance at the bounds by clipping to
                        // the actual range.
                        u1 = u1 <= 0 ? 0 : u1 >= 1 ? 1 : u1;
                    }
                    return Point(x:p1x + u1 * v1x,y:p1y + u1 * v1y);
                }
            }
            return nil
        }
        
        static func getSide(px:Float, py:Float, vx:Float, vy:Float, x:Float, y:Float, isInfinite:Bool)->Int {
            var v2x = x - px,
            v2y = y - py,
            // ccw = v2.cross(v1);
            ccw = v2x * vy - v2y * vx;
            if (ccw == Float(0.0) && !isInfinite) {
                // If the point is on the infinite line, check if it's on the
                // finite line too: Project v2 onto v1 and determine ccw based
                // on which side of the finite line the point lies. Calculate
                // the 'u' value of the point on the line, and use it for ccw:
                // u = v2.dot(v1) / v1.dot(v1)
                ccw = (v2x * vx + v2x * vx) / (vx * vx + vy * vy);
                // If the 'u' value is within the line range, set ccw to 0,
                // otherwise its already correct sign is all we need.
                if (ccw >= 0 && ccw <= 1){
                    ccw = 0;
                    }
            }
            if (ccw < 0){
            return -1
            }
            else if (ccw>0){
                return 1
            }
            else{
                return 0
            }
        }
        
        static func getSignedDistance(px:Float, py:Float, vx:Float, vy:Float, x:Float, y:Float)->Float {
            if(vx == Float(0)){
                if(vy >  Float(0)){
                  return x - px
                }
                else{
                    return px - x
                }
            }
            else if (vy ==  Float(0)){
                if(vx <  Float(0)){
                    return y - py
                }
                else{
                    return py - y
                }
             
            }
            else{
                  return ((x-px) * vy - (y-py) * vx) / sqrt(vx * vx + vy * vy);
            }
            
        }
    
    
    }
