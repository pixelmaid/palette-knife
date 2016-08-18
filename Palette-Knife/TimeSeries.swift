//
//  TimeSeries.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 6/28/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

class TimeSeries: Emitter{
    
    var timer:NSDate
    var intervalTimer = NSTimer()
    //TODO: this is duplication to facilitate KVC- should be removed/fixed
    var timerTime = FloatEmitter(val:0);
    override init(){
        timer = NSDate()
        super.init()
        self.events =  ["TIME_INCREMENT"]
        self.createKeyStorage();
        timerTime.name = "time";
        
        
    }
    
    func getTimeElapsed()->Float{
        let currentTime = NSDate();
        let t = currentTime.timeIntervalSinceDate(timer)
        return Float(t);
    }
    
    func startInterval(){
        print("starting timer for \(self.name)");
        intervalTimer  = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(TimeSeries.timerIntervalCallback), userInfo: nil, repeats: true)
    }
    
    override func destroy(){
        super.destroy();
        intervalTimer.invalidate();
    }
    
    @objc func timerIntervalCallback()
    {
        let currentTime = NSDate();
        let t = Float(currentTime.timeIntervalSinceDate(timer))
        
        self.timerTime.set(t)
        for key in keyStorage["TIME_INCREMENT"]!
        {
            print("listeners on time increment\(keyStorage["TIME_INCREMENT"], key)")
 
            if(key.1 != nil){
                let condition = key.1;
                if(condition.evaluate()){
                    print("condition true, posted time increment \(key.0,(self["time"]! as! Emitter).get(), self.name)")
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0,"event":"TIME_INCREMENT"])
                }
                else{
                    print("condition false, not posting time increment, \((self["time"]! as! Emitter).get(), self.name)")
                }
            }
            else{
                print("no condition, posted time increment \(key.0,self.name)")
                
                NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0,"event":"TIME_INCREMENT"])
            }
            
        }
        
        
    }
    
    
    
}
