//
//  DetailsTableViewCell.swift
//  ContactsList
//
//  Created by Amandeep Singh on 3/11/17.
//  Copyright © 2017 Amandeep Singh. All rights reserved.
//

import UIKit

class DetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageView_Photo: UIImageView!
    @IBOutlet weak var label_Title: UILabel!
    @IBOutlet weak var label_Numbers: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imageView_Photo.setBorderWidthAndColor(width: 1, color: COLORS.COLOR_RED)
        imageView_Photo.setRadius(radius: imageView_Photo.frame.size.width/2)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
