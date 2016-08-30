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
    func brushDrawHandler(data:(Geometry,String,String),key:String){
        self.geometryModified.raise(data)
    }
    
    func createState(name:String){
        
        states[name] = State();
    }
    
    
    
    
    func deltaChange(data:(String,(Float,Float),(Float,Float)),key:String){
        print("delta change called for \(self.name) delta:\(delta.x.get(),delta.y.get(),angle.get())")
        
        let centerX = origin.x.get();
        let centerY = origin.y.get();
        
        self.matrix.reset();
        if(self.parent != nil){
            self.matrix.prepend(self.parent!.matrix)
        }
        var xScale = self.scaling.x.get();
        print("reflection on the x axis \(self.reflectX),reflection on the y axis \(self.reflectY), \(self.name)")

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
                 print("brush position currently is \(transformedCoords.0,transformedCoords.1)")
       
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
        print("\n\ntransition to state called for mapping =\(mapping != nil), from state:\(currentState), for object named:\(self.name), from notifcation \(notification.userInfo?["event"])\n\n")
        
        if(mapping != nil){
            let stateTransition = mapping
          
            print("\n\n making transition \(self.name, stateTransition!.toState)")
            
            self.transitionToState(stateTransition!.toState)
            
        }
    }
    
    func transitionToState(state:String){
        print("transition to state called for \(self.name) to state: \(state) \n\n\n\n")
        var constraint_mappings =  states[currentState]!.constraint_mappings
        //print("position change called constraint_mappings \(constraint_mappings.count,state,currentState)")
        for (_, value) in constraint_mappings{
            
            self.setConstraint(value)
            //print("clearing constraints on old state \(self.currentState,value.relativeProperty.constrained)")
            value.relativeProperty.constrained = false;
                        print("toggling constraint off for \(value.relativeProperty.name, value.relativeProperty.constrained)")
            
        }
        print("\(self.name) current position at transition to \(state) = \(self.position.x,self.position.y)")
        self.currentState = state
        constraint_mappings =  states[currentState]!.constraint_mappings
        for (_, value) in constraint_mappings{

            value.relativeProperty.constrained = true;
                        print("toggling constraint for \(value.relativeProperty.name, value.relativeProperty.constrained)")
            
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
            //check to see if there's a conditional on the method, 
            //and return if it evaluates to false
            if(methods[i].2 != nil){
                print("condition to evaluate for method \(methodName.0)");
                if(!methods[i].2!.evaluate()){
                    print("condition to evaluate for method \(methodName.0) is false");

                    return;
                }
                print("condition to evaluate for method \(methodName) is true");

            }
            switch (methodName.0){
            case "newStroke":
                self.newStroke();
                break;
            case "setOrigin":
                self.setOrigin(methodName.1![0] as! Point)
            case "destroy":
                print("executed destroy for \(self.name)")
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
        print("self handler called for \(data.0)")
     // let reference = notification.userInfo?["emitter"] as! Emitter
     
     let mapping = states[currentState]?.getConstraintMapping(stateKey)
     //print("set handler change called for state \(self.currentState), self.name and mapping: \(self.name,key,mapping != nil,notification.userInfo?["event"])")
     
     if(mapping != nil){
     //print("set handler change initiated for state \(self.currentState)")
     
     //let constraint = mapping as! Constraint
        self.setConstraint(mapping!)
     }
     }
    
    func setConstraint(constraint:Constraint){
        constraint.relativeProperty.set(constraint.reference.get());
    }
    
    func addStateTransition(key:String, reference:Emitter, fromState: String, toState:String){
        //print("adding state transition \(key) from \(reference) from \(fromState) to \(toState)")
        
        states[fromState]!.addStateTransitionMapping(key,reference: reference, toState:toState)
        
    }
    
    func removeStateTransition(data:(Brush, String, Emitter),key:String){
        NSNotificationCenter.defaultCenter().removeObserver(data.0, name: data.1, object: data.2)
        data.2.removeKey(data.1)
    }
    
    func addMethod(key:String,state:String, methodName:String, arguments:[Any]?, condition:Condition?){
        states[state]!.addMethod(key,methodName:methodName,arguments:arguments,condition:condition)
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
        print("creating new stroke for \(self.name)")
        self.startInterval()
        
        currentCanvas!.currentDrawing!.retireCurrentStrokes(self.id)
        currentCanvas!.currentDrawing!.newStroke(self.id);
    }
    
    //creates number of clones specified by num and adds them as children
    func spawn(behavior:BehaviorDefinition,num:Int,reflectX:[Bool], reflectY:[Bool]) {
        lastSpawned.removeAll()
        //print("SPAWN change called \(self.children.count)")
        for i in 0...num-1{
            let child = Brush(behaviorDef: behavior, parent:self, canvas:self.currentCanvas!)
            child.setOrigin(self.position)
            child.reflectX = reflectX[i]
            child.reflectY = reflectY[i]
            self.children.append(child);
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
        print("destroying \(self.name)")
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



