//
//  LeafBrush.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 6/1/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

class LeafBrush:Brush{
    var current:StoredDrawing?
    
    var geometry = [StoredDrawing]()
    
    required init(){
        super.init()
        self.name = "LeafBrush"
        
    }

    
  func checkDraw(){
        if((scaling != nil)  && (angle != nil) && (position != nil)){
            current = StoredDrawing(position: position!, scaling: scaling!, angle: angle!)
            geometry.append(current!)
            self.geometryModified.raise((current!,"LEAF","DRAW"))
        }
    }
    
    override func set(targetProp:String,value:Any)->Bool{
        let superSet = super.set(targetProp,value:value)
        if(!superSet){
            switch targetProp{
            default: break
                
            }
        }
        self.checkDraw()
        
        return false;
    }
    


    
}

class FlowerBrush:LeafBrush{
    
    
    required init(){
        super.init()
        self.name = "FlowerBrush"
        
    }
    override func checkDraw(){
        
        
        if((scaling != nil)  && (angle != nil) && (position != nil)){
            current = StoredDrawing(position: position!, scaling: scaling!, angle: angle!)
            geometry.append(current!)

            self.geometryModified.raise((current!,"FLOWER","DRAW"))
        }
        
        
    }
    
}



