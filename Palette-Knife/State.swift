//
//  State.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 7/20/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

struct State {
    var transition_mappings = [String:StateTransition]()
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
    
    func addMethod(key:String, transitionName:String, methodName:String, arguments:[Any]?){
        for (key,var value) in transition_mappings{
            if(value.name == transitionName){
                value.addMethod(key, methodName:methodName, arguments:arguments)
                return;
            }
        }
    
    }
    
    
    mutating func addStateTransitionMapping(key:String,transitionName:String,reference:Emitter,toState:String){
        let mapping = StateTransition(name:transitionName,reference:reference,toState:toState)
        transition_mappings[key] = mapping;
        
        
    }
    
    mutating func removeTransitionMapping(key:String)->StateTransition?{
        return transition_mappings.removeValueForKey(key)
        
    }
 
    func getConstraintMapping(key:String)->Constraint?{
             if let _ = constraint_mappings[key] {
            return  constraint_mappings[key]
        }
        else {
            //print("constraint mapping not found for state:\(key)")

            return nil
        }
    }
    
    func getTransitionMapping(key:String)->StateTransition?{
        if let _ = transition_mappings[key] {
            return  transition_mappings[key]
        }
        else {
           // print("transition mapping not found for state:\(key)")
            
            return nil
        }
    }

    
    func hasTransitionKey(key:String)->Bool{
        if(transition_mappings[key] != nil){
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

struct StateTransition{
    var reference:Emitter
    var toState: String
    var methods = [(String,[Any]?)]()
    let name:String
    init(name:String, reference:Emitter, toState:String){
        self.reference = reference
        self.toState = toState
        self.name = name
    }
    
    mutating func addMethod(key:String, methodName:String, arguments:[Any]?){
        methods.append((methodName,arguments));
    }
    
    
}


