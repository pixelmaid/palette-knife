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

    var methods = [(String,[Any]?,Condition?)]()
    init(){
    
    }
    
    mutating func addConstraintMapping(key:String, reference:Emitter, relativeProperty:Emitter){
        let mapping = Constraint(reference: reference, relativeProperty:relativeProperty)
        constraint_mappings[key] = mapping;
        

    }
    
    mutating func removeConstraintMapping(key:String)->Constraint?{
        constraint_mappings[key]!.relativeProperty.constrained = false;
       return constraint_mappings.removeValueForKey(key)
        
        
    }
    
    
    mutating func addStateTransitionMapping(key:String,reference:Emitter,toState:String){
        let mapping = StateTransition(reference:reference,toState:toState)
        transition_mappings[key] = mapping;
        
        
    }
    
    mutating func addMethod(key:String, methodName:String, arguments:[Any]?, condition:Condition?){
        methods.append((methodName,arguments,condition));
    }
    
    
    
    mutating func removeTransitionMapping(key:String)->Mapping?{
        return transition_mappings.removeValueForKey(key)
        
    }
 
    func getConstraintMapping(key:String)->Mapping?{
             if let _ = constraint_mappings[key] {
            return  constraint_mappings[key]
        }
        else {
            //print("constraint mapping not found for state:\(key)")

            return nil
        }
    }
    
    func getTransitionMapping(key:String)->Mapping?{
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

struct Constraint: Mapping{
    var reference:Emitter
    var relativeProperty:Emitter
    init(reference:Emitter, relativeProperty:Emitter){
        self.reference = reference
        self.relativeProperty = relativeProperty
    }

}

struct StateTransition: Mapping{
    var reference:Emitter
    var toState: String
    init(reference:Emitter, toState:String){
        self.reference = reference
        self.toState = toState
    }
    
}

protocol Mapping{
    var reference:Emitter { get set }

}
