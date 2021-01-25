//
//  BuyInViewController.swift
//  Saavi
//
//  Created by goMad Infotech on 03/03/19.
//  Copyright © 2019 Saavi. All rights reserved.
//

import UIKit


typealias BuyInCompleted = () -> Void

class BuyInViewController: UIViewController {

    //MARK: - - Outlets
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var vwAlert: UIView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnOkay: UIButton!
    var completionBlock:BuyInCompleted? = nil
    
    //MARK: - - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.vwAlert.layer.cornerRadius = 5
        self.vwAlert.clipsToBounds = true
        
        self.btnCancel.layer.cornerRadius = 5
        self.btnCancel.layer.borderColor = UIColor.gray.cgColor
        self.btnCancel.layer.borderWidth = 1.0
        
        self.btnOkay.layer.cornerRadius = 5
        self.btnOkay.layer.borderColor = UIColor.baseBlueColor().cgColor
        self.btnOkay.layer.borderWidth = 1.0
        
    }
    
    //MARK: - - Cancel Button Action
    @IBAction func btnCancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - - Okay Button Action
    @IBAction func btnOkayAction(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        self.completionBlock!()
    }
    
    func showCommonAlertOnWindow(completion:@escaping BuyInCompleted)
    {
        completionBlock = completion
        UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: false, completion: {
        })
    }
    
}
