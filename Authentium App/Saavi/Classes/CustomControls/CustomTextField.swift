//
//  CustomTextField.swift
//  Saavi
//
//  Created by Sukhpreet Singh on 16/06/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    

}

class CustomSalesRepTextField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textColor = UIColor.darkGreyColor()
        self.font = UIFont.Roboto_Medium(baseScaleSize: 18.0)
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }

}

class CustomSalesRepTxtField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.font = UIFont.Roboto_Regular(baseScaleSize: 15)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
}

class CustomBlueBoxTextField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textColor = UIColor.darkGreyColor()
        self.font = UIFont.Roboto_Medium(baseScaleSize: 15.0)
        self.textColor = UIColor.darkGreyColor()
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.baseBlueColor().cgColor
    }
    
}


class customview: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.bgViewColor()
        
    }
    
}
class customSalesRepview: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 0.4
        self.layer.borderColor = UIColor.baseBlueColor().cgColor
        self.backgroundColor = UIColor.white
        
    }
    
}

class customLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.textColor = UIColor.baseBlueColor()
}
    
}

class customLabelGrey: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.font = UIFont.Roboto_Medium(baseScaleSize: 15.0)
        self.textColor = UIColor.darkGreyColor()
    }
}
class customLabelGreyWithBorder: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.font = UIFont.Roboto_Medium(baseScaleSize: 15.0)
        self.textColor = UIColor.darkGreyColor()
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.darkGreyColor().cgColor
    }
}

class customLabelSalesRep: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
/*        self.font = UIFont.Roboto_Medium(baseScaleSize: 13.0)
        self.textColor = UIColor.baseBlueColor() */
    }
    
}

