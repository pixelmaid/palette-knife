//
//  TimeSeries.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 6/28/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

class TimeSeries: Emitter{
    
    var timer:NSDate!
    var intervalTimer:NSTimer!
    //TODO: this is duplication to facilitate KVC- should be removed/fixed
    var timerTime = Observable<Float>(0);
    
    override init(){
        timer = NSDate()

        super.init()
        self.events =  ["TICK"]
        self.createKeyStorage();
        timerTime.name = "time";
        
        
    }
    
    func getTimeElapsed()->Float{
        let currentTime = NSDate();
        let t = currentTime.timeIntervalSinceDate(timer)
        return Float(t);
    }
    
    func startInterval(){
       // if(intervalTimer == nil){
        intervalTimer  = NSTimer.scheduledTimerWithTimeInterval(0.0001, target: self, selector: #selector(TimeSeries.timerIntervalCallback), userInfo: nil, repeats: true)
        //}
        
        
    }
    
    func stopInterval(){
         intervalTimer.invalidate();
        
    }

    
    override func destroy(){
        self.stopInterval();
        super.destroy();
    }
    
    @objc func timerIntervalCallback()
    {
        let currentTime = NSDate();
        let t = Float(currentTime.timeIntervalSinceDate(timer))
        self.timerTime.set(t)
        for key in keyStorage["TICK"]!
        {
            
            if(key.1 != nil){
                let condition = key.1;
                var evaluation = condition.evaluate();
                if(evaluation){
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0,"event":"TICK"])
                }
            }
            else{
                
                NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0,"event":"TICK"])
            }
            
            
            
        }
        
        
    }
    
    
    
}
