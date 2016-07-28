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
    var expressions = [String:(String,Emitter?,String?,Emitter?,String?)]()
    var methods = [(String,String,[Any]?)]()
    var transitions = [(Emitter?,String,String,String)]()
    var behaviorMapper = BehaviorMapper()
    var mappings = [(Emitter?,String?,String,String)]()
    var storedExpressions = [String:Expression]()
    
    func addState(stateName:String){
        states.append(stateName)
    }

    func addMethod(targetState:String, targetMethod:String, arguments:[Any]?){
        methods.append((targetState,targetMethod,arguments))
    }
    
    func addTransition(eventEmitter:Emitter?,event:String, fromState:String,toState:String){
        transitions.append((eventEmitter, event, fromState,toState))
    }
    
    func addMapping(referenceProperty:Emitter?, referenceName:String?, relativePropertyName:String,targetState:String){
        mappings.append((referenceProperty,referenceName,relativePropertyName,targetState))
    }
    
    func addExpression(name:String, type:String, emitter1:Emitter?, operand1Name:String?,emitter2:Emitter?,operand2Name:String?){
        expressions[name]=(type,emitter1, operand1Name, emitter2, operand2Name);
    }
    

    
    func createBehavior(targetBrush:Brush){
        
        for (key,expression_data) in expressions{
            var name = key
            var emitter1:Emitter;
            var emitter2:Emitter

            
            var operand1:Emitter
            var operand2: Emitter
            
            if(expression_data.1 == nil){
                emitter1 = targetBrush;
            }
            else{
                emitter1 = expression_data.1!
            }

            if (expression_data.3 == nil){
                emitter2 = targetBrush
            }
            else{
                emitter2 = expression_data.3!
            }
            
            if(expression_data.2 == nil){
                operand1 = emitter1
            }
            else{
                operand1 = emitter1[expression_data.2!] as! Emitter
            }
            
            if(expression_data.4  == nil){
                operand2 = emitter2
            }
            else{
                operand2 = emitter2[expression_data.4!] as! Emitter
            }

            let expression:Expression;
            switch(expression_data.0){
                case "add":
                   expression = AddExpression(operand1: operand1,operand2: operand2)

                break;
            case "log":
                expression = LogExpression(operand1: operand1,operand2: operand2)
                
                break;
            case "exp":
                expression = ExpExpression(operand1: operand1,operand2: operand2)
                
                break;
            case "logigrowth":
                expression = LogiGrowthExpression(operand1: operand1,operand2: operand2)
                
                break;
            case "sub":
                expression = SubExpression(operand1: operand1,operand2: operand2)
                
                break;
            default:
                expression = AddExpression(operand1: operand1,operand2: operand2)

                    break;
            }
            self.storedExpressions[name] = expression;

        }
        
        for state in states{
            behaviorMapper.createState(targetBrush,stateName:state)

        }
         for method in methods{
            behaviorMapper.addMethod(targetBrush,state:method.0,methodName:method.1,arguments:method.2);
        }
        
        for transition in transitions{
            var reference:Emitter
            if(transition.0 == nil){
                reference = targetBrush
            }
            else{
                reference = transition.0!;
            }
            behaviorMapper.createStateTransition(reference, relative: targetBrush, eventName: transition.1, fromState:transition.2,toState:transition.3, condition: nil)

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
