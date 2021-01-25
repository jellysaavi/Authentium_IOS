//
//  RegisterStepThirdViewController.swift
//  Saavi
//
//  Created by Vikramjeet Singh on 03/10/20.
//  Copyright © 2020 Saavi. All rights reserved.
//

import UIKit

class RegisterStepThirdViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtFieldFirstName: CustomTextField!
    @IBOutlet weak var txtFieldLastName: CustomTextField!
    
    @IBOutlet weak var sideicon_firstName: UIImageView!
    @IBOutlet weak var sideicon_lastName: UIImageView!

    
    @IBOutlet var nextBtn: CustomButton!
    @IBOutlet var backBtn: GrayButton!

    override func viewDidLoad() {
        
        sideicon_firstName.tintColor = UIColor.lightGray
        sideicon_lastName.tintColor = UIColor.lightGray
      //  nextBtn.layer.cornerRadius = 10.0 * Configration.scalingFactor()
        //backBtn.layer.cornerRadius = 10.0 * Configration.scalingFactor()

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
        if (txtFieldFirstName.text?.count)! < 2
        {
            txtFieldFirstName.becomeFirstResponder()
            txtFieldFirstName.textColor = UIColor.errorTextFieldColor()
            sideicon_firstName.tintColor = UIColor.errorTextFieldColor()
            Helper.shared.showAlertOnController( message: "Please enter a valid first name.", title: CommonString.alertTitle)
        }
        else if (txtFieldLastName.text?.count)! < 2
        {
            txtFieldLastName.becomeFirstResponder()
            txtFieldLastName.textColor = UIColor.errorTextFieldColor()
            sideicon_lastName.tintColor = UIColor.errorTextFieldColor()
            Helper.shared.showAlertOnController( message: "Please enter a valid last name.", title: CommonString.alertTitle)
        }
        else
        {
            RegisterInfo.shared.first_name = txtFieldFirstName.text
            RegisterInfo.shared.last_name = txtFieldLastName.text

            DispatchQueue.main.async {
                if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterStepFourthViewController") as? RegisterStepFourthViewController
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
        if textField == txtFieldFirstName
        {
            sideicon_firstName.tintColor = UIColor.baseBlueColor()
        }
        if textField == txtFieldLastName
        {
            sideicon_lastName.tintColor = UIColor.baseBlueColor()
        }

        
    }
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if UIScreen.main.bounds.height < 570
        {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
        
        textField.textColor = AppConfig.darkGreyColor()
        
        if textField == txtFieldFirstName
        {
            sideicon_firstName.tintColor = UIColor.lightGray
        }
        if textField == txtFieldLastName
        {
            sideicon_lastName.tintColor = UIColor.lightGray
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
                return newText.count<=25
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
