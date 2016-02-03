//
//  Node.swift
//  DrawPad
//
//  Created by JENNIFER MARY JACOBS on 2/1/16.
//

import Foundation


protocol PropertyObservable {
    typealias PropertyType
    typealias TargetType
    typealias DataType
    var propertyChanged: Event<(PropertyType,TargetType,DataType,DataType)> { get }
}

protocol NodeObservable {
    typealias PropertyType
    typealias TargetType
    var propertyChanged: Event<(PropertyType,TargetType)> { get }
}
enum NodeProperty {
    case Selected, Name, Linked, Value
}


class MultiplierTerminal: NodeTerminal{
    var modifier = Float(1);
    
    override func setValue(value:Float){
        self.value = value;
        valueChanged.raise((.Value,self,value, oldValue as Any))
        
        for output in self.outputs {
            output.setValue(self.value*modifier)
        }
    }}

class AdderTerminal: NodeTerminal{
    var modifier = Float(1);
    
   override func setValue(value:Float){
        self.value = value;
        valueChanged.raise((.Value,self,value, oldValue as Any))
        
        for output in self.outputs {
            output.setValue(self.value+modifier)
        }
    }
}

class NodeTerminal: PropertyObservable {
    typealias PropertyType = NodeProperty
    let propertyChanged = Event<(NodeProperty,NodeTerminal,Any,Any)>()
    let valueChanged = Event<(NodeProperty,NodeTerminal,Any,Any)>()
    var oldValue = Float(0)
    var outputs = [NodeTerminal]();

    dynamic var selected: Bool = false {
        didSet {
        propertyChanged.raise((.Selected,self,selected, oldValue as Any))
        }
    }
    
    dynamic var name: String = "" {
        didSet {
        propertyChanged.raise((.Name, self, name, oldValue as Any))
        }
    }
    
    
    dynamic var value: Float = 0.0{
        didSet {
        self.oldValue = oldValue

        }
    }
    
    func setValue(value:Float){
        self.value = value;
        valueChanged.raise((.Value,self,value, oldValue as Any))
        
        for output in self.outputs {
            output.setValue(self.value)
        }
    }
    
    func addOutput(output:NodeTerminal){
        self.outputs.append(output);
    }
    
}

class Node: NodeObservable{
    typealias PropertyType = NodeProperty
    let propertyChanged = Event<((NodeProperty,Node))>()
    let valueChanged = Event<((NodeProperty,Node))>()
    var terminals = [String:NodeTerminal]();
    var locked = [String:Bool]();
    var name = "";
    init(name:String){
        self.name = name;
    }
    
    func addTerminal(name: String, type:String = "standard"){
        var terminal:NodeTerminal
        
        if(type == "multiplier"){
            print("creating multiplier terminal,\(name)")

            terminal = MultiplierTerminal()
        }
        else if(type == "addition"){
            print("creating addition terminal,\(name)")
            
            terminal = AdderTerminal();
        }
        else{
            print("creating standard terminal,\(name)")
            terminal = NodeTerminal()
        }
        terminals[name] = terminal;
        terminal.valueChanged.addHandler(self, handler: Node.onValueChanged)
        terminal.name = name
        locked[name] = false;
    }
    
    
    func updateTerminalValue(name: String, value: Float){
        terminals[name]!.setValue(value);
    }
    
    func onValueChanged(data: (NodeProperty,NodeTerminal,Any,Any)) {
        
          //  print("A terminal changed for \(self.name)!\(data.0, data.1.name)");

            locked[data.1.name] = true;
            print("unlocked \(self.name,data.1.name,data.1.value)");
            var allLocked = true
            for (key,value) in locked {
               // print("\(key) = \(value)")
                if(!value){
                    allLocked = false;
                }
            }
            if(allLocked){
              //  print("All set");
                valueChanged.raise((.Value,self));
                for (key,_) in locked {
                    locked[key] = false
                }

            }
            
        }
    
}