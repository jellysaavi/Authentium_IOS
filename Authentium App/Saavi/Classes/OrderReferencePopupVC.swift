//
//  OrderReferencePopupVC.swift
//  Saavi
//
//  Created by goMad Infotech on 15/07/19.
//  Copyright © 2019 Saavi. All rights reserved.
//

import UIKit

enum OrderReferenceStatus {
    case skip
    case submit
}

typealias OrderReferenceCompleted = (_ value : OrderReferenceStatus, _ strReference : String?) -> Void

class OrderReferencePopupVC: UIViewController {
    
    //MARK: - - Outlets/Variables
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var txtFldOrderReference: UITextField!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnSkip: UIButton!
    
    // Handle completion if needed.
    var completionBlock : OrderReferenceCompleted? = nil
    
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
        self.lblDetail.font = UIFont.SFUI_Regular(baseScaleSize: 20.0)
        self.txtFldOrderReference.font = UIFont.Roboto_Regular(baseScaleSize: 20)
        self.btnSubmit.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
        self.btnSkip.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
    }
    
    //MARK: - Buttons Actions
    /// Submit Button Action
    @IBAction func btnSubmitAction(_ sender: Any) {
        if (self.txtFldOrderReference.text?.count)! > 0{
            
            self.txtFldOrderReference.becomeFirstResponder()
            Helper.shared.showAlertOnController( message: "Please enter order reference.", title: CommonString.alertTitle)
        }else{
            
            self.dismiss(animated: true, completion: {
                if self.completionBlock != nil
                {
                    self.completionBlock!(OrderReferenceStatus.submit, self.txtFldOrderReference.text)
                }
            })
        }
    }
    
    /// Skip Button Action
    @IBAction func btnSkipAction(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            if self.completionBlock != nil{
                self.completionBlock!(OrderReferenceStatus.skip, self.txtFldOrderReference.text)
            }
        })
    }
}
