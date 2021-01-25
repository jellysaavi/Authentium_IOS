//
//  CustomTabBarCellCollectionViewCell.swift
//  Saavi
//
//  Created by Sukhpreet on 01/08/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class CustomTabBarCellCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tabItemImageView: UIImageView!
    @IBOutlet weak var tabItemTextLabel: UILabel!
    @IBOutlet var badgeCountLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.tabItemTextLabel.font = UIFont.SFUI_Regular(baseScaleSize: 12.0)
        self.tabItemTextLabel.adjustsFontSizeToFitWidth = true
    }
}
