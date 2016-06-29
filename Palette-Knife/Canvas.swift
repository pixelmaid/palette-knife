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

class Canvas: WebTransmitter, Hashable{
    var id = NSUUID().UUIDString;
    var name:String;
    var drawings = [Drawing]()
    var currentDrawing:Drawing?
    var event = Event<(String)>()
    var geometryModified = Event<(Geometry,String,String)>()

    //MARK: - Hashable
    var hashValue : Int {
        get {
            return "\(self.id)".hashValue
        }
    }
    
    
    required init(){
        name = "default_"+id;
    }
    
    func initDrawing(){
        currentDrawing = Drawing();
        drawings.append(currentDrawing!)
        currentDrawing!.event.addHandler(self,handler: Canvas.drawingDataGenerated);
        currentDrawing!.geometryModified.addHandler(self,handler: Canvas.drawHandler);

        var string = "{\"canvas_id\":\""+self.id+"\","
        string += "\"drawing_id\":\""+currentDrawing!.id+"\","
        string += "\"type\":\"new_drawing\"}"
        self.event.raise((string));

    }
    
    func drawingDataGenerated(data:(String)){
        var string = "{\"canvas_id\":\""+self.id+"\","
        string += data;
        string += "}"
        self.event.raise((string));
    }
    
    
    //Event handlers
    //chains communication between brushes and view controller
    func drawHandler(data:(Geometry,String,String)){
        self.geometryModified.raise(data)
    }
    
    
    
}


// MARK: Equatable
func ==(lhs:Canvas, rhs:Canvas) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

  
