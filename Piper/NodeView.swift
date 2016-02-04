//
//  NodeView.swift
//  DrawPad
//
//  Created by JENNIFER MARY JACOBS on 1/31/16.
//

import UIKit

class NodeView: UIView {
    var terminals =  [NodeTerminalView]();
    var name = ""
    var node: Node?
    var label =  UILabel(frame: CGRectMake(0, 0, 150, 20));
    
    // MARK: Initialization
    init(node:Node) {
        print("inputs=\(terminals)")
        self.node = node;
        super.init(frame: CGRect(x: 100, y: 100, width: 150, height: node.terminals.count*20+50))

       self.backgroundColor=UIColor.grayColor()
        self.layer.cornerRadius=25
        self.layer.borderWidth=0
        self.name = node.name
        var index = 0;
        for (key,_) in node.terminals{
            print("key=\(key)");
            let terminal = NodeTerminalView(terminal: node.terminals[key]!);
            self.addSubview(terminal);
            terminals.append(terminal);
            terminal.frame.origin.x = 0;
            terminal.frame.origin.y =  CGFloat(index*20)+25;
            index += 1;
        }
        self.addSubview(self.label);
        self.label.center = CGPointMake(160, 284)
        self.label.textAlignment = NSTextAlignment.Center
        self.label.frame.origin.x = 0
        self.label.frame.origin.y = 5
        self.label.text = self.name
        self.label.textColor = UIColor.blackColor()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func terminalSelected(sender: NodeTerminalView){
        print("selected terminal")
    }
    
    
}


class NodeTerminalView: UIView {
    var terminal: NodeTerminal?
    var label = UILabel(frame: CGRectMake(0, 0, 100, 20));
    var valueLabel = UITextField(frame: CGRectMake(0, 0, 50, 20));
    let valueChanged = Event<(NodeProperty,NodeTerminal,Any,Any)>()
    let colorChanged = Event<(NodeProperty,UIColor)>()
    var color = UIColor.blueColor();
    
    var selected = false;
    // MARK: Initialization
    init(terminal:NodeTerminal) {
        self.terminal = terminal;
        label.text = terminal.name;
        label.textColor = UIColor.whiteColor()
        label.center = CGPointMake(160, 284)
        label.textAlignment = NSTextAlignment.Center
        super.init(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
        self.addSubview(label);
        self.addSubview(valueLabel);
        valueLabel.text = String(0)
        self.label.frame.origin.x = 0;
        self.label.frame.origin.y = 0;
        valueLabel.frame.origin.x = 90;
        terminal.valueChanged.addHandler(self, handler: NodeTerminalView.onValueChanged)
        terminal.colorChanged.addHandler(self, handler: NodeTerminalView.onColorChanged)

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       // self.backgroundColor = UIColor.blueColor()
        
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //self.backgroundColor = UIColor.clearColor()
        
    }
    
    func updateBackgroundColor(color:UIColor){
        self.color = color;
        self.backgroundColor = color
    }
    
    func onValueChanged(data: (NodeProperty,ObservableNode)) {
        self.valueLabel.text = String((data.1 as! NodeTerminal).value);
    }
    
    func onColorChanged(data: (NodeProperty, UIColor)) {
      //  print("updating color for terminal \(self.label.text)")

        self.updateBackgroundColor(data.1);
    }

    
}

