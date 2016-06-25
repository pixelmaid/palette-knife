//
//  Canvas.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 6/24/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

//Canvas
//stores multiple drawings

class Canvas: Hashable{
    let id = NSUUID().UUIDString;
    var name = ""
    var drawings = [Drawing]()
    var currentDrawing:Drawing?
    //MARK: - Hashable
    var hashValue : Int {
        get {
            return "\(self.id)".hashValue
        }
    }
    
    required init(){
        self.initDrawing()
    }
    
    func initDrawing(){
        currentDrawing = Drawing();
        drawings.append(currentDrawing!)
    }
    
}


// MARK: Equatable
func ==(lhs:Canvas, rhs:Canvas) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

  
