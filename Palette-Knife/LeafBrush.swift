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
    
    required init(behaviorDef: BehaviorDefinition? , canvas:Canvas) {
        fatalError("init(behaviorDef:) has not been implemented")
    }
    
    


    
}

class FlowerBrush:LeafBrush{
    
    
    required init(){
        super.init()
        self.name = "FlowerBrush"
        
    }
    
    required init(behaviorDef: BehaviorDefinition?, canvas:Canvas) {
        fatalError("init(behaviorDef:) has not been implemented")
    }
   
    
}



