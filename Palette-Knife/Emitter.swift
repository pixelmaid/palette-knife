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
    var keyStorage=[String:[(String,EventCondition!)]]()
    
    func createKeyStorage(){
        for e in events{
            keyStorage[e] = [(String,EventCondition!)]();
        }
    }
    
    func assignKey(eventType:String,key:String,eventCondition:EventCondition!){
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
    
    func get(targetProp:String)->Any?{
        switch targetProp{
            
        default:
            return nil
            
        }
        
    }
}

