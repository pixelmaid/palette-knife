//
//  BehaviorMapper.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 5/25/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

typealias BehaviorConfig = (target: Brush, action: String, emitter:Emitter, eventType:String, expression: String?)


// creates mappings between brushes and behaviors
class BehaviorMapper{
   
    func createMapping (config:BehaviorConfig){
        let key = NSUUID().UUIDString;
        let selector = Selector(config.action+":");
        config.emitter.assignKey(config.eventType,key: key)
        NSNotificationCenter.defaultCenter().addObserver(config.target, selector:selector, name:key, object: config.emitter)
        config.target.addBehavior(key, selector: config.action, emitter: config.emitter, expression: config.expression)
        config.target.removeMappingEvent.addHandler(self, handler: BehaviorMapper.removeMapping)
    }
    
    func removeMapping(data:(Brush, String, Emitter)){
        NSNotificationCenter.defaultCenter().removeObserver(data.0, name: data.1, object: data.2)
        data.2.removeKey(data.1)
    }
    
    
}