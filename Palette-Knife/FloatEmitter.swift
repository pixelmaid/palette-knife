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
        self.events =  ["INVALIDATED","CHANGE"]
        self.createKeyStorage();
        

    }
    
    override func get()->Float{
        super.get();
        return val;
    }
    
    override func set(val:Emitter){
        self.set(val.get())
    }
    
    func set(val:Float){
        if(self.val != val){
            self.val = val
            self.invalidated = true;

       // print("float key storage change,\(keyStorage["CHANGE"]!.count)")
        for key in keyStorage["INVALIDATED"]!  {
            NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0])
            
        }
        for key in keyStorage["CHANGE"]!  {
            NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0])
            
        }
        }
        
        
    }
    
    
}

func ==(lhs: FloatEmitter, rhs: FloatEmitter) -> Bool {
    return lhs.val == rhs.val
}
