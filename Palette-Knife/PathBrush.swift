//
//  PathBrush.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 5/25/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation


class PathBrush:Brush{
    var currentStroke:Stroke?;
    var strokes = [Stroke]();
    
    required init(){
        super.init()
        self.name = "PathBrush"
    }
    
    override func clone()->PathBrush{
        return super.clone() as! PathBrush;
    }
    
   override func setPosition(value:Point){
    super.setPosition(value);
        if((self.penDown) && (self.prevPosition != nil)){
            self.addSegmentToStroke(self.prevPosition,toPoint: self.position);
        }
        print("position \(self.position)")

    }
    
    override func setPenDown(value:Bool){
        super.setPenDown(value)
        if(!self.penDown){
            self.currentStroke = nil
            self.prevPosition = nil
            self.position = nil
        }
        print("pendown \(self.penDown)")
    }
    
    func addSegmentToStroke(fromPoint:Point,toPoint:Point){
        if(self.currentStroke == nil){
            self.currentStroke = Stroke();
            self.strokes.append(self.currentStroke!)
        }
        
        let seg = self.currentStroke!.addSegment(fromPoint,toPoint:toPoint)
        self.geometryModified.raise((seg,"SEGMENT","DRAW"))
        
       
    }
    
    
}