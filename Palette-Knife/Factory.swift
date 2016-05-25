//
//  BrushFactory.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 5/24/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation

typealias StylusType = (Point,Float,Float)
typealias BrushType = (Brush)

class Factory: Emitter
{
    
    required override init(){
        super.init()
 
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