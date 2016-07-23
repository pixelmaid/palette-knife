//
//  FloatEmitter.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 7/22/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

class FloatEmitter: Emitter, Equatable{
    var val:Float;
    
    init(val:Float){
        self.val = val;
        super.init();
        self.events =  ["CHANGE"]
        self.createKeyStorage();
    }
    
    func get()->Float{
        return val;
    }
    
    func set(val:Float){
        self.val = val
        for key in keyStorage["CHANGE"]!  {
            /* if(key.1 != nil){
             let eventCondition = key.1;
             if(eventCondition.validate(self)){
             NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0])
             
             }
             else{
             print("EVALUATION FOR CONDITION FAILED")
             }
             
             }
             else{*/
            NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0])
            //}
        }

    }
    
    
}

func ==(lhs: FloatEmitter, rhs: FloatEmitter) -> Bool {
    return lhs.val == rhs.val
}
