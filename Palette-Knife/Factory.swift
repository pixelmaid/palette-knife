//
//  Factory.swift
//  Palette-Knife
//
//  Created by JENNIFER MARY JACOBS on 5/5/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation
class Factory
{
    class func create(name : String) -> Factory?
    {
        let appName = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String
        guard let any : AnyObject.Type = NSClassFromString(appName + "." + name) , let ns = any as? Factory.Type  else
        {
            return nil;
        }
        return ns.init()
    }
    
    func description() -> String
    {
        return  NSStringFromClass(self.dynamicType)
    }
    
    required init()
    {
    }
    
    func hello()
    {
        print("base hello");
    }
    
}