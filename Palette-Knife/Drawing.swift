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
    var allStrokes = [String:[Stroke]]();
    var bakeQueue = [Stroke]();
    var bakedStrokes = [Stroke]();
    // var geometry = [Geometry]();
    var transmitEvent = Event<(String)>()
    let gCodeGenerator = GCodeGenerator();
    let svgGenerator = SVGGenerator();
    
    var geometryModified = Event<(Geometry,String,String)>()
    
    override init(){
        super.init();
        gCodeGenerator.startDrawing();
        self.name = "drawing"
    }
    
    //TODO: fix getGcode function
    func getGcode()->String{
       /* var source = gCodeGenerator.source;
        for list in self.allStrokes{
            
            for i in 0..<list.1.count{
                source+=list.1[i].gCodeGenerator.source;
                source+=gCodeGenerator.endSegment(list.1[i].segments[list.1[i].segments.count-1]);
            }
        }
        source += gCodeGenerator.end();(
        return source*/
        return ""
    }
    
    func getSVG()->String{
        var orderedStrokes = [Stroke]()
        for list in self.allStrokes{
            for i in 0..<list.1.count{
                orderedStrokes.append(list.1[i])
            }
        }
        return svgGenerator.generate(orderedStrokes)
        
    }
    
    //MARK: - Hashable
    var hashValue : Int {
        get {
            return "\(self.id)".hashValue
        }
    }
    
    func retireCurrentStrokes(parentID:String){
        if (self.activeStrokes[parentID] != nil){
            self.activeStrokes[parentID]!.removeAll();
        }
    }
    
    func newStroke(parentID:String){
        let stroke = Stroke(parentID:parentID);
        stroke.parentID = parentID;
        if (self.activeStrokes[parentID] == nil){
            self.activeStrokes[parentID] = [Stroke]()
        }
        self.activeStrokes[parentID]!.append(stroke);
        
        if (self.allStrokes[parentID] == nil){
            self.allStrokes[parentID] = [Stroke]()
            
        }
        self.allStrokes[parentID]!.append(stroke);
        self.bakeQueue.append(stroke)
        //self.geometry.append(self.currentStroke!)
        var data = "\"drawing_id\":\""+self.id+"\","
        data += "\"stroke_id\":\""+stroke.id+"\","
        data += "\"time\":\""+String(self.getTimeElapsed())+"\","
        
        data += "\"type\":\"new_stroke\""
        //self.transmitEvent.raise((data))
        
        //TODO: START HERE TOMORROW- don't know position of new stroke here, need to adjust gcode generator to match
    }
    
    func addSegmentToStroke(parentID:String, point:Point, weight:Float){
        if (self.activeStrokes[parentID] == nil){
            return
        }
        for i in 0..<self.activeStrokes[parentID]!.count{
            let currentStroke = self.activeStrokes[parentID]![i]
            let seg = currentStroke.addSegment(point,d:weight)
            
            var data = "\"drawing_id\":\""+self.id+"\","
            data += "\"stroke_id\":\""+currentStroke.id+"\","
            data += "\"type\":\"stroke_data\","
            data += "\"strokeData\":{"
            data += "\"segments\":"+seg.toJSON()+",";
            data += "\"lengths\":{\"length\":"+String(currentStroke.getLength())+",\"time\":"
            data += String(self .getTimeElapsed())
            data += "}}"
            //self.transmitEvent.raise((data))
            self.geometryModified.raise((seg,"SEGMENT","DRAW"))
        }
    }
    
    func bakeAllStrokesInQueue(){
        var source_string = "[\"TR, 8000 \", \"C6\",";
        
        for i in 0..<bakeQueue.count{
            var source = bakeQueue[i].gCodeGenerator.source;
            for i in 0..<source.count{
                if(i>0){
                    source_string += ","
                }
                source_string += "\""+source[i]+"\""
            }
            source_string+=",\""+gCodeGenerator.endSegment(bakeQueue[i].segments[bakeQueue[i].segments.count-1])+"\"]"
            bakedStrokes.append(bakeQueue[i])
        }
        bakeQueue.removeAll();
        var data = "\"drawing_id\":\""+self.id+"\","
        data += "\"type\":\"gcode\","
        data += "\"data\":"+source_string
        self.transmitEvent.raise((data));
        //print("source",data);
    }
    
}


// MARK: Equatable
func ==(lhs:Drawing, rhs:Drawing) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}


