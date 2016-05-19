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


class Stroke{
    var segments = [Segment]();
    
    
    init(){
        
    }
    
}

struct Segment {
    
    var point = Point(x:0,y:0);
    var diameter = Float(0);
    var color = Color(r:0,g:0,b:0);
    
    init(x:Float,y:Float) {
        self.point.x=x;
        self.point.y=y;
    }
    
    
}