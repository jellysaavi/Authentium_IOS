//
//  CustomButton.swift
//  Saavi
//
//  Created by Sukhpreet Singh on 15/06/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpView()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUpView()
    }
    func setUpView()
    {
        DispatchQueue.main.async {
            self.layer.cornerRadius = self.frame.size.height / 2
        }
        self.backgroundColor = UIColor.buttonBackgroundColor()
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitle(titleLabel?.text?.uppercased(), for: .normal)
        self.clipsToBounds = true
        self.titleLabel?.font = UIFont.Roboto_Bold(baseScaleSize: 18.0)
    }
}

class CustomButtonSalesRep: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.baseBlueColor().cgColor
        self.layer.borderWidth = 1.0
        self.setTitleColor(UIColor.baseBlueColor(), for: .normal)
        self.setTitle(titleLabel?.text?.uppercased(), for: .normal)
        self.clipsToBounds = true
        self.titleLabel?.font = UIFont.Roboto_Medium(baseScaleSize: 13.0)
        self.layer.cornerRadius = 5.0 * Configration.scalingFactor()
    }
    
}
class GrayButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpGrayButtonView()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUpGrayButtonView()
    }
    func setUpGrayButtonView()
    {
        DispatchQueue.main.async {
            self.layer.cornerRadius = self.frame.size.height / 2
        }
        self.backgroundColor = UIColor(red: 40.0/255.0, green: 50.0/255.0, blue: 80.0/255.0, alpha: 1.0)
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitle(titleLabel?.text?.uppercased(), for: .normal)
        self.clipsToBounds = true
        self.titleLabel?.font = UIFont.Roboto_Bold(baseScaleSize: 18.0)
    }
}

class CustomButtonGreyBorder: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.darkGreyColor().cgColor
        self.layer.borderWidth = 1.0
        self.setTitleColor(UIColor.baseBlueColor(), for: .normal)
//        self.setTitle(titleLabel?.text?.uppercased(), for: .normal)
       // self.clipsToBounds = true
        self.titleLabel?.font = UIFont.Roboto_Medium(baseScaleSize: 13.0)
       // self.layer.cornerRadius = 5.0 * Configration.scalingFactor()
    }
    
}


