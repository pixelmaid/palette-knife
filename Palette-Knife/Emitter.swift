//
//  Emitter.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 5/25/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation
import SwiftKVC

class Emitter: Model, Equatable  {
    
    var events =  [String]()
    var keyStorage=[String:[(String,Condition!)]]()
    var invalidated = false;
    var constrained = false;
    var name = "default"
    func set(value:Emitter){
    }
    func createKeyStorage(){
        for e in events{
            self.keyStorage[e] = [(String,Condition!)]();
        }
        
    }
    
    dynamic func propertyInvalidated(notification: NSNotification){
        self.invalidated = true;
        
        //print("property invalidated \(reference.get(),reference)")
        for key in keyStorage["INVALIDATED"]!  {
            NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0, "event":"INVALIDATED"])
            
        }
        
    }
    
    func assignKey(eventType:String,key:String,condition:Condition!){
        keyStorage[eventType]?.append((key,condition))
    }
    
    func removeKey(key:String){
        for(eventType,keyList) in keyStorage{
            keyStorage[eventType] = keyList.filter() {$0.0 != key}
            
        }
    }
    
    func get()->Float{
        invalidated = false;
        return 0;
    }
    
    func destroy(){
        NSNotificationCenter.defaultCenter().removeObserver(self);
        
    }
}

// MARK: Equatable
func ==(lhs:Emitter, rhs:Emitter) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

