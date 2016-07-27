//
//  Brush.swift
//  Palette-Knife
//
//  Created by JENNIFER MARY JACOBS on 5/5/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation


class Brush: Factory, WebTransmitter, Hashable{
    
    //hierarcical data
    var children = [Brush]();
    var parent: Brush?
    var lastSpawned = [Brush]();
    
    //dictionary to store expressions for emitter->action handlers
    var states = [String:State]();
    var currentState:String
    //dictionary for storing arrays of handlers for children (for later removal)
    var childHandlers = [Brush:[Disposable]]()
    
    //geometric/stylistic properties
    var strokeColor = Color(r:0,g:0,b:0);
    var fillColor = Color(r:0,g:0,b:0);
    var weight = FloatEmitter(val: 5.0)
    var reflect = false;
    var position = PointEmitter(x:0,y:0)
    var prevPosition = PointEmitter(x:0,y:0)
    var penDown = false;
    var scaling = PointEmitter(x:1,y:1)
    var angle = FloatEmitter(val:0)
    var n1:Float!
    var n2:Float!
    var length:Float!
    var name = "Brush"
    var currentCanvas:Canvas?
    var geometryModified = Event<(Geometry,String,String)>()
    var transmitEvent = Event<(String)>()
    
    let removeMappingEvent = Event<(Brush,String,Emitter)>()
    
    var id = NSUUID().UUIDString;
    
    required init(){
        self.currentState = "default"
        super.init()
        self.events =  ["SPAWN", "STATE_COMPLETE"]
        self.createKeyStorage();
        self.createState("default");
       
        self.createState(currentState);
    }
    
    //MARK: - Hashable
    var hashValue : Int {
        get {
            return "\(self.id)".hashValue
        }
    }
    
    //Event handlers
    //chains communication between brushes and view controller
    func brushDrawHandler(data:(Geometry,String,String)){
        self.geometryModified.raise(data)
    }
    
    func createState(name:String){
        
        states[name] = State();
    }
    
    
    
    
    //NS Notification handlers
    // communication between emitter and brush
    //setHandler: recieves  expression in the form of "propertyA:propertyB" which is used to determine mapping for set action
    dynamic func setHandler(notification: NSNotification){
        
        let reference = notification.userInfo?["emitter"] as! Emitter
       
        let key = notification.userInfo?["key"] as! String
        let mapping = states[currentState]?.getMapping(key)
         if(mapping != nil){
         let constraint = mapping as! Constraint
            print("setting relative \(constraint.relativeProperty.get()) to reference \(reference.get())")
         constraint.relativeProperty.set(reference);
         }
    }
    
    //NS Notification handlers
    // communication between emitter and brush
    //setHandler: recieves  expression in the form of "propertyA:propertyB" which is used to determine mapping for set action
    dynamic func stateTransitionHandler(notification: NSNotification){
       
        let key = notification.userInfo?["key"] as! String
        let mapping = states[currentState]?.getMapping(key)
        if(mapping != nil){
            let stateTransition = mapping as! StateTransition
            self.currentState = stateTransition.toState;
            print("transition to state\(currentState)")
           //execute methods
            self.executeStateMethods()
            //check constraints
            
            //trigger state complete after functions are executed
            for key in self.keyStorage["STATE_COMPLETE"]!  {
                NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0])
                
                
            }
        }
    }
    
    func executeStateMethods(){
        let methods = self.states[currentState]!.methods
        for i in 0..<methods.count{
            let methodName = methods[i];
            switch (methodName){
                case "newStroke":
                    self.newStroke();
                    break;
            case "destroy":
                self.destroy();
                break;
            default:
                break;
            }
        }
        
    }

    // setHandler: recieves  expression in the form of "propertyA:propertyB" which is used to determine mapping for set action
    /*dynamic func setHandler(notification: NSNotification){
     let emitter = notification.userInfo?["emitter"] as! Emitter
     let key = notification.userInfo?["key"] as! String
     let mapping = states[currentState]![key]
     if(mapping != nil){
     let expression = mapping!.2
     let settings = expression.componentsSeparatedByString("|")
     for s in settings{
     let emitterProp = s.componentsSeparatedByString(":")[0]
     let targetProp = s.componentsSeparatedByString(":")[1]
     self.set(targetProp,value: emitter[emitterProp])
     }
     
     }*/
    
    
    
   /* dynamic func setChildHandler(notification:NSNotification){
        let emitter = notification.userInfo?["emitter"] as! Brush
        let spawned = emitter.lastSpawned;
        let key = notification.userInfo?["key"] as! String
        let mapping = states[currentState]!.getMapping(key)
        if(mapping != nil){
            let expression = mapping!.2
            let settings = expression.componentsSeparatedByString("|")
            for s in settings{
                let childProp = s.componentsSeparatedByString(":")[0]
                let setter = s.componentsSeparatedByString(":")[1]
                let setterTarget = setter.componentsSeparatedByString(".")[0]
                let setterProp = setter.componentsSeparatedByString(".")[1]
                var t:Emitter?
                
                if(setterTarget == "parent"){
                    t = emitter;
                    
                }
                else if(setterTarget=="stylus"){
                    t = stylus
                }
                else{
                    t = nil
                }
                for i in 0...spawned.count-1{
                    if(setterProp.containsString(",")){
                        let cProp = setterProp.componentsSeparatedByString(",")[i]
                        spawned[i].set(childProp,value: t!.get(cProp))
                    }
                    else{
                        spawned[i].set(childProp,value: t!.get(setterProp))
                    }
                }
                
            }
        }
    }
    
    dynamic func spawnHandler(notification:NSNotification){
        let emitter = notification.userInfo?["emitter"] as! Emitter
        let key = notification.userInfo?["key"] as! String
        let mapping = states[currentState]!.getMapping(key)
        if(mapping != nil){
            
            let expression = mapping!.2
            let type = expression.componentsSeparatedByString(":")[0]
            let string_count = expression.componentsSeparatedByString(":")[1]
            let count =  NSNumberFormatter().numberFromString(string_count)?.integerValue
            self.spawn(type, num:count!)
        }
    }*/
    
    //sets canvas target to output geometry into
    func setCanvasTarget(canvas:Canvas){
        self.currentCanvas = canvas;
    }
    
    func addConstraint(key:String, reference:Emitter, relative:Emitter, targetState:String){
        relative.set(reference);

        states[targetState]!.addConstraintMapping(key,reference: reference, relativeProperty: relative)
    }
    
    func addStateTransition(key:String, reference:Emitter, fromState: String, toState:String){
        states[fromState]!.addStateTransitionMapping(key,reference: reference, toState:toState)
    }
    
    func addMethod(key:String,state:String, methodName:String){
        states[state]!.addMethod(key,methodName:methodName)
    }
    
    
    
    func clone()->Brush{
        let clone = Brush.create(self.name) as! Brush;
        
        clone.reflect = self.reflect;
        clone.penDown = self.penDown;
        clone.position = self.position;
        clone.scaling = self.scaling;
        clone.strokeColor = self.strokeColor;
        clone.fillColor = self.fillColor;
        return clone;
        
    }
    
    /*func set(targetProp:String,value:Any)->Bool{
        switch targetProp{
        case "position":
            self.setPosition(value as! Point)
            return true
        case "weight":
            self.weight = (value as! Float)
            
            return true
        case "penDown":
            self.setPenDown(value as! Bool)
        case "length":
            self.setLength(value as! Float * 100+0.5)
            return true
        case "angle":
            self.setAngle(value as! Float)
            return true
        case "scaling":
            self.setScale(value as! Point)
            return true
        case "scalingAll":
            let s = value as! Float
            
            self.setScale(Point(x:s,y:s))
            return true
        default: break
        }
        
        
        return false;
    }
    
    override func get(targetProp:String)->Any?{
        switch targetProp{
        case "position":
            return self.position
        case "penDown":
            return self.penDown
        case "angle":
            return self.angle
        case "n1":
            return self.n1
        case "n2":
            return self.n2
        case "length":
            return self.length
        case "scaling":
            return self.scaling
            
        default:
            return nil
            
        }
        
    }
    
    func setPosition(value:Point){
            self.prevPosition.set(position);
            self.position.set(value)
    }
    
    func setAngle(value:Float){
        self.angle = value
        self.n1 = angle-90
        self.n2 = angle+90
        
    }
    
    func setLength(value:Float){
        self.length = value;
    }
    
    func setScale(value:Point){
        if(self.scaling == nil){
            self.scaling = value
        }
        else{
            self.scaling.set(value)
        }
    }
    
    func setStrokeColor(value:Color){
        self.strokeColor.setValue(value)
    }
    
    func setReflect(value:Bool){
        self.reflect = value
    }
    
    func setPenDown(value:Bool){
        self.penDown = value
    }*/
    
    
    
    func removeBehavior(key:String){
        for (key, var val) in states {
            if(val.hasKey(key)){
                let removal =  val.removeMapping(key)!
                let data = (self, key, removal.reference)
                removeMappingEvent.raise(data)
                break
            }
        }
    }
    
    //METHODS AVAILABLE TO USER
    
    //
    func newStroke(){
        self.startInterval()

    }
    
    //creates number of clones specified by num and adds them as children
    func spawn(type:String,num:Int) {
        lastSpawned.removeAll()
        for _ in 0...num-1{
            let child = Brush.create(type) as! Brush;
            self.children.append(child);
            child.parent = self;
            let handler = self.children.last!.geometryModified.addHandler(self,handler: Brush.brushDrawHandler)
            childHandlers[child]=[Disposable]();
            childHandlers[child]?.append(handler)
            lastSpawned.append(child)
        }
        
        for key in keyStorage["SPAWN"]!  {
            NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0])
        }
    }
    
    //removes child at an index and returns it
    // removes listener on child, but does not destroy it
    func removeChildAt(index:Int)->Brush{
        let child = self.children.removeAtIndex(index)
        for h in childHandlers[child]!{
            h.dispose()
        }
        childHandlers.removeValueForKey(child)
        return child
    }
    
    
    
    /*func transformDelta(delta:Point)->Point {
        if((self.parent) != nil){
            let newDelta = self.parent!.transformDelta(delta);
            return newDelta;
        }
        else{
            return delta;
        }
    }*/
    
    func destroyChildren(){
        for child in self.children as [Brush] {
            child.destroy();
            
        }
    }
    
    override func destroy() {
        super.destroy();
    }
    
    //END METHODS AVAILABLE TO USER
}


// MARK: Equatable
func ==(lhs:Brush, rhs:Brush) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}



