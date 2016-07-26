//
//  BehaviorMapper.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 5/25/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

typealias BehaviorConfig = (target: Brush, action: String, emitter:Emitter, eventType:String, eventCondition:Condition!, expression: String?)


// creates mappings between brushes and behaviors
class BehaviorMapper{
    
    /*func createMapping (config:BehaviorConfig){
        let key = NSUUID().UUIDString;
        let selector = Selector(config.action+":");
        config.emitter.assignKey(config.eventType,key: key,eventCondition: config.eventCondition)
        NSNotificationCenter.defaultCenter().addObserver(config.target, selector:selector, name:key, object: config.emitter)
        config.target.addBehavior(key, selector: config.action, emitter: config.emitter, expression: config.expression)
        config.target.removeMappingEvent.addHandler(self, handler: BehaviorMapper.removeMapping)
    }*/
    
    func removeMapping(data:(Brush, String, Emitter)){
        NSNotificationCenter.defaultCenter().removeObserver(data.0, name: data.1, object: data.2)
        data.2.removeKey(data.1)
    }
    
    func createMapping(reference:Emitter, relative:Brush, relativeProperty:Emitter){
        let key = NSUUID().UUIDString;
        reference.assignKey("CHANGE",key: key,eventCondition: nil)
        let selector = Selector("setHandler"+":");
        NSNotificationCenter.defaultCenter().addObserver(relative, selector:selector, name:key, object: reference)
        relative.addConstraint(key, reference: reference, relative: relativeProperty)
        relative.removeMappingEvent.addHandler(self, handler: BehaviorMapper.removeMapping)
    
    }
    
    func createState(target:Brush,stateName:String){
        target.createState(stateName);
    }
    
    func createStateTransition(reference:Emitter,relative:Brush, eventName:String, fromState:String, toState:String, condition:Condition!){
        
        let key = NSUUID().UUIDString;
        reference.assignKey(eventName,key:key,eventCondition: condition)
        let selector = Selector("stateTransitionHandler"+":");
        NSNotificationCenter.defaultCenter().addObserver(relative, selector:selector, name:key, object: reference)
        relative.addStateTransition(key, reference: reference, fromState:fromState, toState:toState)
        relative.removeMappingEvent.addHandler(self, handler: BehaviorMapper.removeMapping)
    }
    
    func addMethod(relative:Brush,state:String,methodName:String){
        let key = NSUUID().UUIDString;
        relative.addMethod(key,state:state,methodName:methodName)
    }
}


