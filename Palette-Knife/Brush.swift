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
    var x:FloatEmitter
    var y:FloatEmitter
    var prevPosition = PointEmitter(x:0,y:0)
    var penDown = false;
    var scaling = PointEmitter(x:1,y:1)
    var angle = FloatEmitter(val:0)
    var n1:Float!
    var n2:Float!
    var length:Float!
  
    var currentCanvas:Canvas?
    var geometryModified = Event<(Geometry,String,String)>()
    var transmitEvent = Event<(String)>()
    let removeMappingEvent = Event<(Brush,String,Emitter)>()
    let positionKey = NSUUID().UUIDString;
    var time = FloatEmitter(val:0)
    var id = NSUUID().UUIDString;
    
    required init(behaviorDef:BehaviorDefinition?, canvas:Canvas){
        self.currentState = "default"
        self.x = self.position.x;
        self.y = self.position.y;
        super.init()
        self.name = "brush"
        self.time = self.timerTime
        self.events =  ["SPAWN", "STATE_COMPLETE"]
        self.createKeyStorage();
        self.createState(currentState);
        self.setCanvasTarget(canvas)
        let selector = Selector("positionChange"+":");
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:selector, name:positionKey, object: self.position)
        self.position.assignKey("CHANGE",key: positionKey,eventCondition: nil)
        if(behaviorDef != nil){
            behaviorDef?.createBehavior(self)
        }
        //TODO: no idea why this is needed- is hack for having state transitions working correctly
        //self.addStateTransition(NSUUID().UUIDString, reference: self, fromState: "default", toState: "default")
        self.startInterval()
        
        self.transitionToState(currentState)
    }
    
    required init() {
        fatalError("init() has not been implemented")
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
        
       // let reference = notification.userInfo?["emitter"] as! Emitter
        
        let key = notification.userInfo?["key"] as! String
        let mapping = states[currentState]?.getConstraintMapping(key)
       // print("set handler change called \(self.name,key,mapping != nil,currentState,notification.userInfo?["event"])")
        
        if(mapping != nil){
            let constraint = mapping as! Constraint
            self.setConstraint(constraint)
                   }
    }
    
    func setConstraint(constraint:Constraint){
        print("setting change called relative \(constraint.relativeProperty.get(), constraint.relativeProperty.name) to reference \(constraint.reference.get(),constraint.reference.name)")
        constraint.relativeProperty.set(constraint.reference);

    }
    
    
    dynamic func positionChange(notification: NSNotification){
        print("position change called\(position.x.get(),position.y.get())")
        //  print("stylus position \(stylus.position.x.get(),stylus.position.y.get()))")
        
        self.prevPosition.set(position.prevX,y: position.prevY);
        print("canvas, drawing \( self.currentCanvas, self.name)")
        self.currentCanvas!.currentDrawing!.addSegmentToStroke(self.position.clone(),weight: self.weight.get());
        self.angle.set(self.position.sub(self.prevPosition).angle)
        
        
    }
    
    dynamic func stateTransitionHandler(notification: NSNotification){
        
        let key = notification.userInfo?["key"] as! String
        let mapping = states[currentState]?.getTransitionMapping(key)
        //print("transition to state called \(mapping != nil,currentState,self.name,notification.userInfo?["event"])")
        
        if(mapping != nil){
            print("making transition \(self.name)")
            let stateTransition = mapping as! StateTransition
            self.transitionToState(stateTransition.toState)
            
        }
    }
    
    func transitionToState(state:String){
        let constraint_mappings =  states[currentState]!.constraint_mappings
        print("position change called constraint_mappings \(constraint_mappings.count,state,currentState)")
        for (_, value) in constraint_mappings{
           

            self.setConstraint(value)
        }
        self.currentState = state
        //execute methods
        self.executeStateMethods()
        //check constraints
        
        //trigger state complete after functions are executed
        print("listeners for state complete transition: \(self.name, self.keyStorage["STATE_COMPLETE"]!.count)")
        for key in self.keyStorage["STATE_COMPLETE"]!  {
            NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0,"event":"STATE_COMPLETE"])
            
        }
    }
    
    
    
    func executeStateMethods(){
        let methods = self.states[currentState]!.methods
        for i in 0..<methods.count{
            let methodName = methods[i];
            switch (methodName.0){
            case "newStroke":
                self.newStroke();
                break;
            case "destroy":
                self.destroy();
                break;
            case "spawn":
                self.spawn((methodName.1![0] as! BehaviorDefinition),num:(methodName.1![1] as! Int));
                break;
            default:
                break;
            }
        }
        
    }
    
    //sets canvas target to output geometry into
    func setCanvasTarget(canvas:Canvas){
        self.currentCanvas = canvas;
    }
    
    func addConstraint(key:String, reference:Emitter, relative:Emitter, targetState:String){
        states[targetState]!.addConstraintMapping(key,reference:reference,relativeProperty: relative)
    }
    
    func addStateTransition(key:String, reference:Emitter, fromState: String, toState:String){
        print("adding state transition \(key) from \(reference) from \(fromState) to \(toState)")
        //if(reference != self){
        states[fromState]!.addStateTransitionMapping(key,reference: reference, toState:toState)
        //}
    }
    
    func addMethod(key:String,state:String, methodName:String, arguments:[Any]?){
        states[state]!.addMethod(key,methodName:methodName,arguments:arguments)
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
    
    
    func removeConstraint(key:String){
        for (key, var val) in states {
            if(val.hasConstraintKey(key)){
                let removal =  val.removeConstraintMapping(key)
                let data = (self, key, removal!.reference)
                removeMappingEvent.raise(data)
                break
            }
        }
    }
    
    func removeTransition(key:String){
        for (key, var val) in states {
            if(val.hasTransitionKey(key)){
                let removal =  val.removeTransitionMapping(key)!
                let data = (self, key, removal.reference)
                removeMappingEvent.raise(data)
                break
            }
        }
    }
    
    //METHODS AVAILABLE TO USER
    
    
    
    func newStroke(){
        print("creating new stroke")
        currentCanvas!.newStroke();
    }
    
    //creates number of clones specified by num and adds them as children
    func spawn(behavior:BehaviorDefinition,num:Int) {
        lastSpawned.removeAll()
        print("SPAWN change called \(self.children.count)")
        for _ in 0...num-1{
            let child = Brush(behaviorDef: behavior, canvas:self.currentCanvas!)
            self.children.append(child);
            child.parent = self;
            let handler = self.children.last!.geometryModified.addHandler(self,handler: Brush.brushDrawHandler)
            childHandlers[child]=[Disposable]();
            childHandlers[child]?.append(handler)
            lastSpawned.append(child)
        }
        
        for key in keyStorage["SPAWN"]!  {
            NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0,"event":"SPAWN"])
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



