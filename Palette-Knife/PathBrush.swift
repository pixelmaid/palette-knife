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
    
    let positionKey = NSUUID().UUIDString;

    required init(){
        super.init()
        self.name = "PathBrush"
        let selector = Selector("positionChange"+":");

        NSNotificationCenter.defaultCenter().addObserver(self, selector:selector, name:positionKey, object: self.position)
        self.position.assignKey("CHANGE",key: positionKey,eventCondition: nil)

    }
    
    override func clone()->PathBrush{
        return super.clone() as! PathBrush;
    }
    
    dynamic func positionChange(notification: NSNotification){
    self.prevPosition.set(position.prevX.get(),y: position.prevY.get());
    self.currentCanvas!.currentDrawing!.addSegmentToStroke(self.position.clone(),weight: self.weight.get());
    print("angle, position, \(self.prevPosition, self.position, self.position.sub(self.prevPosition).angle.get(),self.angle))")
    self.angle.set(self.position.sub(self.prevPosition).angle)
   
    
    }
    
    override func newStroke(){
        currentCanvas!.newStroke();
    }
    
   
    
    
}
