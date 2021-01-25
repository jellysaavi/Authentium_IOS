//
//  RegisterationSucessPopupViewController.swift
//  Saavi
//
//  Created by goMad Infotech on 12/07/19.
//  Copyright © 2019 Saavi. All rights reserved.
//

import UIKit

typealias RegisterationCompleted = (_ value : RegisterationStatus) -> Void

enum RegisterationStatus {
    case back
    case moveNext
}

class RegisterationSucessPopupViewController: UIViewController {

    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblDescription2: UILabel!
    @IBOutlet weak var lblDescription3: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
   
    // Handle completion if needed.
    var completionBlock : RegisterationCompleted? = nil

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

        self.lblDescription.font = UIFont.SFUI_Regular(baseScaleSize: 20.0)
        self.lblDescription2.font = UIFont.SFUI_Regular(baseScaleSize: 20.0)
        self.lblDescription3.font = UIFont.SFUI_Regular(baseScaleSize: 20.0)
        
        self.btnBack.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
        self.btnContinue.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
    }
    
    //MARK: - Buttons Actions
    /// Back button click action
    @IBAction func BtnBackAction(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            if self.completionBlock != nil
            {
                self.completionBlock!(RegisterationStatus.back)
            }
        })
    }
    
    /// Continue button click action
    @IBAction func btnContinueAction(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            if self.completionBlock != nil
            {
                self.completionBlock!(RegisterationStatus.moveNext)
            }
        })
    }
    
}
