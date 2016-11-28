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
    var r = Float(0);
    var g = Float(0);
    var b = Float(0);
    
    mutating func setValue(value:Color){
        self.r = value.r;
        self.g = value.g;
        self.b = value.b;
    }
    
    func toCGColor()->CGColor{
        return UIColor(red:CGFloat(self.r/255),green:CGFloat(self.g/255),blue:CGFloat(self.b/255), alpha:CGFloat(1)).CGColor;
    }
    
}
