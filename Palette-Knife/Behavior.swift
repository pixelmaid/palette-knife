//
//  Behavior.swift
//  Palette-Knife
//
//  Created by JENNIFER MARY JACOBS on 5/5/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

// Behavior: stores actions: events and callbacks that determine the drawing behavior of the target brush

class Behavior{
    var targets = [Brush]()
    
    init(){
        
    }
    
    func addTarget(target:Brush){
        self.targets.append(target);
    }
    
    func removeTarget(target:Brush){
        let index = self.targets.indexOf(target);
        if(index > -1){
            self.targets.removeAtIndex(index!);
        }
    }
    
    func addTargets(targets:[Brush]) {
       for item in targets {
            self.addTarget(item);
  
        }
    }
    
    func add


    
    
    
    
}