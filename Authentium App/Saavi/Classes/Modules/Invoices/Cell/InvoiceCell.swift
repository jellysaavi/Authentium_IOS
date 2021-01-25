//
//  InvoiceCell.swift
//  Saavi
//
//  Created by goMad Infotech on 19/07/19.
//  Copyright © 2019 Saavi. All rights reserved.
//

import UIKit

class InvoiceCell: UITableViewCell {

    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgViewRightArrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.imgViewRightArrow.tintColor = .darkGreyColor()
        }
        self.lblDate?.textColor = UIColor.black
        self.lblDate?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
        self.lblName?.textColor = UIColor.black
        self.lblName?.font = UIFont.SFUI_SemiBold(baseScaleSize: 18.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
