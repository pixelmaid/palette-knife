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
    
    var point:Point;
    var handleIn: Point;
    var handleOut: Point;
    var path:Stroke?;
    var index:Int?
    var diameter = Float(0);
    var color = Color(r:0,g:0,b:0);
    
    init(x:Float,y:Float) {
        self.init(x:x,y:y,hi_x:0,hi_y:0,ho_x:0,ho_y:0)
    }
    
    init(point:Point){
        self.init(point:point,handleIn:Point(x: 0, y: 0),handleOut:Point(x: 0, y: 0))
    }
    
    init(x:Float,y:Float,hi_x:Float,hi_y:Float,ho_x:Float,ho_y:Float){
        let point = Point(x:x,y:y)
        let hI = Point(x: hi_x,y: hi_y)
        let hO = Point(x: ho_x,y: ho_y)
        self.init(point:point,handleIn:hI,handleOut:hO)

    }
    
    init(point:Point,handleIn:Point,handleOut:Point) {
        self.point = point
        self.handleIn = handleIn
        self.handleOut = handleOut
    }
    
    
    func getPreviousSegment()->Segment?{
        if(self.path != nil){
            if(self.index>0){
                return path!.segments[self.index!-1]
            }
        }
        return nil
    }
    
    
    
    
}

// Stroke: Model for storing a stroke object in multiple representations
// as a series of segments
// as a series of vectors over time
class Stroke:Geometry {
    var segments = [Segment]();
    
    
    init(){
        
    }
    
    func addSegment(var segment:Segment)->Segment{
        segment.path = self
        segment.index = self.segments.count;
        segments.append(segment)
        return segment
    }
    
    func addSegment(point:Point)->Segment{
        let segment = Segment(point:point)
        return self.addSegment(segment)
    }
    
    func addSegment(segments:[Segment])->[Segment]{
        for i in 0...segments.count-1{
            self.addSegment(segments[i])
        }
        
        return segments
    }
    
    
    
    /*init(fromPoint:Point,angle:Float,length:Float){
        self.fromPoint = fromPoint;
        self.toPoint = fromPoint.pointAtDistance(length,a:angle)
    }
    
    init(center:Point,radius:Float,startAngle:Float,endAngle:Float,clockwise:Bool){
        self.center = center
        self.radius = radius
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.clockwise = clockwise
    }*/
    
   func lineTo(to:Point) {
        // Let's not be picky about calling moveTo() first:
        let seg = Segment(point:to)
        self.addSegment(seg);
    }
    
    
    func arcTo(from:Point, through:Point, to:Point) throws{
        // Calculate center, vector and extend for non SVG versions:
        // Construct the two perpendicular middle lines to
        // (from, through) and (through, to), and intersect them to get
        // the center.
        let l1 = Line(p:from.add(through).div(2), v: through.sub(from).rotate(90), asVector: true)
        let l2 = Line(p: through.add(to).div(2),v: to.sub(through).rotate(90), asVector: true)
        let line = Line(p: from, v: to, asVector: false)
        let throughSide = line.getSide(through,isInfinite: false);
        let center = l1.intersect(l2, isInfinite: true);
       
        
        //print("throughSide:\(throughSide) l1:\(l1.p,l1.v) l2:\(l2.p,l2.v) center:\(center)")
        // If the two lines are collinear, there cannot be an arc as the
        // circle is infinitely big and has no center point. If side is
        // 0, the connecting arc line of this huge circle is a line
        // between the two points, so we can use #lineTo instead.
        // Otherwise we bail out:
        if (center == nil) {
            if (throughSide == nil){
                return self.lineTo(to);
            }
            throw DrawError.InvalidArc
        }
         print("line: \(line.p.x,line.p.y,line.v.x,line.v.y)l1:\(l1.p.x,l1.p.y,l1.v.x,l1.v.y) l2:\(l2.p.x, l2.p.y,l2.v.x,l2.v.y) center:\(center!.x,center!.y)\n\n")
            var vector = from.sub(center!);
            var extent = vector.getDirectedAngle(to.sub(center!));
            let centerSide = line.getSide(center!, isInfinite: false);
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
            
            let ext = abs(extent)
            var count:Float
            if ext >= 360{
                count = 4
            }
            else{
                count = ceil(ext / 90)
            }
            let inc = extent / count
            let half = inc *  Float(M_PI/360)
            let z = 4 / 3 *  sin(half) / (1 + cos(half));
            var segments = [Segment]();
            for i in 0...Int(count-1) {
                // Explicitly use to point for last segment, since depending
                // on values the calculation adds imprecision:
                var pt = to
                let out = vector.rotate(90).mul(z);
                pt = center!.add(vector);
                    
                
                if (i == 0) {
                    // Modify startSegment
                    //current.setHandleOut(out);
                } else {
                    // Add new Segment
                    let _in = vector.rotate(-90).mul(z);
                    
                    segments.append(Segment(point: pt, handleIn: _in, handleOut: out));
                }
                vector = vector.rotate(inc);
            }
        
            // Add all segments at once at the end for higher performance
           self.addSegment(segments);
        }
    }


        

