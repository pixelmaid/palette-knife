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
        print("draw rect called")
    }
    
    func drawPath(fP: Point, tP: Point, w:Float, c:Color) {
       print("drawPath\(fP.x,fP.y,tP.x,tP.y,w,c)")
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
        self.alpha = 1
        UIGraphicsEndImageContext()


        }
    
    func drawPolygon(){
        
    }
    


}
