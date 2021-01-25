//
//  RegisterStepFifthViewController.swift
//  Saavi
//
//  Created by Vikramjeet Singh on 03/10/20.
//  Copyright © 2020 Saavi. All rights reserved.
//

import UIKit

class RegisterStepFifthViewController: UIViewController {

    @IBOutlet weak var txtFieldCountry: CustomTextField!
    @IBOutlet weak var txtFieldCity: CustomTextField!
    
    @IBOutlet weak var sideicon_country: UIImageView!
    @IBOutlet weak var sideicon_city: UIImageView!

    
  //  @IBOutlet var nextBtn: CustomButton!
   // @IBOutlet var backBtn: GrayButton!

    override func viewDidLoad() {
        
        sideicon_country.tintColor = UIColor.lightGray
        sideicon_city.tintColor = UIColor.lightGray
        //nextBtn.layer.cornerRadius = 10.0 * Configration.scalingFactor()
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
        if (txtFieldCountry.text?.count)! < 2
        {
            txtFieldCountry.becomeFirstResponder()
            txtFieldCountry.textColor = UIColor.errorTextFieldColor()
            sideicon_country.tintColor = UIColor.errorTextFieldColor()
            Helper.shared.showAlertOnController( message: "Please enter a valid country name.", title: CommonString.alertTitle)
        }
        else if (txtFieldCity.text?.count)! < 2
        {
            txtFieldCity.becomeFirstResponder()
            txtFieldCity.textColor = UIColor.errorTextFieldColor()
            sideicon_city.tintColor = UIColor.errorTextFieldColor()
            Helper.shared.showAlertOnController( message: "Please enter a valid city name.", title: CommonString.alertTitle)
        }
        else
        {
            RegisterInfo.shared.country = txtFieldCountry.text
            RegisterInfo.shared.city = txtFieldCity.text
            self.RegisterSeller()
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
        if textField == txtFieldCountry
        {
            sideicon_country.tintColor = UIColor.baseBlueColor()
        }
        if textField == txtFieldCity
        {
            sideicon_city.tintColor = UIColor.baseBlueColor()
        }

    }
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if UIScreen.main.bounds.height < 570
        {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
        
        textField.textColor = AppConfig.darkGreyColor()
        
        if textField == txtFieldCountry
        {
            sideicon_country.tintColor = UIColor.lightGray
        }
        if textField == txtFieldCity
        {
            sideicon_city.tintColor = UIColor.lightGray
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
    
    func RegisterSeller()
    {
        let request = [
            "email": RegisterInfo.shared.email!,
            "password": RegisterInfo.shared.password!,
            "first_name": RegisterInfo.shared.first_name!,
            "last_name": RegisterInfo.shared.last_name!,
            "mobile_number": RegisterInfo.shared.mobile_number!,
            "country": RegisterInfo.shared.country!,
            "city": RegisterInfo.shared.city! as Any]
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: request, strURL: SyncEngine.baseURL + SyncEngine.RegisterSeller, withIndicator: true) { (response : Any) in
            
                let obj = response as? Dictionary<String,Any>
                if obj != nil
                {
                    debugPrint(obj! as Dictionary)
//                    if obj!.keyExists(key: "email"), let email = obj!["email"] as? String
//                    {
//                        Helper.shared.showAlertOnController( message: email, title: CommonString.alertTitle)
//                        return
//                    }
                    
                    DispatchQueue.main.async
                    {
                        for controller in self.navigationController!.viewControllers as Array {
                            if controller.isKind(of: ViewController.self) {
                                self.navigationController!.popToViewController(controller, animated: true)
                                break
                            }
                        }
                    }
                    Helper.shared.showAlertOnController( message: "Registeration Successful", title: CommonString.app_name)

                }

        }
    }

    @IBAction func PopToLoginView(_ sender: Any) {
    }
    
}
