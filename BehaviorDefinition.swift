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
    var expressions = [String:(Emitter?,String?,Emitter?,String?)]()
    var methods = [(String,String)]()
    var transitions = [(Emitter?,String,String,String)]()
    var behaviorMapper = BehaviorMapper()
    var mappings = [(Emitter?,String?,String,String)]()
    var storedExpressions = [String:Expression]()
    
    func addState(stateName:String){
        states.append(stateName)
    }

    func addMethod(targetState:String, targetMethod:String){
        methods.append((targetState,targetMethod))
    }
    
    func addTransition(eventEmitter:Emitter?,event:String, fromState:String,toState:String){
        transitions.append((eventEmitter, event, fromState,toState))
    }
    
    func addMapping(referenceProperty:Emitter?, referenceName:String?, relativePropertyName:String,targetState:String){
        mappings.append((referenceProperty,referenceName,relativePropertyName,targetState))
    }
    
    func addExpression(name:String, emitter1:Emitter?, operand1Name:String,emitter2:Emitter?,operand2Name:String){
        expressions[name]=(emitter1, operand1Name, emitter2, operand2Name);
    }
    

    
    func createBehavior(targetBrush:Brush){
        
        for (key,expression_data) in expressions{
            var name = key
            var emitter1:Emitter;
            var emitter2:Emitter

            
            var operand1:Emitter
            var operand2: Emitter
            
            if(expression_data.0 == nil){
                emitter1 = targetBrush;
            }
            else{
                emitter1 = expression_data.0!
            }

            if (expression_data.2 == nil){
                emitter2 = targetBrush
            }
            else{
                emitter2 = expression_data.2!
            }
            
            if(expression_data.1 == nil){
                operand1 = emitter1
            }
            else{
                print("expression data 1 = \(expression_data.1!, emitter1)")
                operand1 = emitter1[expression_data.1!] as! Emitter
            }
            
            if(expression_data.3 == nil){
                operand2 = emitter2
            }
            else{
                operand2 = emitter2[expression_data.3!] as! Emitter
            }

            
           var expression = AddExpression(operand1: operand1,operand2: operand2)
            self.storedExpressions[name] = expression;

        }
        
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
        //referenceProperty!,referenceName!,relativePropertyName,targetState
        for mapping in mappings{
            var referenceProperty:Emitter
            if(mapping.0 == nil){
                referenceProperty = storedExpressions[mapping.1!]! as Emitter
            }
            else{
                referenceProperty = mapping.0!
            }
            let relativeProperty = (targetBrush[mapping.2]) as! Emitter
            behaviorMapper.createMapping(referenceProperty, relative: targetBrush, relativeProperty:relativeProperty, targetState: mapping.3)
        }

        
        
    }
    
}
