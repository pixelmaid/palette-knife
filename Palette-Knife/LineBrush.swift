//
//  LineBrush.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 6/1/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation
//brush that draws straight lines of varying sizes
class LineBrush:Brush{
    var current:Line?
    
    var geometry = [Line]()
       required init(){
        super.init()
        self.name = "LineBrush"
        
    }

    
    func checkDraw(){
        
                current = Line(p: position, length: length!, angle: angle!, asVector: false)
                geometry.append(current!)

                self.geometryModified.raise((current!,"LINE","DRAW"))
        
            
        
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
        
    
    
    override func clone()->LineBrush{
        return super.clone() as! LineBrush;
    }
    
}
