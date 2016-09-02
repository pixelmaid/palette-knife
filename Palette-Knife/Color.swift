//
//  Color.swift
//  Palette-Knife
//
//  Created by JENNIFER MARY JACOBS on 5/5/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation
import UIKit

struct Color {
    var r = 0;
    var g = 0;
    var b = 0;
    
    mutating func setValue(value:Color){
        self.r = value.r;
        self.g = value.g;
        self.b = value.b;
    }
    
    func toCGColor()->CGColor{
        return UIColor(red:CGFloat(self.r),green:CGFloat(self.g),blue:CGFloat(self.b), alpha:CGFloat(0.25)).CGColor;
    }
    
}
