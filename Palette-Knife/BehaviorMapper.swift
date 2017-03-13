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
    
      
    func createMapping(id:String, reference:Observable<Float>, relative:Brush, relativeProperty:Observable<Float>,stateId:String){
        relative.addConstraint(id, reference:reference, relative: relativeProperty, stateId: stateId)
    
    }
    
    func createState(target:Brush,stateId:String,stateName:String){
        target.createState(stateId, name:stateName);
    }
    
    func createStateTransition(id:String,name:String,reference:Emitter,relative:Brush, eventName:String, fromStateId:String, toStateId:String, condition:Condition!){
        reference.assignKey(eventName,key:id,condition: condition)
        let selector = Selector("stateTransitionHandler"+":");
        NSNotificationCenter.defaultCenter().addObserver(relative, selector:selector, name:id, object: reference)
        relative.addStateTransition(id, name:name,reference: reference, fromStateId:fromStateId, toStateId:toStateId)
        relative.removeTransitionEvent.addHandler(relative, handler: Brush.removeStateTransition, key:id)
        
    }
    
    func addMethod(relative:Brush,transitionName:String,methodId:String,methodName:String, arguments:[Any]?){
       
        relative.addMethod(transitionName,methodId:methodId,methodName:methodName, arguments:arguments)
    }
}


