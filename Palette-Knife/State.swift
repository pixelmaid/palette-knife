//
//  State.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 7/20/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

struct State {
    var transitions = [String:StateTransition]()
    var constraint_mappings = [String:Constraint]()
    
    init(){
    
    }
    
    mutating func addConstraintMapping(key:String, reference:Observable<Float>, relativeProperty:Observable<Float>){
        let mapping = Constraint(reference: reference, relativeProperty:relativeProperty)
        constraint_mappings[key] = mapping;
    }
    
    mutating func removeConstraintMapping(key:String)->Constraint?{
        constraint_mappings[key]!.relativeProperty.constrained = false;
       return constraint_mappings.removeValueForKey(key)
    }
    
    
    mutating func addStateTransitionMapping(id:String, name:String, reference:Emitter,toState:String)->StateTransition{
        let mapping = StateTransition(id:id, name:name, reference:reference,toState:toState)
        transitions[id] = mapping;
        return mapping;
    }
    
    mutating func removeTransitionMapping(key:String)->StateTransition?{
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

    
  
}

struct Constraint{
    var reference:Observable<Float>
    var relativeProperty:Observable<Float>
    init(reference:Observable<Float>, relativeProperty:Observable<Float>){
        self.reference = reference
        self.relativeProperty = relativeProperty
    }

}

class StateTransition{
    var reference:Emitter
    var toState: String
    var methods = [(String,[Any]?)]()
    let name: String
    let id: String
    
    init(id:String, name:String, reference:Emitter, toState:String){
        self.reference = reference
        self.toState = toState
        self.name = name
        self.id = id;
    }
    
    func addMethod(methodName:String, arguments:[Any]?){
        methods.append((methodName,arguments));
    }

}


