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
    
    init(inc:Float,times:Int){
        for i in 1..<times{
            val.append(Float(i)*inc)
        }
    }
    
    func incrementIndex(){
                   index += 1;
        
    }
    
    override func get() -> Float {
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
        print("accessing buffer, \(val.count,index)")
        let v = val[index]
        self.incrementIndex();
        return v;
    }
    
}

class Range:Generator{
    var val = [Float]();
    var index = 0;
    init(min:Int,max:Int,start:Float,stop:Float){
        let increment = (stop-start)/Float(max-min)
        for i in min...max-1{
            print(i)
            val.append(start+increment*Float(i))
        }
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
