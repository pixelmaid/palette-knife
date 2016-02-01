//
//  NodeView.swift
//  DrawPad
//
//  Created by JENNIFER MARY JACOBS on 1/31/16.
//

import UIKit

class NodeView: UIView {
    var terminals = [String]()
    var name = ""
    var label =  UILabel(frame: CGRectMake(0, 0, 100, 20));
    private var kvoContext: UInt8 = 1
    
    // MARK: Initialization
    init(terminals:[String], name:String) {
       self.terminals = terminals
        print("inputs=\(terminals)")
        super.init(frame: CGRect(x: 100, y: 100, width: 100, height: 160))
       self.backgroundColor=UIColor.grayColor()
        self.layer.cornerRadius=25
        self.layer.borderWidth=0
        self.name = name;
        for index in 0...terminals.count-1{
            let terminal = NodeTerminalView(terminal: terminals[index]);
            self.addSubview(terminal);
            terminal.frame.origin.x = 0;
            terminal.frame.origin.y =  CGFloat(index*20)+25;
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
    var terminal = ""
    var label = UILabel(frame: CGRectMake(0, 0, 100, 20));
    var selected = false;
    // MARK: Initialization
    init(terminal:String) {
        self.terminal = terminal;
        label.text = terminal;
        label.textColor = UIColor.whiteColor()
        label.center = CGPointMake(160, 284)
        label.textAlignment = NSTextAlignment.Center
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        self.addSubview(label);
        self.label.frame.origin.x = 0;
        self.label.frame.origin.y = 0;
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.backgroundColor = UIColor.blueColor()
        
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.backgroundColor = UIColor.clearColor()
        
    }
    
}

