//
//  Expression.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 7/22/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation


class Expression: Observable<Float>{
    var operand1:Observable<Float>
    var operand2:Observable<Float>
    var operand1Key = NSUUID().UUIDString;
    var operand2Key = NSUUID().UUIDString;

    required init(operand1:Observable<Float>,operand2:Observable<Float>){
        self.operand1 = operand1;
        self.operand2 = operand2;
        super.init(0)
        
        
        operand1.didChange.addHandler(self, handler: Expression.setHandler,key:operand1Key)
        operand2.didChange.addHandler(self, handler: Expression.setHandler, key:operand2Key)
        
        //initial set after intialize 
        //TODO: check if this causes errors...
        self.setHandler((name,0,0),key:"_")

    }
    
    
    
   //placeholder sethandler does nothing
    func setHandler(data:(String,Float,Float),key:String){
      
    }

    
    
}


class AddExpression:Expression{
    
    override func setHandler(data:(String,Float,Float),key:String){
        
       self.set(operand1.get() + operand2.get())
    }
    
}

class SubExpression:Expression{
    
    override func setHandler(data:(String,Float,Float),key:String){
    
        self.set(operand1.get() - operand2.get())
    }
    
}

class MultExpression:Expression{
    
    override func setHandler(data:(String,Float,Float),key:String){
        self.set(operand1.get() * operand2.get())
    }
    
 
}

class LogExpression:Expression{
    
    override func setHandler(data:(String,Float,Float),key:String){
     self.set(log(operand1.get()+1)/20 + operand2.get());
    }
    
}

class ExpExpression:Expression{
    
    override func setHandler(data:(String,Float,Float),key:String){
        self.set(pow(operand1.get(),2)/10 + operand2.get());
    }
    
}

class LogiGrowthExpression:Expression{
    
    override func setHandler(data:(String,Float,Float),key:String){
        let a = Float(3);
        let b = Float(10000);
        let k = Float(-3.8);
        let x = operand1.get()
        let val = a/(1+b*pow(2.7182818284590451,x*k))
        self.set(val + operand2.get());
    }
    
}




