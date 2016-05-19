//
//  ViewController.swift
//  Palette-Knife
//
//  Created by JENNIFER MARY JACOBS on 5/4/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var canvasView: CanvasView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var bP = BrushProperties();
        bP.reflect = false;
        bP.position = Point(x:100,y:200);
        
        
        let pathBrush = PathBrush();
        print(pathBrush);
        var pB = NSClassFromString("PaletteKnife.PathBrush")
        print(pB);
        if let f = Brush.create("PathBrush")
              {
                            print(f.position);
                
                     }
                else
                 {
                            print("No class")
                     }

       /* let brush = Brush.create("PathBrush");
       brush!.setValue(bP);
        brush!.setPosition(Point(x:50,y:50));
        print("position \(brush!.position.x)\(brush!.position.y)")*/

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

