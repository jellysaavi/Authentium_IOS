//
//  RegisterStepFourthViewController.swift
//  Saavi
//
//  Created by Vikramjeet Singh on 03/10/20.
//  Copyright © 2020 Saavi. All rights reserved.
//

import UIKit

class RegisterStepFourthViewController: UIViewController {
    
    @IBOutlet weak var txtFieldPhone: CustomTextField!
    @IBOutlet weak var sideicon_phone: UIImageView!
    @IBOutlet var nextBtn: CustomButton!
    @IBOutlet var backBtn: GrayButton!

    override func viewDidLoad()
    {
        
        sideicon_phone.tintColor = UIColor.lightGray
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
       if (txtFieldPhone.text?.count)! < 10 || !(txtFieldPhone.text?.starts(with: "0"))!
       {
            txtFieldPhone.becomeFirstResponder()
            txtFieldPhone.textColor = UIColor.errorTextFieldColor()
            sideicon_phone.tintColor = UIColor.errorTextFieldColor()
            Helper.shared.showAlertOnController( message: "Invalid mobile number. Please ensure it is exactly 10 numbers and it should start with a 0", title: CommonString.alertTitle)
       }
       else
       {
        RegisterInfo.shared.mobile_number = txtFieldPhone.text

        DispatchQueue.main.async {
            if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterStepFifthViewController") as? RegisterStepFifthViewController
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
        if textField == txtFieldPhone
        {
            sideicon_phone.tintColor = UIColor.baseBlueColor()
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if UIScreen.main.bounds.height < 570
        {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
        
        textField.textColor = AppConfig.darkGreyColor()
        
        if textField == txtFieldPhone
        {
            sideicon_phone.tintColor = UIColor.lightGray
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
            if textField == txtFieldPhone {
                return newText.count<=10
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
