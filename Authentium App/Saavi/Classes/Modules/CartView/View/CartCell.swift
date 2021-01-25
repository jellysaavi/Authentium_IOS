//
//  CartCollectionViewCell.swift
//  Saavi
//
//  Created by Sukhpreet on 25/09/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class CartTableViewCell: UITableViewCell {
    
    static let cartCellReuseIdentifier = "cartCellReuseIdentifier"
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblProductStatus: PaddingLabel!
    @IBOutlet weak var productStatusHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblUnitOfMeasurement: UIButton!
    @IBOutlet weak var txtQuantity: UITextField!
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var btnShowImage: UIButton!
    @IBOutlet weak var btnPencil: UIButton!
    @IBOutlet weak var lblGst: UILabel!
    @IBOutlet var LblTotalPricePerQuantity: UILabel!
    
    override func awakeFromNib()
    {
        self.txtQuantity.keyboardType = UserInfo.shared.isSalesRepUser! ? .decimalPad:AppFeatures.shared.IsAllowDecimal ? .decimalPad:.numberPad
        self.lblDescription.font = UIFont.SFUI_Regular(baseScaleSize: 14.0)
        self.lblProductStatus.font = UIFont.SFUI_Bold(baseScaleSize: 13.0)
        self.lblPrice.font = UIFont.SFUI_SemiBold(baseScaleSize: 14.0)
        self.lblPrice.adjustsFontSizeToFitWidth = true
        self.lblPrice.textColor = UIColor.baseBlueColor()
        self.lblGst.font = UIFont.SFUIText_Regular(baseScaleSize: 11.0)
        
        self.lblUnitOfMeasurement.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 14.0)
        self.txtQuantity.font = UIFont.SFUI_Regular(baseScaleSize: 14.0)
    }
    
}
