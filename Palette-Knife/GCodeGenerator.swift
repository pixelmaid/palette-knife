//
//  GCodeGenerator.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 8/22/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation


class GCodeGenerator {
    
    var source = ""
    var x = Float(0)
    var y = Float(0)
    var z = Float(0)
    let retractHeight = Float(0.59)
    let clearanceHeight = Float(0.6)
    let feedHeight = Float(0)
    let cuttingFeedRate = Float(0.500)
    let leadInOutFeedRate = Float(0.6562)
    let depthLimit = Float(-0.31)
    let inX = Float(10.35);
    let pX = Float(1366);
    let inY = Float(7.76);
    let pY = Float(1024);
    var newStroke = false;
    init(){
        //TODO: set vc here
    }
    
    func generateVirtualTool()->String{
        return "TR, 8000\nC6\nPAUSE 2\n"
    }
    
    func end()->String{
        var s = jog3(self.x,y: self.y,z: self.retractHeight);
        s += self.jogHome()+"END\n"
        return s
    }
    
    func jogHome()->String{
        self.x = 0;
        self.y = 0;
        self.z = clearanceHeight;
        return String("JH \n")
    }
    
    func jog3(x:Float,y:Float,z:Float)->String{
        self.x = x;
        self.y = y;
        self.z = z;
        return String("J3, \(x), \(y), \(z)\n")
    }
    
    func move3(x:Float,y:Float,z:Float)->String{
        self.x = x;
        self.y = y;
        self.z = z;
        return String("M3, \(x), \(y), \(z)\n")
    }
    
    func moveSpeedSet(xy:Float,z:Float)->String{
        return String("MS, \(xy), \(z)\n")
    }
    
    func startNewStroke(){
        self.newStroke=true;
    }
    
    func drawSegment(segment:Segment)->String{
        let _x = Numerical.map(segment.point.x.get(), istart:0, istop: self.pX, ostart: self.inX, ostop: 0)
        
        let _y = Numerical.map(segment.point.y.get(), istart:0, istop:self.pY, ostart:  self.inY, ostop: 0 )
        
        let _z = Numerical.map(segment.diameter, istart: 0.2, istop: 42, ostart: 0, ostop: self.depthLimit)

        if(self.newStroke){
            //source += "PAUSE 2\n"
            source += jog3(_x,y:_y,z: self.retractHeight);
            source += jog3(_x,y:_y,z: 0);
            source += moveSpeedSet(self.cuttingFeedRate,z:self.cuttingFeedRate)
            self.newStroke = false;
        }
               source += self.move3(_x, y: _y, z: _z);
        print("gcode \(_z,source)")
        return source;
    }
    
    
    func endSegment(segment:Segment)->String{
        var s = ""
        
        let _x = Numerical.map(segment.point.x.get(), istart:0, istop: self.pX, ostart: self.inX, ostop: 0)
        
        let _y = Numerical.map(segment.point.y.get(), istart:0, istop:self.pY, ostart:  self.inY, ostop: 0 )
        
        s += jog3(_x,y:_y,z: self.retractHeight);
        
        
        return s
        
    }

    
    func startDrawing()->String{
        source += self.generateVirtualTool();
        return source;
        
    }
    
    
    
}
