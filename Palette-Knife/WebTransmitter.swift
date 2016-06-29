//
//  WebTransmitter.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 6/27/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation


protocol WebTransmitter{
    var name: String { get set }
    var id:String { get set }
    var event:Event<(String)>{get set}
}
