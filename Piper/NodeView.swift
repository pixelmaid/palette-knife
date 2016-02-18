//
//  NodeView.swift
//  DrawPad
//
//  Created by JENNIFER MARY JACOBS on 1/31/16.
//

import UIKit
import Swift

enum ViewProperty {
    case Selected
}

//master view to manage all nodes
class NodeViewContainer: UIView{
    
    
    var lastSelectedTerminal: DefaultView?
    var firstTargetTerminal: DefaultView?
    var secondTargetTerminal: DefaultView?
    var context: CGContext?
    var imageView: UIImageView?
    var nodeViews = [DefaultView]()
    
    init(){
        super.init(frame: CGRect(x: 0, y: 0, width: 2000, height: 2000))
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 2000, height: 2000))
        self.addSubview(imageView!)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addNodeView(view: NodeView) {
        self.addSubview(view);
        self.nodeViews.append(view)
        view.terminalSelectionChanged.addHandler(self,handler: NodeViewContainer.onTerminalSelectionChanged)
        
    }
    
    func onTerminalSelectionChanged(data:(ViewProperty,DefaultView)){
        if( firstTargetTerminal == nil){
            firstTargetTerminal = data.1
        }
        else {
            secondTargetTerminal = data.1
        }
        
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        var hitTestView = super.hitTest(point, withEvent:event)
        if (hitTestView == self) {
            hitTestView = nil;
        }
        
        print("hit test for master view,\(hitTestView)")
        return hitTestView;
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(firstTargetTerminal != nil && lastSelectedTerminal != nil){
           firstTargetTerminal!.model!.addOutput(lastSelectedTerminal!.model!)
            var p1 = firstTargetTerminal!.superview!.convertPoint(firstTargetTerminal!.frame.origin, toView:imageView! )
            p1.x += firstTargetTerminal!.frame.width;
            p1.y += firstTargetTerminal!.frame.height/2;

            var  p2 = lastSelectedTerminal!.superview!.convertPoint(lastSelectedTerminal!.frame.origin, toView:imageView! )
            p2.y += lastSelectedTerminal!.frame.height/2;

            self.drawLineFrom(p1,toPoint: p2, color: UIColor.redColor())
            firstTargetTerminal = nil
            lastSelectedTerminal = nil
        }
        if(lastSelectedTerminal != nil){
            lastSelectedTerminal!.selected = false
            lastSelectedTerminal = nil

        }
        if(firstTargetTerminal != nil){
            firstTargetTerminal!.selected = false
            firstTargetTerminal = nil

        }
        
        for index in 0...self.nodeViews.count-1{
            let view = self.nodeViews[index] as! DefaultView

            view.selected = false
        }
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first  {
            let  point = touch.locationInView(self)
            let hit = self.hitTest(point, withEvent: nil)
            if(hit != nil){
                 if hit is NodeTerminalView{
                let df = hit as! DefaultView
                for index in 0...self.nodeViews.count-1{
                    let view = self.nodeViews[index] as! DefaultView
                    if(df.isDescendantOfView(view)){
                        if(lastSelectedTerminal != nil && self.lastSelectedTerminal != self.firstTargetTerminal){
                            lastSelectedTerminal!.selected = false
                        }
                        if (df.superview! != firstTargetTerminal?.superview){
                            df.selected = true
                            lastSelectedTerminal = df
                            
                        }
                    }
                    view.selected = false
                    
                }
                }
            }
        }
    }
    
    
    func clearLines(){
         imageView!.image = nil
    }
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint, color:UIColor) {
        print("drawing line from \(fromPoint, toPoint)")
        UIGraphicsBeginImageContext(self.frame.size)
        
        context = UIGraphicsGetCurrentContext()!
        imageView!.image?.drawInRect(CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        

        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, 3)
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        CGContextStrokePath(context)
       imageView!.image = UIGraphicsGetImageFromCurrentImageContext()
       imageView!.alpha = 1

        UIGraphicsEndImageContext()
        
    }
    
}



class NodeView:DefaultView {
    var terminals =  [NodeTerminalView]();
    var name = ""
    let label = UILabel(frame: CGRectMake(0, 0, 200, 20));
    let terminalSelectionChanged = Event<(ViewProperty,DefaultView)>()
    // MARK: Initialization
    init(node:Node) {
        //print("inputs=\(terminals)")
        super.init(frame: CGRect(x: 100, y: 100, width: 200, height: node.terminals.count*20+50))
        self.model = node;

        self.backgroundColor=UIColor.grayColor()
        self.layer.cornerRadius=25
        self.layer.borderWidth=0
        self.name = node.name
        var index = 0;
        for (key,_) in node.terminals{
            let terminal = NodeTerminalView(terminal: node.terminals[key]!);
            self.addSubview(terminal);
            terminals.append(terminal);
            terminal.frame.origin.x = 0;
            terminal.frame.origin.y =  CGFloat(index*20)+25;
            index += 1;
            terminal.selectedChanged.addHandler(self, handler:NodeView.onSelectedChanged)
            
        }
        self.addSubview(self.label);
       // self.label.center = CGPointMake(160, 284)
        self.label.textAlignment = NSTextAlignment.Center
        self.label.frame.origin.x = 0
        self.label.frame.origin.y = 5
        self.label.text = self.name
        self.label.textColor = UIColor.blackColor()
        self.label.userInteractionEnabled = false;
        
        
    }
   
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func terminalAdded(data:(NodeProperty,NodeTerminal)){
        
    }
    
    func terminalSelected(sender: NodeTerminalView){
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.selected = true
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(selected){
            let point = touches.first?.locationInView(self)
            let prevPoint = touches.first?.previousLocationInView(self)
            self.frame.origin.x+=point!.x-prevPoint!.x;
            self.frame.origin.y+=point!.y-prevPoint!.y;
        }
        else if(passForwardTouchEvents){
            self.superview!.touchesMoved(touches,withEvent: event)
        }
        //print("touches moved for nodeview\(self)")
        
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(passForwardTouchEvents){
            self.superview!.touchesEnded(touches,withEvent: event)
        }
        else{
            self.selected = false;
        }
        
    }
    
    
    func onSelectedChanged(data:(ViewProperty, DefaultView)){
        terminalSelectionChanged.raise((.Selected,data.1))
        if(data.1.selected){
            data.1.passForwardTouchEvents = true;
            self.passForwardTouchEvents = true;
        }
        else{
            data.1.passForwardTouchEvents = false;
            self.passForwardTouchEvents = true;
            
            
        }
    }
    
    
    
}

class NodeTerminalView: DefaultView {
    var label = UILabel(frame: CGRectMake(0, 0, 100, 20));
    var valueLabel = UITextField(frame: CGRectMake(0, 0, 100, 20));
    let valueChanged = Event<(NodeProperty,NodeTerminal,Any,Any)>()
    let colorChanged = Event<(NodeProperty,UIColor)>()
    var color = UIColor.blueColor();
    var hasInput = false
    var hasOutput = false;
    
    // MARK: Initialization
    init(terminal:NodeTerminal) {
        label.text = terminal.name;
        label.textColor = UIColor.whiteColor()
        label.center = CGPointMake(160, 284)
        label.textAlignment = NSTextAlignment.Center
        label.userInteractionEnabled = false;
        
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
        self.model = terminal;

        self.addSubview(label);
        self.addSubview(valueLabel);
        valueLabel.text = String(0)
        valueLabel.userInteractionEnabled = true;
       valueLabel.addTarget(self, action: "valueChanged:", forControlEvents: UIControlEvents.EditingChanged)
        self.label.frame.origin.x = 0;
        self.label.frame.origin.y = 0;
        valueLabel.frame.origin.x = 90;
        terminal.valueChanged.addHandler(self, handler: NodeTerminalView.onValueChanged)
        terminal.colorChanged.addHandler(self, handler: NodeTerminalView.onColorChanged)
        self.layer.borderWidth = CGFloat(1.0)
        self.layer.borderColor = UIColor.whiteColor().CGColor
        
    }
    
    
    func valueChanged(textField: UITextField) {
       let value  = (valueLabel.text! as NSString).floatValue
        
        self.model!.setValue(value)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.selected = true;
        
        
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if(self.passForwardTouchEvents){
            self.superview!.touchesMoved(touches,withEvent: event)
        }
        else{
            
        }
    }
    
    
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(self.passForwardTouchEvents){
            self.superview!.touchesEnded(touches,withEvent: event)
        }
        else{
            self.selected = false;

        }
    
    
    }
    
    
    func updateBackgroundColor(color:UIColor){
        self.color = color;
        self.backgroundColor = color
    }
    
    func onValueChanged(data: (NodeProperty,ObservableNode)) {
        var nt = data.1 as! NodeTerminal;
        if(nt.rangeValue.count>0){
            self.valueLabel.text = String((data.1 as! NodeTerminal).rangeValue[0]);
        }
        else{
            self.valueLabel.text = String((data.1 as! NodeTerminal).value);
        }
        
    }
    
    func onColorChanged(data: (NodeProperty, UIColor)) {
        //  print("updating color for terminal \(self.label.text)")
        
        self.updateBackgroundColor(data.1);
    }
    
    
}


class DefaultView: UIView{
    var passForwardTouchEvents = false
    let selectedChanged = Event<(ViewProperty,DefaultView)>()
    var model: ObservableNode?
    dynamic var selected: Bool = false{
        didSet {
        if(self.selected){
            self.layer.borderColor = UIColor.blueColor().CGColor
            self.layer.borderWidth = CGFloat(3.0)
        }
        else{
            self.layer.borderColor = UIColor.whiteColor().CGColor
            self.layer.borderWidth = CGFloat(1.0)
            
        }
        selectedChanged.raise((.Selected, self))
        }
    }
    
}



