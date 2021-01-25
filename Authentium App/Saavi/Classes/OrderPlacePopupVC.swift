//
//  OrderPlacePopupVC.swift
//  Saavi
//
//  Created by goMad Infotech on 15/07/19.
//  Copyright © 2019 Saavi. All rights reserved.
//

import UIKit

enum OrderPlaceStatus {
    case no
    case yes
}

typealias OrderPlaceCompleted = (_ value : OrderPlaceStatus) -> Void

class OrderPlacePopupVC: UIViewController {

    //MARK: - - Outlets/Variables
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var btnYes: UIButton!
    
    // Handle completion if needed.
    var completionBlock : OrderPlaceCompleted? = nil

    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeUIChanges()
    }
    
    //MARK: - Implement UI changes
    private func makeUIChanges() -> Void {
        //Set corner radius
        self.viewAlert.layer.cornerRadius = 10
        self.viewAlert.clipsToBounds = true
        
        self.lblTitle.font = UIFont.SFUI_Regular(baseScaleSize: 20.0)
        self.btnNo.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
        self.btnYes.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
        
        self.btnNo.setTitleColor(UIColor.white, for: .normal)
        self.btnYes.setTitleColor(UIColor.white, for: .normal)
        self.btnNo.backgroundColor = UIColor.primaryColor()
        self.btnYes.backgroundColor = UIColor.primaryColor2()
    }
    
    //MARK: - Buttons Actions
    /// No Button Action
    @IBAction func btnNoAction(_ sender: Any) {
        self.dismiss(animated: false, completion: {
            if self.completionBlock != nil
            {
                self.completionBlock!(OrderPlaceStatus.no)
            }
        })
    }
    
    /// Yes Button Action
    @IBAction func btnYesAction(_ sender: Any) {
        self.dismiss(animated: false, completion: {
            if self.completionBlock != nil
            {
                self.completionBlock!(OrderPlaceStatus.yes)
            }
        })
    }
}
