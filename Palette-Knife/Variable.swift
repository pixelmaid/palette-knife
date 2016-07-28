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
        var old_index = index;
       let v = val[index]
        self.incrementIndex();
        print("incrementing index to \(old_index,self.index, self.val.count, self.val)")
        return v;
    }
    
    
    
}
