//
//  StrokeCellTableViewCell.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 2/21/17.
//  Copyright © 2017 pixelmaid. All rights reserved.
//

import UIKit

class StrokeCell: UITableViewCell {

    //MARK: properties

    @IBOutlet weak var moveDownButton: UIButton!
    @IBOutlet weak var moveUpButton: UIButton!
    @IBOutlet weak var strokeLabel: UILabel!
    //var strokeImage:CanvasView;
    var id: String!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
       // strokeImage = CanvasView(frame: CGRectMake(0,0,90,90));
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        // strokeImage = CanvasView(frame: CGRectMake(0,0,90,90));
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
       // strokeImage.backgroundColor = UIColor.blueColor();
    // self.addSubview(strokeImage)
               // Initialization code
    }

  
    
    func modeClicked(){
    
    }

}
