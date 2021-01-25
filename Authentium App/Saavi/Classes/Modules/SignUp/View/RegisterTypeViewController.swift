//
//  RegisterTypeViewController.swift
//  Saavi
//
//  Created by Vikramjeet Singh on 05/10/20.
//  Copyright © 2020 Saavi. All rights reserved.
//

import UIKit

class RegisterTypeViewController: UIViewController {
    
    @IBOutlet var type_buyerBtn: UIButton!
    @IBOutlet var type_driverBtn: UIButton!
    @IBOutlet var type_sellerBtn: UIButton!
    
    var selectedUserType = String()
    
    

    override func viewDidLoad() {
        
        selectedUserType = ""
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func BackButton(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func NextButton(_ sender: Any)
    {
        if selectedUserType == ""
        {
            Helper.shared.showAlertOnController(message:"Please select user type", title: "",hideOkayButton: true

            )
            Helper.shared.dismissAddedToCartAlert()
            return
        }
        
        if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterStepFirstViewController") as? RegisterStepFirstViewController
        {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func BuyerButtonSelected(_ sender: Any)
    {
        selectedUserType = "Buyer"
        RegisterInfo.shared.user_type = selectedUserType

        type_buyerBtn.setImage(UIImage(named: "tick"), for: .normal)
        type_driverBtn.setImage(UIImage(named: "untick"), for: .normal)
        type_sellerBtn.setImage(UIImage(named: "untick"), for: .normal)
    }
    
    @IBAction func DriverButtonSelected(_ sender: Any)
    {
        selectedUserType = "Driver"
        RegisterInfo.shared.user_type = selectedUserType


        type_buyerBtn.setImage(UIImage(named: "untick"), for: .normal)
        type_driverBtn.setImage(UIImage(named: "tick"), for: .normal)
        type_sellerBtn.setImage(UIImage(named: "untick"), for: .normal)
    }
    
    @IBAction func SellerButtonSelected(_ sender: Any)
    {
        selectedUserType = "Seller"
        RegisterInfo.shared.user_type = selectedUserType

        type_buyerBtn.setImage(UIImage(named: "untick"), for: .normal)
        type_driverBtn.setImage(UIImage(named: "untick"), for: .normal)
        type_sellerBtn.setImage(UIImage(named: "tick"), for: .normal)

    }
    
    @IBAction func PopToLoginView(_ sender: Any)
    {
        DispatchQueue.main.async
        {
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: ViewController.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }
    }
    
    
    
    
    
}
