//
//  Expression.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 7/22/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation


protocol Expresssion{
    var operand1:FloatEmitter {get set}
    var operand2:FloatEmitter {get set}
    init(operand1:FloatEmitter,operand2:FloatEmitter)
    func compute()->Float

}

class AddExpression: Emitter, Expresssion{
    var operand1:FloatEmitter
    var operand2:FloatEmitter
    
    required init(operand1:FloatEmitter,operand2:FloatEmitter){
        self.operand1 = operand1;
        self.operand2 = operand2
        super.init()
        self.events = ["CHANGE"]
        self.createKeyStorage()
    }
    
    func compute()->Float{
        return operand1.get() + operand2.get();
    }
    
    
}
