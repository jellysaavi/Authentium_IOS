//
//  CustomTextView.swift
//  Saavi
//
//  Created by Sukhpreet on 05/09/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class CustomTextView: UITextView {

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyBorder()
    }
    
    
    func applyBorder()
    {
        self.textColor = AppConfig.darkGreyColor()
        self.layer.borderColor = UIColor.init(red: 229.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1.0).cgColor
        self.layer.borderWidth = 1.0
        self.font = UIFont.SFUI_Regular(baseScaleSize: 17.0)
        self.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.layer.cornerRadius = 5.0 * Configration.scalingFactor()
    }

    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
class CustomSalesRepTextView: UITextView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyBorderColor()
      
    }
    func applyBorderColor()
    {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.textColor = UIColor.lightGray
        self.font = UIFont.Roboto_Regular(baseScaleSize: 15.0)
    }
}
