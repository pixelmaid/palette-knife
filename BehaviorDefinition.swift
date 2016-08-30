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
    var expressions = [String:(Any?,String?,Bool,Any?,String?,Bool,String)]()
    var conditions = [String:(Any?,String?,Bool,Any?,String?,Bool,String)]()
    var generators = [String:(String,[Any])]()
    var storedGenerators = [String:Generator]()
    var methods = [(String,String,[Any]?,String?)]()
    var transitions = [(Emitter?,String,String,String,String?)]()
    var behaviorMapper = BehaviorMapper()
    var mappings = [(Any?,String?,Bool,String,String)]()
    var storedExpressions = [String:Expression]()
    var storedConditions = [String:Condition]()
    
    
    func addCondition(name:String, reference:Any?, referenceName:String?,referenceParentFlag:Bool, relative:Any?, relativeName:String?, relativeParentFlag:Bool, relational:String){
        
        conditions[name] = (reference,referenceName,referenceParentFlag,relative,relativeName,relativeParentFlag,relational)
        
    }
    
    func addInterval(name:String,inc:Float,times:Int){
        generators[name] = ("interval",[inc,times]);
    }
    func addState(stateName:String){
        states.append(stateName)
    }

    func addMethod(targetState:String, targetMethod:String, arguments:[Any]?,condition:String?){
        methods.append((targetState,targetMethod,arguments,condition))
    }
    
    func addTransition(eventEmitter:Emitter?,event:String, fromState:String,toState:String, condition:String?){
        transitions.append((eventEmitter, event, fromState,toState,condition))
    }
    
    func addMapping(referenceProperty:Any?, referenceName:String?, parentFlag:Bool, relativePropertyName:String,targetState:String){
        mappings.append((referenceProperty,referenceName,parentFlag,relativePropertyName,targetState))
    }
    
    func addExpression(name:String, emitter1:Any?, operand1Name:String?, parentFlag1:Bool, emitter2:Any?,operand2Name:String?,parentFlag2:Bool,type:String){
        expressions[name]=(emitter1, operand1Name, parentFlag1, emitter2, operand2Name,parentFlag2,type);
    }
    
    
    
    //TODO: add in cases for other generators
    func generateGenerator(name:String, data:(String,[Any])){
        switch(data.0){
            case "interval":
                let interval = Interval(inc:data.1[0] as! Float,times:data.1[1] as! Int)
                storedGenerators[name] = interval;
                break;
        default:
            break;
        }
    }

    func generateOperands(targetBrush:Brush,data:(Any?,String?,Bool,Any?,String?,Bool,String))->(Observable<Float>,Observable<Float>){
        var emitter1:Any
        var emitter2:Any
        
        let operand1:Observable<Float>
        let operand2: Observable<Float>
        
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
            if(storedGenerators[data.1!]) != nil{
                operand1 = storedGenerators[data.1!]!;
            }
            else{
                print("data 1 =\(data.1!, (emitter1 as! Emitter)[data.1!])")
                operand1 = (emitter1 as! Emitter)[data.1!]! as! Observable<Float>
            }
        }
        else{
            operand1 = emitter1 as! Observable<Float>
        }
        
        if(data.4 != nil){
            if(storedGenerators[data.4!]) != nil{
                operand2 = storedGenerators[data.4!]!;
            }
            else{
            operand2 = (emitter2 as! Emitter)[data.4!]! as! Observable<Float>
            }
        }
        else{
            operand2 = emitter2  as! Observable<Float>
        }
        
        return(operand1,operand2)
        
        
    }
    
    func generateCondition(targetBrush:Brush, name:String,data:(Any?,String?,Bool,Any?,String?,Bool,String)){
        let operands = generateOperands(targetBrush, data:data)
        let operand1 = operands.0;
        let operand2 = operands.1;

        let condition = Condition(a: operand1, b: operand2, relational: data.6)
        storedConditions[name] = condition;

    }
    
    func generateExpression(targetBrush:Brush, name:String,data:(Any?,String?,Bool,Any?,String?,Bool,String)){
        let operands = generateOperands(targetBrush, data:data)
        let operand1 = operands.0;
        let operand2 = operands.1;
        let expression:Expression;
        switch(data.6){
        case "add":
            expression = AddExpression(operand1: operand1,operand2: operand2)
        case "mult":
            expression = MultExpression(operand1: operand1,operand2: operand2)
      
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
    
    func createBehavior(targetBrush:Brush){
       print("creating behavior, conditions \(conditions)")
        
        for (key, generator_data) in generators{
            self.generateGenerator(key,data:generator_data)
        }

        for (key, condition_data) in conditions{
            self.generateCondition(targetBrush,name:key,data:condition_data)
        }
        
        for (key,expression_data) in expressions{
           self.generateExpression(targetBrush,name:key,data:expression_data)

            

        }
        
        for state in states{
            behaviorMapper.createState(targetBrush,stateName:state)

        }
         for method in methods{
            let condition:Condition?
            if((method.3) != nil){
                condition = storedConditions[method.3!]!
            }
            else{
                condition = nil
            }
            behaviorMapper.addMethod(targetBrush,state:method.0,methodName:method.1,arguments:method.2,condition:condition);
        }
        
        for transition in transitions{
            var reference:Any
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
            behaviorMapper.createStateTransition(reference as! Emitter, relative: targetBrush, eventName: transition.1, fromState:transition.2,toState:transition.3, condition: condition)

        }
        //referenceProperty!,referenceName!,relativePropertyName,targetState
        for mapping in mappings{
            var referenceProperty:Observable<Float>
            if(mapping.0 == nil){
                if(mapping.2 == true){
                   referenceProperty = targetBrush.parent![mapping.1!]! as! Observable<Float>
                }
                else{
                referenceProperty = storedExpressions[mapping.1!]! as! Observable<Float>
                }
            }
            else{
                if(mapping.1 != nil){
                referenceProperty = (mapping.0! as! Emitter)[mapping.1!] as! Observable<Float>
                }
                else{
                    referenceProperty = mapping.0! as! Observable<Float>
                }
            }
            let relativeProperty = (targetBrush[mapping.3]) as! Observable<Float>
            behaviorMapper.createMapping(referenceProperty, relative: targetBrush, relativeProperty:relativeProperty, targetState: mapping.4)
        }

        
        
    }
    
}
