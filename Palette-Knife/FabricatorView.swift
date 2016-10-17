//
//  FabricatorView.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 10/17/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation
import UIKit

class FabricatorView:  UIImageView {
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
    override func drawRect(rect: CGRect) {
    }
    
    func clear(){
        self.image = nil
    }
    
    func drawFabricatorPosition(x:Float,y:Float,z:Float) {
        self.clear();
        UIGraphicsBeginImageContext(self.frame.size)
        let context = UIGraphicsGetCurrentContext()!
        self.image?.drawInRect(CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        
        let color = Color(r:0,g:255,b:0)
        
        let _x = Numerical.map(x, istart:0, istop: GCodeGenerator.inX, ostart: 0, ostop: GCodeGenerator.pX)
        
        let _y = Numerical.map(y, istart:0, istop:GCodeGenerator.inY, ostart:  GCodeGenerator.pY, ostop: 0 )
        print("X,Y \(_x,_y)")
        
        let fromPoint = CGPoint(x:CGFloat(_x),y:CGFloat(_y));
        let toPoint = CGPoint(x:CGFloat(_x),y:CGFloat(_y));

        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, CGFloat(10))
        CGContextSetStrokeColorWithColor(context, color.toCGColor())
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        CGContextMoveToPoint(context, fromPoint.x,fromPoint.y)
        CGContextAddLineToPoint(context,  toPoint.x,toPoint.y)
        CGContextStrokePath(context)
        
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        self.alpha = 1
        UIGraphicsEndImageContext()
        
        
}
}

