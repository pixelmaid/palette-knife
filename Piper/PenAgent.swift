//
//  PenAgent.swift
//  DrawPad
//
//  Created by JENNIFER MARY JACOBS on 1/28/16.
//

import Foundation
import UIKit

class PenAgent {
    
    var lastPoint: Point;
    var points = [Point]();
    
    
    init() {
        lastPoint = Point(x:0,y:0);
        }
    
    func addPoint(x: Float, y:Float){
        points.append(Point(x:x,y:y));
        lastPoint = points[points.count-1];
    }
    
    func setLastPoint(x:Float, y:Float){
        lastPoint.x = x;
        lastPoint.y = y;

    }
    
    func checkProximity(point:Point,threshold:Float)->[Point]{
        var closePoints = [Point]()
        if(points.count>0){
        for index in 0...points.count-1{
            if(points[index].dist(point)<threshold){
                closePoints.append(points[index]);
            }
            }
        }
        return closePoints;
        
    }
    
    func getLastPoint() -> CGPoint{
        return CGPoint(x:CGFloat(lastPoint.x),y:CGFloat(lastPoint.y));
    }
}

struct Point {
    
    var x = Float(0);
    var y = Float(0);
    var diameter = Float(0);
    var color = Color(r:0,g:0,b:0);
    init(x:Float,y:Float) {
        self.x=x;
        self.y=y;
    }
    
    func dist(point:Point)->Float{
        return sqrtf(distanceSqrd(self,p2: point));
    
    }

    func distanceSqrd(p1:Point, p2:Point)->Float{
        return powf((p1.x-p2.x), 2.0)+powf((p1.y-p2.y), 2.0)
    }
    
    
}

struct Color {
    var r = 0;
    var g = 0;
    var b = 0;
    
}