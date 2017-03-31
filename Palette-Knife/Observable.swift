//
//  Observable.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 8/18/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation
import SwiftKVC

class Observable<T>:Model  {
    
    var name = "observable"
    var isPassive = false;
    var invalidated = false;
    var constrained = false;
    var subscribers = [String:Int]();
    var constraintTarget: Observable<T>?
    let didChange = Event<(String,T, T)>()
    private var value: T
    
    init(_ initialValue: T) {
        value = initialValue
    }
    
    func set(newValue: T) {
        let oldValue = value
        value = newValue
        invalidated = true;
        didChange.raise((name, oldValue, newValue))

    }
    
    //used for passiveConstraints
    
    func passiveConstrain(target:Observable<T>){
        self.constraintTarget = target;
        target.isPassive = true;
    }
    
    //sets without raising change event
    func setSilent(newValue:T){
        value = newValue
    }
    
    func get(id:String?) -> T {
        invalidated = false;
        if(constraintTarget != nil){
            return constraintTarget!.get(id);
        }
        return value
    }
    
    func getSilent() -> T {
        return value
    }
    
    func subscribe(id:String){
        subscribers[id] = 0
    }
    
    func unsubscribe(id:String){
        print("unsubscribe called\(id,subscribers)");
        subscribers.removeValueForKey(id)
    }

}
