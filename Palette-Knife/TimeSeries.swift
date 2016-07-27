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
    var time = FloatEmitter(val:0);
    override init(){
        timer = NSDate()
        super.init()
        self.events =  ["TIME_INCREMENT"]
        self.createKeyStorage();
        time.name = "time";

     
    }
    
    func getTimeElapsed()->Float{
        let currentTime = NSDate();
        let t = currentTime.timeIntervalSinceDate(timer)
        return Float(t);
    }
    
    func startInterval(){
        intervalTimer  = NSTimer.scheduledTimerWithTimeInterval(0.005, target: self, selector: #selector(TimeSeries.timerIntervalCallback), userInfo: nil, repeats: true)
    }
    
    override func destroy(){
        super.destroy();
        intervalTimer.invalidate();
    }

  @objc func timerIntervalCallback()
    {
        let currentTime = NSDate();
        let t = Float(currentTime.timeIntervalSinceDate(timer))

        self.time.set(t)
        print("current time =\(self.time.get())")
        if(t>4){
            print("listeners on time increment\(keyStorage["TIME_INCREMENT"])")
        for key in keyStorage["TIME_INCREMENT"]! {
                  NSNotificationCenter.defaultCenter().postNotificationName(key.0, object: self, userInfo: ["emitter":self,"key":key.0])
            
        }
        }

    }
        


}
