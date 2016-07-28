//
//  Expression.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 7/22/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation


class Expression: Emitter{
    var operand1:Emitter
    var operand2:Emitter
    
    required init(operand1:Emitter,operand2:Emitter){
        self.operand1 = operand1;
        self.operand2 = operand2;
        super.init()
        self.events = ["CHANGE"]
        self.createKeyStorage()
        self.createMapping(operand1);

    }
    
    func createMapping(reference:Emitter){
        let key = NSUUID().UUIDString;
        reference.assignKey("CHANGE",key: key,eventCondition: nil)
        let selector = Selector("setHandler"+":");
        NSNotificationCenter.defaultCenter().addObserver(self, selector:selector, name:key, object: reference)
 
    }
    
    
    
    dynamic func setHandler(notification: NSNotification){
        for key in keyStorage["CHANGE"]!  {
            NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0,"event":"CHANGE"])
            
        }
    }
    
    override func get()->Float{
        return 0;
    }
    
    
    
}


class AddExpression:Expression{
    
    override func get()->Float{
        print("adding:\(operand1.get() , operand2.get())")
        return operand1.get() + operand2.get();
    }
    
}

class SubExpression:Expression{
    
    override func get()->Float{
        return operand1.get() - operand2.get();
    }
    
}


