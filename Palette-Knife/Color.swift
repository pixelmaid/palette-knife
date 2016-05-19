//
//  Color.swift
//  Palette-Knife
//
//  Created by JENNIFER MARY JACOBS on 5/5/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

struct Color {
    var r = 0;
    var g = 0;
    var b = 0;
    
    mutating func setValue(value:Color){
        self.r = value.r;
        self.g = value.g;
        self.b = value.b;
    }
    
}