//
//  ViewResonder.swift
//  DrawPad
//
//  Created by JENNIFER MARY JACOBS on 1/28/16.
//  Copyright © 2016 Ray Wenderlich. All rights reserved.
//

import UIKit

class ViewResonder: UIResponder {
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        swiped = false
        if let touch = touches.first as? UITouch {
            lastPoint = touch.locationInView(self.view)
        }
    }
}
