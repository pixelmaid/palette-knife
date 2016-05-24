//
//  BrushFactory.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 5/24/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation


class Factory: Observable
{
    
    required override init(){
        
    }
    
    class func create(name : String) -> Factory?
    {
        let appName = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String
        guard let any : AnyObject.Type = NSClassFromString(appName + "." + name) , let ns = any as? Factory.Type  else
        {
            return nil;
        }
        return ns.init()
    }
}

/*typealias BrushFactory = () -> BrushObject?



enum BrushType {
    case Brush, PathBrush, ShapeBrush
}

enum BrushHelper {
    static func factoryFor(type : BrushType) -> BrushFactory {
        switch type {
       
        case .PathBrush:
            return PathBrush.make;
        
        default :
            return Brush.make;
        }
        
        
    }
}*/