//
//  PathBrush.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 5/25/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

//Basic path drawing brush
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
            self.addSegmentToStroke(self.position);
        }
    
    }
    
    override func setPenDown(value:Bool){
        super.setPenDown(value)
        if(!self.penDown){
            self.currentStroke = nil
            self.prevPosition = nil
            self.position = nil
        }
    }
    
    func addSegmentToStroke(point:Point){
        if(self.currentStroke == nil){
            self.currentStroke = Stroke();
            self.strokes.append(self.currentStroke!)
        }
        
        let seg = self.currentStroke!.addSegment(point)
       // self.geometryModified.raise((seg,"SEGMENT","DRAW"))
        
       
    }
    
    
}