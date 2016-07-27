//
//  State.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 7/20/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

struct State {
    var mappings = [String:Mapping]()
    var methods = [(String,[Any]?)]()
    init(){
    
    }
    
    mutating func addConstraintMapping(key:String,reference:Emitter,relativeProperty:Emitter){
        let mapping = Constraint(reference: reference,relativeProperty:relativeProperty)
        relativeProperty.constrained = true;
       print("constrained relative\(relativeProperty,relativeProperty.constrained)")
        mappings[key] = mapping;
        

    }
    
    mutating func removeConstraintMapping(key:String,relativeProperty:Emitter){
        relativeProperty.constrained = false;
        mappings.removeValueForKey(key)
        
        
    }
    
    
    mutating func addStateTransitionMapping(key:String,reference:Emitter,toState:String){
        let mapping = StateTransition(reference:reference,toState:toState)
        mappings[key] = mapping;
        
        
    }
    
    mutating func addMethod(key:String, methodName:String, arguments:[Any]?){
        methods.append((methodName,arguments));
    }
    
    
    
    mutating func removeMapping(key:String)->Mapping?{
        return mappings.removeValueForKey(key)
        
    }
    
    func getMapping(key:String)->Mapping?{
             if let _ = mappings[key] {
            return  mappings[key]
        }
        else {
            print("mapping not found for state:\(key)")

            return nil
        }
    }
    
    func hasKey(key:String)->Bool{
        if(mappings[key] != nil){
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
