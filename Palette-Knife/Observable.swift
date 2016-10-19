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
    var invalidated = false;
    var constrained = false;
    var subscribers = [String:Int]();
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
    
    //sets without raising change event
    func setSilent(newValue:T){
        value = newValue
    }
    
    func get(id:String?) -> T {
        invalidated = false;
        return value
    }
    
    func subscribe(id:String){
        subscribers[id] = 0
    }
    
    func unsubscribe(id:String){
        subscribers.removeValueForKey(id)
    }

}
