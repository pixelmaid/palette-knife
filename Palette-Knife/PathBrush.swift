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
            self.currentCanvas!.currentDrawing!.addSegmentToStroke(self.position,weight: self.weight);
            //self.setLength(currentStroke!.getLength())
        }
    
    if(self.prevPosition != nil){
        self.setAngle(self.position.sub(self.prevPosition).angle)
    }
    else{
        self.setAngle(0)
    }

    
    }
    
    override func setPenDown(value:Bool){
        super.setPenDown(value)
        if(!self.penDown){
            self.currentCanvas!.currentDrawing!.currentStroke = nil;
        }
    }
    
   
    
    
}
