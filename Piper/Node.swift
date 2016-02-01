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
    var propertyChanged: Event<(PropertyType,TargetType,DataType)> { get }
}
enum NodeProperty {
    case Selected, Name, Linked, Value
}


class NodeTerminal: PropertyObservable {
    typealias PropertyType = NodeProperty
    let propertyChanged = Event<(NodeProperty,NodeTerminal,Any)>()
    var outputs = [NodeTerminal]();

    dynamic var selected: Bool = false {
        didSet {
        propertyChanged.raise((.Selected,self,selected))
        }
    }
    
    dynamic var name: String = "" {
        didSet {
        propertyChanged.raise((.Name, self, name))
        }
    }
    
    
    dynamic var value: Float = 0.0{
        didSet {
       propertyChanged.raise((.Value,self,value))
        for output in self.outputs {
            output.setValue(self.value)
            }
        }
    }
    
    func setValue(value:Float){
        self.value = value;
    }
    
    func addOutput(output:NodeTerminal){
        self.outputs.append(output);
        print("added output",output.name);
    }
    
}

class Node: PropertyObservable{
    typealias PropertyType = NodeProperty
    let propertyChanged = Event<((NodeProperty,Node,Any))>()
    var terminals = [String:NodeTerminal]();
    var name = "";
    init(name:String){
        self.name = name;
    }
    
    func addTerminal(name: String){
        let terminal = NodeTerminal();
        terminals[name] = terminal;
        terminal.propertyChanged.addHandler(self, handler: Node.onPropertyChanged)
        terminal.name = name
    }
    
    
    func updateTerminalValue(name: String, value: Float){
        terminals[name]!.setValue(value);
    }
    
    func onPropertyChanged(data: (NodeProperty,NodeTerminal, Any)) {
        print("A terminal changed for \(self.name)!\(data.0, data.1.name, data.2)");
    }
}