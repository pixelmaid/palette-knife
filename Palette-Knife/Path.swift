//
//  Stroke.swift
//  Palette-Knife
//
//  Created by JENNIFER MARY JACOBS on 5/5/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//
import Foundation

enum DrawError: ErrorType {
    case InvalidArc
    
}
protocol Geometry {
    
}

// Segment: line segement described as two points
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

struct Arc {
    
    var throughPoint: Point
    var fromPoint: Point
    var toPoint: Point
    var center: Point
    var radius: Float
    var startAngle: Float
    var endAngle: Float
    var clockwise: Bool
    
    init(fromPoint:Point,angle:Float,length:Float){
        self.fromPoint = fromPoint;
        self.toPoint = fromPoint.pointAtDistance(length,a:angle)
    }
    
    init(center:Point,radius:Float,startAngle:Float,endAngle:Float,clockwise:Bool){
        self.center = center
        self.radius = radius
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.clockwise = clockwise
    }
    
    static func lineTo(to:Point) {
        // Let's not be picky about calling moveTo() first:
        //this._add([ new Segment(Point.read(arguments)) ]);
    }
    
    
    static func arcTo( from:Point, through:Point, to:Point) throws{
        // Calculate center, vector and extend for non SVG versions:
        // Construct the two perpendicular middle lines to
        // (from, through) and (through, to), and intersect them to get
        // the center.
        var l1 = Line(p:from.add(through).div(2), v: through.sub(from).rotate(90), asVector: true)
        var l2 = Line(p: through.add(to).div(2),v: to.sub(through).rotate(90), asVector: true)
        var line = Line(p: from, v: to, asVector: false)
        var throughSide = line.getSide(through,isInfinite: false);
        var center = l1.intersect(l2, isInfinite: true);
        
        // If the two lines are collinear, there cannot be an arc as the
        // circle is infinitely big and has no center point. If side is
        // 0, the connecting arc line of this huge circle is a line
        // between the two points, so we can use #lineTo instead.
        // Otherwise we bail out:
        if (center != nil) {
            if (throughSide != nil){
                return self.lineTo(to);
            }
            throw DrawError.InvalidArc
        }
            var vector = from.sub(center!);
            var extent = vector.getDirectedAngle(to.sub(center!));
            var centerSide = line.getSide(center!, isInfinite: false);
            if (centerSide! == 0) {
                // If the center is lying on the line, we might have gotten
                // the wrong sign for extent above. Use the sign of the side
                // of the through point.
                extent = Float(throughSide!) * abs(extent);
            } else if (throughSide! == centerSide!) {
                // If the center is on the same side of the line (from, to)
                // as the through point, we're extending bellow 180 degrees
                // and need to adapt extent.
                extent += extent < 0 ? 360 : -360;
            }
            
            var ext = abs(extent)
            var count:Float
            if ext >= 360{
                count = 4
            }
            else{
                count = ceil(ext / 90)
            }
            var inc = extent / count
            var half = inc *  Float(M_PI/360)
            var z = 4 / 3 *  sin(half) / (1 + cos(half));
            var segments = [];
            for i in 0...Int(count) {
                // Explicitly use to point for last segment, since depending
                // on values the calculation adds imprecision:
                var pt = to
                var out:Point
                if (i < Int(count)) {
                    out = vector.rotate(90).mul(z);
                    
                    pt = center!.add(vector);
                    
                }
                if (i == 0) {
                    // Modify startSegment
                    //current.setHandleOut(out);
                } else {
                    // Add new Segment
                    var _in = vector.rotate(-90).mul(z);
                    
                    segments.push(Segment(pt, _in, out));
                }
                vector = vector.rotate(inc);
            }
        }
            // Add all segments at once at the end for higher performance
            //this._add(segments);
         
}
        

