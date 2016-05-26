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
    var keyStorage=[String:[String]]()
    
    func createKeyStorage(){
        for e in events{
            keyStorage[e] = [String]();
        }
    }
    
    func assignKey(eventType:String,key:String){
       keyStorage[eventType]?.append(key)
    }
    
    func removeKey(key:String){
        for(eventType,keyList) in keyStorage{
            keyStorage[eventType] = keyList.filter() {$0 != key}
            
        }
    }
}

