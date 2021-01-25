//
//  RecurringOrderPopupVC.swift
//  Saavi
//
//  Created by Vikramjeet Singh on 04/08/20.
//  Copyright © 2020 Saavi. All rights reserved.
//

enum SelectionType {
    case NoThanks
    case YesPlease
}

typealias SelectionTypeDone = (_ value : SelectionType) -> Void


import UIKit

class RecurringOrderPopupVC: UIViewController {
    
    
    @IBOutlet var noThanksBtn: UIButton!
    @IBOutlet var yesPleaseBtn: UIButton!
    @IBOutlet var viewAlert: UIView!
    @IBOutlet var lblTitle: UILabel!
    
    var completionBlock1 : SelectionTypeDone? = nil


    override func viewDidLoad()
    {
        self.noThanksBtn.backgroundColor = UIColor.primaryColor()
        self.yesPleaseBtn.backgroundColor = UIColor.primaryColor2()
        self.noThanksBtn.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
        self.yesPleaseBtn.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)

        self.lblTitle.font = UIFont.SFUI_Regular(baseScaleSize: 20.0)

        self.viewAlert.layer.cornerRadius = 10
        self.viewAlert.clipsToBounds = true

        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func NoThanksButton(_ sender: Any)
    {
        self.dismiss(animated: false, completion: {
            if self.completionBlock1 != nil{
                self.completionBlock1!(SelectionType.NoThanks)
            }
        })
    }
    
    @IBAction func YesPleaseButton(_ sender: Any)
    {
        self.dismiss(animated: false, completion: {
            if self.completionBlock1 != nil{
                self.completionBlock1!(SelectionType.YesPlease)
            }
        })
    }
    
    
}
