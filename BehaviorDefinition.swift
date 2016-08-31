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
    var methods = [(String,String,String,[Any]?)]()
    var transitions = [String:(Emitter?,String,String,String,String?)]()
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
    
    func addRange(name:String,min:Int,max:Int,start:Float,stop:Float){
        generators[name] = ("range",[min,max,start,stop]);
    }
    
    func addAlternate(name:String,values:[Float]){
        generators[name] = ("alternate",[values]);
    }
    
    func addState(stateName:String){
        states.append(stateName)
    }

    func addMethod(targetState:String, targetTransition:String, targetMethod:String, arguments:[Any]?){
        methods.append((targetState,targetTransition, targetMethod,arguments))
    }
    
    func addTransition(name:String, eventEmitter:Emitter?, event:String, fromState:String,toState:String, condition:String?){
        transitions[name] = (eventEmitter, event, fromState,toState,condition);
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
            case "range":
                let range = Range(min:data.1[0] as! Int, max:data.1[1] as! Int, start: data.1[2] as! Float, stop:data.1[3] as! Float)
                storedGenerators[name] = range;

                break;
            case "alternate":
                let alternate = Alternate(values:data.1[0] as! [Float])
                storedGenerators[name] = alternate;
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
    
    func generateCondition(targetBrush:Brush, name:String, data:(Any?,String?,Bool,Any?,String?,Bool,String)){
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
    
    func generateMapping(targetBrush:Brush, data:(Any?,String?,Bool,String,String)){
        
       // expression (name:String, reference:Any?, referenceName:String?,referenceParentFlag:Bool, relative:Any?, relativeName:String?, relativeParentFlag:Bool, relational:String)
        //mapping (referenceProperty:Any?, referenceName:String?, parentFlag:Bool, relativePropertyName:String,targetState:String)
        //operand (Any?,String?,Bool,Any?,String?,Bool,String)
        let operands = generateOperands(targetBrush, data:(data.0,data.1,data.2,targetBrush,data.3,false,""))
        let referenceOperand = operands.0;
        let relativeOperand = operands.1;
        
        behaviorMapper.createMapping(referenceOperand, relative: targetBrush, relativeProperty: relativeOperand, targetState: data.4)
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
            behaviorMapper.addMethod(targetBrush,state:method.0,transition:method.1,methodName:method.2, arguments:method.3);
        }
        
        for (key,transition_data) in transitions{
            var reference:Any
            if(transition_data.0 == nil){
                reference = targetBrush
            }
            else{
                reference = transition_data.0!;
            }
            let condition:Condition?
            if((transition_data.4) != nil){
                condition = storedConditions[transition_data.4!]
            }
            else{
                condition = nil
            }
          
            behaviorMapper.createStateTransition(key, reference: reference as! Emitter, relative: targetBrush, eventName: transition_data.1, fromState:transition_data.2,toState:transition_data.3, condition: condition)

        }
        //referenceProperty!,referenceName!,relativePropertyName,targetState
        for mapping_data in mappings{
            self.generateMapping(targetBrush,data:mapping_data);
        }

        
        
    }
    
}
