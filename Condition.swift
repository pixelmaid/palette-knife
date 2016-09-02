//
//  Behavior.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 7/22/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

class Condition {
    var referenceA:Observable<Float>
    var referenceB:Observable<Float>
    var relational:String
    
    
    init(a:Observable<Float>,b:Observable<Float>, relational:String){
        self.referenceA = a
        self.referenceB = b
        self.relational  = relational;
    }
    
    func evaluate()->Bool{
        switch (relational){
        case "<":
            return referenceA.get() < referenceB.get();
            
        case ">":
            return referenceA.get() > referenceB.get();
            
        case "==":
            let a = referenceA.get()
            let b = referenceB.get()
            print("checking equality \(a,b)")
            return a == b;
        case "!=":
            let a = referenceA.get()
            let b = referenceB.get()
            print("checking inequality \(a,b)")
            return a != b;
        case "within":
            let interval = self.referenceB as! Interval
            let value = interval.get();
            if(value > 0){
                if(referenceA.get()>value){
                    interval.incrementIndex();
                    return true;
                }
            }
            return false;
            
        default:
            return false;
        }
        
    }
}
