//
//  ViewController.swift
//  DrawPad
//


import UIKit
import WebKit

class ViewController: UIViewController, WKScriptMessageHandler {
    
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
    var outputNode1 = OutputNode(name:"output node 1");
    var rangeNodeY = RangeNode(name:"rangeY");
    var rangeNodeX = RangeNode(name:"rangeX");
    
    var multiplierNode = MultiplierNode(name:"multiplier node");
    var additionNodeX = AdditionNode(name:"addition nodeX");
    var additionNodeY = AdditionNode(name:"addition nodeY");
    var penNode = Node(name:"pen node");
    var lastPoint = CGPoint(x:0,y:0);
    var context: CGContext?
    var nodeViewContainer: NodeViewContainer!
    var webView: WKWebView!
    let tap = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // DOUBLE TAP
        tap.numberOfTapsRequired = 2
        tap.addTarget(self, action: "clearDrawing")
        view.userInteractionEnabled = true
        
        view.addGestureRecognizer(tap)
        let contentController = WKUserContentController();
        contentController.addScriptMessageHandler(
            self,
            name: "callbackHandler"
        )
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        self.webView = WKWebView(
            frame: CGRectMake(20, 20,800,500),
            configuration: config
        )
        self.webView.layer.cornerRadius=1
        self.webView.layer.borderWidth=1
        self.webView.layer.borderColor = UIColor.blackColor().CGColor
        let localfilePath = NSBundle.mainBundle().URLForResource("web/blockly", withExtension: "html");
        let myRequest = NSURLRequest(URL: localfilePath!);
  
        self.view.addSubview(webView)
        webView.loadRequest(myRequest);
        
        nodeViewContainer = NodeViewContainer()
        self.view.addSubview(nodeViewContainer)
        outputNode1.valueChanged.addHandler(self,handler:ViewController.onOutputChanged)
        
        cloneNode.valueChanged.addHandler(self,handler:ViewController.onOutputChanged)
        
        for index in 0...inputs.count-1{
            penNode.addTerminal(inputs[index]);
        }
        for index in 0...outputs.count-1{
            outputNode1.addTerminal(outputs[index]);
            //outputNode2.addTerminal(outputs[index]);
        }
        //cloneNode.setTarget(outputNode1);
        
        
       /* let penInputView = self.addView(penNode);
        
        let cloneView = self.addView(cloneNode);
        cloneView.frame.origin.x = 700
        cloneView.frame.origin.y = 100;
        cloneNode.terminals["num"]!.setValue(Float(10))

        
        let outputView1 = self.addView(outputNode1)
        outputView1.frame.origin.x = 500
        
        let additionViewX = self.addView(additionNodeX);
        additionViewX.frame.origin.x = 300
        
        let additionViewY = self.addView(additionNodeY);
        additionViewY.frame.origin.x = 300
        additionViewY.frame.origin.y = 200;
        
        let multiplierNodeView = self.addView(multiplierNode);
        multiplierNodeView.frame.origin.x = 300
        multiplierNodeView.frame.origin.y = 300;
        
        
        let rangeViewY = self.addView(rangeNodeY);
        rangeViewY.frame.origin.x = 500
        rangeViewY.frame.origin.y = 300;
        
        let rangeViewX = self.addView(rangeNodeX);
        rangeViewX.frame.origin.x = 700
        rangeViewX.frame.origin.y = 300;*/
        
        
        
        (multiplierNode.terminals["multiplier"]!as NodeTerminal).setValue(100)
        //(repeatNode.terminals["limit"]!as NodeTerminal).setValue(5)
        //(repeatNode.terminals["count"]!as NodeTerminal).setValue(0)
        
        //(additionNodeX.terminals["addition"]!as NodeTerminal).setValue(0)
        //(additionNodeY.terminals["addition"]!as NodeTerminal).setValue(100)
        
        
        
        
        penNode.terminals["force"]!.setColor(UIColor.redColor());
        penNode.terminals["angle"]!.setColor(UIColor.greenColor());
        penNode.terminals["x"]!.setColor(UIColor.purpleColor());
        penNode.terminals["y"]!.setColor(UIColor.orangeColor());
        
        /*penNode.terminals["x"]!.addOutput(rangeNodeX.terminals["inputValue"]!);
         penNode.terminals["force"]!.addOutput(multiplierNode.terminals["value"]!);
         
         penNode.terminals["y"]!.addOutput(rangeNodeY.terminals["inputValue"]!);
         penNode.terminals["force"]!.addOutput(cloneNode.terminals["diameter"]!);
         penNode.terminals["y"]!.addOutput(cloneNode.terminals["hue"]!);
         rangeNodeY.addOutput(cloneNode.terminals["y"]!);
         rangeNodeX.addOutput(cloneNode.terminals["x"]!);
         multiplierNode.addOutput(rangeNodeX.limit);
         multiplierNode.addOutput(rangeNodeY.limit);*/
        
        
    }
    
    func clearDrawing(){
        print("double tap performed")
        tempImageView.image = nil
    }
    
    func sendDataToWebView(x:Float,y:Float,force:Float){
        //let source = "setPenData(" + (NSString(format: "%.2f", x) as String) + "," + (NSString(format: "%.2f", y) as String) + "," + (NSString(format: "%.2f", force) as String)+")"
       self.webView.evaluateJavaScript("setPenData( \(x),\(y),\(force) )", completionHandler: nil)
    }
    
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
       if(message.name == "callbackHandler") {
        
        UIGraphicsBeginImageContext(view.frame.size)
        context = UIGraphicsGetCurrentContext()!
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
            let sentData = message.body as! NSDictionary
            let arr = sentData["data"] as! NSArray
        for d in arr{
            print("data passed\(d["x1"],d["y1"],d["diameter"])")
            let x1 = d["x1"] as! Float
            let y1 = d["y1"] as! Float
            let x2 = d["x2"] as! Float
            let y2 = d["y2"] as! Float
            let diameter = d["diameter"] as! Float
            let h = CGFloat(1.0)
            let fromPoint = CGPoint(x:CGFloat(x1),y:CGFloat(y1));
            let toPoint = CGPoint(x:CGFloat(x2),y:CGFloat(y2));
            drawLineFrom(fromPoint, toPoint: toPoint, force:CGFloat(diameter), hue: h);
        }
        
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
        }
    }

    
    
    
    func addView(targetNode:Node) ->NodeView{
        let nv = NodeView(node:targetNode);
        nodeViewContainer.addNodeView(nv)
        return nv
    }
    
    
    
    func onOutputChanged(data:(NodeProperty,ObservableNode)){
        let node = data.1 as! Node
        
        if(node is CloneNode){
            // print("on output changed");
            let diameter = CGFloat(node.terminals["diameter"]!.value)
            let h = CGFloat(node.terminals["hue"]!.value)
            let count = Int(node.terminals["num"]!.value);
            //print("num of y values\(count,node.terminals["y"]!.rangeValue)")
            if(count>0){
                for index in 0...count-1{
                    let y = node.terminals["y"]?.rangeValue[index]
                    let oldY = node.terminals["y"]?.oldRangeValue[index]
                    let x = node.terminals["x"]?.rangeValue[index]
                    let oldX = node.terminals["x"]?.oldRangeValue[index]
                    
                    let fromPoint = CGPoint(x:CGFloat(oldX!),y:CGFloat(oldY!));
                    let toPoint = CGPoint(x:CGFloat(x!),y:CGFloat(y!));
                    
                    drawLineFrom(fromPoint, toPoint: toPoint, force:diameter, hue: self.mapColor(h));
                    lastPoint = toPoint;
                }
            }
        }
        else if( node is Node){
            let diameter = CGFloat(node.terminals["diameter"]!.value)
            let h = CGFloat(node.terminals["hue"]!.value)
            let y = node.terminals["y"]!.value
             let oldY = node.terminals["y"]!.oldValue
            let x = node.terminals["x"]!.value
            let oldX = node.terminals["x"]!.oldValue

            let fromPoint = CGPoint(x:CGFloat(oldX),y:CGFloat(oldY));
            let toPoint = CGPoint(x:CGFloat(x),y:CGFloat(y));

            drawLineFrom(fromPoint, toPoint: toPoint, force:diameter, hue: self.mapColor(h));

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
        //let color = UIColor.init(hue: hue,saturation:CGFloat(1),brightness:CGFloat(1), alpha:CGFloat(1))
        let color = UIColor.redColor()
        
        print("points\(fromPoint,toPoint,color,force)")
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, brushWidth*force)
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        CGContextStrokePath(context)
        
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
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
            
            sendDataToWebView(x,y:y,force:force)
            
            //penNode.updateValue(["x":x,"y":y,"force":force,"angle":angle]);
           // drawLineFrom(CGPoint(x: 0,y: 0), toPoint: CGPoint(x: 500,y: 500), force: CGFloat(10), hue: CGFloat(1))
            
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

