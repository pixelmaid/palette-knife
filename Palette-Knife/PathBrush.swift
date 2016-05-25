//
//  PathBrush.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 5/25/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation


class PathBrush:Brush{
    
    required init(){
        super.init()
        self.name = "PathBrush"
    }
    
    override func clone()->PathBrush{
        return super.clone() as! PathBrush;
    }
    
    
}