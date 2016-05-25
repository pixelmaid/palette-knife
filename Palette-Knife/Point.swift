//
//  Point.swift
//  Palette-Knife
//
//  Created by JENNIFER MARY JACOBS on 5/5/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation
import UIKit

struct Point {
    
    var x = Float(0);
    var y = Float(0);
    var diameter = Float(0);
    var color = Color(r:0,g:0,b:0);
    
    init(x:Float,y:Float) {
        self.x=x;
        self.y=y;
    }
    
    func add(point:Point)->Point{
        return Point(x:self.x+point.x,y:self.y+point.y);
    }
    
    func dist(point:Point)->Float{
        return sqrtf(distanceSqrd(self,p2: point));
        
    }
    
    func distanceSqrd(p1:Point, p2:Point)->Float{
        return powf((p1.x-p2.x), 2.0)+powf((p1.y-p2.y), 2.0)
    }
    
    mutating func setValue(value:Point){
        x = value.x;
        y = value.y;
    }
    
    func toCGPoint()->CGPoint{
        return CGPoint(x:CGFloat(self.x),y:CGFloat(self.y))
    }
    
    
    
}

