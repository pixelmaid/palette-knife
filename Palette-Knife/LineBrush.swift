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
    
    required init(behaviorDef: BehaviorDefinition? , canvas:Canvas) {
        fatalError("init(behaviorDef:) has not been implemented")
    }
    
    override func clone()->LineBrush{
        return super.clone() as! LineBrush;
    }
    
}
