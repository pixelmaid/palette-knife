//
//  State.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 7/20/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

class State {
    var transitions = [String:StateTransition]()
    var constraint_mappings = [String:Constraint]()
    let name: String
    let id: String
    
    init(id:String,name:String){
        self.id = id;
        self.name = name;
    }
    
     func addConstraintMapping(key:String, reference:Observable<Float>, relativeProperty:Observable<Float>){
        let mapping = Constraint(id:key,reference: reference, relativeProperty:relativeProperty)
        constraint_mappings[key] = mapping;
    }
    
     func removeConstraintMapping(key:String)->Constraint?{
        constraint_mappings[key]!.relativeProperty.constrained = false;
       return constraint_mappings.removeValueForKey(key)
    }
    
    
     func addStateTransitionMapping(id:String, name:String, reference:Emitter,toState:String)->StateTransition{
        let mapping = StateTransition(id:id, name:name, reference:reference,toState:toState)
        transitions[id] = mapping;
        return mapping;
    }
    
     func removeTransitionMapping(key:String)->StateTransition?{
        return transitions.removeValueForKey(key)
        
    }
 
    func getConstraintMapping(key:String)->Constraint?{
             if let _ = constraint_mappings[key] {
            return  constraint_mappings[key]
        }
        else {

            return nil
        }
    }
    
    func getTransitionMapping(key:String)->StateTransition?{
        if let _ = transitions[key] {
            return  transitions[key]
        }
        else {
            
            return nil
        }
    }

    
    func hasTransitionKey(key:String)->Bool{
        if(transitions[key] != nil){
            return true
        }
        return false
    }
    
    func hasConstraintKey(key:String)->Bool{
        if(constraint_mappings[key] != nil){
            return true
        }
        return false
    }
    
    func toJSON()->String{
        var data = "{\"id\":\""+(self.id)+"\","
        data += "\"name\":\""+self.name+"\","
        data += "\"mappings\":[";
        var count = 0;
        for (_, mapping) in constraint_mappings{
            if(count>0){
                data += ","
            }
            data += mapping.toJSON();
            count += 1;
        }
        data += "]"
        data += "}"
        return data;
    }



    
  
}

struct Constraint{
    var reference:Observable<Float>
    var relativeProperty:Observable<Float>
    var id:String
    init(id:String, reference:Observable<Float>, relativeProperty:Observable<Float>){
        self.reference = reference
        self.relativeProperty = relativeProperty
        self.id = id;
    }
    
    func toJSON()->String{
        var data = "{\"id\":\""+(self.id)+"\"}"
        return data;
    }
}

class Method{
    var name: String;
    var id: String;
    var arguments: [Any]?
    
    init(id:String,name:String,arguments:[Any]?){
        self.name = name;
        self.id = id;
        self.arguments = arguments;
    }
    
    func toJSON()->String{
        var data = "{\"id\":\""+(self.id)+"\","
        data += "\"name\":\""+(self.name)+"\"}"
        return data;
    }
    
}

class StateTransition{
    var reference:Emitter
    var toState: String
    var methods = [Method]()
    let name: String
    let id: String
    
    init(id:String, name:String, reference:Emitter, toState:String){
        self.reference = reference
        self.toState = toState
        self.name = name
        self.id = id;
    }
    
    func addMethod(id:String, name:String, arguments:[Any]?){
        methods.append(Method(id:id, name:name,arguments:arguments));
    }
    
    func toJSON()->String{
        var data = "{\"id\":\""+(self.id)+"\","
        data += "\"name\":\""+self.name+"\","
        data += "\"methods\":[";
        for i in 0..<methods.count{
            if(i>0){
                data += ","
            }
            data += methods[i].toJSON();
        }
        data += "]"
        data += "}"
        return data;
    }

}


