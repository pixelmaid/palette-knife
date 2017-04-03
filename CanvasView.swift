//
//  CanvasView.swift
//  Palette-Knife
//
//  Created by JENNIFER MARY JACOBS on 5/4/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import UIKit

class CanvasView:  UIImageView {
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
    
    
    override func drawRect(rect: CGRect) {
        
    }
    
    func redrawAll(strokeList:[Stroke]){
        self.clear();
        UIGraphicsBeginImageContext(self.frame.size)
        let context = UIGraphicsGetCurrentContext()!
        self.image?.drawInRect(CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        
        print("redraw all strokes \(strokeList.count)");
        
        for i in 0..<strokeList.count{
            let stroke = strokeList[i];
            self.drawSingleStroke(stroke,i:i,context:context);
        }
        
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    
    func drawSingleStroke(stroke:Stroke,i:Int,context:CGContext){
        var c:Color;
       
        for j in 1..<stroke.segments.count{
          
            let seg = stroke.segments[j];
            if(stroke.selected){
                c = ToolManager.defaultSelectedColor;
            }
                
            else{
                print("segment color \(seg.color)")
                c = seg.color;
            }
            self.drawPath((seg.getPreviousSegment()?.point)!,tP:seg.point,w:ToolManager.defaultPenDiameter, c:c,context:context)
        }
    }
    
    
    
    func drawPath(fP: Point, tP: Point, w:Float, c:Color, context:CGContext) {
        
        let color = c.toCGColor();
        let fromPoint = fP.toCGPoint();
        let toPoint = tP.toCGPoint();
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, CGFloat(w))
        CGContextSetStrokeColorWithColor(context, color)
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        CGContextMoveToPoint(context, fromPoint.x,fromPoint.y)
        CGContextAddLineToPoint(context,  toPoint.x,toPoint.y)
        CGContextStrokePath(context)
        
        
        
    }
    
    func drawIsolatedPath(fP: Point, tP: Point, w:Float, c:Color) {
        UIGraphicsBeginImageContext(self.frame.size)
        let context = UIGraphicsGetCurrentContext()!
        self.image?.drawInRect(CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        
        let color = c.toCGColor();
        let fromPoint = fP.toCGPoint();
        let toPoint = tP.toCGPoint();
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, CGFloat(w))
        CGContextSetStrokeColorWithColor(context, color)
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        CGContextMoveToPoint(context, fromPoint.x,fromPoint.y)
        CGContextAddLineToPoint(context,  toPoint.x,toPoint.y)
        CGContextStrokePath(context)
        
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
    }
    
    
    func drawArc(center:Point, radius:Float,startAngle:Float,endAngle:Float, w:Float, c:Color){
        UIGraphicsBeginImageContext(self.frame.size)
        let context = UIGraphicsGetCurrentContext()!
        self.image?.drawInRect(CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        
        let color = c.toCGColor();
        
        
        let _center = center.toCGPoint()
        let _radius = CGFloat(radius);
        let _startAngle = CGFloat(Float(M_PI/180)*startAngle)
        let _endAngle = CGFloat(Float(M_PI)/180*endAngle)
        
        let path = CGPathCreateMutable();
        
        CGPathAddArc(path, nil, _center.x, _center.y, _radius, _startAngle, _endAngle, false)
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, CGFloat(w))
        CGContextSetStrokeColorWithColor(context, color)
        
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        CGContextAddPath(context, path)
        CGContextStrokePath(context)
        
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        self.alpha = 1
        UIGraphicsEndImageContext()
        
        
    }
    
    func drawPolygon(){
        
    }
    
    func clear(){
        self.image = nil
    }
    
    func drawFlower(position:Point){
        UIGraphicsBeginImageContext(self.frame.size)
        
        let context = UIGraphicsGetCurrentContext()
        self.image?.drawInRect(CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        
        let color3 = UIColor(red: 0.754, green: 0.101, blue: 0.876, alpha: 1.000)
        
        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalInRect: CGRect(x: CGFloat(position.x.get(nil)-52/2), y: CGFloat(position.y.get(nil)-46/2), width: 52, height: 46))
        color3.setFill()
        ovalPath.fill()
        
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        self.alpha = 1
        UIGraphicsEndImageContext()
        
        
    }
    
    
    func drawLeaf(position:Point,angle:Float,scale:Float){
        //// General Declarations
        UIGraphicsBeginImageContext(self.frame.size)
        
        let context = UIGraphicsGetCurrentContext()
        self.image?.drawInRect(CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        
        //// Color Declarations
        let color = UIColor(red: 0.000, green: 1.000, blue: 0.069, alpha: 1.000)
        let color2 = UIColor(red: 0.207, green: 0.397, blue: 0.324, alpha: 1.000)
        
        //// Group
        CGContextSaveGState(context!)
        CGContextTranslateCTM(context!, position.toCGPoint().x, position.toCGPoint().y)
        CGContextRotateCTM(context!,(50+CGFloat(angle)) * CGFloat(M_PI) / 180)
        CGContextScaleCTM(context!, CGFloat(scale), CGFloat(scale))
        
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 0.54, y: 0))
        bezierPath.addCurveToPoint(CGPoint(x: 48.17, y: -18.48), controlPoint1: CGPoint(x: 0.54, y: 0), controlPoint2: CGPoint(x: 34.57, y: -2.64))
        bezierPath.addCurveToPoint(CGPoint(x: 54.98, y: -66), controlPoint1: CGPoint(x: 61.78, y: -34.32), controlPoint2: CGPoint(x: 54.98, y: -66))
        bezierPath.addCurveToPoint(CGPoint(x: 7.35, y: -40.92), controlPoint1: CGPoint(x: 54.98, y: -66), controlPoint2: CGPoint(x: 17.56, y: -58.08))
        bezierPath.addCurveToPoint(CGPoint(x: 0.54, y: 0), controlPoint1: CGPoint(x: -2.86, y: -23.76), controlPoint2: CGPoint(x: 0.54, y: 0))
        bezierPath.closePath()
        color.setFill()
        bezierPath.fill()
        color2.setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()
        
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.moveToPoint(CGPoint(x: -0.32, y: 0))
        bezier2Path.addCurveToPoint(CGPoint(x: 54.68, y: -66), controlPoint1: CGPoint(x: -0.32, y: 0), controlPoint2: CGPoint(x: 21.94, y: -49.18))
        color.setFill()
        bezier2Path.fill()
        color2.setStroke()
        bezier2Path.lineWidth = 1
        bezier2Path.stroke()
        
        
        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.moveToPoint(CGPoint(x: 6.68, y: -12))
        bezier3Path.addCurveToPoint(CGPoint(x: 47.68, y: -18), controlPoint1: CGPoint(x: 6.68, y: -12), controlPoint2: CGPoint(x: 34.68, y: -10))
        color.setFill()
        bezier3Path.fill()
        color2.setStroke()
        bezier3Path.lineWidth = 1
        bezier3Path.stroke()
        
        
        //// Bezier 4 Drawing
        let bezier4Path = UIBezierPath()
        bezier4Path.moveToPoint(CGPoint(x: 16.68, y: -29))
        bezier4Path.addCurveToPoint(CGPoint(x: 56.68, y: -44), controlPoint1: CGPoint(x: 16.68, y: -29), controlPoint2: CGPoint(x: 48.47, y: -36))
        color.setFill()
        bezier4Path.fill()
        color2.setStroke()
        bezier4Path.lineWidth = 1
        bezier4Path.stroke()
        
        
        //// Bezier 5 Drawing
        let bezier5Path = UIBezierPath()
        bezier5Path.moveToPoint(CGPoint(x: 16.68, y: -29))
        bezier5Path.addCurveToPoint(CGPoint(x: 12.68, y: -46), controlPoint1: CGPoint(x: 16.68, y: -29), controlPoint2: CGPoint(x: 8.68, y: -36))
        color2.setStroke()
        bezier5Path.lineWidth = 1
        bezier5Path.stroke()
        
        
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        self.alpha = 1
        UIGraphicsEndImageContext()
        
        
        
    }
    
    
    
}
