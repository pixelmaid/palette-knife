//
//  Color.swift
//  Palette-Knife
//
//  Created by JENNIFER MARY JACOBS on 5/5/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation
import UIKit

struct Color {
    var r = Float(0);
    var g = Float(0);
    var b = Float(0);
    var a = Float(1);
    var h = Float(0);
    var s = Float(0);
    var l = Float(0);
    
    init(r:Float,g:Float,b:Float,a:Float){
        self.r = r;
        self.g = g;
        self.b = b;
        self.a = a;
        let uicolor = UIColor(red:CGFloat(self.r/255),green:CGFloat(self.g/255),blue:CGFloat(self.b/255), alpha:CGFloat(a));
        var ch: CGFloat = 0
        var cs: CGFloat = 0
        var cl: CGFloat = 0
        var ca: CGFloat = 0

        uicolor.getHue(&ch, saturation: &cs, brightness: &cl, alpha: &ca)
        
        self.h = Float(ch)*360.0;
        self.s = Float(ch);

        self.l = Float(ch);

        
    }
    
    init(h:Float,s:Float,l:Float,a:Float){
        self.h = h;
        self.s = s;
        self.l = l;
        self.a = a;
        let uicolor = UIColor(hue:CGFloat(h/360),saturation:CGFloat(self.s),brightness:CGFloat(self.l), alpha:CGFloat(a));
        var cr: CGFloat = 0
        var cg: CGFloat = 0
        var cb: CGFloat = 0
        var ca: CGFloat = 0
        
        uicolor.getRed(&cr, green: &cb, blue: &cg, alpha: &ca)
        
        self.r = Float(cr)*255;
        self.g = Float(cg)*255;
        
        self.b = Float(cb)*255;
        
    }
    
    mutating func setValue(value:Color){
        self.r = value.r;
        self.g = value.g;
        self.b = value.b;
        self.a = value.a;
        
        let uicolor = UIColor(red:CGFloat(self.r/255),green:CGFloat(self.g/255),blue:CGFloat(self.b/255), alpha:CGFloat(a));
        var ch: CGFloat = 0
        var cs: CGFloat = 0
        var cl: CGFloat = 0
        var ca: CGFloat = 0
        
        uicolor.getHue(&ch, saturation: &cs, brightness: &cl, alpha: &ca)
        
        self.h = Float(ch);
        self.s = Float(ch);
        
        self.l = Float(ch);

    }
    
    
    
    func toCGColor()->CGColor{
        let uicolor = UIColor(red:CGFloat(self.r/255),green:CGFloat(self.g/255),blue:CGFloat(self.b/255), alpha:CGFloat(a));
        return uicolor.CGColor;
    }
    
}
