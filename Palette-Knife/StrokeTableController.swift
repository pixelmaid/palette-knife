//
//  StrokeTableControllerViewController.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 2/21/17.
//  Copyright © 2017 pixelmaid. All rights reserved.
//

import UIKit

class StrokeTableController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        var testStroke = StrokeCell();
        tableView
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
