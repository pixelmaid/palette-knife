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
    
      
    func createMapping(id:String, reference:Observable<Float>, relative:Brush, relativeProperty:Observable<Float>,targetState:String){
        relative.addConstraint(id, reference:reference, relative: relativeProperty, targetState: targetState)
    
    }
    
    func createState(target:Brush,stateName:String){
        target.createState(stateName);
    }
    
    func createStateTransition(id:String,name:String,reference:Emitter,relative:Brush, eventName:String, fromState:String, toState:String, condition:Condition!){
        reference.assignKey(eventName,key:id,condition: condition)
        let selector = Selector("stateTransitionHandler"+":");
        NSNotificationCenter.defaultCenter().addObserver(relative, selector:selector, name:id, object: reference)
        relative.addStateTransition(id, name:name,reference: reference, fromState:fromState, toState:toState)
        relative.removeTransitionEvent.addHandler(relative, handler: Brush.removeStateTransition, key:id)
        
    }
    
    func addMethod(relative:Brush,transitionName:String,methodName:String, arguments:[Any]?){
       
        relative.addMethod(transitionName,methodName:methodName, arguments:arguments)
    }
}


