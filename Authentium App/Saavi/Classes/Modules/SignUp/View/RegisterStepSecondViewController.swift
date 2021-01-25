//
//  RegisterStepSecondViewController.swift
//  Saavi
//
//  Created by Vikramjeet Singh on 03/10/20.
//  Copyright © 2020 Saavi. All rights reserved.
//

import UIKit

class RegisterStepSecondViewController: UIViewController, UITextFieldDelegate
{
    
    @IBOutlet weak var txtFieldPassword: CustomTextField!
    @IBOutlet weak var sideicon_password: UIImageView!
    @IBOutlet var nextBtn: CustomButton!
    @IBOutlet var backBtn: GrayButton!


    override func viewDidLoad()
    {
        sideicon_password.tintColor = UIColor.lightGray
       // nextBtn.layer.cornerRadius = 10.0 * Configration.scalingFactor()
      //  backBtn.layer.cornerRadius = 10.0 * Configration.scalingFactor()

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
        if (txtFieldPassword.text?.count)! < 8
        {
            txtFieldPassword.becomeFirstResponder()
            txtFieldPassword.textColor = UIColor.errorTextFieldColor()
            sideicon_password.tintColor = UIColor.errorTextFieldColor()
            Helper.shared.showAlertOnController( message: "Password should contain minimum 8 characters.", title: CommonString.alertTitle)
        }
        else
        {
            RegisterInfo.shared.password = txtFieldPassword.text

            DispatchQueue.main.async {
                if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterStepThirdViewController") as? RegisterStepThirdViewController
                {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    @IBAction func BackButton(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if UIScreen.main.bounds.height < 570
        {
            self.view.frame = CGRect(x: 0, y: -30, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
        if textField == txtFieldPassword
        {
            sideicon_password.tintColor = UIColor.baseBlueColor()
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if UIScreen.main.bounds.height < 570
        {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
        
        textField.textColor = AppConfig.darkGreyColor()
        
        if textField == txtFieldPassword
        {
            sideicon_password.tintColor = UIColor.lightGray
        }
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
            if textField == txtFieldPassword {
                return newText.count<=25
            }
        }
        return true
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
