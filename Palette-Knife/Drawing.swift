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

class Drawing: TimeSeries, Hashable{
    let id = NSUUID().UUIDString;
    var name:String = ""
    var currentStroke:Stroke?;
    var geometry = [Geometry]();
       var geometryModified = Event<(Geometry,String,String)>()
    //MARK: - Hashable
    var hashValue : Int {
        get {
            return "\(self.id)".hashValue
        }
    }
    
    func initStroke(){
        self.currentStroke = Stroke();
        self.geometry.append(self.currentStroke!)
        var data = "\"drawing_id\":\""+self.id+"\","
        data += "\"stroke_id\":\""+self.currentStroke!.id+"\","
        data += "\"time\":\""+String(self.getTimeElapsed())+"\","

        data += "\"type\":\"new_stroke\""
        self.event.raise((data))
    }
    
    func addSegmentToStroke(point:Point){
        if(self.currentStroke == nil){
            self.initStroke();
        }
        
        let seg = self.currentStroke!.addSegment(point)
        var data = "\"drawing_id\":\""+self.id+"\","
        data += "\"stroke_id\":\""+self.currentStroke!.id+"\","
        data += "\"type\":\"stroke_data\","
        data += "\"strokeData\":{"
        data += "\"segments\":"+seg.toJSON()+",";
        data += "\"length\":{\"data\":"+String(currentStroke!.getLength())+",\"time\":"
        data += String(currentStroke!.getTimeElapsed())
        data += "}}"
        print("current length = \(currentStroke!.getLength())")
        self.event.raise((data))
        self.geometryModified.raise((seg,"SEGMENT","DRAW"))
    }
    
}


// MARK: Equatable
func ==(lhs:Drawing, rhs:Drawing) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

  
