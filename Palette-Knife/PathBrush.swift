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
        let selector = Selector("positionChange"+":");

        NSNotificationCenter.defaultCenter().addObserver(self, selector:selector, name:positionKey, object: self.position)
        self.position.assignKey("CHANGE",key: positionKey,eventCondition: nil)

    }
    
    required init(behaviorDef: BehaviorDefinition?) {
        fatalError("init(behaviorDef:) has not been implemented")
    }
    
    override func clone()->PathBrush{
        return super.clone() as! PathBrush;
    }
    
    dynamic override func positionChange(notification: NSNotification){
    print("position change\(position.x.get(),position.y.get())")
      //  print("stylus position \(stylus.position.x.get(),stylus.position.y.get()))")

    self.prevPosition.set(position.prevX,y: position.prevY);
    self.currentCanvas!.currentDrawing!.addSegmentToStroke(self.position.clone(),weight: self.weight.get());
    self.angle.set(self.position.sub(self.prevPosition).angle)
   
    
    }
    
    override func newStroke(){
        super.newStroke();
        currentCanvas!.newStroke();
    }
    
   
    
    
}
