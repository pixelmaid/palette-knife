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
    
    func addSegmentToStroke(point:Point, weight:Float){
        if(self.currentStroke == nil){
            self.initStroke();
        }
        
        var seg = self.currentStroke!.addSegment(point)
        seg.diameter = weight;
        var data = "\"drawing_id\":\""+self.id+"\","
        data += "\"stroke_id\":\""+self.currentStroke!.id+"\","
        data += "\"type\":\"stroke_data\","
        data += "\"strokeData\":{"
        data += "\"segments\":"+seg.toJSON()+",";
        data += "\"lengths\":{\"length\":"+String(currentStroke!.getLength())+",\"time\":"
        data += String(self .getTimeElapsed())
        data += "}}"
        self.event.raise((data))
        self.geometryModified.raise((seg,"SEGMENT","DRAW"))
    }
    
}


// MARK: Equatable
func ==(lhs:Drawing, rhs:Drawing) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

  
