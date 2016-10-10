//
//  Brush.swift
//  Palette-Knife
//
//  Created by JENNIFER MARY JACOBS on 5/5/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//
import Foundation

class Brush: TimeSeries, WebTransmitter, Hashable{
    
    //hierarcical data
    var children = [Brush]();
    var parent: Brush?
    var lastSpawned = [Brush]();
    
    //dictionary to store expressions for emitter->action handlers
    var states = [String:State]();
    var transitions = [String:StateTransition]();
    var currentState:String
    //dictionary for storing arrays of handlers for children (for later removal)
    var childHandlers = [Brush:[Disposable]]()
    
    //geometric/stylistic properties
    var strokeColor = Color(r:0,g:0,b:0);
    var fillColor = Color(r:0,g:0,b:0);
    var weight = Observable<Float>(5.0)
    var reflectY = Observable<Float>(0)
    var reflectX = Observable<Float>(0)
    var position = Point(x:0,y:0)
    var delta = Point(x:0,y:0)
    var deltaKey = NSUUID().UUIDString;
    
    var xBuffer = CircularBuffer()
    var yBuffer = CircularBuffer()
    var bufferKey = NSUUID().UUIDString;

    var weightBuffer = Buffer()
    var origin = Point(x:0,y:0)
    var x:Observable<Float>
    var y:Observable<Float>
    var dx:Observable<Float>
    var dy:Observable<Float>
    var ox:Observable<Float>
    var oy:Observable<Float>
    var scaling = Point(x:1,y:1)
    var angle = Observable<Float>(0)
    var bufferLimitX = Observable<Float>(0)
    var bufferLimitY = Observable<Float>(0)

    //event Handler wrapper for draw updates
    var drawKey = NSUUID().UUIDString;
    
    var currentCanvas:Canvas?
    var geometryModified = Event<(Geometry,String,String)>()
    var transmitEvent = Event<(String)>()
    let removeMappingEvent = Event<(Brush,String,Observable<Float>)>()
    let removeTransitionEvent = Event<(Brush,String,Emitter)>()
    
    var time = Observable<Float>(0)
    var id = NSUUID().UUIDString;
    var matrix = Matrix();
    var index = Observable<Float>(0) //stores index of child
    
    init(name:String, behaviorDef:BehaviorDefinition?, parent:Brush?, canvas:Canvas){
        self.x = self.position.x;
        self.y = self.position.y;
        self.dx = delta.x;
        self.dy = delta.y
        self.ox = origin.x;
        self.oy = origin.y;
        delta.parentName = "brush"
        self.currentState = "start"
        
        super.init()
        self.name = name;
        self.time = self.timerTime
        
        //setup events and create listener storage
        self.events =  ["SPAWN", "STATE_COMPLETE", "DELTA_BUFFER_LIMIT_REACHED"]
        self.createKeyStorage();
        
        
        //add in default state
        //self.createState(currentState);
        
        //self.addStateTransition(NSUUID().UUIDString, name:"setup", reference: self, fromState: nil, toState: "default")
       
        //setup listener for delta observable
        self.delta.didChange.addHandler(self, handler:Brush.deltaChange, key:deltaKey)
        self.xBuffer.bufferEvent.addHandler(self, handler: Brush.deltaBufferLimitReached, key: bufferKey)
        
        
        self.setCanvasTarget(canvas)
        self.parent = parent
        
        //setup behavior
        if(behaviorDef != nil){
            behaviorDef?.createBehavior(self)
        }
        _  = NSTimer.scheduledTimerWithTimeInterval(0.00001, target: self, selector: #selector(Brush.defaultCallback), userInfo: nil, repeats: false)
    }
    
    
    @objc func defaultCallback(){
        self.transitionToState(self.getTransitionByName("setup")!)
        
    }
    
    
    //MARK: - Hashable
    var hashValue : Int {
        get {
            return "\(self.id)".hashValue
        }
    }
    
    //Event handlers
    //chains communication between brushes and view controller
    func brushDrawHandler(data:(Geometry,String,String),key:String){
        self.geometryModified.raise(data)
    }
    
    func createState(id:String,name:String){
        print("creating state:\(name)");
        states[name] = State(id:id,name:name);
    }
    
    
    func deltaBufferLimitReached(data:(String), key:String){
        print("delta buffer limit reached")
        bufferLimitX.set(1)
    }
    
    
    
    func deltaChange(data:(String,(Float,Float),(Float,Float)),key:String){
        
        let centerX = origin.x.get();
        let centerY = origin.y.get();
        
        self.matrix.reset();
        if(self.parent != nil){
            self.matrix.prepend(self.parent!.matrix)
        }
        var xScale = self.scaling.x.get();
        
        if(self.reflectX.get()==1){
            print("reflecting x axis")

            xScale *= -1.0;
        }
        var yScale = self.scaling.y.get();
        if(self.reflectY.get()==1){
            print("reflecting y axis")
            yScale *= -1.0;
        }
        self.matrix.scale(xScale, y: yScale, centerX: centerX, centerY: centerY);
        self.matrix.rotate(self.angle.get(), centerX: centerX, centerY: centerY)
        let _dx = self.position.x.get()+delta.x.get();
        let _dy = self.position.y.get()+delta.y.get();
        
        let transformedCoords = self.matrix.transformPoint(_dx, y: _dy)
        
        xBuffer.push(delta.x.get());
        yBuffer.push(delta.y.get());
        bufferLimitX.set(0)
        bufferLimitY.set(0)

        weightBuffer.push(weight.get());
        self.currentCanvas!.currentDrawing!.addSegmentToStroke(self.id, point:Point(x:transformedCoords.0,y:transformedCoords.1),weight: self.weight.get());
        self.position.set(_dx,y:_dy);
        
    }
    
    
    func setOrigin(p:Point){
        print("setting origin for \(self.name) to \(p.get())")
        self.origin.set(p);
        self.position.set(origin)
        
    }
    
    dynamic func stateTransitionHandler(notification: NSNotification){
        
        let key = notification.userInfo?["key"] as! String
        let mapping = states[currentState]?.getTransitionMapping(key)

        print("state transition called, mapping = \(mapping,currentState,states[currentState]?.transitions, key)")
       
        if(mapping != nil){
            let stateTransition = mapping
      
            self.raiseBehaviorEvent(stateTransition!.toJSON(), event: "transition")
            self.transitionToState(stateTransition!)
            
        }
    }
    
    func transitionToState(transition:StateTransition){
        var constraint_mappings =  states[currentState]!.constraint_mappings
        for (_, value) in constraint_mappings{
        
            self.setConstraint(value)
            value.relativeProperty.constrained = false;
            
        }
        self.currentState = transition.toState;
        self.raiseBehaviorEvent(states[currentState]!.toJSON(), event: "state")

        
        print("transitioning \(self.name) to \(transition.toState)")
        constraint_mappings =  states[currentState]!.constraint_mappings
        for (_, value) in constraint_mappings{
            
            value.relativeProperty.constrained = true;
            
            //self.setConstraint(value)
            
        }
        //execute methods
        self.executeTransitionMethods(transition.methods)
        //check constraints
        
        //trigger state complete after functions are executed
        
        _  = NSTimer.scheduledTimerWithTimeInterval(0.00001, target: self, selector: #selector(Brush.completeCallback), userInfo: nil, repeats: false)
        
    }
    
    func raiseBehaviorEvent(d:String, event:String){
        var data = "{\"brush_id\":\""+self.id+"\","
        data += "\"event\":\""+event+"\",";
        data += "\"type\":\"behavior_change\","
        data += "\"data\":"+d;
        data += "}"
        self.transmitEvent.raise(data);
    }
    
    @objc func completeCallback(){
        for key in self.keyStorage["STATE_COMPLETE"]!  {
            if(key.1 != nil){
                let condition = key.1;
                if(condition.evaluate()){
                    NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0,"event":"STATE_COMPLETE"])
                }
            }
            else{
                 NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0,"event":"STATE_COMPLETE"])
            }
            
        }
    }
    
    
    
    func executeTransitionMethods(methods:[Method]){
        
        for i in 0..<methods.count{
            let method = methods[i];
            let methodName = method.name;
            switch (methodName){
            case "newStroke":
                self.newStroke();
                break;
            case "setOrigin":
                self.setOrigin(method.arguments![0] as! Point)
            case "destroy":
                self.destroy();
                break;
            case "spawn":
                print("spawn called")
                self.spawn((method.arguments![0] as! String), behavior:(method.arguments![1] as! BehaviorDefinition),num:(method.arguments![2] as! Int));
                break;
            case "bake":
                self.bake();
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
    
    func addConstraint(id:String,reference:Observable<Float>, relative:Observable<Float>, targetState:String){
        //let stateKey = NSUUID().UUIDString;
        reference.didChange.addHandler(self, handler:  Brush.setHandler, key:id)
        self.removeMappingEvent.addHandler(self, handler: Brush.removeConstraint,key:id)
        states[targetState]!.addConstraintMapping(id,reference:reference,relativeProperty: relative)
    }
    
    func removeConstraint(data:(Brush, String, Observable<Float>),key:String){
        data.2.didChange.removeHandler(key)
    }
    
    
    
    
    //setHandler: triggered when constraint is changed, evaluates if brush is in correct state to encact constraint
    func setHandler(data:(String,Float,Float),stateKey:String){
        // let reference = notification.userInfo?["emitter"] as! Emitter
        
        let mapping = states[currentState]?.getConstraintMapping(stateKey)
        
        if(mapping != nil){
            
            //let constraint = mapping as! Constraint
            self.setConstraint(mapping!)
        }
    }
    
    func setConstraint(constraint:Constraint){
        constraint.relativeProperty.set(constraint.reference.get());
  
        
        
    }
    
    func addStateTransition(id:String, name:String, reference:Emitter, fromStateName: String, toStateName:String){
        
        let transition:StateTransition
       
        var state = self.getStateByName(fromStateName);
            print("state by name\(state,fromStateName)")
            transition = state!.addStateTransitionMapping(id,name:name,reference: reference, toState:toStateName)
        self.transitions[id] = transition;
    }
    
    func removeStateTransition(data:(Brush, String, Emitter),key:String){
        NSNotificationCenter.defaultCenter().removeObserver(data.0, name: data.1, object: data.2)
        data.2.removeKey(data.1)
    }
    
    func addMethod(transitionName:String, methodId:String, methodName:String, arguments:[Any]?){
        let transition = self.getTransitionByName(transitionName);
        if(transition != nil){
            transition!.addMethod(methodId, name:methodName,arguments:arguments)
        }
        
    }
    
    func getTransitionByName(name:String)->StateTransition?{
        for(_,transition) in self.transitions{
            if(transition.name == name){
                return transition;
            }
        }
        return nil
    }
    
    func getStateByName(name:String)->State?{
        print("states \(states)");
        for(_,state) in self.states{
            if(state.name == name){
                return state;
            }
        }
        return nil
    }
    
    
    /*
     TODO: Finish implementing clone
     func clone()->Brush{
     let clone = Brush(behaviorDef: nil, parent: self.parent, canvas: self.currentCanvas)
     
     clone.reflectX = self.reflectX;
     clone.reflectY = self.reflectY;
     clone.position = self.position.clone();
     clone.scaling = self.scaling.clone();
     clone.strokeColor = self.strokeColor;
     clone.fillColor = self.fillColor;
     return clone;
     
     }*/
    
    
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
                removeTransitionEvent.raise(data)
                break
            }
        }
    }
    
    //METHODS AVAILABLE TO USER
    
    
    
    func newStroke(){
        self.startInterval()
        
        currentCanvas!.currentDrawing!.retireCurrentStrokes(self.id)
        currentCanvas!.currentDrawing!.newStroke(self.id);
    }
    
    //creates number of clones specified by num and adds them as children
    func spawn(name:String,behavior:BehaviorDefinition,num:Int) {
        lastSpawned.removeAll()
        for i in 0...num-1{
            print("at spawn, buffer length = \(self.xBuffer.val.count)")
            let child = Brush(name:name, behaviorDef: behavior, parent:self, canvas:self.currentCanvas!)
            self.children.append(child);
            child.index.set(Float(self.children.count-1));
            let handler = self.children.last!.geometryModified.addHandler(self,handler: Brush.brushDrawHandler, key:child.drawKey)
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
    
    
    
    func destroyChildren(){
        for child in self.children as [Brush] {
            child.destroy();
            
        }
    }
    
    override func destroy() {
        currentCanvas!.currentDrawing!.retireCurrentStrokes(self.id)
        super.destroy();
    }
    
    //sends the current strokes in the bake queue as gcode to the server
    func bake(){
        self.currentCanvas!.currentDrawing!.bakeAllStrokesInQueue();
    }
    
    //END METHODS AVAILABLE TO USER
}


// MARK: Equatable
func ==(lhs:Brush, rhs:Brush) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}



