//
//  Emitter.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 5/25/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation
import SwiftKVC

class Emitter: Model  {
    
    var events =  [String]()
    var keyStorage=[String:[(String,Condition!)]]()
    var invalidated = false;
    var constrained = false;
    
    func set(value:Emitter){
    }
    
      func createKeyStorage(){
        for e in events{
            self.keyStorage[e] = [(String,Condition!)]();
        }

    }
    
    dynamic func propertyInvalidated(notification: NSNotification){
        self.invalidated = true;
        let reference = notification.userInfo?["emitter"] as! Emitter
        //print("property invalidated \(reference.get(),reference)")
        for key in keyStorage["INVALIDATED"]!  {
            NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0])
            
        }
        
    }
    
    func assignKey(eventType:String,key:String,eventCondition:Condition!){
        if(eventCondition != nil){
            keyStorage[eventType]?.append((key,eventCondition))
        }
        else{
            keyStorage[eventType]?.append((key,nil))
 
        }
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

