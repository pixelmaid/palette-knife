//
//  BehaviorDefinition.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 7/27/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation


class BehaviorDefinition {
    
    var states = [String]()
    var expressions = [(Emitter,Emitter,String)]()
    var methods = [(String,String)]()
    var transitions = [(Emitter?,String,String,String)]()
    var behaviorMapper = BehaviorMapper()
    var mappings = [(Emitter,String,String)]()
    
    func addState(stateName:String){
        states.append(stateName)
    }

    func addMethod(targetState:String, targetMethod:String){
        methods.append((targetState,targetMethod))
    }
    
    func addTransition(eventEmitter:Emitter?,event:String, fromState:String,toState:String){
        transitions.append((eventEmitter, event, fromState,toState))
    }
    
    func addMapping(referenceProperty:Emitter, relativePropertyName:String,targetState:String){
        mappings.append((referenceProperty,relativePropertyName,targetState))
    }
    

    
    func createBehavior(targetBrush:Brush){
        for state in states{
            behaviorMapper.createState(targetBrush,stateName:state)

        }
         for method in methods{
            behaviorMapper.addMethod(targetBrush,state:method.0,methodName:method.1);
        }
        
        for transition in transitions{
            var relative:Emitter
            if(transition.0 == nil){
                relative = targetBrush
            }
            else{
                relative = transition.0!;
            }
            behaviorMapper.createStateTransition(relative, relative: targetBrush, eventName: transition.1, fromState:transition.2,toState:transition.3, condition: nil)

        }
        
        for mapping in mappings{
            print("mapping name\(mapping.1,targetBrush[mapping.1])")
            let relativeProperty = (targetBrush[mapping.1]) as! Emitter
            behaviorMapper.createMapping(mapping.0, relative: targetBrush, relativeProperty:relativeProperty, targetState: mapping.2)
        }

        
        
    }
    
}
