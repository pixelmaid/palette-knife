//
//  StrokeCellData.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 2/21/17.
//  Copyright © 2017 pixelmaid. All rights reserved.
//

import Foundation
//
//  Meal.swift
//  FoodTracker
//
//  Created by Jane Appleseed on 11/10/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit


class StrokeCellData {
    
    //MARK: Properties
    
    var name: String
    var photo: UIImage?
    
    //MARK: Initialization
    
    init?(name: String, photo: UIImage?) {
        
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        
    }
}
