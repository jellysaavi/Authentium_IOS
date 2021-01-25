//
//  ProfileMessageCell.swift
//  Saavi
//
//  Created by Sukhpreet on 30/06/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class ProfileMessageCell: UITableViewCell {
    @IBOutlet weak var lblMessageText: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
