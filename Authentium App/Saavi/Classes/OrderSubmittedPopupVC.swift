//
//  OrderSubmittedPopupVC.swift
//  Saavi
//
//  Created by goMad Infotech on 15/07/19.
//  Copyright © 2019 Saavi. All rights reserved.
//

import UIKit

typealias OrderSubmitted = () -> Void

class OrderSubmittedPopupVC: UIViewController {

    //MARK: - - Outlets
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var viewElements: UIView!
    @IBOutlet weak var lblMessage2: UILabel!
    @IBOutlet weak var btnOk: UIButton!
    
    // Handle completion if needed.
    var completionBlock : OrderSubmitted? = nil

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
        
        self.lblMessage.font = UIFont.SFUI_Regular(baseScaleSize: 20.0)
        self.viewElements.backgroundColor = UIColor.primaryColor()
        self.lblMessage2.font = UIFont.SFUI_SemiBold(baseScaleSize: 28.0)
        self.btnOk.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
    }
    
    //MARK: - Ok Buttons Actions
    @IBAction func btnOkAction(_ sender: Any) {
        self.dismiss(animated: false, completion: {
            if self.completionBlock != nil
            {
                self.completionBlock!()
            }
        })
    }
    

}
