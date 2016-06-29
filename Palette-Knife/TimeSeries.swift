//
//  TimeSeries.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 6/28/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

class TimeSeries{
    
    var event = Event<(String)>()
    var timer:NSDate

    init(){
        timer = NSDate()

    }
    
    func getTimeElapsed()->Float{
        let currentTime = NSDate();
        let time = currentTime.timeIntervalSinceDate(timer)
        return Float(time);
    }

}
