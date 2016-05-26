//
//  Stroke.swift
//  Palette-Knife
//
//  Created by JENNIFER MARY JACOBS on 5/5/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//
import Foundation

// Stroke: Model for storing a stroke object in multiple representations
// as a series of segments
// as a series of vectors over time


class Stroke:Geometry {
    var segments = [Segment]();
    
    
    init(){
        
    }
    
    func addSegment(segment:Segment)->Segment{
        segments.append(segment)
        return segment
    }
    
    func addSegment(fromPoint:Point,toPoint:Point)->Segment{
        let segment = Segment(fromPoint:fromPoint,toPoint:toPoint)
        return self.addSegment(segment)
    }
    
}

struct Segment:Geometry {
    
    var fromPoint:Point;
    var toPoint:Point;

    var diameter = Float(0);
    var color = Color(r:0,g:0,b:0);
    
    init(fromX:Float,fromY:Float,toX:Float,toY:Float) {
        self.fromPoint = Point(x: fromX,y:fromY)
        self.toPoint = Point(x: toX,y:toY)

    }
    
    init(fromPoint:Point,toPoint:Point) {
        self.fromPoint = fromPoint
        self.toPoint = toPoint
    }

    
    
}

protocol Geometry {
    
}