//
//  BrushManager.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 5/25/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

enum BehaviorError: ErrorType {
    case duplicateName
    case behaviorDoesNotExist
}

class BehaviorManager{
    var behaviors = [String:BehaviorDefinition]()
    var activeBehavior:BehaviorDefinition?;
    
    init(){
        
    }
    
    
    func handleAuthoringRequest(data:JSON) throws->(String,String){
        let element_data = data["data"] as JSON;
        let type = element_data["type"].stringValue;
        print("authoring request data,type\(data,type)");
        if(activeBehavior == nil && type != "behavior_added"){
            let name = "my_behavior"
            activeBehavior = BehaviorDefinition(id:NSUUID().UUIDString,name: name)
            if(behaviors[name] != nil){
                throw BehaviorError.duplicateName;
            }
            else{
                behaviors[name] = activeBehavior;
            }
        }
        
        switch(type){
            
        case "behavior_added":
            activeBehavior = BehaviorDefinition(id:data["id"].stringValue, name: data["name"].stringValue);
            if(behaviors[data["name"].stringValue] != nil){
                throw BehaviorError.duplicateName;
            }
            else{
                behaviors[data["name"].stringValue] = activeBehavior;
            }
            return ("behavior_added","success")
        case "state_added":
            activeBehavior?.addState(data["id"].stringValue, stateName: data["name"].stringValue);
            return ("state_added","success")
        case "transition_added":
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
                emitter = nil;
            }
            
            activeBehavior?.addTransition(data["id"].stringValue, name: data["name"].stringValue, eventEmitter: emitter, parentFlag: data["parentFlag"].boolValue, event: data["event"].stringValue, fromStateId: data["fromStateId"].stringValue, toStateId: data["toStateId"].stringValue, condition: data["condition"].stringValue)
            return ("transition_added","success")
            
        case "method_added":
            //TODO: need to adjust this so that methods with existing arguments can be added
            let arguments:[Any]?
            arguments = nil
            
            activeBehavior?.addMethod(data["targetTransition"].stringValue, methodId: data["id"].stringValue, targetMethod: data["targetMethod"].stringValue, arguments: arguments)
            
            return ("method_added","success")
        case "mapping_added":
            let referenceNames:[String]?
            let referenceProperty:Any?
            if(data["referenceNames"] != nil){
                let jsonList =  data["referenceNames"].arrayValue;
                referenceNames = [String]();
                for i in jsonList{
                    referenceNames?.append(i.stringValue);
                }
            }
            else{
                referenceNames = nil;
            }
            if(data["referenceProperty"] != nil){
                switch(data["referenceProperty"].stringValue){
                case "stylus":
                    referenceProperty = stylus;
                    break;
                default:
                    referenceProperty = nil;
                    break;
                }
                
            }
            else{
                referenceProperty = nil;
            }
            activeBehavior?.addMapping(data["id"].stringValue, referenceProperty:referenceProperty, referenceNames: referenceNames, relativePropertyName: data["relativePropertyName"].stringValue, targetState: data["targetState"].stringValue)
            return ("mapping_added","success")
            
        case "generator_added":
            let type = data["type"].stringValue;
            
            switch(type){
            case "random":
                activeBehavior?.addRandomGenerator(data["name"].stringValue, min: data["min"].floatValue, max: data["max"].floatValue)
                return ("generator_added","success");
                
            case "alternate":
                let jsonValues =  data["values"].arrayValue;
                var values = [Float]();
                for i in jsonValues{
                    values.append(i.floatValue);
                }
                activeBehavior?.addAlternate(data["name"].stringValue, values: values)
                return ("generator_added","success")
                
                
            case "range":
                
                activeBehavior?.addRange(data["name"].stringValue, min: data["min"].intValue, max: data["max"].intValue, start: data["start"].floatValue, stop: data["stop"].floatValue)
                return ("generator_added","success")
                
                // case "random_walk":
                
                //return "success"
                
                //case "sine":
                
            //  return "success";
            default:
                break;
            }
            break;
            
        default:
            break
        }
        
        
        
        return (type,"success")
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
            
            
            b.addMapping(NSUUID().UUIDString, referenceProperty:stylus, referenceNames: ["dx"], relativePropertyName: "dx", targetState: "default")
            b.addMapping(NSUUID().UUIDString, referenceProperty:stylus, referenceNames: ["dy"], relativePropertyName: "dy", targetState: "default")
            // b.addMapping(NSUUID().UUIDString, referenceProperty:stylus, referenceNames: ["force"], relativePropertyName: "weight", targetState: "default")
            
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
        dripBehavior!.addExpression("weightExpression", emitter1: nil, operand1Names:["weight"], emitter2: nil, operand2Names: ["weightGenerator"], type: "add")
        dripBehavior!.addRandomGenerator("randomTimeGenerator", min:50, max: 100)
        dripBehavior!.addCondition("lengthCondition", reference: nil, referenceNames: ["distance"], relative: nil, relativeNames: ["randomTimeGenerator"], relational: ">")
        dripBehavior!.addState(NSUUID().UUIDString, stateName: "die");
        
        dripBehavior!.addTransition(NSUUID().UUIDString, name: "tickTransition", eventEmitter: nil, parentFlag: false, event: "TICK", fromStateId: "default", toStateId: "default", condition: nil)
        dripBehavior!.addMapping(NSUUID().UUIDString, referenceProperty: Observable<Float>(2), referenceNames: nil, relativePropertyName: "dy", targetState: "default")
        
        dripBehavior!.addMapping(NSUUID().UUIDString, referenceProperty: nil, referenceNames: ["weightExpression"], relativePropertyName: "weight", targetState: "default")
        
        
        
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
            radial_spawnBehavior!.addExpression("angle_expression", emitter1: nil, operand1Names: ["index"], emitter2: Observable<Float>(60), operand2Names: nil, type: "mult")
            
            radial_spawnBehavior!.addMapping(NSUUID().UUIDString, referenceProperty: nil, referenceNames: ["angle_expression"], relativePropertyName: "angle", targetState: "start")
            
            radial_spawnBehavior!.addMapping(NSUUID().UUIDString, referenceProperty:stylus, referenceNames: ["dx"], relativePropertyName: "dx", targetState: "default")
            radial_spawnBehavior!.addMapping(NSUUID().UUIDString, referenceProperty:stylus, referenceNames: ["dy"], relativePropertyName: "dy", targetState: "default")
            
            
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
            
            branchBehavior.addExpression("xDeltaExp", emitter1: nil, operand1Names: ["parent","currentStroke","xBuffer"],emitter2: Observable<Float>(0.65), operand2Names: nil, type: "mult")
            
            
            branchBehavior.addExpression("yDeltaExp", emitter1: nil, operand1Names: ["parent","currentStroke","yBuffer"], emitter2: Observable<Float>(0.65), operand2Names: nil, type: "mult")
            
            branchBehavior.addExpression("weightDeltaExp", emitter1: nil, operand1Names: ["parent","currentStroke","weightBuffer"],  emitter2: Observable<Float>(0.45), operand2Names: nil,type: "mult")
            
            
            branchBehavior.addMapping(NSUUID().UUIDString, referenceProperty:nil, referenceNames: ["xDeltaExp"], relativePropertyName: "dx", targetState: "default")
            branchBehavior.addMapping(NSUUID().UUIDString, referenceProperty:nil, referenceNames: ["yDeltaExp"], relativePropertyName: "dy", targetState: "default")
            
            branchBehavior.addMapping(NSUUID().UUIDString, referenceProperty:nil, referenceNames:["weightDeltaExp"], relativePropertyName: "weight", targetState: "default")
            
            
            branchBehavior.addTransition(NSUUID().UUIDString, name: "tickTransition", eventEmitter: nil, parentFlag: false, event: "TICK", fromStateId: branchBehavior.getStateByName("default")!, toStateId:branchBehavior.getStateByName("default")!, condition: nil)
            
            
            
            
            rootBehavior.addInterval("timeInterval",inc:1,times:nil)
            
            
            rootBehavior.addCondition("stylusDownCondition", reference:stylus, referenceNames: ["penDown"], relative:Observable<Float>(1), relativeNames:nil, relational: "==")
            
            rootBehavior.addCondition("incrementCondition", reference: nil, referenceNames: ["time"], relative:nil, relativeNames: ["timeInterval"], relational: "within")
            
            rootBehavior.addCondition("stylusANDIncrement",reference: nil, referenceNames: ["stylusDownCondition"], relative:nil, relativeNames: ["incrementCondition"], relational: "&&");
            
            rootBehavior.addTransition(NSUUID().UUIDString, name:"stylusDownT", eventEmitter: stylus, parentFlag:false, event: "STYLUS_DOWN", fromStateId: rootBehavior.getStateByName("default")!, toStateId: rootBehavior.getStateByName("default")!, condition:nil)
            
            rootBehavior.addMethod("stylusDownT", methodId:NSUUID().UUIDString, targetMethod: "setOrigin", arguments: [stylus.position])
            rootBehavior.addMethod("stylusDownT", methodId:NSUUID().UUIDString, targetMethod: "newStroke", arguments: nil)
            rootBehavior.addMethod("stylusDownT", methodId:NSUUID().UUIDString, targetMethod: "startInterval", arguments: nil)
            
            rootBehavior.addMapping(NSUUID().UUIDString, referenceProperty:stylus, referenceNames: ["dx"], relativePropertyName: "dx", targetState: "default")
            
            rootBehavior.addMapping(NSUUID().UUIDString, referenceProperty:stylus,  referenceNames: ["dy"], relativePropertyName: "dy", targetState: "default")
            
            rootBehavior.addMapping(NSUUID().UUIDString, referenceProperty:stylus,  referenceNames: ["force"], relativePropertyName: "weight", targetState: "default")
            
            
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
