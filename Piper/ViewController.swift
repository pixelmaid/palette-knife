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
    var outputNode = Node(name:"output node");
    var multiplierNode = Node(name:"multiplier node");
    var penNode = Node(name:"pen node");
    var lastPoint = CGPoint(x:0,y:0);

  override func viewDidLoad() {
    super.viewDidLoad()
    
    outputNode.valueChanged.addHandler(self,handler:ViewController.onOutputChanged)
    for index in 0...inputs.count-1{
        penNode.addTerminal(inputs[index]);
    }
    for index in 0...outputs.count-1{
       outputNode.addTerminal(outputs[index]);
    }
    
    multiplierNode.addTerminal("multiplier",type: "multiplier");
    (multiplierNode.terminals["multiplier"]as! MultiplierTerminal).multiplier = 2;
    
    penNode.terminals["x"]!.addOutput(outputNode.terminals["x"]!);
    penNode.terminals["y"]!.outputs.append(outputNode.terminals["y"]!);
    penNode.terminals["force"]!.outputs.append(multiplierNode.terminals["multiplier"]!);
    multiplierNode.terminals["multiplier"]!.outputs.append(outputNode.terminals["diameter"]!);

    
    var penInputView = NodeView(terminals: inputs, name:"pen input");
    self.view.addSubview(penInputView)
    var outputView = NodeView(terminals: outputs, name: "output");
    self.view.addSubview(outputView)
    outputView.frame.origin.x = 400
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
            
            penNode.updateTerminalValue("x",value:x);
            penNode.updateTerminalValue("y",value:y);
            penNode.updateTerminalValue("force",value:force);

            
            
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

