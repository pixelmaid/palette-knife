//
//  BehaviorManager.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 5/25/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

enum BehaviorError: ErrorType {
    case duplicateName
    case behaviorDoesNotExist
    case mappingDoesNotExist;
    case transitionDoesNotExist;
}

class BehaviorManager{
    var behaviors = [String:BehaviorDefinition]()
    var activeBehavior:BehaviorDefinition?;
    var canvas:Canvas
    init(canvas:Canvas){
        self.canvas = canvas;
    }
    
    
    func handleAuthoringRequest(authoring_data:JSON) throws->(String,String,JSON?){
        let data = authoring_data["data"] as JSON;
        let type = data["type"].stringValue;
        print("authoring request \(type)");
        
        switch(type){
            
        case "behavior_added":
            let name = data["name"].stringValue;
            let id = data["id"].stringValue;
            let setupId = data["setupId"].stringValue;
            let endId = data["dieId"].stringValue;
            print("behaviors with name\(name, behaviors[name])");
            
            let behavior = BehaviorDefinition(id:data["id"].stringValue, name: data["name"].stringValue);
            if(behaviors[id] != nil){
                throw BehaviorError.duplicateName;
            }
            else{
                behaviors[id] = behavior;
                activeBehavior = behavior;
                activeBehavior?.addState(setupId, stateName: "setup");
                activeBehavior?.addState(endId, stateName: "die");
                
                let brush = Brush(name: "brush_"+data["id"].stringValue, behaviorDef: activeBehavior, parent: nil, canvas: canvas)
                return ("behavior_added","success",nil)
            }
            
            
            
            
        case "state_added":
            print("state added behaviors \(behaviors.count,data["behaviorId"].stringValue,behaviors)");
            behaviors[data["behaviorId"].stringValue]!.addState(data["id"].stringValue, stateName: data["name"].stringValue);
            
            behaviors[data["behaviorId"].stringValue]!.createBehavior()
            
            return ("state_added","success",nil)
        case "state_removed":
          
            behaviors[data["behaviorId"].stringValue]!.removeState(data["stateId"].stringValue);
            
            behaviors[data["behaviorId"].stringValue]!.createBehavior()
            
            return ("state_removed","success",nil)

        case "transition_added","transition_event_added":
            let event = data["eventName"].stringValue;
            print("adding transition \(data)")
            let emitter:Emitter?
            if(data["emitter"] != nil){
                switch(data["emitter"].stringValue){
                case "stylus":
                    emitter = stylus;
                    break;
                default:
                    emitter = nil;
                    break;
                }
            }
            else{
                switch(event){
                    case "STYLUS_UP","STYLUS_DOWN","STYLUS_MOVE":
                    emitter = stylus
                    break;
                    case "TICK","STATE_COMPLETE":
                    emitter = nil;
                    break;
                default:
                    emitter = nil
                    break;
                }
            }
            
            behaviors[data["behaviorId"].stringValue]!.addTransition(data["transitionId"].stringValue, name: data["name"].stringValue, eventEmitter: emitter, parentFlag: data["parentFlag"].boolValue, event: data["eventName"].stringValue, fromStateId: data["fromStateId"].stringValue, toStateId: data["toStateId"].stringValue, condition: data["condition"].stringValue)
            

            behaviors[data["behaviorId"].stringValue]!.createBehavior()
            
            return ("transition_added","success",nil)
        
        case "transition_removed":
            do{
            try behaviors[data["behaviorId"].stringValue]!.removeTransition(data["transitionId"].stringValue);
            behaviors[data["behaviorId"].stringValue]!.createBehavior()

            return("transition_removed","success",nil);
            }
            catch{
                print("transition id does not exist, cannot remove");
                return (type,"failure",nil)
                
            }
        case "transition_event_removed":
            do{
            try behaviors[data["behaviorId"].stringValue]!.setTransitionToDefaultEvent(data["transitionId"].stringValue)
                behaviors[data["behaviorId"].stringValue]!.createBehavior();
                return ("transition_event_removed","success",nil)
            }
            catch{
                return ("transition_event_removed","failure",nil)
            }
        
            

        case "method_added","method_argument_changed":
            let behaviorId = data["behaviorId"].stringValue
            let targetTransition:String?
            if(data["targetTransition"] != nil){
                targetTransition = data["targetTransition"].stringValue;
            }
            else{
                targetTransition = nil;
            }
            var arguments:[Any]? = nil;
            let dataArguments = data["args"];
            let targetMethod = data["targetMethod"].stringValue
            
            var methodJSON:JSON = [:]
            switch(targetMethod){
              case "spawn":
                let name:String;
                let behavior:BehaviorDefinition;
                let num:Int;
                
                if(dataArguments != nil){
                    let spawnBehaviorId = (dataArguments.arrayValue)[0].stringValue;
                    if(spawnBehaviorId == "self"){
                        behavior = self.behaviors[behaviorId]!;
                    }
                    else{
                        behavior = self.behaviors[spawnBehaviorId]!;
                    }
                    name = behavior.name+"_child";
                    num = (dataArguments.arrayValue)[1].intValue
                   
                    arguments = [name,behavior,num];
                }
                else{
                    arguments = [self.behaviors[behaviorId]!.name+"_child","self",1]
                }
                var behavior_list = [String:String]()
                
                for (key,value) in self.behaviors{
                    if key != behaviorId {
                    behavior_list[key] = value.name;
                    }
                }
                behavior_list["self"] = "self";
                methodJSON["argumentList"] = JSON(behavior_list);
                methodJSON["defaultArgument"] = JSON("self");
                break;
                
           
                
                
            case "setOrigin", "newStroke":
                if(dataArguments != nil){
                    let arg = (dataArguments.arrayValue)[0].stringValue;
                    switch(arg){
                        case "stylus_position":
                            arguments = [stylus.position];
                            break;
                        case "parent_position":
                            arguments = ["parent_position"];
                            break;
                    case "parent_origin":
                        arguments = ["parent_origin"];
                        break;
                    default:
                        //TODO: handle arbitrary point values here
                        break;
                    }
                }
                else{
                    arguments = [stylus.position];
                }
                methodJSON["argumentList"] = JSON(["stylus_position":"stylus_position","parent_position":"parent_position","parent_origin":"parent_origin" ])
                methodJSON["defaultArgument"] = JSON("stylus_position");

                break;
            case "startTimer":
                arguments = nil
                break;
            case "stopTimer":
                arguments = nil

                break;
            default:
                arguments = nil;
                break;
            }
            
            print("arguments= \(arguments)")
            behaviors[data["behaviorId"].stringValue]!.addMethod(targetTransition, methodId: data["methodId"].stringValue, targetMethod: targetMethod, arguments: arguments)
            behaviors[data["behaviorId"].stringValue]!.createBehavior();
            
            return ("method_added","success",methodJSON)
           
        case "method_removed":
            
            behaviors[data["behaviorId"].stringValue]!.removeMethod(data["methodId"].stringValue)
            behaviors[data["behaviorId"].stringValue]!.createBehavior();
            print("removed method");
            return ("method_removed","success",nil)

            
        case "mapping_added":
            let behaviorId = data["behaviorId"].stringValue;
            let expressionId = data["expressionId"].stringValue;
            self.addExpression(behaviorId, expressionId: expressionId, expressionText: "", expressionPropertyList: nil)
            behaviors[behaviorId]!.addMapping(data["mappingId"].stringValue, referenceProperty:nil, referenceNames: [expressionId], relativePropertyName: data["relativePropertyName"].stringValue, stateId: data["stateId"].stringValue,type: data["constraintType"].stringValue)
            
            behaviors[behaviorId]!.createBehavior()
            
            return (type,"success",nil)
            
        case "mapping_updated":
        let behaviorId = data["behaviorId"].stringValue;
            let expressionId = data["expressionId"].stringValue;
            
            let propertyList = data["expressionPropertyList"];
            let expressionText = data["expressionText"].stringValue;
            
            self.addExpression(behaviorId, expressionId: expressionId, expressionText: expressionText, expressionPropertyList: propertyList)

            
            print("behavior update mapping, target state:\(data["stateId"].stringValue)");
            
            behaviors[behaviorId]!.addMapping(data["mappingId"].stringValue, referenceProperty:nil, referenceNames: [expressionId], relativePropertyName: data["relativePropertyName"].stringValue, stateId: data["stateId"].stringValue,type: data["constraintType"].stringValue)
            behaviors[data["behaviorId"].stringValue]!.createBehavior()
            
            return (type,"success",nil)
            
            
        case "expression_text_modified":
            let behaviorId = data["behaviorId"].stringValue;
            let expressionId = data["expressionId"].stringValue;
            let expressionText = data["expressionText"].stringValue;
            let propertyList = data["expressionPropertyList"];

            self.addExpression(behaviorId, expressionId: expressionId, expressionText: expressionText, expressionPropertyList: propertyList)
            
            behaviors[behaviorId]!.createBehavior()
            
            return (type,"success",nil)

            
        case "mapping_relative_removed":
            
            do{
                try behaviors[data["behaviorId"].stringValue]!.removeMapping(data["mappingId"].stringValue);
                behaviors[data["behaviorId"].stringValue]!.createBehavior()
                
                return (type,"success",nil)
                
            }
            catch{
                print("mapping id does not exist, cannot remove");
                return (type,"failure",nil)
                
            }
            
        case "mapping_reference_removed":
            let behaviorId = data["behaviorId"].stringValue;
            let expressionId = data["expressionId"].stringValue;
            
            let propertyList = data["expressionPropertyList"];
            let expressionText = data["expressionText"].stringValue;
            
            self.addExpression(behaviorId, expressionId: expressionId, expressionText: expressionText, expressionPropertyList: propertyList)
            
            return (type,"success",nil)


            
        case "generator_added":
            let type = data["generator_type"].stringValue;
            
            switch(type){
            case "random":
                behaviors[data["behaviorId"].stringValue]!.addRandomGenerator(data["generatorId"].stringValue, min: data["min"].floatValue, max: data["max"].floatValue)
                break;
            case "alternate":
                let jsonValues =  data["values"].arrayValue;
                var values = [Float]();
                for i in jsonValues{
                    values.append(i.floatValue);
                }
                behaviors[data["behaviorId"].stringValue]!.addAlternate(data["generatorId"].stringValue, values: values)
                break;
                
                
            case "range":
                
                behaviors[data["behaviorId"].stringValue]!.addRange(data["generatorId"].stringValue, min: data["min"].intValue, max: data["max"].intValue, start: data["start"].floatValue, stop: data["stop"].floatValue)
                break;
                
            case "sine":
                behaviors[data["behaviorId"].stringValue]!.addSine(data["generatorId"].stringValue, freq: data["freq"].floatValue, amp: data["amp"].floatValue, phase: data["phase"].floatValue);
                
                break;
                // case "random_walk":
                
                //return "success"
                
                
            //  return "success";
            default:
                break;
            }
            
            behaviors[data["behaviorId"].stringValue]!.createBehavior()
            
            return ("generator_added","success",nil);
            
            
            
        default:
            break
        }
        
        
        
        return (type,"fail",nil)
    }
    
    func addExpression(behaviorId:String, expressionId:String, expressionText:String, expressionPropertyList:JSON?){
        var emitterOperandList = [String:(Any?,[String]?)]();
        
        if(expressionPropertyList != nil){
            print("expression list present\(expressionPropertyList!.dictionaryValue)")
            var dataExpressionDictionary = expressionPropertyList!.dictionaryValue;
        for (key,value) in dataExpressionDictionary{
            let dataEmitterValue = (value.arrayValue)[0].stringValue;
            let emitter:Any?
            switch(dataEmitterValue){
            case "stylus":
                emitter = stylus;
                break;
            default:
                emitter = nil;
                break;
            }
            var propertyList:[String]?;
            
            if ((value.arrayValue)[1] != nil) {
                let dataPropertyList = (value.arrayValue)[1].arrayValue;
                propertyList = [String]();
                
                for i in 0..<dataPropertyList.count {
                    let property = dataPropertyList[i].stringValue;
                    propertyList!.append(property)
                }
            }
            
            emitterOperandList[key]=(emitter,propertyList);
        }
        }
        
        print("emitter operand list \(emitterOperandList,expressionText)")
        behaviors[behaviorId]!.addExpression(expressionId, emitterOperandList: emitterOperandList, expressionText: expressionText)
    }
    
    
    func getAllBehaviorJSON()->String {
        var behavior_string = "["
        for (_, behavior) in behaviors {
            let data = behavior.toJSON();
            behavior_string += data+","
        }
        behavior_string = behavior_string.substringToIndex(behavior_string.endIndex.predecessor()) + "]";
        return behavior_string;
        
    }
    
    func getBehaviorJSON(name:String) throws->String{
        if(behaviors[name] != nil){
            return (behaviors[name]!.toJSON());
        }
        else{
            throw BehaviorError.behaviorDoesNotExist;
        }
        
    }
    
    func defaultSetup(name:String) throws->BehaviorDefinition {
        let b = BehaviorDefinition(id:NSUUID().UUIDString,name: name)
        //TODO: add check for if name is a duplicate
        if(behaviors[name] != nil){
            throw BehaviorError.duplicateName;
        }
        else{
            
            behaviors[name] = b;
            b.addState(NSUUID().UUIDString,stateName:"start")
            b.addState(NSUUID().UUIDString,stateName:"default")
            
            b.addTransition(NSUUID().UUIDString, name: "setup", eventEmitter: nil, parentFlag: false, event: "STATE_COMPLETE", fromStateId: "start", toStateId:"default", condition: nil)
            return b;
        }
        
        
    }
    
    func initSpawnTemplate(name:String)->BehaviorDefinition?{
        do {
            let b = try defaultSetup(name);
            
            
            b.addMethod("setup", methodId:NSUUID().UUIDString, targetMethod: "newStroke", arguments:nil)
            b.addMethod("setup", methodId:NSUUID().UUIDString, targetMethod: "setOrigin", arguments: ["parent"])
            b.addMethod("setup", methodId: NSUUID().UUIDString, targetMethod: "startInterval", arguments: nil);
            return b;
            
        }
        catch {
            return nil;
        }
    }
    
    func initStandardTemplate(name:String) ->BehaviorDefinition?{
        
        do {
            let b = try defaultSetup(name);
            
            b.addTransition(NSUUID().UUIDString, name:"stylusDownTransition", eventEmitter: stylus, parentFlag:false, event: "STYLUS_DOWN", fromStateId: b.getStateByName("default")!, toStateId: b.getStateByName("default")!, condition:nil)
            b.addTransition(NSUUID().UUIDString, name:"stylusUpTransition", eventEmitter: stylus, parentFlag:false, event: "STYLUS_UP", fromStateId: b.getStateByName("default")!, toStateId: b.getStateByName("default")!, condition:nil)
            
            b.addMethod("stylusDownTransition", methodId:NSUUID().UUIDString, targetMethod: "setOrigin", arguments: [stylus.position])
            b.addMethod("stylusDownTransition", methodId:NSUUID().UUIDString, targetMethod: "newStroke", arguments: nil)
            b.addMethod("stylusDownTransition", methodId:NSUUID().UUIDString, targetMethod: "startInterval", arguments: nil)
            b.addMethod("stylusUpTransition", methodId:NSUUID().UUIDString, targetMethod: "stopInterval", arguments: nil)
            
            
            b.addMapping(NSUUID().UUIDString, referenceProperty:stylus, referenceNames: ["dx"], relativePropertyName: "dx", stateId: "default", type:"active")
            b.addMapping(NSUUID().UUIDString, referenceProperty:stylus, referenceNames: ["dy"], relativePropertyName: "dy", stateId: "default", type:"active")
            // b.addMapping(NSUUID().UUIDString, referenceProperty:stylus, referenceNames: ["force"], relativePropertyName: "weight", stateId: "default")
            
            return b;
        }
        catch {
            return nil;
        }
        
    }
    
    
    //---------------------------------- HARDCODED BEHAVIORS ---------------------------------- //
    func initBakeBehavior()->BehaviorDefinition?{
        let b1 = initStandardTemplate("b1");
        
        
        b1!.addTransition(NSUUID().UUIDString, name:"stylusUpT", eventEmitter: stylus, parentFlag:false, event: "STYLUS_UP", fromStateId: b1!.getStateByName("default")!, toStateId: b1!.getStateByName("default")!, condition:nil);
        
        
        b1!.addMethod("stylusUpT", methodId:NSUUID().UUIDString, targetMethod: "bake", arguments: nil)
        //b1.addMethod("stylusUpT", methodId:NSUUID().UUIDString, targetMethod: "liftUp", arguments: nil)
        
        b1!.addMethod("stylusDownTransition",methodId:NSUUID().UUIDString,targetMethod: "jogTo", arguments: [stylus.position])
        
        return b1;
    }
    
    func initDripBehavior()->BehaviorDefinition?{
        let dripBehavior = initSpawnTemplate("dripBehavior");
        
        dripBehavior!.addLogiGrowthGenerator("weightGenerator", a:10,b:15,k:0.36);
        //  dripBehavior!.addExpression("weightExpression", emitter1: nil, operand1Names:["weight"], emitter2: nil, operand2Names: ["weightGenerator"], type: "add")
        dripBehavior!.addRandomGenerator("randomTimeGenerator", min:50, max: 100)
        dripBehavior!.addCondition("lengthCondition", reference: nil, referenceNames: ["distance"], relative: nil, relativeNames: ["randomTimeGenerator"], relational: ">")
        dripBehavior!.addState(NSUUID().UUIDString, stateName: "die");
        
        dripBehavior!.addTransition(NSUUID().UUIDString, name: "tickTransition", eventEmitter: nil, parentFlag: false, event: "TICK", fromStateId: "default", toStateId: "default", condition: nil)
        dripBehavior!.addMapping(NSUUID().UUIDString, referenceProperty: Observable<Float>(2), referenceNames: nil, relativePropertyName: "dy", stateId: "default", type:"active")
        
        dripBehavior!.addMapping(NSUUID().UUIDString, referenceProperty: nil, referenceNames: ["weightExpression"], relativePropertyName: "weight", stateId: "default", type:"active")
        
        
        
        dripBehavior!.addTransition(NSUUID().UUIDString, name: "dieTransition", eventEmitter: nil, parentFlag: false, event: "TICK", fromStateId: dripBehavior!.getStateByName("default")!, toStateId: dripBehavior!.getStateByName("die")!, condition: "lengthCondition")
        
        
        let parentBehavior = initStandardTemplate("parentBehavior");
        parentBehavior!.addInterval("lengthInterval", inc: 100, times: nil)
        parentBehavior!.addCondition("lengthCondition", reference: nil, referenceNames: ["distance"], relative: nil, relativeNames: ["lengthInterval"], relational: "within")
        parentBehavior!.addTransition(NSUUID().UUIDString, name: "lengthTransition", eventEmitter: nil, parentFlag: false, event: "TICK", fromStateId: parentBehavior!.getStateByName("default")!, toStateId: parentBehavior!.getStateByName("default")!, condition: "lengthCondition")
        parentBehavior!.addMethod("lengthTransition", methodId: NSUUID().UUIDString, targetMethod: "spawn", arguments: ["dripBehavior",dripBehavior,1]);
        
        return parentBehavior;
        
        
    }
    
    func initRadialBehavior()->BehaviorDefinition?{
        do{
            let radial_spawnBehavior = initSpawnTemplate("radial_spawn_behavior");
            //   radial_spawnBehavior!.addExpression("angle_expression", emitter1: nil, operand1Names: ["index"], emitter2: Observable<Float>(60), operand2Names: nil, type: "mult")
            
            radial_spawnBehavior!.addMapping(NSUUID().UUIDString, referenceProperty: nil, referenceNames: ["angle_expression"], relativePropertyName: "angle", stateId: "start", type:"active")
            
            radial_spawnBehavior!.addMapping(NSUUID().UUIDString, referenceProperty:stylus, referenceNames: ["dx"], relativePropertyName: "dx", stateId: "default", type:"active")
            radial_spawnBehavior!.addMapping(NSUUID().UUIDString, referenceProperty:stylus, referenceNames: ["dy"], relativePropertyName: "dy", stateId: "default", type:"active")
            
            
            radial_spawnBehavior!.addState(NSUUID().UUIDString,stateName:"die")
            
            radial_spawnBehavior!.addTransition(NSUUID().UUIDString, name: "dieTransition", eventEmitter: stylus, parentFlag: false, event: "STYLUS_UP", fromStateId: radial_spawnBehavior!.getStateByName("default")!, toStateId:  radial_spawnBehavior!.getStateByName("die")!, condition: nil)
            
            radial_spawnBehavior!.addMethod("dieTransition", methodId:NSUUID().UUIDString, targetMethod: "jogAndBake", arguments: nil)
            
            
            
            let radial_behavior = try defaultSetup("radial_behavior");
            
            radial_behavior.addTransition(NSUUID().UUIDString, name:"stylusDownTransition", eventEmitter: stylus, parentFlag:false, event: "STYLUS_DOWN", fromStateId: radial_behavior.getStateByName("default")!, toStateId: radial_behavior.getStateByName("default")!, condition:nil)
            radial_behavior.addTransition(NSUUID().UUIDString, name:"stylusUpTransition", eventEmitter: stylus, parentFlag:false, event: "STYLUS_UP", fromStateId: radial_behavior.getStateByName("default")!, toStateId: radial_behavior.getStateByName("default")!, condition:nil)
            
            radial_behavior.addMethod("stylusDownTransition", methodId:NSUUID().UUIDString, targetMethod: "setOrigin", arguments: [stylus.position])
            radial_behavior.addMethod("stylusDownTransition", methodId:NSUUID().UUIDString, targetMethod: "startInterval", arguments: nil)
            radial_behavior.addMethod("stylusUpTransition", methodId:NSUUID().UUIDString, targetMethod: "stopInterval", arguments: nil)
            
            
            
            
            radial_behavior.addMethod("stylusDownTransition", methodId:NSUUID().UUIDString, targetMethod: "spawn", arguments: ["radial_spawn_behavior",radial_spawnBehavior,6])
            radial_behavior.addMethod("stylusDownTransition",methodId:NSUUID().UUIDString,targetMethod: "jogTo", arguments: [stylus.position])
            return radial_behavior
            
        }
        catch{
            return nil;
        }
        
    }
    
    func initFractalBehavior()->BehaviorDefinition?{
        do{
            let branchBehavior =  try defaultSetup("branch");
            let rootBehavior =  try defaultSetup("root");
            
            branchBehavior.addRandomGenerator("random1", min: 2 , max: 5)
            branchBehavior.addState(NSUUID().UUIDString,stateName:"spawnEnd");
            
            
            branchBehavior.addCondition("spawnCondition", reference: nil, referenceNames: ["ancestors"], relative: Observable<Float>(2), relativeNames: nil, relational: "<")
            branchBehavior.addCondition("noSpawnCondition", reference: nil, referenceNames: ["ancestors"], relative: Observable<Float>(1), relativeNames: nil, relational: ">")
            
            
            branchBehavior.addState(NSUUID().UUIDString,stateName: "die");
            
            branchBehavior.addCondition("timeLimitCondition", reference: nil, referenceNames: ["time"], relative: nil, relativeNames: ["random1"], relational: ">")
            
            branchBehavior.addCondition("offCanvasCondition", reference: nil, referenceNames: ["offCanvas"], relative: Observable<Float>(1), relativeNames: nil, relational: "==")
            
            
            branchBehavior.addTransition(NSUUID().UUIDString, name: "destroyTransition", eventEmitter: nil, parentFlag: false, event: "TICK", fromStateId: branchBehavior.getStateByName("default")!, toStateId: branchBehavior.getStateByName("die")!, condition: "timeLimitCondition")
            
            branchBehavior.addTransition(NSUUID().UUIDString, name: "offCanvasTransition", eventEmitter: nil, parentFlag: false, event: "STATE_COMPLETE", fromStateId: branchBehavior.getStateByName("default")!, toStateId: branchBehavior.getStateByName("die")!, condition: "offCanvasCondition")
            
            branchBehavior.addMethod("destroyTransition",methodId:NSUUID().UUIDString,targetMethod: "jogAndBake", arguments: nil)
            branchBehavior.addMethod("offCanvasTransition",methodId:NSUUID().UUIDString,targetMethod: "jogAndBake", arguments: nil)
            
            
            // branchBehavior.addMethod("destroyTransition", methodId: NSUUID().UUIDString, targetMethod: "destroy", arguments: nil)
            
            // branchBehavior.addMethod("defaultdestroyTransition", methodId: NSUUID().UUIDString, targetMethod: "destroy", arguments: nil)
            
            
            branchBehavior.addTransition(NSUUID().UUIDString, name:"spawnTransition" , eventEmitter: nil, parentFlag: false, event: "STATE_COMPLETE", fromStateId: branchBehavior.getStateByName("die")!, toStateId: branchBehavior.getStateByName("spawnEnd")!, condition: "spawnCondition")
            
            // branchBehavior.addMethod("spawnTransition", methodId: NSUUID().UUIDString, targetMethod: "spawn", arguments: ["branchBehavior",branchBehavior,2])
            
            branchBehavior.addMethod("setup", methodId:NSUUID().UUIDString, targetMethod: "newStroke", arguments:nil)
            branchBehavior.addMethod("setup", methodId:NSUUID().UUIDString, targetMethod: "setOrigin", arguments: ["parent"])
            branchBehavior.addMethod("setup", methodId:NSUUID().UUIDString, targetMethod: "startInterval", arguments:nil)
            branchBehavior.addMethod("spawnEnd",  methodId:NSUUID().UUIDString, targetMethod: "destroy", arguments:nil)
            
            //branchBehavior.addExpression("xDeltaExp", emitter1: nil, operand1Names: ["parent","currentStroke","xBuffer"],emitter2: Observable<Float>(0.65), operand2Names: nil, type: "mult")
            
            
            //branchBehavior.addExpression("yDeltaExp", emitter1: nil, operand1Names: ["parent","currentStroke","yBuffer"], emitter2: /Observable<Float>(0.65), operand2Names: nil, type: "mult")
            
            // branchBehavior.addExpression("weightDeltaExp", emitter1: nil, operand1Names: ["parent","currentStroke","weightBuffer"],  emitter2: Observable<Float>(0.45), operand2Names: nil,type: "mult")
            
            
            branchBehavior.addMapping(NSUUID().UUIDString, referenceProperty:nil, referenceNames: ["xDeltaExp"], relativePropertyName: "dx", stateId: "default", type:"active")
            branchBehavior.addMapping(NSUUID().UUIDString, referenceProperty:nil, referenceNames: ["yDeltaExp"], relativePropertyName: "dy", stateId: "default", type:"active")
            
            branchBehavior.addMapping(NSUUID().UUIDString, referenceProperty:nil, referenceNames:["weightDeltaExp"], relativePropertyName: "weight", stateId: "default", type:"active")
            
            
            branchBehavior.addTransition(NSUUID().UUIDString, name: "tickTransition", eventEmitter: nil, parentFlag: false, event: "TICK", fromStateId: branchBehavior.getStateByName("default")!, toStateId:branchBehavior.getStateByName("default")!, condition: nil)
            
            
            
            
            rootBehavior.addInterval("timeInterval",inc:1,times:nil)
            
            
            rootBehavior.addCondition("stylusDownCondition", reference:stylus, referenceNames: ["penDown"], relative:Observable<Float>(1), relativeNames:nil, relational: "==")
            
            rootBehavior.addCondition("incrementCondition", reference: nil, referenceNames: ["time"], relative:nil, relativeNames: ["timeInterval"], relational: "within")
            
            rootBehavior.addCondition("stylusANDIncrement",reference: nil, referenceNames: ["stylusDownCondition"], relative:nil, relativeNames: ["incrementCondition"], relational: "&&");
            
            rootBehavior.addTransition(NSUUID().UUIDString, name:"stylusDownT", eventEmitter: stylus, parentFlag:false, event: "STYLUS_DOWN", fromStateId: rootBehavior.getStateByName("default")!, toStateId: rootBehavior.getStateByName("default")!, condition:nil)
            
            rootBehavior.addMethod("stylusDownT", methodId:NSUUID().UUIDString, targetMethod: "setOrigin", arguments: [stylus.position])
            rootBehavior.addMethod("stylusDownT", methodId:NSUUID().UUIDString, targetMethod: "newStroke", arguments: nil)
            rootBehavior.addMethod("stylusDownT", methodId:NSUUID().UUIDString, targetMethod: "startInterval", arguments: nil)
            
            rootBehavior.addMapping(NSUUID().UUIDString, referenceProperty:stylus, referenceNames: ["dx"], relativePropertyName: "dx", stateId: "default", type:"active")
            
            rootBehavior.addMapping(NSUUID().UUIDString, referenceProperty:stylus,  referenceNames: ["dy"], relativePropertyName: "dy", stateId: "default", type:"active")
            
            rootBehavior.addMapping(NSUUID().UUIDString, referenceProperty:stylus,  referenceNames: ["force"], relativePropertyName: "weight", stateId: "default", type:"active")
            
            
            rootBehavior.addTransition(NSUUID().UUIDString, name: "spawnTransition", eventEmitter: nil, parentFlag: false, event: "TICK", fromStateId: rootBehavior.getStateByName("default")!, toStateId: rootBehavior.getStateByName("default")!, condition: "stylusANDIncrement")
            
            rootBehavior.addTransition(NSUUID().UUIDString, name:"stylusUpT", eventEmitter: stylus, parentFlag:false, event: "STYLUS_UP", fromStateId: rootBehavior.getStateByName("default")!, toStateId: rootBehavior.getStateByName("default")!, condition:nil)
            
            rootBehavior.addMethod("spawnTransition", methodId: NSUUID().UUIDString, targetMethod: "spawn", arguments: ["branchBehavior",branchBehavior,2])
            
            //rootBehavior.addMethod("stylusUpT", methodId:NSUUID().UUIDString, targetMethod: "bake", arguments: nil)
            rootBehavior.addMethod("stylusUpT", methodId:NSUUID().UUIDString, targetMethod: "jogAndBake", arguments: nil)
            
            //  rootBehavior.addMethod("stylusDownT",methodId:NSUUID().UUIDString,targetMethod: "jogTo", arguments: nil)
            
            
            return rootBehavior;
        }
        catch{
            return nil
        }
        
        
        
    }
    
    //---------------------------------- END HARDCODED BEHAVIORS ---------------------------------- //
    
    
    
}
