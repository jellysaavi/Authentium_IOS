//
//  HistoryTableViewCell.swift
//  Saavi
//
//  Created by Sukhpreet SIngh on 29/09/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblOrderStatus: UILabel!
    @IBOutlet weak var lblOrderNumber: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        lblOrderNumber.font = UIFont.SFUI_Regular(baseScaleSize: 15.0)
        lblDescription.font = UIFont.SFUI_Regular(baseScaleSize: 15.0)
        lblOrderStatus.font = UIFont.SFUI_Regular(baseScaleSize: 15.0)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
