//
//  Behavior.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 7/22/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

protocol Condition{
    var prop:String { get set }
    var value:Any? {get set}
    func validate(emitter:Emitter)->Bool
}

struct stylusCondition: Condition{
    var prop: String
    var value: Any?
    
    init(state:String, value:Any?){
        self.prop = state
        self.value = value;
    }
    
    
    func validate(emitter:Emitter)->Bool{
        let stylus = emitter as! Stylus
        switch(prop){
        case "MOVE_BY":
            if stylus.getDistance() > self.value as! Float {
                stylus.resetDistance()
                return true
            }
            else{
                return false
            }
        default:
            break
        }
        
        print("ERROR: CONDITIONAL EVALUATED WITH NO VALID PROP")
        return false
        
    }
    
}

struct spawnCondition: Condition{
    var prop: String
    var value: Any?
    
    init(state:String, value:Any?){
        self.prop = state
        self.value = value;
    }
    
    
    func validate(emitter:Emitter)->Bool{
        let emitter = emitter as! Brush
        switch(prop){
        case "IS_TYPE":
            if emitter.lastSpawned[0].name == self.value as! String {
                return true
            }
            else{
                return false
            }
        default:
            break
        }
        
        print("ERROR: CONDITIONAL EVALUATED WITH NO VALID PROP")
        return false
        
    }
    
}
