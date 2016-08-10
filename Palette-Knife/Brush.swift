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
    var origin: PointEmitter?
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
    
    required init(behaviorDef:BehaviorDefinition?, parent:Brush?, canvas:Canvas){
        self.x = self.position.x;
        self.y = self.position.y;
        
        self.currentState = "default"

        super.init()
        self.name = "brush"
        self.time = self.timerTime
        
        //setup events and create listener storage
        self.events =  ["SPAWN", "STATE_COMPLETE"]
        self.createKeyStorage();
        
        
        //add in default state
        self.createState(currentState);
        
        //add in default stop state with destroy method
        //self.createState("stop");
        //let destroy_key = NSUUID().UUIDString;
        //self.addMethod(destroy_key, state: "stop", methodName: "destroy", arguments: nil)
        
        
        self.setCanvasTarget(canvas)
        let selector = Selector("positionChange"+":");
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:selector, name:positionKey, object: self.position)
        self.position.assignKey("CHANGE",key: positionKey,eventCondition: nil)
        self.parent = parent
        
        if(behaviorDef != nil){
            behaviorDef?.createBehavior(self)
        }
            _  = NSTimer.scheduledTimerWithTimeInterval(0.00001, target: self, selector: #selector(Brush.defaultCallback), userInfo: nil, repeats: false)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    @objc func defaultCallback(){
        self.transitionToState(currentState)

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
      print("set handler change called for state \(self.currentState), self.name and mapping: \(self.name,key,mapping != nil,notification.userInfo?["event"])")
        
        if(mapping != nil){
            print("set handler change initiated for state \(self.currentState)")

            let constraint = mapping as! Constraint
            self.setConstraint(constraint)
                   }
    }
    
    func setConstraint(constraint:Constraint){
        constraint.relativeProperty.set(constraint.reference);

    }
    
    
    dynamic func positionChange(notification: NSNotification){
        print("position change called\(position.x.get(),position.y.get())")
        if(origin == nil){
            origin = self.position.clone();
            print("generating new origin for \(self.name,origin!.x.get(),origin!.y.get())")

        }
        //if(self.parent != nil){
            //print("parent angle = \(self.parent!.id, self.parent!.angle.get())")
        //}
        self.prevPosition.set(position.prevX,y: position.prevY);
        let pos = self.position.clone()//self.position.rotate(self.angle.get())
        let rpos = self.position.rotate(self.angle.get(),origin:self.origin!)
        print("angle = \(self.angle.get()) rpos =\(rpos.x.get(),rpos.y.get()) pos= \(pos.x.get(),pos.y.get())")
        self.currentCanvas!.currentDrawing!.addSegmentToStroke(self.id, point:rpos,weight: self.weight.get());
        
        
    }
    
    dynamic func stateTransitionHandler(notification: NSNotification){
        
        let key = notification.userInfo?["key"] as! String
        let mapping = states[currentState]?.getTransitionMapping(key)
        print("\n\ntransition to state called for mapping =\(mapping != nil), from state:\(currentState), for object named:\(self.name), from notifcation \(notification.userInfo?["event"])\n\n")
        
        if(mapping != nil){
            let stateTransition = mapping as! StateTransition
            print("\n\n making transition \(self.name, stateTransition.toState)")

            self.transitionToState(stateTransition.toState)
            
        }
    }
    
    func transitionToState(state:String){
        print("transition to state called for \(self.name) to state: \(state) \n\n\n\n")
        var constraint_mappings =  states[currentState]!.constraint_mappings
        //print("position change called constraint_mappings \(constraint_mappings.count,state,currentState)")
        for (key, value) in constraint_mappings{
           

            self.setConstraint(value)
            //print("clearing constraints on old state \(self.currentState,value.relativeProperty.constrained)")
            value.relativeProperty.constrained = false;

            
        }
        self.currentState = state
        constraint_mappings =  states[currentState]!.constraint_mappings
        for (_, value) in constraint_mappings{
            value.relativeProperty.constrained = true;

            //self.setConstraint(value)

        }
        //execute methods
        print("executed methods, name \(self.name) state \(self.currentState))")
        self.executeStateMethods()
        //check constraints
        
        //trigger state complete after functions are executed
        
        _  = NSTimer.scheduledTimerWithTimeInterval(0.00001, target: self, selector: #selector(Brush.completeCallback), userInfo: nil, repeats: false)
        
    }
    
    @objc func completeCallback(){
        for key in self.keyStorage["STATE_COMPLETE"]!  {
            NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0,"event":"STATE_COMPLETE"])
            
        }
    }
    
    
    
    func executeStateMethods(){
        let methods = self.states[currentState]!.methods
        print("transition made, methods to execute \(self.name, methods)")

        for i in 0..<methods.count{
            let methodName = methods[i];
            switch (methodName.0){
            case "newStroke":
                self.newStroke();
                break;
            case "destroy":
                print("executed destroy for \(self.name)")
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
        //print("adding state transition \(key) from \(reference) from \(fromState) to \(toState)")
        
        states[fromState]!.addStateTransitionMapping(key,reference: reference, toState:toState)
        
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
        //print("creating new stroke")
        self.startInterval()

        if(origin != nil){
        var oldOriginX = origin!.x.get();
        var oldOriginY = origin!.y.get();
        print("retiring origin for \(self.name, oldOriginX,oldOriginY)")
        self.origin = nil

        }
        currentCanvas!.currentDrawing!.retireCurrentStrokes(self.id)
        currentCanvas!.currentDrawing!.newStroke(self.id);
    }
    
    //creates number of clones specified by num and adds them as children
    func spawn(behavior:BehaviorDefinition,num:Int) {
        lastSpawned.removeAll()
        //print("SPAWN change called \(self.children.count)")
        for _ in 0...num-1{
            let child = Brush(behaviorDef: behavior, parent:self, canvas:self.currentCanvas!)
            self.children.append(child);
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
        print("destroying \(self.name)")
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
        currentCanvas!.currentDrawing!.retireCurrentStrokes(self.id)
        super.destroy();
    }
    
    //END METHODS AVAILABLE TO USER
}


// MARK: Equatable
func ==(lhs:Brush, rhs:Brush) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}



