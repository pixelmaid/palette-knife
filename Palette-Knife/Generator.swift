//
//  Variable.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 7/28/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation


class Generator:Observable<Float>{
    
    init(){
        super.init(0)
    }
    
}

class Interval:Generator{
    var val = [Float]();
    var index = 0;
    var infinite = false;
    let inc:Float
    init(inc:Float,times:Int?){
        self.inc = inc;
        super.init();
        if(times != nil){
            for i in 1..<times!{
                val.append(Float(i)*self.inc)
            }
        }
        else{
            infinite = true;
            self.incrementIndex();
            
        }
    }
    
    func incrementIndex(){
        index += 1;
        
    }
    
    override func get() -> Float {
        if(infinite){
            return Float(self.index)*self.inc
        }
        if(index < val.count){
            let v = val[index]
            
            return v;
        }
        return -1;
    }
    
    
}

class Buffer:Generator{
    var val = [Float]();
    var index = 0;
    
    func push(v: Float){
        val.append(v)
    }
    
    func incrementIndex(){
        if(index<val.count-1){
            index += 1;
        }
    }
    
    override func get() -> Float {
        let v = val[index]
        self.incrementIndex();
        return v;
    }
    
}

class CircularBuffer:Generator{
    var val = [Float]();
    var index = 0;
    var bufferEvent = Event<(String)>()
    func push(v: Float){
        val.append(v)
        
    }
    
    func incrementIndex(){
        if(index<val.count-1){
            index += 1;
        }
        else{
            index = 0;
           // bufferEvent.raise("BUFFER_LIMIT_REACHED");
        }
    }
    
    override func get() -> Float {
        let v = val[index]
        self.incrementIndex();
        return v;
    }
    
}

class Range:Generator{
    var val = [Float]();
    var index = Observable<Float>(0);
    init(min:Int,max:Int,start:Float,stop:Float){
        let increment = (stop-start)/Float(max-min)
        for i in min...max-1{
            val.append(start+increment*Float(i))
        }
    }
    
    func incrementIndex(){
        index.set(Float(index.get() + 1));
        if(index.get()>=Float(val.count)){
            index.set(0);
        }
    }
    override func get() -> Float {
        let v = val[Int(index.get())]
        self.incrementIndex();
        return v;
    }
    
    
    
}

//returns an incremental value updating to infinity;
class Increment:Generator{
    var inc:Observable<Float>
    var start:Observable<Float>
    var index = Observable<Int>(0)
    
    init(inc:Observable<Float>, start:Observable<Float>){
        self.inc = Observable<Float>(inc.get());
        self.start = start;
    }
    
    func incrementIndex(){
        index.set(index.get()+1);
        
    }
    override func get() -> Float {
        let v = ((Float(index.get())*inc.get()) + start.get());
        self.incrementIndex();
        return v;
    }
    
    
    
    
}

class easeInOut:Generator{
    var start:Observable<Float>
    var stop:Observable<Float>
    var max:Observable<Float>
    var range:Observable<Float>
    var index = Observable<Float>(0)
    
    
    init(start:Observable<Float>,stop:Observable<Float>,max:Observable<Float>){
        self.start = Observable<Float>(start.get());
        self.stop = Observable<Float>(stop.get());
        self.max = Observable<Float>(max.get());
        self.range = Observable<Float>(stop.get()-start.get());
    }
    
    func incrementIndex(){
        index.set(index.get()+1);
        
    }
    /*override func get() -> Float {
     let v = ((Float(index.get())*inc.get()) + start.get());
     self.incrementIndex();
     return v;
     }*/
    
}


class Alternate:Generator{
    var val = [Float]();
    var index = 0;
    
    init(values:[Float]){
        val = values;
    }
    
    func incrementIndex(){
        index += 1;
        if(index>=val.count){
            index=0;
        }
    }
    override func get() -> Float {
        let v = val[index]
        self.incrementIndex();
        return v;
    }
    
    
    
}
