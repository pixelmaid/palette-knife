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
    var reflectY = false;
    var reflectX = false;
    var position = Point(x:0,y:0)
    var delta = Point(x:0,y:0)
    var deltaKey = NSUUID().UUIDString;
    
    var xBuffer = Buffer()
    var yBuffer = Buffer()
    var weightBuffer = Buffer()
    var origin = Point(x:0,y:0)
    var x:Observable<Float>
    var y:Observable<Float>
    var dx:Observable<Float>
    var dy:Observable<Float>
    var scaling = Point(x:1,y:1)
    var angle = Observable<Float>(0)
    var length:Float!
    
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
    var index = -1; //stores index of child
    
    init(behaviorDef:BehaviorDefinition?, parent:Brush?, canvas:Canvas){
        self.x = self.position.x;
        self.y = self.position.y;
        self.dx = delta.x;
        self.dy = delta.y
        delta.parentName="brush"
        self.currentState = "default"
        
        super.init()
        self.name = "brush"
        self.time = self.timerTime
        
        //setup events and create listener storage
        self.events =  ["SPAWN", "STATE_COMPLETE"]
        self.createKeyStorage();
        
        
        //add in default state
        self.createState(currentState);
        
        self.addStateTransition("start", key: NSUUID().UUIDString, reference: self, fromState: nil, toState: "default")
       
        //setup listener for delta observable
        self.delta.didChange.addHandler(self, handler:Brush.deltaChange, key:deltaKey)
        
        self.setCanvasTarget(canvas)
        self.parent = parent
        
        //setup behavior
        if(behaviorDef != nil){
            behaviorDef?.createBehavior(self)
        }
        _  = NSTimer.scheduledTimerWithTimeInterval(0.00001, target: self, selector: #selector(Brush.defaultCallback), userInfo: nil, repeats: false)
    }
    
    
    @objc func defaultCallback(){
        self.transitionToState(self.transitions["start"]!)
        
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
    
    func createState(name:String){
        
        states[name] = State();
    }
    
    
    
    
    func deltaChange(data:(String,(Float,Float),(Float,Float)),key:String){
        
        let centerX = origin.x.get();
        let centerY = origin.y.get();
        
        self.matrix.reset();
        if(self.parent != nil){
            self.matrix.prepend(self.parent!.matrix)
        }
        var xScale = self.scaling.x.get();
        
        if(self.reflectX){
            xScale *= -1.0;
        }
        var yScale = self.scaling.y.get();
        if(self.reflectY){
            yScale *= -1.0;
        }
        self.matrix.scale(xScale, y: yScale, centerX: centerX, centerY: centerY);
        self.matrix.rotate(self.angle.get(), centerX: centerX, centerY: centerY)
        let _dx = self.position.x.get()+delta.x.get();
        let _dy = self.position.y.get()+delta.y.get();
        
        let transformedCoords = self.matrix.transformPoint(_dx, y: _dy)
        
        xBuffer.push(delta.x.get());
        yBuffer.push(delta.y.get());
        weightBuffer.push(weight.get());
        self.currentCanvas!.currentDrawing!.addSegmentToStroke(self.id, point:Point(x:transformedCoords.0,y:transformedCoords.1),weight: self.weight.get());
        self.position.set(_dx,y:_dy);
        
    }
    
    
    func setOrigin(p:Point){
        origin = p.clone();
        self.position.set(origin)
        
    }
    
    dynamic func stateTransitionHandler(notification: NSNotification){
        
        let key = notification.userInfo?["key"] as! String
        let mapping = states[currentState]?.getTransitionMapping(key)
        
        if(mapping != nil){
            let stateTransition = mapping
            
            
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
    
    @objc func completeCallback(){
        for key in self.keyStorage["STATE_COMPLETE"]!  {
            NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0,"event":"STATE_COMPLETE"])
            
        }
    }
    
    
    
    func executeTransitionMethods(methods:[(String,[Any]?)]){
        
        for i in 0..<methods.count{
            let methodName = methods[i];
            switch (methodName.0){
            case "newStroke":
                self.newStroke();
                break;
            case "setOrigin":
                self.setOrigin(methodName.1![0] as! Point)
            case "destroy":
                self.destroy();
                break;
            case "spawn":
                self.spawn((methodName.1![0] as! BehaviorDefinition),num:(methodName.1![1] as! Int),reflectX:methodName.1![2] as! [Bool], reflectY:methodName.1![3] as! [Bool]);
                
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
    
    func addConstraint(reference:Observable<Float>, relative:Observable<Float>, targetState:String){
        let stateKey = NSUUID().UUIDString;
        reference.didChange.addHandler(self, handler:  Brush.setHandler, key:stateKey)
        self.removeMappingEvent.addHandler(self, handler: Brush.removeConstraint,key:stateKey)
        
        states[targetState]!.addConstraintMapping(stateKey,reference:reference,relativeProperty: relative)
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
    
    func addStateTransition(name:String, key:String, reference:Emitter, fromState: String?, toState:String){
        
        let transition:StateTransition
        if(fromState != nil){
         transition = states[fromState!]!.addStateTransitionMapping(name, key:key,reference: reference, toState:toState)
        }
        else{
            transition = StateTransition(name: name, reference: reference, toState: toState)
        }
        self.transitions[name] = transition;
    }
    
    func removeStateTransition(data:(Brush, String, Emitter),key:String){
        NSNotificationCenter.defaultCenter().removeObserver(data.0, name: data.1, object: data.2)
        data.2.removeKey(data.1)
    }
    
    func addMethod(transitionName:String, methodName:String, arguments:[Any]?){
        transitions[transitionName]!.addMethod(methodName,arguments:arguments)
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
    func spawn(behavior:BehaviorDefinition,num:Int,reflectX:[Bool], reflectY:[Bool]) {
        lastSpawned.removeAll()
        for i in 0...num-1{
            let child = Brush(behaviorDef: behavior, parent:self, canvas:self.currentCanvas!)
            child.setOrigin(self.position)
            // child.reflectX = reflectX[i]
            //child.reflectY = reflectY[i]
            self.children.append(child);
            child.index = self.children.count-1;
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
    
    //END METHODS AVAILABLE TO USER
}


// MARK: Equatable
func ==(lhs:Brush, rhs:Brush) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}



