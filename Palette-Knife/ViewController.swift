//
//  ViewController.swift
//  Palette-Knife
//
//  Created by JENNIFER MARY JACOBS on 5/4/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import UIKit
import MessageUI

let behaviorMapper = BehaviorMapper()
var stylus = Stylus(x: 0,y:0,angle:0,force:0)

class ViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var new_canvas: UIButton!
    @IBOutlet weak var new_drawing: UIButton!
    @IBOutlet weak var clearAll: UIButton!
    @IBOutlet weak var gcodeExport: UIButton!
    
    var brushes = [String:Brush]()
    var socketManager = SocketManager();
    var currentCanvas: Canvas?
    let socketKey = NSUUID().UUIDString
    let drawKey = NSUUID().UUIDString
    
    override func viewDidLoad() {
        
        
        
        super.viewDidLoad()
        
        
        clearAll.addTarget(self, action: #selector(ViewController.clearClicked(_:)), forControlEvents: .TouchUpInside)
        
        
        gcodeExport.addTarget(self, action: #selector(ViewController.gcodeExportClicked(_:)), forControlEvents: .TouchUpInside)
        
        
        
        socketManager.socketEvent.addHandler(self,handler: ViewController.socketHandler, key:socketKey)
        socketManager.connect();
        
        self.initCanvas();
        self.initTestBrushes();
        
    }
    
    //event handler for socket connections
    func socketHandler(data:(String), key:String){
        switch(data){
        case "first_connection":
            //self.initCanvas();
            //self.initTestBrushes();
            break;
        case "disconnected":
            break;
        case "connected":
            break
        default:
            break
        }
        
    }
    
    func clearClicked(sender: AnyObject?) {
        canvasView.clear()
    }
    
    func gcodeExportClicked(sender: AnyObject?){
        let gcode = (currentCanvas?.currentDrawing?.getGcode())! as NSString;
        let gcode_data = gcode.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let svg = (currentCanvas?.currentDrawing?.getSVG())! as NSString;
        let svg_data = svg.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let mailComposeViewController = configuredMailComposeViewController()
        mailComposeViewController.addAttachmentData(gcode_data, mimeType:"sbp" , fileName: "drawing.sbp")
        
        mailComposeViewController.addAttachmentData(svg_data, mimeType:"svg" , fileName: "drawing.svg")
        
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["jenniferj.net@gmail.com"])
        mailComposerVC.setSubject("GCODE")
        mailComposerVC.setMessageBody("gcode", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    func newCanvasClicked(sender: AnyObject?){
        self.initCanvas();
    }
    
    func newDrawingClicked(sender: AnyObject){
        currentCanvas?.initDrawing();
    }
    
    func initCanvas(){
        currentCanvas = Canvas();
        socketManager.initAction(currentCanvas!);
        socketManager.initAction(stylus);
        currentCanvas!.initDrawing();
        currentCanvas!.geometryModified.addHandler(self,handler: ViewController.canvasDrawHandler, key:drawKey)
        
        
    }
    
    func initTestBrushes(){
        let num = 30
        
        let falseConstant = Observable<Float>(0)
        let angleRange = Range(min: 0, max: num, start: 0, stop: 1)
        let reflectConstant = Observable<Float>(1)
        let b2 = BehaviorDefinition(name:"b2")
        
        
        b2.addInterval("timeInterval",inc:0.005,times:nil)
        
        b2.addMethod("setup", targetMethod: "newStroke", arguments: nil)
        b2.addMapping(nil, referenceName: "ox", parentFlag: true, relativePropertyName: "ox", targetState: "default")
        b2.addMapping(nil, referenceName: "oy", parentFlag: true, relativePropertyName: "oy", targetState: "default")
        b2.addMapping(nil, referenceName: "ox", parentFlag: true, relativePropertyName: "x", targetState: "default")
        b2.addMapping(nil, referenceName: "oy", parentFlag: true, relativePropertyName: "y", targetState: "default")
        
        b2.addState("delay")
        b2.addState("grow")
        b2.addState("spawn")
        b2.addState("die")
        b2.addState("reflect")
        
        
        b2.addCondition("indexCondition", reference: angleRange, referenceName: "index", referenceParentFlag: false, relative: Observable<Float>(Float(num/2)), relativeName: nil, relativeParentFlag: false, relational: "==")
        
        b2.addTransition("defaultDelayTransition", eventEmitter: nil, parentFlag:false, event:"STATE_COMPLETE", fromState: "default", toState: "delay", condition: nil)
        
        b2.addTransition("reflectTransition", eventEmitter: nil, parentFlag:false, event:"STATE_COMPLETE", fromState: "default", toState: "reflect", condition: "indexCondition")
        
        
        b2.addMapping(reflectConstant, referenceName: nil, parentFlag: false, relativePropertyName: "reflectX", targetState: "default")
        
        b2.addTransition("reflectEndTransition", eventEmitter: nil, parentFlag:false, event:
            "STATE_COMPLETE", fromState: "reflect", toState: "default", condition: nil)
        
        b2.addIncrement("angleIncrememt", inc:angleRange, start:Observable<Float>(-1))
        
        b2.addMapping(nil, referenceName: "xBuffer", parentFlag: true, relativePropertyName: "dx", targetState: "grow")
        b2.addMapping(nil, referenceName: "yBuffer", parentFlag: true, relativePropertyName: "dy", targetState: "grow")
        b2.addMapping(nil, referenceName: "weightBuffer", parentFlag: true, relativePropertyName: "weight", targetState: "grow")
        
        b2.addMapping(nil, referenceName: "angleIncrememt", parentFlag: false, relativePropertyName: "angle", targetState: "grow")
        
        b2.addCondition("incrementCondition", reference: nil, referenceName: "time", referenceParentFlag: false, relative:nil, relativeName: "timeInterval", relativeParentFlag: false, relational: "within")
        
        b2.addTransition("intervalTransition", eventEmitter: nil, parentFlag:false, event:
            "TIME_INCREMENT", fromState: "delay", toState: "grow", condition: "incrementCondition")
        
        b2.addCondition("growCompleteCondition", reference: nil, referenceName: "bufferLimitX", referenceParentFlag: true, relative: falseConstant, relativeName:nil, relativeParentFlag: false, relational: "==")
        
        b2.addCondition("growSpawnCondition", reference: nil, referenceName: "bufferLimitX", referenceParentFlag: true, relative: falseConstant, relativeName:nil, relativeParentFlag: false, relational: "!=")
        
        b2.addCondition("limitCondition", reference: angleRange, referenceName: "index", referenceParentFlag: false, relative: Observable<Float>(Float(num-1)), relativeName: nil, relativeParentFlag: false, relational: "<")
        
        b2.addTransition("growEndTransition", eventEmitter: nil, parentFlag:false, event:
            "STATE_COMPLETE", fromState: "grow", toState: "delay", condition: "growCompleteCondition")
        
        b2.addTransition("startSpawnTransition", eventEmitter: nil, parentFlag:false, event:
            "STATE_COMPLETE", fromState: "grow", toState: "spawn", condition: "limitCondition")
        
        b2.addTransition("growSpawnTransition", eventEmitter: nil, parentFlag:false, event:
            "STATE_COMPLETE", fromState: "spawn", toState: "die", condition: "growSpawnCondition")
        
        
        b2.addMethod("growSpawnTransition", targetMethod: "spawn", arguments: ["b3",b2,1])
        b2.addMethod("growSpawnTransition", targetMethod: "destroy", arguments: nil)
        
        print(b2.toJSON());
        
        
        let b1 = BehaviorDefinition(name:"b1")
        b1.addTransition("stylusDownT", eventEmitter: stylus, parentFlag:false, event: "STYLUS_DOWN", fromState: "default", toState: "default", condition:nil)
        b1.addMethod("stylusDownT", targetMethod: "setOrigin", arguments: [stylus.position])
        b1.addMethod("stylusDownT", targetMethod: "newStroke", arguments: nil)
        
        b1.addMapping(stylus, referenceName: "dx", parentFlag: false, relativePropertyName: "dx", targetState: "default")
        b1.addMapping(stylus, referenceName: "dy", parentFlag: false, relativePropertyName: "dy", targetState: "default")
        b1.addMapping(stylus, referenceName: "force", parentFlag: false, relativePropertyName: "weight", targetState: "default")
        
        b1.addTransition("stylusUpT", eventEmitter: stylus, parentFlag:false, event: "STYLUS_UP", fromState: "default", toState: "default", condition:nil)
        
        
        b1.addTransition("stylusUpT",eventEmitter: stylus, parentFlag:false, event: "STYLUS_UP", fromState: "default", toState: "default", condition:nil)
        
        b1.addMethod("stylusUpT", targetMethod: "spawn", arguments: ["b2",b2,1])
        
        
        
        let b1_brush = Brush(name:"b1",behaviorDef: b1, parent:nil, canvas:self.currentCanvas!)
    }
    
    
    
    func canvasDrawHandler(data:(Geometry,String,String), key:String){
        switch data.2{
        case "DRAW":
            switch data.1{
            case "SEGMENT":
                let seg = data.0 as! Segment
                
                let prevSeg = seg.getPreviousSegment()
                
                if(prevSeg != nil){
                    canvasView.drawPath(prevSeg!.point,tP: seg.point, w:seg.diameter, c:Color(r:0,g:0,b:0))
                }
                
                break
                /*case "ARC":
                 let arc = data.0 as! Arc
                 canvasView.drawArc(arc.center, radius: arc.radius, startAngle: arc.startAngle, endAngle: arc.endAngle, w: 10, c: Color(r:0,g:0,b:0))
                 break*/
                
            case "LINE":
                let line = data.0 as! Line
                
                canvasView.drawPath(line.p, tP:line.v, w: 10, c: Color(r:0,g:0,b:0))
                break
                
            case "LEAF":
                let leaf = data.0 as! StoredDrawing
                
                canvasView.drawLeaf(leaf.position, angle:leaf.angle, scale:leaf.scaling.x.get())
                break
                
            case "FLOWER":
                let flower = data.0 as! StoredDrawing
                canvasView.drawFlower(flower.position)
                
                break
                
            case "POLYGON":
                //canvasView.drawPath(stylus.prevPosition, tP:stylus.position, w:10, c:Color(r:0,g:0,b:0))
                break
            default:
                break
                
            }
            break
        case "DELETE":
            
            break
        default : break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first  {
            
            _ = touch.locationInView(view);
            let force = Float(touch.force);
            let angle = Float(touch.azimuthAngleInView(view))
            stylus.onStylusUp()
            // socketManager.sendStylusData(force, position: stylus.position, angle: angle, delta: stylus.position.sub(stylus.prevPosition),penDown:stylus.penDown)
            //socketManager.sendStylusData();
            
        }
        
    }
    
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first  {
            let point = touch.locationInView(view)
            let x = Float(point.x)
            let y = Float(point.y)
            ;
            let force = Float(touch.force);
            let angle = Float(touch.azimuthAngleInView(view))
            stylus.onStylusDown(x, y:y, force:force, angle:angle)
            // socketManager.sendStylusData(force, position: stylus.position, angle: angle, delta: stylus.position.sub(stylus.prevPosition),penDown:stylus.penDown)
            // socketManager.sendStylusData();
            
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first  {
            
            let point = touch.locationInView(view);
            let x = Float(point.x)
            let y = Float(point.y)
            let force = Float(touch.force);
            let angle = Float(touch.azimuthAngleInView(view))
            stylus.onStylusMove(x, y:y, force:force, angle:angle)
            // socketManager.sendStylusData(force, position: stylus.position, angle: angle, delta: stylus.position.sub(stylus.prevPosition),penDown:stylus.penDown)
            // socketManager.sendStylusData();
        }
    }
    
    
    
    
}
