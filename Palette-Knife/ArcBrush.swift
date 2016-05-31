//
//  ArcBrush.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 5/26/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation
//brush that draws arcs of varying sizes
class ArcBrush:Brush{
    var currentArc:Arc?
    
    required init(){
        super.init()
        self.name = "ArcBrush"
    }
    
    override func clone()->ArcBrush{
        return super.clone() as! ArcBrush;
    }

}
