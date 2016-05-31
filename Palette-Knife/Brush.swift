//
//  Brush.swift
//  Palette-Knife
//
//  Created by JENNIFER MARY JACOBS on 5/5/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation


class Brush: Factory, Hashable{
   
    //hierarcical data
    var parent: Brush?
    var children = [Brush]();
    
    //dictionary to store expressions for emitter->action handlers
    var behavior_mappings = [String:(Emitter,String,String)]();
    
    //dictionary for storing arrays of handlers for children (for later removal)
    var childHandlers = [Brush:[Disposable]]()
   
    //geometric/stylistic properties
    var strokeColor = Color(r:0,g:0,b:0);
    var fillColor = Color(r:0,g:0,b:0);
    var reflect = false;
    var position: Point!;
    var prevPosition: Point!;
    var penDown = false;
    var scaling = Point(x:1,y:1);
    var name = "Brush"
    var geometryModified = Event<(Geometry,String,String)>()
    let removeMappingEvent = Event<(Brush,String,Emitter)>()
    let id = NSUUID().UUIDString;
    
    required init(){
        super.init()
        self.events =  ["SPAWN"]
        self.createKeyStorage();
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
    
    //NS Notification handlers
    // communication between emitter and brush
    
    
    // setHandler: recieves  expression in the form of "propertyA:propertyB" which is used to determine mapping for set action
    dynamic func setHandler(notification: NSNotification){
        let emitter = notification.userInfo?["emitter"] as! Emitter
        let key = notification.userInfo?["key"] as! String
        let mapping = behavior_mappings[key]
        let expression = mapping!.2
        let emitterProp = expression.componentsSeparatedByString(":")[0]
        let targetProp = expression.componentsSeparatedByString(":")[1]
        self.set(targetProp,value: emitter[emitterProp])

    }
    
    dynamic func setChildHandler(notification:NSNotification){
       let spawned = self.children.last as! ArcBrush;
       spawned.setPosition()

    }
    
    dynamic func spawnHandler(notification:NSNotification){
        let emitter = notification.userInfo?["emitter"] as! Emitter
        let key = notification.userInfo?["key"] as! String
        let mapping = behavior_mappings[key]
        let expression = mapping!.2
        let type = expression.componentsSeparatedByString(":")[0]
        self.spawn(type)
        
    }
    
    func addBehavior(key:String, selector:String, emitter: Emitter, expression:String?){
        if(expression != nil){
            behavior_mappings[key] = (emitter,selector,expression!)
        }
        else{
            behavior_mappings[key] = (emitter,selector,"")
        }
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
    
    func set(targetProp:String,value:Any){
        switch targetProp{
            case "position":
                self.setPosition(value as! Point)
            break
            case "penDown":
                self.setPenDown(value as! Bool)
            break

        default:
            
            break
        }
    }
    
    func setPosition(value:Point){
        if(self.position != nil){
            self.prevPosition = self.position;
            self.position.setValue(value)

        }
        else{
            self.position = value;
        }
    }
    
    func setScale(value:Point){
        self.scaling.setValue(value)
    }
    
    func setStrokeColor(value:Color){
        self.strokeColor.setValue(value)
    }
    
    func setReflect(value:Bool){
        self.reflect = value
    }
    
    func setPenDown(value:Bool){
        self.penDown = value
    }
    
  
    
    func removeBehavior(key:String){
        let removal =  behavior_mappings.removeValueForKey(key)!
        let data = (self, key, removal.0)
        removeMappingEvent.raise(data);
    }
    
    //creates number of clones specified by num and adds them as children
    func spawn(type:String) {
        let child = Brush.create(type) as! Brush;
        self.children.append(child);
        let handler = self.children.last!.geometryModified.addHandler(self,handler: Brush.brushDrawHandler)
        childHandlers[child]=[Disposable]();
        childHandlers[child]?.append(handler)
        
        for key in keyStorage["SPAWN"]!  {
            NSNotificationCenter.defaultCenter().postNotificationName(key, object: self, userInfo: ["emitter":self,"key":key])
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
    
    //move(point): point should be a vector (i.e mouse delta). Transforms point in accordance with current geometric properties
    func move(point:Point) {
        let d = self.transformDelta(point);
        self.position = self.position.add(d);
    }
    
    
    func transformDelta(delta:Point)->Point {
        if((self.parent) != nil){
            let newDelta = self.parent!.transformDelta(delta);
            return newDelta;
        }
        else{
            return delta;
        }
    }
    
    func destroyChildren(){
        for child in self.children as [Brush] {
            child.destroy();
            
        }
    }
    
    func destroy() {
       
    }
}


// MARK: Equatable
func ==(lhs:Brush, rhs:Brush) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

    

