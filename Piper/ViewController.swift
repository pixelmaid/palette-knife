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
    var inputs = [String](arrayLiteral: "force","angle","x","y");
    var outputs = [String](arrayLiteral: "x","y","diameter");
    var outputNode1 = Node(name:"output node 1");
    var outputNode2 = Node(name:"output node 2");
    var multiplierNode = Node(name:"multiplier node");
    var additionNodeX = Node(name:"addition nodeX");
    var additionNodeY = Node(name:"addition nodeY");
    var penNode = Node(name:"pen node");
    var lastPoint = CGPoint(x:0,y:0);

  override func viewDidLoad() {
    super.viewDidLoad()
    
   outputNode1.valueChanged.addHandler(self,handler:ViewController.onOutputChanged)
  outputNode2.valueChanged.addHandler(self,handler:ViewController.onOutputChanged)

    for index in 0...inputs.count-1{
        penNode.addTerminal(inputs[index]);
    }
    for index in 0...outputs.count-1{
       outputNode1.addTerminal(outputs[index]);
       outputNode2.addTerminal(outputs[index]);
    }
    
    multiplierNode.addTerminal("multiplier",type: "multiplier");
    (multiplierNode.terminals["multiplier"]as! MultiplierTerminal).modifier = 2;
    additionNodeX.addTerminal("addition",type: "addition");
    (additionNodeX.terminals["addition"]as! AdderTerminal).modifier = 10;
    additionNodeY.addTerminal("addition",type: "addition");
    (additionNodeY.terminals["addition"]as! AdderTerminal).modifier = 100;
    

    
    
    let penInputView = NodeView(node:penNode);
    self.view.addSubview(penInputView)
  


    let outputView1 = NodeView(node:outputNode1);
    self.view.addSubview(outputView1)
    outputView1.frame.origin.x = 500
    
    let outputView2 = NodeView(node:outputNode2);
    self.view.addSubview(outputView2)
    outputView2.frame.origin.x = 500
    outputView2.frame.origin.y = 300;
    
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

    
    penNode.terminals["force"]!.setColor(UIColor.redColor());
    penNode.terminals["angle"]!.setColor(UIColor.greenColor());
    penNode.terminals["x"]!.setColor(UIColor.purpleColor());
    penNode.terminals["y"]!.setColor(UIColor.orangeColor());

    
    
   penNode.terminals["x"]!.addOutput(outputNode1.terminals["x"]!);
   penNode.terminals["y"]!.addOutput(outputNode1.terminals["y"]!);
    penNode.terminals["force"]!.addOutput(multiplierNode.terminals["multiplier"]!);
  multiplierNode.terminals["multiplier"]!.addOutput(outputNode1.terminals["diameter"]!);
    
    
    penNode.terminals["x"]!.addOutput(additionNodeX.terminals["addition"]!);
  penNode.terminals["y"]!.addOutput(additionNodeY.terminals["addition"]!);
    additionNodeX.terminals["addition"]!.addOutput(outputNode2.terminals["x"]!);
    additionNodeY.terminals["addition"]!.addOutput(outputNode2.terminals["y"]!);
 
    multiplierNode.terminals["multiplier"]!.addOutput(outputNode2.terminals["diameter"]!);
    
    
    
    
    
    for _ in 0...agentCount-1 {
        penAgents.append(PenAgent());
    }

    // Do any additional setup after loading the view, typically from a nib.
  }
    
    
    func onOutputChanged(data:(NodeProperty,Node)){
        
    let fromPoint = CGPoint(x:CGFloat(data.1.terminals["x"]!.oldValue),y:CGFloat(data.1.terminals["y"]!.oldValue));
    let toPoint = CGPoint(x:CGFloat(data.1.terminals["x"]!.value),y:CGFloat(data.1.terminals["y"]!.value));
        print("from point\(fromPoint.x,fromPoint.y) to point\(toPoint.x,toPoint.y)")

    let diameter = CGFloat(data.1.terminals["diameter"]!.value)
    drawLineFrom(fromPoint, toPoint: toPoint, force:diameter)
    lastPoint = toPoint;
    data.1.terminals["y"]!.oldValue = data.1.terminals["y"]!.value;

    }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swiped = false
       
        
        
        if let touch = touches.first {
            let point = touch.locationInView(view);
            let x = Float(point.x)
            let y = Float(point.y)
            let force = Float(touch.force);
            
           penNode.updateTerminalValue("x",value:x);
            penNode.updateTerminalValue("y",value:y);
            penNode.updateTerminalValue("force",value:force);
            
            for index in 0...agentCount-1 {
                penAgents[index].setLastPoint(Float(point.x),y: Float(point.y));
            }
        }
    }
    
    
    func mapColor(val: CGFloat)->CGFloat{
        let start1=CGFloat(0);
        let end1 = view.frame.size.height;
        let start2 = CGFloat(0);
        let end2 = CGFloat(1);
        return start2 + (end2 - start2) * (val - start1) / (end1 - start1);
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint, force:CGFloat) {
        
        // 1
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        // 2
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        // 3
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, brushWidth*force)
        CGContextSetRGBStrokeColor(context, mapColor(toPoint.y), green, blue, 1.0)
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        
        // 4
        CGContextStrokePath(context)
        
        // 5
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
        
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // 6
        swiped = true
        if let touch = touches.first  {
            
            let point = touch.locationInView(view);
            let x = Float(point.x)
            let y = Float(point.y)
            let force = Float(touch.force);
            let angle = Float(touch.azimuthAngleInView(view))

            
            
            penNode.updateTerminalValue("x",value:x);
            penNode.updateTerminalValue("y",value:y);
            penNode.updateTerminalValue("force",value:force);
            penNode.updateTerminalValue("angle",value:angle);
            
            
            for index in 0...agentCount-1 {
                let i = Float(index);
                let x = Float(x)+10*force*i;
                let y = Float(y)+10*force*i;
                let secondPoint = CGPoint(x:CGFloat(x),y:CGFloat(y));
               // drawLineFrom(penAgents[index].getLastPoint(), toPoint: secondPoint, force: touch.force)
                penAgents[index].addPoint(x,y:y);
                var closePoints = penAgents[index].checkProximity(Point(x: x,y: y),threshold:60*Float(touch.force));
                if(closePoints.count>0){
                for j in 0...closePoints.count-1{
                    let sPoint = CGPoint(x:CGFloat(closePoints[j].x),y:CGFloat(closePoints[j].y));
                    //drawLineFrom(sPoint, toPoint: secondPoint, force: 0.15)
                }
                }

            }
           
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

