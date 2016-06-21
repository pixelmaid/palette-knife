//
//  BehaviorMapper.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 5/25/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

typealias BehaviorConfig = (target: Brush, action: String, emitter:Emitter, eventType:String, eventCondition:EventCondition!, expression: String?)


// creates mappings between brushes and behaviors
class BehaviorMapper{
   
    func createMapping (config:BehaviorConfig){
        let key = NSUUID().UUIDString;
        let selector = Selector(config.action+":");
        config.emitter.assignKey(config.eventType,key: key,eventCondition: config.eventCondition)
        NSNotificationCenter.defaultCenter().addObserver(config.target, selector:selector, name:key, object: config.emitter)
        config.target.addBehavior(key, selector: config.action, emitter: config.emitter, expression: config.expression)
        config.target.removeMappingEvent.addHandler(self, handler: BehaviorMapper.removeMapping)
    }
    
    func removeMapping(data:(Brush, String, Emitter)){
        NSNotificationCenter.defaultCenter().removeObserver(data.0, name: data.1, object: data.2)
        data.2.removeKey(data.1)
    }
    
    
}


protocol EventCondition{
    var prop:String { get set }
    var value:Any? {get set}
    func validate(emitter:Emitter)->Bool
}

struct stylusCondition: EventCondition{
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

struct spawnCondition: EventCondition{
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