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
        print("check draw\(length,angle,position)")
       
        
            if((length != nil)  && (angle != nil) && (position != nil)){
                current = Line(p: position!, length: length!, angle: angle!, asVector: false)
                geometry.append(current!)

                self.geometryModified.raise((current!,"LINE","DRAW"))
                     print("raise angle draw")
            }
            else if((position != nil) && (prevPosition != nil)){
                current = Line(p:position,v:prevPosition,asVector:false);
                geometry.append(current!)

                self.geometryModified.raise((current!,"LINE","DRAW"))
                print("raise point draw")


            }
            
        
    }
    
    override func set(targetProp:String,value:Any)->Bool{
        print("setting for linebrush \(targetProp,value)")
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
