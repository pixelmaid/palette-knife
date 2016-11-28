//
//  GCodeGenerator.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 8/22/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation


class GCodeGenerator {
    
    var source = [String]()
    var x = Float(0)
    var y = Float(0)
    var z = Float(0)
    var xOffset = Float(0);
    var yOffset = Float(0);
    static let retractHeight = Float(0.59)
    let clearanceHeight = Float(0.6)
    let feedHeight = Float(0)
    let cuttingFeedRate = Float(8)
    let plungingFeedRate = Float(10)
    let depthLimit = Float(-0.06)
    static let inX = Float(95);
    static let pX = Float(1366);
    static let inY = Float(45);
    static let pY = Float(1024);
    
    
    static var fabricatorX: Float!
    static var fabricatorY: Float!
    static var fabricatorZ: Float!
    static var fabricatorStatus = Observable<Float>(32)
    
    
    var newStroke = false;
    init(){
        //TODO: set vc here
    }
    
    func setOffset(x:Float, y:Float){
        self.xOffset = x;
        self.yOffset = y;
    }
    
    func generateVirtualTool()->String{
        return "TR, 8000\nC6\nPAUSE 2\n"
    }
    
    func end()->String{
        var s = jog3(self.x,y: self.y,z: GCodeGenerator.retractHeight);
        s += self.jogHome()+"END"
        return s
    }
    
    func jogHome()->String{
        self.x = 0;
        self.y = 0;
        self.z = clearanceHeight;
        return String("JH")
    }
    
    func jog3(x:Float,y:Float,z:Float)->String{
        self.x = x;
        self.y = y;
        self.z = z;
        return String("J3, \(x), \(y), \(z)")
    }
    
    func move3(x:Float,y:Float,z:Float)->String{
        self.x = x;
        self.y = y;
        self.z = z;
        return String("M3, \(x), \(y), \(z)")
    }
    
    func moveSpeedSet(xy:Float,z:Float)->String{
        return String("MS, \(xy), \(z)")
    }
    
    func startNewStroke(){
        self.newStroke=true;
    }
    
    func drawSegment(segment:Segment)->[String]{
        var _x = Numerical.map(segment.point.x.get(nil), istart:GCodeGenerator.pX, istop: 0, ostart: GCodeGenerator.inX, ostop: 0) + xOffset
        
        var _y = Numerical.map(segment.point.y.get(nil), istart:0, istop:GCodeGenerator.pY, ostart:  GCodeGenerator.inY, ostop: 0 ) + yOffset
        
        var _z = Numerical.map(segment.diameter, istart: 0.2, istop: 42, ostart: 0, ostop: self.depthLimit)
        /*if(_x>GCodeGenerator.inX){
            _x = GCodeGenerator.inX;
        }
        else if(_x<0){
            _x = 0;
        }*/

        /*if(_y>GCodeGenerator.inY){
            _y = GCodeGenerator.inY;
        }
        else if(_y<0){
            _y = 0;
        }*/
        if(_z>self.depthLimit){
            _z = self.depthLimit;
        }

        if(self.newStroke){
           // source.append(jog3(_x,y:_y,z: GCodeGenerator.retractHeight));
            source.append(jog3(_x,y:_y,z: 0));
            source.append(moveSpeedSet(self.cuttingFeedRate,z:self.plungingFeedRate))
            self.newStroke = false;
        }
               source.append(self.move3(_x, y: _y, z: _z));
        return source;
    }
    
    
    func endSegment(segment:Segment)->String{
        var s = ""
        
        let _x = Numerical.map(segment.point.x.get(nil), istart:GCodeGenerator.pX, istop: 0, ostart: GCodeGenerator.inX, ostop: 0) + xOffset
        
        let _y = Numerical.map(segment.point.y.get(nil), istart:0, istop:GCodeGenerator.pY, ostart:  GCodeGenerator.inY, ostop: 0 ) + yOffset
        
        s += jog3(_x,y:_y,z: GCodeGenerator.retractHeight);
        
        
        return s
        
    }

    //TODO: Change to append set of strings rather than virtual tool all as one
    func startDrawing()->[String]{
        source.append(self.generateVirtualTool());
        return source;
        
    }
    
    
    
}
