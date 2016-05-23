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
        pathBrush.position.x = 100;
        pathBrush.position.y = 100;
        //print(pathBrush);
        let f = pathBrush.clone();
        f.foo();
        let b = Behavior();
        let e = Event<(EventType,Observable)>()
        b.addEventActionPair(pathBrush,event:e,action:PathBrush.testHandler);
        e.raise((EventType.STYLUS_DOWN,f));

        //f!.position.x = 400;
        //f!.position.y = 400;
        print("positions\(pathBrush.position.x,pathBrush.position.y,f.position.x,f.position.y)");

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

