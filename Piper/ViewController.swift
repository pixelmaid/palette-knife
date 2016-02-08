//
//  ViewController.swift
//  DrawPad
//


import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    
    
    var red: CGFloat = 1
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var brushWidth: CGFloat = 2
    var opacity: CGFloat = 1.0
    var swiped = false
    var penAgents = [PenAgent]();
    var agentCount = 1;
    var inputs = [String](arrayLiteral: "x","y","force", "angle");
    var outputs = [String](arrayLiteral: "x","y","diameter", "hue");
    var cloneNode = CloneNode(name:"clone");
    var outputNode1 = Node(name:"output node 1");
    var rangeNodeY = RangeNode(name:"rangeY");
    var rangeNodeX = RangeNode(name:"rangeX");
    
    // var repeatNode =  RepeatNode(name:"repeat node");
    // var outputNode2 = Node(name:"output node 2");
    var multiplierNode = MultiplierNode(name:"multiplier node");
    var additionNodeX = AdditionNode(name:"addition nodeX");
    var additionNodeY = AdditionNode(name:"addition nodeY");
    var penNode = Node(name:"pen node");
    var lastPoint = CGPoint(x:0,y:0);
    var context: CGContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outputNode1.valueChanged.addHandler(self,handler:ViewController.onOutputChanged)
        
        cloneNode.valueChanged.addHandler(self,handler:ViewController.onOutputChanged)
        
        for index in 0...inputs.count-1{
            penNode.addTerminal(inputs[index]);
        }
        for index in 0...outputs.count-1{
            outputNode1.addTerminal(outputs[index]);
            //outputNode2.addTerminal(outputs[index]);
        }
        cloneNode.setTarget(outputNode1);
        
        
        let penInputView = NodeView(node:penNode);
        self.view.addSubview(penInputView)
        
        let cloneView = NodeView(node:cloneNode);
        self.view.addSubview(cloneView)
        cloneView.frame.origin.x = 700
        cloneView.frame.origin.y = 100;
        
        
        let outputView1 = NodeView(node:outputNode1);
        self.view.addSubview(outputView1)
        outputView1.frame.origin.x = 500
        
        /*let outputView2 = NodeView(node:outputNode2);
         self.view.addSubview(outputView2)
         outputView2.frame.origin.x = 500
         outputView2.frame.origin.y = 300;
         */
        
        let additionViewX = NodeView(node:additionNodeX);
        self.view.addSubview(additionViewX)
        additionViewX.frame.origin.x = 300
        
        let additionViewY = NodeView(node:additionNodeY);
        self.view.addSubview(additionViewY)
        additionViewY.frame.origin.x = 300
        additionViewY.frame.origin.y = 200;
        
        let multiplierNodeView = NodeView(node:multiplierNode);
        self.view.addSubview(multiplierNodeView)
        multiplierNodeView.frame.origin.x = 300
        multiplierNodeView.frame.origin.y = 300;
        
        
        let rangeViewY = NodeView(node:rangeNodeY);
        self.view.addSubview(rangeViewY)
        rangeViewY.frame.origin.x = 500
        rangeViewY.frame.origin.y = 300;
        let rangeViewX = NodeView(node:rangeNodeX);
        self.view.addSubview(rangeViewX)
        rangeViewX.frame.origin.x = 700
        rangeViewX.frame.origin.y = 300;
        
        /*  let repeatNodeView = NodeView(node:repeatNode);
         self.view.addSubview(repeatNodeView)
         repeatNodeView.frame.origin.x = 500
         repeatNodeView.frame.origin.y = 300;*/
        
        (multiplierNode.terminals["multiplier"]!as NodeTerminal).setValue(40)
        //(repeatNode.terminals["limit"]!as NodeTerminal).setValue(5)
        //(repeatNode.terminals["count"]!as NodeTerminal).setValue(0)
        
        //(additionNodeX.terminals["addition"]!as NodeTerminal).setValue(0)
        //(additionNodeY.terminals["addition"]!as NodeTerminal).setValue(100)
        
        
        
        
        penNode.terminals["force"]!.setColor(UIColor.redColor());
        penNode.terminals["angle"]!.setColor(UIColor.greenColor());
        penNode.terminals["x"]!.setColor(UIColor.purpleColor());
        penNode.terminals["y"]!.setColor(UIColor.orangeColor());
        
        penNode.terminals["x"]!.addOutput(rangeNodeX.terminals["inputValue"]!);
        penNode.terminals["force"]!.addOutput(multiplierNode.terminals["value"]!);

        penNode.terminals["y"]!.addOutput(rangeNodeY.terminals["inputValue"]!);
        penNode.terminals["force"]!.addOutput(cloneNode.terminals["diameter"]!);
        penNode.terminals["y"]!.addOutput(cloneNode.terminals["hue"]!);
        rangeNodeY.addOutput(cloneNode.terminals["y"]!);
        rangeNodeX.addOutput(cloneNode.terminals["x"]!);
        multiplierNode.addOutput(rangeNodeX.limit);
        multiplierNode.addOutput(rangeNodeY.limit);
        
        
        //additionNodeX.addOutput(outputNode1.terminals["x"]!);
        //additionNodeY.addOutput(outputNode1.terminals["y"]!);
        
        //outputNode1.addOutput(repeatNode);
        // repeatNode.addOutput(multiplierNode.terminals["multiplier"]!)
        //  multiplierNode.addOutput(additionNodeY.terminals["addition"]!)
        //  multiplierNode.addOutput(outputNode1.terminals["diameter"]!);
        
        
        //  additionNodeX.addOutput(outputNode2.terminals["x"]!);
        
        // additionNodeY.addOutput(outputNode2.terminals["y"]!);
        
        
        // multiplierNode.addOutput(outputNode2.terminals["diameter"]!);
        //penNode.terminals["x"]!.addOutput(outputNode2.terminals["hue"]!);
        
        
        
        
        for _ in 0...agentCount-1 {
            penAgents.append(PenAgent());
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    func onOutputChanged(data:(NodeProperty,ObservableNode)){
        print("on output changed");
        let node = data.1 as! Node
        let diameter = CGFloat(node.terminals["diameter"]!.value)
        let h = CGFloat(node.terminals["hue"]!.value)
        let count = node.terminals["y"]!.rangeValue.count-1;
        //print("num of y values\(count,node.terminals["y"]!.rangeValue)")
        if(count>1){
            for index in 0...count-1{
                let y = node.terminals["y"]?.rangeValue[index]
                let oldY = node.terminals["y"]?.oldRangeValue[index]
                let x = node.terminals["x"]?.rangeValue[index]
                let oldX = node.terminals["x"]?.oldRangeValue[index]

                let fromPoint = CGPoint(x:CGFloat(oldX!),y:CGFloat(oldY!));
                let toPoint = CGPoint(x:CGFloat(x!),y:CGFloat(y!));
                //print("from point\(fromPoint.x,fromPoint.y) to point\(toPoint.x,toPoint.y)")
                
                //drawLineFrom(fromPoint, toPoint: toPoint, force:diameter, hue: h);
                drawLineFrom(fromPoint, toPoint: toPoint, force:diameter, hue: self.mapColor(h));
                lastPoint = toPoint;
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first  {

        let point = touch.locationInView(view);
        let x = Float(point.x)
        let y = Float(point.y)
        let force = Float(touch.force);
        let angle = Float(touch.azimuthAngleInView(view))
        
        //penNode.updateValue(["x":x,"y":y,"force":force,"angle":angle]);
    
        }

    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first  {

        let point = touch.locationInView(view);
        let x = Float(point.x)
        let y = Float(point.y)
        let force = Float(touch.force);
        let angle = Float(touch.azimuthAngleInView(view))
        

        penNode.updateValue(["x":x,"y":y,"force":force,"angle":angle]);
        penNode.updateValue(["x":x,"y":y,"force":force,"angle":angle]);

        }
    }
    
    
    
    func mapColor(val: CGFloat)->CGFloat{
        // let start1=CGFloat(0-2*M_PI);
        // let end1 = CGFloat(2*M_PI);
        let start1=CGFloat(0);
        let end1 = CGFloat(view.frame.size.height);
        
        let start2 = CGFloat(0);
        let end2 = CGFloat(1);
        return start2 + (end2 - start2) * (val - start1) / (end1 - start1);
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint, force:CGFloat, hue:CGFloat) {
        let color = UIColor.init(hue: hue,saturation:CGFloat(1),brightness:CGFloat(1), alpha:CGFloat(1))
        
        
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, brushWidth*force)
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        CGContextStrokePath(context)
        
        
        /* for index in 0...100{
         
         
         CGContextSetLineCap(context, CGLineCap.Round)
         CGContextSetLineWidth(context, brushWidth*force)
         CGContextSetStrokeColorWithColor(context, color.CGColor)
         CGContextSetBlendMode(context, CGBlendMode.Normal)
         
         CGContextMoveToPoint(context, fromPoint.x, fromPoint.y+CGFloat(10*index))
         CGContextAddLineToPoint(context, toPoint.x, toPoint.y+CGFloat(10*index))
         
         CGContextStrokePath(context)
         }*/
        
        
        
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // 6
        swiped = true
        if let touch = touches.first  {
            
            UIGraphicsBeginImageContext(view.frame.size)
            context = UIGraphicsGetCurrentContext()!
            tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
            
            
            let point = touch.locationInView(view);
            let x = Float(point.x)
            let y = Float(point.y)
            let force = Float(touch.force);
            let angle = Float(touch.azimuthAngleInView(view))
            
            
            
            penNode.updateValue(["x":x,"y":y,"force":force,"angle":angle]);
            
            
            tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            tempImageView.alpha = opacity
            UIGraphicsEndImageContext()
            
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func reset(sender: AnyObject) {
    }
    
    @IBAction func share(sender: AnyObject) {
    }
    
    @IBAction func pencilPressed(sender: AnyObject) {
    }
}

