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
    var expressions = [String:(String,Emitter?,String?,Emitter?,String?,Bool)]()
    var conditions = [String:(Emitter?,String?,Bool,Emitter?,String?,Bool,String)]()

    var methods = [(String,String,[Any]?,Condition?)]()
    var transitions = [(Emitter?,String,String,String,String?)]()
    var behaviorMapper = BehaviorMapper()
    var mappings = [(Emitter?,String?,String,String)]()
    var storedExpressions = [String:Expression]()
    var storedConditions = [String:Condition]()
    
    
    func addCondition(name:String, reference:Emitter?, referenceName:String?,referenceParentFlag:Bool, relative:Emitter?, relativeName:String?, relativeParentFlag:Bool, relational:String){
        
        conditions[name] = (reference,referenceName,referenceParentFlag,relative,relativeName,relativeParentFlag,relational)
        
    }
    
    func addState(stateName:String){
        states.append(stateName)
    }

    func addMethod(targetState:String, targetMethod:String, arguments:[Any]?,condition:Condition?){
        methods.append((targetState,targetMethod,arguments,condition))
    }
    
    func addTransition(eventEmitter:Emitter?,event:String, fromState:String,toState:String, condition:String?){
        transitions.append((eventEmitter, event, fromState,toState,condition))
    }
    
    func addMapping(referenceProperty:Emitter?, referenceName:String?, relativePropertyName:String,targetState:String){
        mappings.append((referenceProperty,referenceName,relativePropertyName,targetState))
    }
    
    func addExpression(name:String, type:String, emitter1:Emitter?, operand1Name:String?,emitter2:Emitter?,operand2Name:String?,parentFlag:Bool){
        expressions[name]=(type,emitter1, operand1Name, emitter2, operand2Name,parentFlag);
    }
    

    func generateCondition(targetBrush:Brush, name:String,data:(Emitter?,String?,Bool,Emitter?,String?,Bool,String)){
        var emitter1:Emitter;
        var emitter2:Emitter
        
        
        let operand1:Emitter
        let operand2: Emitter
        
        if(data.0 == nil){
            if(data.2 == false){
                emitter1 = targetBrush
            }
            else{
                emitter1 = targetBrush.parent!
            }
        }
        else{
            emitter1 = data.0!
        }
        
        if(data.3 == nil){
            if(data.5 == false){
                emitter2 = targetBrush
            }
            else{
                emitter2 = targetBrush.parent!
            }
        }
        else{
            emitter2 = data.3!
        }
        
        if(data.1 != nil){
            operand1 = emitter1[data.1!]! as! Emitter
        }
        else{
            operand1 = emitter1;
        }
        
        if(data.4 != nil){
            operand2 = emitter2[data.4!]! as! Emitter
        }
        else{
            operand2 = emitter2;
        }
        
        let condition = Condition(a: operand1, b: operand2, relational: data.6)
        storedConditions[name] = condition;
        
        
    }
    
    func createBehavior(targetBrush:Brush){
       print("creating behavior, conditions \(conditions)")
        for (key, condition_data) in conditions{
            self.generateCondition(targetBrush,name:key,data:condition_data)
        }
        
        for (key,expression_data) in expressions{
            let name = key
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
                if(expression_data.5){
                    print("name,parent \(targetBrush.name,targetBrush.parent)")
                    emitter2 = targetBrush.parent!;
                    
                }
                else{
                    emitter2 = targetBrush;
                }

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
         
            //todo: add condition for methods
            behaviorMapper.addMethod(targetBrush,state:method.0,methodName:method.1,arguments:method.2,condition:nil);
        }
        
        for transition in transitions{
            var reference:Emitter
            if(transition.0 == nil){
                reference = targetBrush
            }
            else{
                reference = transition.0!;
            }
            let condition:Condition?
            if((transition.4) != nil){
                condition = storedConditions[transition.4!]
            }
            else{
                condition = nil
            }
            print("creating transition,condition = \(condition,transition.4,storedConditions)")
            behaviorMapper.createStateTransition(reference, relative: targetBrush, eventName: transition.1, fromState:transition.2,toState:transition.3, condition: condition)

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
