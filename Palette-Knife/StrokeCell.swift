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

    @IBOutlet weak var strokeLabel: UILabel!
    @IBOutlet weak var strokeImage: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
