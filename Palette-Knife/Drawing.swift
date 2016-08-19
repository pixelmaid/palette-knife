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

class Drawing: TimeSeries, WebTransmitter, Hashable{
   var id = NSUUID().UUIDString;
    var activeStrokes = [String:[Stroke]]();
   // var geometry = [Geometry]();
    var transmitEvent = Event<(String)>()

       var geometryModified = Event<(Geometry,String,String)>()
    
    //MARK: - Hashable
    var hashValue : Int {
        get {
            return "\(self.id)".hashValue
        }
    }
    
    override init(){
        super.init()
        self.name = "drawing"

    }
    
    func retireCurrentStrokes(parentID:String){
        if (self.activeStrokes[parentID] != nil){
            self.activeStrokes[parentID]!.removeAll();
        }
    }
    
    func newStroke(parentID:String){
        let stroke = Stroke();
        if (self.activeStrokes[parentID] == nil){
            self.activeStrokes[parentID] = [Stroke]()
        }
        self.activeStrokes[parentID]!.append(stroke);
        //self.geometry.append(self.currentStroke!)
        var data = "\"drawing_id\":\""+self.id+"\","
        data += "\"stroke_id\":\""+stroke.id+"\","
        data += "\"time\":\""+String(self.getTimeElapsed())+"\","

        data += "\"type\":\"new_stroke\""
        self.transmitEvent.raise((data))
    }
    
    func addSegmentToStroke(parentID:String, point:Point, weight:Float){
         if (self.activeStrokes[parentID] == nil){
            //print("tried to add segment to strokes, but no strokes exist")
           return
        }
        for i in 0..<self.activeStrokes[parentID]!.count{
        let currentStroke = self.activeStrokes[parentID]![i]
        var seg = currentStroke.addSegment(point)
            if(seg.getPreviousSegment() != nil){
        print("added segment to stroke \(seg.point.x.get(),seg.point.y.get(),seg.getPreviousSegment()!.point.x.get(),seg.getPreviousSegment()!.point.y.get())")
        }
        seg.diameter = weight;
        var data = "\"drawing_id\":\""+self.id+"\","
        data += "\"stroke_id\":\""+currentStroke.id+"\","
        data += "\"type\":\"stroke_data\","
        data += "\"strokeData\":{"
        data += "\"segments\":"+seg.toJSON()+",";
        data += "\"lengths\":{\"length\":"+String(currentStroke.getLength())+",\"time\":"
        data += String(self .getTimeElapsed())
        data += "}}"
        self.transmitEvent.raise((data))
        self.geometryModified.raise((seg,"SEGMENT","DRAW"))
        }
    }
    
}


// MARK: Equatable
func ==(lhs:Drawing, rhs:Drawing) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

  
