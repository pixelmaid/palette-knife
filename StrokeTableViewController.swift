//
//  StrokeTableViewController.swift
//  
//
//  Created by JENNIFER MARY JACOBS on 2/21/17.
//
//

import UIKit

class StrokeTableViewController: UITableViewController {

    //MARK: Properties
    var strokes = [StrokeCellData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSampleCells();

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    //MARK: Private Methods
    
    private func loadSampleCells() {
        let photo1 = UIImage(named: "radial")
        let photo2 = UIImage(named: "radial")
        let photo3 = UIImage(named: "radial")
        
        guard let stroke1 = StrokeCellData(name: "stroke1", photo: photo1) else {
            fatalError("Unable to instantiate stroke1")
        }
        guard let stroke2 = StrokeCellData(name: "stroke2", photo: photo2) else {
            fatalError("Unable to instantiate stroke1")
        }
        guard let stroke3 = StrokeCellData(name: "stroke3", photo: photo3) else {
            fatalError("Unable to instantiate stroke1")
        }
        
        strokes += [stroke1, stroke2, stroke3]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        print("num of sections called");
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("strokes count \(strokes.count)");

        return strokes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StrokeTableCell", forIndexPath: indexPath) as! StrokeCell

        // Fetches the appropriate meal for the data source layout.
        let stroke = strokes[indexPath.row]
        
        cell.strokeLabel.text = stroke.name
        cell.strokeImage.image = stroke.photo
        print("tableView \(cell)");


        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
