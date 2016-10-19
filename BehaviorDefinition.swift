//
//  BehaviorDefinition.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 7/27/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation
import SwiftKVC

class BehaviorDefinition {
    
    var states = [String:String]()
    var expressions = [String:(Any?,String?,Bool,Any?,String?,Bool,String)]()
    var conditions = [(String,Any?,String?,Bool,Any?,String?,Bool,String)]()
    var generators = [String:(String,[Any])]()
    var storedGenerators = [String:Generator]()
    var methods = [(String,String,String,[Any]?)]()
    var transitions = [String:(String,Emitter?,Bool,String,String,String,String?)]()
    var behaviorMapper = BehaviorMapper()
    var mappings = [String:(Any?,String?,Bool,String,String)]()
    var storedExpressions = [String:Expression]()
    var storedConditions = [String:Condition]()
    var name:String;
    var id: String;
    
    init(id:String, name:String){
        self.name = name;
        self.id = id;
    }
    
    func toJSON()->String{
        var json_string = "{"
        
        json_string+="\"name\":\""+self.name+"\","
        json_string+="\"id\":\""+self.id+"\","
        
        json_string+="\"states\":["
        
        for (key,name) in states {
            json_string += "{"
            json_string += "\"id\":\""+key+"\","
            
            json_string += "\"name\":\""+name+"\","
            json_string += "\"mappings\":["
            
            var hasMapping = false;
            for (id,data) in mappings {
                if(data.4 == name){
                    hasMapping = true;
                    json_string += "{"
                    json_string += "\"id\":\""+id+"\","
                    var refName = ""
                    if(data.0 != nil){
                        refName = (data.0 as! Observable<Float>).name;
                    }
                    if(data.2){
                        refName = "parent."+refName;
                    }
                    
                    if(data.1 != nil){
                        refName += data.1!
                        
                    }
                    json_string += "\"reference\":\""+refName+"\","
                    json_string += "\"relative\":\""+data.3+"\","
                    json_string += "\"state\":\""+data.4+"\""
                    
                    json_string += "},"
                }
            }
            if(hasMapping){
                json_string.removeAtIndex(json_string.endIndex.predecessor())
            }
            json_string += "]},"
        }
        if(states.count > 0){
            json_string.removeAtIndex(json_string.endIndex.predecessor())
        }
        json_string += "],"
        json_string += "\"transitions\":["
        
        
        for(key, data) in transitions{
            
            var methods = getMethodsByTransition(data.0);
            json_string += "{"
            json_string += "\"id\":\""+key+"\","
            json_string += "\"name\":\""+data.3+"\","
            json_string += "\"fromState\":\""+self.getStateByName(data.4)!+"\","
            json_string += "\"toState\":\""+self.getStateByName(data.5)!+"\","
            json_string += "\"methods\":["
            for i in 0..<methods.count{
                
                if(i>0){
                    json_string += ","
                }
                json_string += "{"
                json_string += "\"id\":\""+methods[i].1+"\","
                json_string += "\"name\":\""+methods[i].2+"\""
                json_string+="}"
            }
            json_string += "]"
            if(data.6 != nil){
                json_string += ",\"condition_name\":\""+data.6!+"\""
            }
            json_string += "},"
        }
        
        
        
        if(transitions.count > 0){
            json_string.removeAtIndex(json_string.endIndex.predecessor())
        }
        
        
        //debugPrint("++++JSON STRING = \(json_string) \nJSON STRING++++");
        json_string+="]}"
        
        return json_string
    }
    
    //TODO: remove eventually- this is bad
    func getStateByName(name:String)->String?{
        for(id,state) in self.states{
            if(state == name){
                return id;
            }
        }
        return nil
    }
    
    func getMethodsByTransition(name:String)->[(String,String,String,[Any]?)]{
        var tmethods = [(String,String,String,[Any]?)]();
        for m in methods {
            if m.0 == name{
                tmethods.append(m)
            }
        }
        return tmethods;
    }
    
    func addCondition(name:String, reference:Any?, referenceName:String?,referenceParentFlag:Bool, relative:Any?, relativeName:String?, relativeParentFlag:Bool, relational:String){
        
        conditions.append(name,reference,referenceName,referenceParentFlag,relative,relativeName,relativeParentFlag,relational)
        
    }
    
    func addInterval(name:String,inc:Float,times:Int?){
        generators[name] = ("interval",[inc,times]);
    }
    
    func addIncrement(name:String,inc:Observable<Float>,start:Observable<Float>){
        generators[name] = ("increment",[inc,start]);
    }
    
    func addRange(name:String,min:Int,max:Int,start:Float,stop:Float){
        generators[name] = ("range",[min,max,start,stop]);
    }
    
    func addRandomGenerator(name:String,min:Float,max:Float){
        generators[name] = ("random",[min,max]);
    }
    
    func addAlternate(name:String,values:[Float]){
        generators[name] = ("alternate",[values]);
    }
    
    func addState(stateId:String, stateName:String){
        states[stateId] = stateName;
    }
    
    func addMethod(targetTransition:String, methodId: String, targetMethod:String, arguments:[Any]?){
        methods.append((targetTransition,methodId,targetMethod,arguments))
    }
    
    func addTransition(transitionId:String, name:String, eventEmitter:Emitter?,parentFlag:Bool, event:String, fromStateName:String,toStateName:String, condition:String?){
        transitions[transitionId]=((name,eventEmitter, parentFlag, event, fromStateName,toStateName,condition))
    }
    
    func addMapping(id:String, referenceProperty:Any?, referenceName:String?, parentFlag:Bool, relativePropertyName:String,targetState:String){
        mappings[id] = ((referenceProperty,referenceName,parentFlag,relativePropertyName,targetState))
    }
    
    func addExpression(name:String, emitter1:Any?, operand1Name:String?, parentFlag1:Bool, emitter2:Any?,operand2Name:String?,parentFlag2:Bool,type:String){
        expressions[name]=(emitter1, operand1Name, parentFlag1, emitter2, operand2Name,parentFlag2,type);
    }
    
    
    
    //TODO: add in cases for other generators
    func generateGenerator(name:String, data:(String,[Any])){
        switch(data.0){
        case "interval":
            let interval = Interval(inc:data.1[0] as! Float,times:data.1[1] as? Int)
            storedGenerators[name] = interval;
            break;
        case "range":
            let range = Range(min:data.1[0] as! Int, max:data.1[1] as! Int, start: data.1[2] as! Float, stop:data.1[3] as! Float)
            storedGenerators[name] = range;
        case "random":
            let random = RandomGenerator(min:data.1[0] as! Float, max:data.1[1] as! Float)
            storedGenerators[name] = random;
            
            break;
        case "alternate":
            let alternate = Alternate(values:data.1[0] as! [Float])
            storedGenerators[name] = alternate;
        case "increment":
            let increment = Increment(inc:data.1[0] as! Observable<Float>, start:data.1[1] as! Observable<Float>)
            storedGenerators[name] = increment;
            
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
            else if(storedExpressions[data.1!] != nil){
                operand1 = storedExpressions[data.1!]!;
                
            }
            else if(storedConditions[data.1!] != nil){
                operand1 = storedConditions[data.1!]!;
                
            }
            else{
                print("data 1 = \(data.1)")
                operand1 = (emitter1 as! Model)[data.1!]! as! Observable<Float>
            }
        }
        else{
            operand1 = emitter1 as! Observable<Float>
        }
        
        if(data.4 != nil){
            print("looking in generators for \(data.4)");
            if(storedGenerators[data.4!]) != nil{
                operand2 = storedGenerators[data.4!]!;
            }
            else if(storedExpressions[data.4!] != nil){
                operand2 = storedExpressions[data.4!]!;
                
            }
            else if(storedConditions[data.4!] != nil){
                operand2 = storedConditions[data.4!]!;
                
            }
            else{
                operand2 = (emitter2 as! Model)[data.4!]! as! Observable<Float>
            }
        }
        else{
            operand2 = emitter2  as! Observable<Float>
        }
        
        return(operand1,operand2)
        
        
    }
    
    func generateCondition(targetBrush:Brush, data:(String, Any?,String?,Bool,Any?,String?,Bool,String)){
        let name = data.0;
        //TODO: THIS IS GARBAGE CODE. Find a better solution
        let operands = generateOperands(targetBrush, data:(data.1,data.2,data.3,data.4,data.5,data.6,data.7))
        let operand1 = operands.0;
        let operand2 = operands.1;
        
        let condition = Condition(a: operand1, b: operand2, relational: data.7)
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
    
    func generateMapping(targetBrush:Brush, id:String, data:(Any?,String?,Bool,String,String)){
        
        // expression (name:String, reference:Any?, referenceName:String?,referenceParentFlag:Bool, relative:Any?, relativeName:String?, relativeParentFlag:Bool, relational:String)
        //mapping (referenceProperty:Any?, referenceName:String?, parentFlag:Bool, relativePropertyName:String,targetState:String)
        //operand (Any?,String?,Bool,Any?,String?,Bool,String)
        let operands = generateOperands(targetBrush, data:(data.0,data.1,data.2,targetBrush,data.3,false,""))
        let referenceOperand = operands.0;
        let relativeOperand = operands.1;
        
        behaviorMapper.createMapping(id, reference: referenceOperand, relative: targetBrush, relativeProperty: relativeOperand, targetState: data.4)
    }
    
    func createBehavior(targetBrush:Brush){
        
        for (key, generator_data) in generators{
            self.generateGenerator(key,data:generator_data)
        }
        
        for i in 0..<conditions.count{
            self.generateCondition(targetBrush,data:conditions[i])
        }
        
        for (key,expression_data) in expressions{
            self.generateExpression(targetBrush,name:key,data:expression_data)
            
            
            
        }
        
        for (id,state) in states{
            behaviorMapper.createState(targetBrush,stateId:id, stateName:state)
            
        }
        
        for (key,transition) in transitions{
            var reference:Any
            if(transition.1 == nil){
                if(transition.2){
                    reference = targetBrush.parent!
                }
                else{
                    reference = targetBrush
                }
            }
            else{
                reference = transition.1!;
            }
            let condition:Condition?
            if((transition.6) != nil){
                condition = storedConditions[transition.6!]
            }
            else{
                condition = nil
            }
            
            
            behaviorMapper.createStateTransition(key,name: transition.0,reference:reference as! Emitter, relative: targetBrush, eventName: transition.3, fromStateName:transition.4,toStateName:transition.5, condition: condition)
            
        }
        
        for method in methods{
            behaviorMapper.addMethod(targetBrush,transitionName:method.0,methodId:method.1,methodName:method.2,arguments:method.3);
        }
        
        //referenceProperty!,referenceName!,relativePropertyName,targetState
        for (id, mapping_data) in mappings{
            self.generateMapping(targetBrush,id:id, data:mapping_data);
        }
        
        
        
    }
    
}
