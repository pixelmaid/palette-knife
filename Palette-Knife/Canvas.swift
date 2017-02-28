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
    var transmitEvent = Event<(String)>()
    var initEvent = Event<(WebTransmitter,String)>()

    var geometryModified = Event<(Any,String,String)>()

    let drawKey = NSUUID().UUIDString;
    let  dataKey = NSUUID().UUIDString;

    
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
        currentDrawing!.transmitEvent.addHandler(self,handler: Canvas.drawingDataGenerated, key:drawKey);
        currentDrawing!.geometryModified.addHandler(self,handler: Canvas.drawHandler, key:dataKey);

        var string = "{\"canvas_id\":\""+self.id+"\","
        string += "\"drawing_id\":\""+currentDrawing!.id+"\","
        string += "\"type\":\"new_drawing\"}"
        self.transmitEvent.raise((string));

    }
    
    func hitTest(point:Point, threshold:Float)->Stroke?{
       let hit = currentDrawing!.hitTest(point,threshold:threshold)
        if(hit != nil){
            print("found stroke \(hit)");
            return hit;
        }
        print("found no stroke");

        return nil;
    }
    
    func deleteStroke(stroke:Stroke)->Bool{
        for d in drawings{
            if(d.deleteStroke(stroke)){
                //let strokes = self.getAllStrokes();
                return true;
            }
        }
        return false;
    }
    
    func getAllStrokes()->[Stroke]{
        var strokes = [Stroke]();
        for d in drawings{
            strokes = strokes + d.getAllStrokes()
        }
        return strokes
    }
    
    func drawingDataGenerated(data:(String), key:String){
        var string = "{\"canvas_id\":\""+self.id+"\","
        string += data;
        string += "}"
        self.transmitEvent.raise((string));
    }
    
    
    
    
    //Event handlers
    //chains communication between brushes and view controller
    func drawHandler(data:(Any,String,String), key:String){
        self.geometryModified.raise(data)
    }
    
    
    
}


// MARK: Equatable
func ==(lhs:Canvas, rhs:Canvas) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

  
