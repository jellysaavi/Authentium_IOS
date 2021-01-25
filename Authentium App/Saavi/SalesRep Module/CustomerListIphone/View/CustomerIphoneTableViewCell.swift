//
//  CustomerIphoneTableViewCell.swift
//  Saavi
//
//  Created by goMad Infotech on 14/11/18.
//  Copyright © 2018 Saavi. All rights reserved.
//

import UIKit

class CustomerIphoneTableViewCell: UITableViewCell {
    @IBOutlet weak var lblCustmerName: UILabel!
    @IBOutlet weak var btnAccount: CustomButtonSalesRep!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }

}
