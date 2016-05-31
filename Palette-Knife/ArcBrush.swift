//
//  ArcBrush.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 5/26/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation
//brush that draws arcs of varying sizes
class ArcBrush:PathBrush{
    
    required init(){
        print("arc brush init")
        super.init()
        self.name = "ArcBrush"
        
    }
    
    func setPosition(){
        currentStroke = Stroke();
        self.strokes.append(currentStroke!);
        do{
            try currentStroke!.arcTo(Point(x: 20,y: 20),through:Point(x:60,y:20),to:Point(x:80,y:80))
         
            for seg in (currentStroke?.segments)!{
                self.geometryModified.raise((seg,"SEGMENT","DRAW"))
                
            }
        }
        catch DrawError.InvalidArc {
            print("Invalid Arc")
        }
        catch {
            print("unknown error")
        }
        
    }

    
    
    override func clone()->ArcBrush{
        return super.clone() as! ArcBrush;
    }

}
