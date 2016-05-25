//
//  Brush.swift
//  Palette-Knife
//
//  Created by JENNIFER MARY JACOBS on 5/5/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation




class Brush: Factory, Equatable {
    var children = [Brush]();
    var strokes = [Stroke]();
    var parent: Brush?
    var behavior_mappings = [String:(Emitter,String,String)]();
    
    //geometric/stylistic properties
    var strokeColor = Color(r:0,g:0,b:0);
    var fillColor = Color(r:0,g:0,b:0);

    var reflect = false;
    var penDown = false;
    var position = Point(x:0,y:0);
    var scaling = Point(x:1,y:1);
    var name = "Brush"
    var drawEvent = Event<(Brush)>()
    let removeMappingEvent = Event<(Brush,String,Emitter)>()
    
    required init(){
        super.init()
        self.events =  ["SPAWN"]
        self.createKeyStorage();
    }
    
    func testHandler (data:(Point,Float,Float)){
        print("test handler triggered by\(data.0,data.1,data.2)");
    }
    
    dynamic func notificationHandler(notification: NSNotification){
        let emitter = notification.userInfo?["emitter"]
        //print("notification\(emitter)")
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
    
    func setValue(args:BrushProperties){
        
        if ((args.strokeColor) != nil) {
            self.strokeColor=(args.strokeColor)!;
        }
        if ((args.reflect) != nil) {
            self.reflect=(args.reflect)!;
        }
        if ((args.penDown) != nil) {
            self.penDown=(args.penDown)!;
        }
        if ((args.position) != nil) {
            self.position=(args.position)!;
        }
        if ((args.scaling) != nil) {
            self.scaling=(args.scaling)!;
        }
        if((args.children) != nil){
            for (index, data ) in args.children! {
                self.children[index].setValue(data);
            }
        }
    }
    
    func setPosition(value:Point){
        self.position.setValue(value)
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
    
    func addBehavior(key:String, selector:String, emitter: Emitter, expression:String?){
        if(expression != nil){
            behavior_mappings[key] = (emitter,selector,expression!)
        }
        else{
            behavior_mappings[key] = (emitter,selector,"")
        }
    }
    
    func removeBehavior(key:String){
        let removal =  behavior_mappings.removeValueForKey(key)!
        let data = (self, key, removal.0)
        removeMappingEvent.raise(data);
    }
    
    //creates number of clones specified by num and adds them as children
    func spawn(num:Int, args:[BrushProperties]) {
        let spawned = self.clone();
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

    

struct BrushProperties {
    var strokeColor: Color?;
    var reflect: Bool?;
    var penDown: Bool?;
    var position : Point?;
    var scaling: Point?;
    var children: [Int:BrushProperties]?;
    var type = Brush.self;
    
    func iterate(target:Brush){

        var t = self.type;
        
        var p = self.position;
        
        let mirrored_object = Mirror(reflecting: self)
        
        for (index, attr) in mirrored_object.children.enumerate() {
            if let property_name = attr.label as String! {
                
                print("Attr \(index): \(property_name) = \(attr.value)")
            }
        }
    }
}
