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
    
    var brushInstances = [Brush]();
    var states = [String:String]()
    var expressions = [String:([String:(Any?,[String]?)],String)]();
    var conditions = [(String,Any?,[String]?,Any?,[String]?,String)]()
    var generators = [String:(String,[Any])]()
    var storedGenerators = [String:Generator]()
    var methods = [String:[(String,String,[Any]?)]]()
    var transitions = [String:(String,Emitter?,Bool,String?,String,String,String?)]()
    var behaviorMapper = BehaviorMapper()
    var mappings = [String:(Any?,[String]?,String,String,String)]()
    var storedExpressions = [String:TextExpression]()
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
                if(data.3 == name){
                    hasMapping = true;
                    json_string += "{"
                    json_string += "\"id\":\""+id+"\","
                    var refName = ""
                    if(data.0 != nil){
                        refName = (data.0 as! Observable<Float>).name;
                    }
                    
                    if(data.1 != nil){
                        for var i in 0..<data.1!.count{
                            refName += data.1![i]
                        }
                        
                    }
                    json_string += "\"reference\":\""+refName+"\","
                    json_string += "\"relative\":\""+data.2+"\","
                    json_string += "\"state\":\""+data.3+"\""
                    
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
            
            var method_list = methods[data.0]!;
            json_string += "{"
            json_string += "\"id\":\""+key+"\","
            if(data.3 != nil){
                json_string += "\"event\":\""+data.3!+"\","
            }
            
            json_string += "\"name\":\""+data.0+"\","
            json_string += "\"fromState\":\""+self.getStateByName(data.4)!+"\","
            json_string += "\"toState\":\""+self.getStateByName(data.5)!+"\","
            json_string += "\"methods\":["
            for i in 0..<method_list.count{
                
                if(i>0){
                    json_string += ","
                }
                json_string += "{"
                json_string += "\"id\":\""+method_list[i].0+"\","
                json_string += "\"name\":\""+method_list[i].1+"\""
                json_string += "}"
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
    
    
    
    /*func getMethodsByTransition(name:String)->[(String,String,String,[Any]?)]{
     var tmethods = [(String,String,String,[Any]?)]();
     for m in methods {
     if m.0 == name{
     tmethods.append(m)
     }
     }
     return tmethods;
     }*/
    
    func addCondition(name:String, reference:Any?, referenceNames:[String]?, relative:Any?, relativeNames:[String]?, relational:String){
        
        conditions.append((name,reference,referenceNames,relative,relativeNames,relational))
        
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
    
    func addSine(name:String,freq:Float,amp:Float,phase:Float){
        generators[name] = ("sine",[freq,amp,phase]);
    }
    
    
    func addRandomGenerator(name:String,min:Float,max:Float){
        generators[name] = ("random",[min,max]);
    }
    
    func addLogiGrowthGenerator(name:String,a:Float,b:Float,k:Float){
        
        generators[name] = ("logigrowth",[a,b,k]);
    }
    
    
    func addAlternate(name:String,values:[Float]){
        generators[name] = ("alternate",[values]);
    }
    
    func addState(stateId:String, stateName:String){
        print("adding state\(stateId,stateName)");
        states[stateId] = stateName;
    }
    
    func removeState(stateId:String){
        removeTransitionsForState(stateId);
        removeMappingsForState(stateId);
        if(states[stateId] != nil){
            states.removeValueForKey(stateId);
            
        }
    }
    
    func addMethod(targetTransition:String?, methodId: String, targetMethod:String, arguments:[Any]?){
        var tt:String;
        if(targetTransition != nil){
            tt = targetTransition!
        }
        else{
            tt = "globalTransition"
        }
        if(methods[tt] == nil){
            methods [tt] = [];
        }
        methods[tt]!.append((methodId,targetMethod,arguments))
    }
    
    func removeMethod(methodId:String){
        for (_, var method_list) in methods{
            for i in 0..<method_list.count{
                if method_list[i].0 == methodId{
                    method_list.removeAtIndex(i);
                    if method_list.count == 0{
                        methods.removeValueForKey(methodId);
                        
                    }
                    return;
                }
                
            }
        }
        print("method with id \(methodId) not found");
    }
    
    func removeMethodsForTransition(transitionId:String){
        if(methods[transitionId] != nil){
            
            methods.removeValueForKey(transitionId);
            return;
        }
        
        print("no methods for transition \(transitionId)")
        
    }
    
    func addTransition(transitionId:String, name:String, eventEmitter:Emitter?,parentFlag:Bool, event:String?, fromStateId:String,toStateId:String, condition:String?){
        transitions[transitionId]=((name,eventEmitter, parentFlag, event, fromStateId,toStateId,condition))
    }
    
    func setTransitionToDefaultEvent(transitionId:String) throws{
        if(transitions[transitionId] != nil){
            transitions[transitionId]!.1 = nil;
            transitions[transitionId]!.3 = "STATE_COMPLETE";
            return;
        }
        
        throw BehaviorError.transitionDoesNotExist;

    }
    
    
    func removeTransition(id:String) throws{
        print("removing transition \(transitions,id)")
        
        removeMethodsForTransition(id);
       
        if(transitions[id] != nil){
            transitions.removeValueForKey(id);
            return;
        }
        throw BehaviorError.transitionDoesNotExist;
        
    }
    
    func removeTransitionsForState(stateId:String){
    for (key,transition) in transitions{
        if(transition.5 == stateId || transition.4 == stateId){
            do {
                try removeTransition(key);
            }
            catch{
                print("no transition by that id for that state");
            }

        }
    }
    }
    
    
    func addMapping(id:String, referenceProperty:Any?, referenceNames:[String]?, relativePropertyName:String,stateId:String, type:String){
        print("mapping type = \(type)");
        mappings[id] = ((referenceProperty,referenceNames,relativePropertyName,stateId,type))
        print("mappings:\(mappings)")
        
    }
    
    func removeMappingsForState(stateId:String){
        for(key,mapping) in mappings{
            if mapping.3 == stateId{
                do{
                    try removeMapping(key);

                }
                catch{
                    print("no mapping by that state id")
                }
            }
        }
    }
    
    func removeMapping(id:String) throws{
        print("removing mappings \(mappings,id)")
        if(mappings[id] != nil){
            let mapping = mappings[id];
            if(mapping!.0 == nil){
                if(mapping!.1 != nil){
                    let mappingKey = mapping!.1![0];
                    if(expressions[mappingKey] != nil){
                        expressions.removeValueForKey(mappingKey);
                    }
                }
            }
            mappings.removeValueForKey(id);
            return;
        }
        throw BehaviorError.mappingDoesNotExist;
        
    }
    
    func removeMappingReference(id:String) throws{
        print("removing mapping reference \(mappings,id)")
        if(mappings[id] != nil){
            mappings[id]!.0 = nil;
            mappings[id]!.1 = nil;
            return;
        }
        throw BehaviorError.mappingDoesNotExist;
        
    }
    
    func addExpression(id:String, emitterOperandList:[String:(Any?,[String]?)], expressionText:String){
        expressions[id]=(emitterOperandList,expressionText);
        print("adding expression\(expressions)");
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
        case "sine":
            let sine = Sine(freq: data.1[0] as! Float, amp: data.1[1] as! Float, phase: data.1[2] as! Float);
            storedGenerators[name] = sine;
        case "random":
            let random = RandomGenerator(start:data.1[0] as! Float, end:data.1[1] as! Float)
            storedGenerators[name] = random;
        case "logigrowth":
            let logigrowth = LogiGrowthGenerator(a: data.1[0] as! Float, b:  data.1[1] as! Float, k:  data.1[2] as! Float)
            storedGenerators[name] = logigrowth;
            
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
    
    func generateSingleOperand(targetBrush:Brush, emitter:Any?,propList:[String]?)->Observable<Float>{
        print("stored generators: \(storedGenerators)");
        var targetEmitter:Any;
        var operand:Observable<Float>
        if(emitter == nil){
            targetEmitter = targetBrush;
        }
        else{
            targetEmitter = emitter;
        }
        if(propList != nil){
            if(storedGenerators[propList![0]]) != nil{
                operand = storedGenerators[propList![0]]!;
            }
            else if(storedExpressions[propList![0]] != nil){
                operand = storedExpressions[propList![0]]!;
                
            }
            else if(storedConditions[propList![0]] != nil){
                operand = storedConditions[propList![0]]!;
                
            }
            else{
                operand = (emitter as! Model)[propList![0]]! as! Observable<Float>
            }
            
            if(propList!.count > 1){
                
                for var i in 1..<propList!.count{
                    operand = operand[propList![i]] as! Observable<Float>
                }
            }
        }
        else{
            operand = emitter as! Observable<Float>
        }
        return operand;
    }
    
    func generateOperands(targetBrush:Brush,data:(Any?,[String]?,Any?,[String]?,String))->(Observable<Float>,Observable<Float>){
        var emitter1:Any
        var emitter2:Any
        
        var operand1:Observable<Float>
        var operand2: Observable<Float>
        
        if(data.0 == nil){
            emitter1 = targetBrush;
        }
        else{
            emitter1 = data.0!
        }
        
        if(data.2 == nil){
            emitter2 = targetBrush
        }
        else{
            emitter2 = data.2!
        }
        
        if(data.1 != nil){
            var refPropList = data.1!
            if(storedGenerators[refPropList[0]]) != nil{
                operand1 = storedGenerators[refPropList[0]]!;
            }
            else if(storedExpressions[refPropList[0]] != nil){
                operand1 = storedExpressions[refPropList[0]]!;
                
            }
            else if(storedConditions[refPropList[0]] != nil){
                operand1 = storedConditions[refPropList[0]]!;
                
            }
            else{
                operand1 = (emitter1 as! Model)[refPropList[0]]! as! Observable<Float>
            }
            
            if(refPropList.count > 1){
                
                for var i in 1..<refPropList.count{
                    operand1 = operand1[refPropList[i]] as! Observable<Float>
                }
            }
        }
        else{
            operand1 = emitter1 as! Observable<Float>
        }
        
        if(data.3  != nil){
            var refPropList = data.3!
            if(storedGenerators[refPropList[0]]) != nil{
                operand2 = storedGenerators[refPropList[0]]!;
            }
            else if(storedExpressions[refPropList[0]] != nil){
                operand2 = storedExpressions[refPropList[0]]!;
                
            }
            else if(storedConditions[refPropList[0]] != nil){
                operand2 = storedConditions[refPropList[0]]!;
                
            }
            else{
                operand2 = (emitter2 as! Model)[refPropList[0]] as! Observable<Float>
            }
            
            if(refPropList.count > 1){
                
                for var i in 1..<refPropList.count{
                    operand2 = operand2[refPropList[i]] as! Observable<Float>
                    
                }
            }
        }
        else{
            operand2 = emitter2 as! Observable<Float>
        }
        
        return(operand1,operand2)
        
        
    }
    
    func generateCondition(targetBrush:Brush, data:(String, Any?,[String]?,Any?,[String]?,String)){
        let name = data.0;
        //TODO: THIS IS GARBAGE CODE. Find a better solution
        let operands = generateOperands(targetBrush, data:(data.1,data.2,data.3,data.4,data.5))
        let operand1 = operands.0;
        let operand2 = operands.1;
        
        let condition = Condition(a: operand1, b: operand2, relational: data.5)
        storedConditions[name] = condition;
        
    }
    
    func generateExpression(targetBrush:Brush, name:String, data:([String:(Any?,[String]?)],String)){
        var operands = [String:Observable<Float>]();
        print("expression operand data\(data.0)");
        for (key,value) in data.0 {
            let emitter = value.0;
            let propList = value.1;
            let operand = self.generateSingleOperand(targetBrush, emitter: emitter, propList: propList)
            operands[key] = operand;
        }
        print("expression operands=\(operands)");
        let expression = TextExpression(id:name,operandList: operands, text: data.1);
        self.storedExpressions[name] = expression;
    }
    
    func generateMapping(targetBrush:Brush, id:String, data:(Any?,[String]?,String,String,String)){
        
        var mappingRelativeList = [String]();
        mappingRelativeList.append(data.2);
        let operands = generateOperands(targetBrush, data:(data.0,data.1,targetBrush,mappingRelativeList,""))
        let referenceOperand = operands.0;
        let relativeOperand = operands.1;
        
        behaviorMapper.createMapping(id, reference: referenceOperand, relative: targetBrush, relativeProperty: relativeOperand, stateId: data.3,type:data.4)
    }
    
    func addBrush(targetBrush:Brush){
        self.brushInstances.append(targetBrush);
    }
    
    func createBehavior(){
        print("create behavior called \(self.brushInstances.count)");
        print("expressions before behavior created \(self.storedExpressions)");
        self.storedExpressions.removeAll();
        self.storedConditions.removeAll();
        self.storedGenerators.removeAll();
        print("expressions after clear \(self.storedExpressions)");

        for var i in 0..<self.brushInstances.count{
            let targetBrush = self.brushInstances[i];
            targetBrush.clearBehavior();
            targetBrush.createGlobals();
           
            for (key, generator_data) in generators{
                self.generateGenerator(key,data:generator_data)
            }
            
            for i in 0..<conditions.count{
                self.generateCondition(targetBrush,data:conditions[i])
            }
            
            for (key,expression_data) in expressions{
                self.generateExpression(targetBrush,name:key,data:expression_data)
                
                
                
            }
            print("expressions after created \(self.storedExpressions)");

            for (id,state) in states{
                behaviorMapper.createState(targetBrush,stateId:id, stateName:state)
                
            }
            print("transitions:\(transitions)")
            for (key,transition) in transitions{
                if((transition.3?.isEmpty) == false){
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
                    
                    
                    print("generating transition \(key) because event is: \(transition.3)");
                    
                    behaviorMapper.createStateTransition(key,name: transition.0,reference:reference as! Emitter, relative: targetBrush, eventName: transition.3!, fromStateId:transition.4,toStateId:transition.5, condition: condition)
                }
                    
                    
                else{
                    print("could not generate transition \(key) because event is empty")
                    
                }
                
            }
            
            for (key,method_list) in methods{
                for method in method_list {
                    print("generating method:\(targetBrush,transitionName:key,methodId:method.0,methodName:method.1,arguments:method.2)");
                    behaviorMapper.addMethod(targetBrush,transitionName:key,methodId:method.0,methodName:method.1,arguments:method.2);
                }
            }
            
            //referenceProperty!,referenceName!,relativePropertyName,stateId
            for (id, mapping_data) in mappings{
                if(mapping_data.0 != nil || mapping_data.1 != nil ){
                    print("generating mapping \(id) because reference is not nil")
                    
                    self.generateMapping(targetBrush,id:id, data:mapping_data);
                }
                else{
                    print("could not generate mapping \(id) because reference is nil")
                }
                targetBrush.setupTransition();
                
            }
        }
        
        
    }
    
}
