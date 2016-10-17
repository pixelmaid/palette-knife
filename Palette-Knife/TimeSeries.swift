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
        if(intervalTimer == nil){
        timer = NSDate()
        intervalTimer  = NSTimer.scheduledTimerWithTimeInterval(0.0001, target: self, selector: #selector(TimeSeries.timerIntervalCallback), userInfo: nil, repeats: true)
        }
        
    }
    
    override func destroy(){
        super.destroy();
        intervalTimer.invalidate();
    }
    
    @objc func timerIntervalCallback()
    {
        let currentTime = NSDate();
        let t = Float(currentTime.timeIntervalSinceDate(timer))
        print("timer interval callback")
        self.timerTime.set(t)
        for key in keyStorage["TIME_INCREMENT"]!
        {
            
            if(key.1 != nil){
                let condition = key.1;
                var evaluation = condition.evaluate();
                print("timer evaluation \(evaluation, self.name)");
                if(evaluation){
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0,"event":"TIME_INCREMENT"])
                }
            }
            else{
                
                NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0,"event":"TIME_INCREMENT"])
            }
            
        }
        
        
    }
    
    
    
}
