//
//  TimeSeries.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 6/28/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

class TimeSeries: Emitter{
    
    var event = Event<(String)>()
    var timer:NSDate
    var intervalTimer = NSTimer()
    
    override init(){
        timer = NSDate()
        super.init()
     
    }
    
    func getTimeElapsed()->Float{
        let currentTime = NSDate();
        let time = currentTime.timeIntervalSinceDate(timer)
        return Float(time);
    }
    
    func startInterval(){
        intervalTimer  = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(TimeSeries.timerIntervalCallback), userInfo: nil, repeats: true)
    }
    
  @objc func timerIntervalCallback()
    {
        
    }
    


}
