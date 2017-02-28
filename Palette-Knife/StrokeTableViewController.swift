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
     var strokes = [Stroke]()
     var brushEvent = Event<(String,String)>();

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    //MARK: Public Methods
    
    
    func deactivateAll(){
        self.tableView.userInteractionEnabled = false;
        self.tableView.alpha = 0.75
        self.tableView.hidden = false;

        
    }
    
    func activateAll(){
        self.tableView.userInteractionEnabled = true;
        self.tableView.alpha = 1;
        self.tableView.hidden = true;

    }

    func addStroke(stroke:Stroke){
        strokes.append(stroke);
        tableView.reloadData();
   
    }
    
    func removeStroke(stroke_id:String){
        for i in 0..<strokes.count{
            if(strokes[i].id == stroke_id){
                strokes.removeAtIndex(i);
                tableView.reloadData();
                break;
            }
        }

        
    }
    
    //MARK: Private Methods

    @objc private func moveCellUp(sender: AnyObject){
        let target = ((sender as! UIButton).superview!.superview) as! StrokeCell
        let target_id = target.id;
        for i in 0..<strokes.count{
            if(strokes[i].id == target_id){
                if(i != 0){
                    let t = strokes.removeAtIndex(i);
                    strokes.insert(t, atIndex: i-1)
                    tableView.reloadData();
                    self.brushEvent.raise(("moveStrokeUp",target_id));

                    break;
                }
            }
        }
    }
    
    @objc private func moveCellDown(sender: AnyObject){
        let target = ((sender as! UIButton).superview!.superview) as! StrokeCell
        let target_id = target.id;
        for i in 0..<strokes.count{
            if(strokes[i].id == target_id){
                if(i != strokes.count-1){
                    let t = strokes.removeAtIndex(i);
                    strokes.insert(t, atIndex: i+1)
                    tableView.reloadData();
                    self.brushEvent.raise(("moveStrokeDown",target_id));

                    break;
                }
            }
        }
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
        
       //cell.strokeImage.clear();
       // cell.strokeImage.drawSingleStroke(stroke, i: indexPath.row)
        cell.id = stroke.id;
        cell.moveUpButton.addTarget(self, action: #selector(StrokeTableViewController.moveCellUp(_:)), forControlEvents: .TouchUpInside)
         cell.moveDownButton.addTarget(self, action: #selector(StrokeTableViewController.moveCellDown(_:)), forControlEvents: .TouchUpInside)

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
