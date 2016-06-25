//
//  Drawing.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 6/24/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

//Drawing
//stores geometry

class Drawing: Hashable{
    let id = NSUUID().UUIDString;
    var name:String = ""
    let geometry = [Geometry]()
    //MARK: - Hashable
    var hashValue : Int {
        get {
            return "\(self.id)".hashValue
        }
    }
    
    
    func initDrawing(){
        
    }
    
}


// MARK: Equatable
func ==(lhs:Drawing, rhs:Drawing) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

  
