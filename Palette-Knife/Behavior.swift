//
//  Behavior.swift
//  Palette-Knife
//
//  Created by JENNIFER MARY JACOBS on 5/5/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

// Behavior: stores actions: events and callbacks that determine the drawing behavior of the target brush

class Behavior: Observable{
    var event_action_list = [String:Disposable]()
    
    
    // links a generic target to a generic handler and returns unique id
    func addEventActionPair<U: Observable, T >(target: U, event:Event<T>, action: (U) -> (T)->())->String{
        let wrapper = event.addHandler(target, handler: action)
        let id = NSUUID().UUIDString;
        event_action_list[id]=wrapper;
        return id;
        
    }
    
    
    func disposeOfEventActionPair(uid:String){
        self.event_action_list.removeValueForKey(uid)!
    }
    
    
    
}