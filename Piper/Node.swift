//
//  Node.swift
//  DrawPad
//
//  Created by JENNIFER MARY JACOBS on 2/1/16.
//

import Foundation
import UIKit


protocol PropertyObservable {
    typealias PropertyType
    typealias TargetType
    var propertyChanged: Event<(PropertyType,TargetType)> { get }
}

/*protocol NodeObservable {
    typealias PropertyType
    typealias TargetType
    var propertyChanged: Event<(PropertyType,TargetType)> { get }
}*/
enum NodeProperty {
    case Selected, Name, Linked, Value, Color
}


class ObservableNode: PropertyObservable {
    typealias PropertyType = NodeProperty
    let propertyChanged = Event<(NodeProperty,ObservableNode)>()
    let valueChanged = Event<(NodeProperty,ObservableNode)>()
    
}


class MultiplierTerminal: NodeTerminal{
    var modifier = Float(1);
    
    override func setValue(value:Float){
        self.value = value;
        valueChanged.raise((.Value,self))
        
        for output in self.outputs {
            output.setValue(self.value*modifier)
        }
    }}

class AdderTerminal: NodeTerminal{
    var modifier = Float(1);
    
   override func setValue(value:Float){
        self.value = value;
        valueChanged.raise((.Value,self))
        
        for output in self.outputs {
            output.setValue(self.value+modifier)
        }
    }
}


class NodeTerminal:ObservableNode {
    typealias PropertyType = NodeProperty
    let colorChanged = Event<(NodeProperty, UIColor)>()
    var oldValue = Float(0)
    var color = UIColor.blueColor();
    
    var outputs = [NodeTerminal]();

    dynamic var selected: Bool = false {
        didSet {
        propertyChanged.raise((.Selected,self))
        }
    }
    
    dynamic var name: String = "" {
        didSet {
        propertyChanged.raise((.Name, self))
        }
    }
    
    
    dynamic var value: Float = 0.0{
        didSet {
        self.oldValue = oldValue

        }
    }
    
    func setValue(value:Float){
        self.value = value;
        valueChanged.raise((.Value,self))
        
        for output in self.outputs {
            output.setValue(self.value)
        }
    }
    
    func addOutput(output:NodeTerminal){
        print(" adding output \(output.name,self.color)")
        output.color = self.color;
        output.colorChanged.raise((.Color, self.color));
        self.outputs.append(output);
        
    }
    
    func setColor(color:UIColor){
       self.color = color;
       colorChanged.raise((.Color, self.color));
    }
    
    
}


class RepeatNode: Node{
    var count = NodeTerminal();
    var limit = 1;
    override init(name:String){
        super.init(name: name)
        terminals["count"] = count;
        count.value = 0;
        count.valueChanged.addHandler(self, handler:RepeatNode.onCountChanged)
    }
    
     func onCountChanged(data: (NodeProperty,ObservableNode)) {
        print("count changed to \(count.value)")
    }
}

class Node: ObservableNode{
    typealias PropertyType = NodeProperty
    var terminals = [String:NodeTerminal]();
    var locked = [String:Bool]();
    var name = "";
    var outputs = [ObservableNode]();

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
    
    func onValueChanged(data: (NodeProperty,ObservableNode)) {
        
          //  print("A terminal changed for \(self.name)!\(data.0, data.1.name)");

            locked[(data.1 as! NodeTerminal).name] = true;
           // print("unlocked \(self.name,data.1.name,data.1.value)");
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