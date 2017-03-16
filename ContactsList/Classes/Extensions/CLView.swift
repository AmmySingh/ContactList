//
//  CLView.swift
//  ContactsList
//
//  Created by Amandeep Singh on 3/11/17.
//  Copyright © 2017 Amandeep Singh. All rights reserved.
//

import UIKit

extension UIView {
    
    func setBorderWidthAndColor(width: CGFloat, color: UIColor) {
        
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
    
    func setRadius(radius: CGFloat) {
        
        self.clipsToBounds      = true
        self.layer.cornerRadius = radius
    }
}
