//
//  MenuCollectionViewCell.swift
//  TiketTestApp
//
//  Created by Dedy Yuristiawan on 19/04/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit
import SkeletonView

class MenuCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var menuLabel: UILabel!
    
    var menu: String? {
        didSet{
            menuLabel.text = menu
            menuLabel.clipsToBounds = true
            menuLabel.layer.cornerRadius = 8
            menuLabel.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = false
        self.isSkeletonable = true
        self.clipsToBounds = true
        self.layer.cornerRadius = 8
        self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
    }

}
