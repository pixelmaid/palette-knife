//
//  BluetoothViewController.swift
//  
//
//  Created by JENNIFER MARY JACOBS on 11/18/16.
//
//

import Foundation


class ToolbarView: UIView{
    
    
    @IBOutlet weak var dualBrushButton: UIButton!
    @IBOutlet weak var largeBrushButton: UIButton!
    @IBOutlet weak var smallBrushButton: UIButton!

    var toolbarEvent = Event<(String)>()
    private var selectedColor = UIColor(red:201.0/255,green:200.0/255,blue:191.0/255,alpha:1);

    private var standardColor = UIColor(red:104.0/255,green:104.0/255,blue:103.0/255,alpha:1);

    
    override func drawRect(rect: CGRect) {
   
        /*self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSizeZero
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 5
        
        self.layer.cornerRadius = 6.0

        self.layer.borderColor = UIColor.darkGrayColor().CGColor;
        self.layer.borderWidth = 0.5
        //self.clipsToBounds = true*/
        
        
        dualBrushButton.addTarget(self, action: #selector(ToolbarView.dualBrushClicked(_:)), forControlEvents: .TouchUpInside)
        largeBrushButton.addTarget(self, action: #selector(ToolbarView.largeBrushClicked(_:)), forControlEvents: .TouchUpInside)

        smallBrushButton.addTarget(self, action: #selector(ToolbarView.smallBrushClicked(_:)), forControlEvents: .TouchUpInside)

        disableButtons()
        
        
    }
    
    func disableButtons(){
        dualBrushButton.enabled = false;
        largeBrushButton.enabled = false;
        smallBrushButton.enabled = false;
    }
    
    func enableButtons(){
        dualBrushButton.enabled = true;
        largeBrushButton.enabled = true;
        smallBrushButton.enabled = true;

    }
    
    func dualBrushClicked(sender: AnyObject?){
        dualBrushButton.backgroundColor = selectedColor
        largeBrushButton.backgroundColor = standardColor
        smallBrushButton.backgroundColor = standardColor
        toolbarEvent.raise(("bothActive"));


    }
    
    func largeBrushClicked(sender: AnyObject?){
        largeBrushButton.backgroundColor = selectedColor
        smallBrushButton.backgroundColor = standardColor
        dualBrushButton.backgroundColor = standardColor
        toolbarEvent.raise(("largeActive"));

    }
    
    func smallBrushClicked(sender: AnyObject?){
        smallBrushButton.backgroundColor = selectedColor
        largeBrushButton.backgroundColor = standardColor
        dualBrushButton.backgroundColor = standardColor
        toolbarEvent.raise(("smallActive"));


    }
    
    
    
    

    
    
}
