//
//  BuyInProductListPopupViewController.swift
//  Saavi
//
//  Created by goMad Infotech on 04/03/19.
//  Copyright © 2019 Saavi. All rights reserved.
//

import UIKit

typealias BuyInPlaceOrderCompleted = () -> Void

class BuyInProductListPopupViewController: UIViewController {

    //MARK: - - Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtVwProducts: UITextView!
    @IBOutlet weak var lblContinue: UILabel!
    @IBOutlet weak var vwAlert: UIView!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    var completionBlock:BuyInPlaceOrderCompleted? = nil
    
    //MARK: - - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.vwAlert.layer.cornerRadius = 5
        self.vwAlert.clipsToBounds = true
        
        self.btnNo.layer.cornerRadius = 5
        self.btnNo.layer.borderColor = UIColor.baseBlueColor().cgColor
        self.btnNo.layer.borderWidth = 1.0
        
        self.btnYes.layer.cornerRadius = 5
        self.btnYes.layer.borderColor = UIColor.baseBlueColor().cgColor
        self.btnYes.layer.borderWidth = 1.0
        self.txtVwProducts.layer.borderWidth = 1.0
        self.txtVwProducts.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    //MARK: - - Cancel Button Action
    @IBAction func btnNoAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - - Okay Button Action
    @IBAction func btnYesAction(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        self.completionBlock!()
    }
    
    func showAlertOnWindow(products:String,completion:@escaping BuyInCompleted)
    {
        
        completionBlock = completion
        UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: false, completion: {
        })
        
        self.txtVwProducts.text = products
    }

}
