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
    
   
    
    // links a generic target to a generic handler.
    func addEventActionPair<U: Observable, T: Observable>(target: U, event:Event<(EventType,T)>, action: (U) -> (EventType,Observable)->()){
        event.addHandler(target, handler: action)
    }
    
 
    
}