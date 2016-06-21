//
//  ArcBrush.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 5/26/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation
//brush that draws arcs of varying sizes
class ArcBrush:Brush{
    var currentArc:Arc?
    var arcs = [Arc]()
    required init(){
        super.init()
        self.name = "ArcBrush"
        
    }
    
    func setPosition(center:Point,startAngle:Float,endAngle:Float,radius:Float){
        
        currentArc = Arc(center:center,startAngle: startAngle,endAngle: endAngle,radius: radius);
        self.arcs.append(currentArc!);
        
        self.geometryModified.raise((currentArc!,"ARC","DRAW"))
        
    }

    
    /*func setPosition(p1:Point,length:Float,angle:Float,radius:Float){
        
        currentArc = Arc(point: p1,length: length,angle: angle,radius: radius);
        self.arcs.append(currentArc!);
        
        self.geometryModified.raise((currentArc!,"ARC","DRAW"))
    
    func setPosition(p1:Point,length:Float,angle:Float,radius:Float){
        
        currentArc = Arc(point: p1,length: length,angle: angle,radius: radius);
        self.arcs.append(currentArc!);
       
        self.geometryModified.raise((currentArc!,"ARC","DRAW"))
        
    }*/

    
    
    override func clone()->ArcBrush{
        return super.clone() as! ArcBrush;
    }

}
