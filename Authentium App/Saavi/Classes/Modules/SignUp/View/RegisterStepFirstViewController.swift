//
//  RegisterStepFirstViewController.swift
//  Saavi
//
//  Created by Vikramjeet Singh on 03/10/20.
//  Copyright © 2020 Saavi. All rights reserved.
//

import UIKit

class RegisterStepFirstViewController: UIViewController, UITextFieldDelegate
{

    @IBOutlet weak var txtFieldEmalAddress: CustomTextField!
    @IBOutlet weak var sideicon_email: UIImageView!
    
    @IBOutlet var nextBtn: CustomButton!
    
    override func viewDidLoad() {
        
        sideicon_email.tintColor = UIColor.lightGray
      //  nextBtn.layer.cornerRadius = 10.0 * Configration.scalingFactor()

        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for view in self.view.subviews
        {
            if view is CustomTextField
            {
                (view as! CustomTextField).Underline()
            }
        }
    }
    @IBAction func NextButton(_ sender: Any)
    {
        if txtFieldEmalAddress.text?.isValidEmailAddressFormat() == false
        {
            txtFieldEmalAddress.becomeFirstResponder()
            txtFieldEmalAddress.textColor = UIColor.errorTextFieldColor()
            sideicon_email.tintColor = UIColor.errorTextFieldColor()
            Helper.shared.showAlertOnController( message: "Please enter a valid email address.", title: CommonString.alertTitle)
        }
        else
        {
            RegisterInfo.shared.email = txtFieldEmalAddress.text

            DispatchQueue.main.async {
                if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterStepSecondViewController") as? RegisterStepSecondViewController
                {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @IBAction func BackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func LoginButton(_ sender: Any)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if UIScreen.main.bounds.height < 570
        {
            self.view.frame = CGRect(x: 0, y: -30, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
        if textField == txtFieldEmalAddress
        {
            sideicon_email.tintColor = UIColor.baseBlueColor()
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if UIScreen.main.bounds.height < 570
        {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
        
        textField.textColor = AppConfig.darkGreyColor()
        
        if textField == txtFieldEmalAddress
        {
            sideicon_email.tintColor = UIColor.lightGray
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if textField.text == "", string == " "
        {
            return false
        }
        else if string == "\n"
        {
            textField.resignFirstResponder()
            textField.endEditing(true)
        }
        else{
            let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            return newText.count<=50
        }
        return true
    }
    
    
    
    
}
