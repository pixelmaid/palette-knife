//
//  Variable.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 7/28/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation


class Variable:Emitter{
    
    
}

class Interval:Variable{
    var val = [Float]();
    var index = 0;
    init(inc:Float,times:Int){
        for i in 0..<times{
            val.append(Float(i)*inc)
        }
        super.init();
    }
    
    
    
    override func get() -> Float {
        let v = val[index]
       
        return v;
    }

 
}

class RangeVariable:Variable{
    var val = [Float]();
    var index = 0;
    init(min:Int,max:Int,start:Float,stop:Float){
        let increment = (stop-start)/Float(max-min)
        for i in min...max-1{
            print(i)
            val.append(start+increment*Float(i))
        }
        super.init();
    }
    
    func incrementIndex(){
        index += 1;
        if(index>=val.count){
            index=0;
        }
    }
    override func get() -> Float {
        let old_index = index;
       let v = val[index]
        self.incrementIndex();
        return v;
    }
    
    
    
}


class AlternateVariable:Variable{
    var val = [Float]();
    var index = 0;
    init(values:[Float]){
        val = values;
        super.init();
    }
    
    func incrementIndex(){
        index += 1;
        if(index>=val.count){
            index=0;
        }
    }
    override func get() -> Float {
        let old_index = index;
        let v = val[index]
        self.incrementIndex();
        return v;
    }
    
    
    
}
