//
//  ChangePasswordVC.swift
//  Saavi
//
//  Created by Sukhpreet on 24/11/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController , UITextFieldDelegate {
    
    @IBOutlet weak var txtNewPassword: CustomTextField!
    @IBOutlet weak var txtConfirmPassword: CustomTextField!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var sideIconResetPassword: UIImageView!
    @IBOutlet weak var sideIconConfirmPassword: UIImageView!
    var token = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtNewPassword.delegate = self
        self.txtConfirmPassword.delegate = self
        self.backBtn.setTitleColor(UIColor.baseBlueColor(), for: .normal)
        sideIconResetPassword.tintColor = UIColor.lightGray
        sideIconConfirmPassword.tintColor = UIColor.lightGray
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changePasswordAction(_ sender: Any)
    {
        if txtNewPassword.text == ""
        {
            Helper.shared.showAlertOnController( message: "Please enter password.", title: CommonString.alertTitle)
        }
        else if txtConfirmPassword.text == ""
        {
            Helper.shared.showAlertOnController( message: "Please enter confirm password.", title: CommonString.alertTitle)
        }
        else if txtNewPassword.text?.isValidPassword() == false
        {
            Helper.shared.showAlertOnController( message: "Password should contain atleast one uppercase letter, one special character and one number.", title: CommonString.alertTitle)
        }
        else if txtConfirmPassword.text != txtNewPassword.text
        {
            Helper.shared.showAlertOnController( message: "Password and confirm password do not match.", title: CommonString.alertTitle)
        }
        else
        {
            self.callAPItoChangePassword()
        }
    }
    
    @IBAction func dismissControllerAction()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func callAPItoChangePassword()
    {
        let URL = SyncEngine.baseURL + SyncEngine.changePassword
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: ["ResetToken": token,
                                                                       "NewPassword": self.txtNewPassword.text!,
                                                                       "ConfirmPassword": self.txtConfirmPassword.text!], strURL: URL) { (response: Any) in
                                                                        self.dismissControllerAction()
                                                                        Helper.shared.showAlertOnController( message: "Password changed successfully.", title: CommonString.app_name)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    override func viewDidLayoutSubviews() {
        for view in self.view.subviews
        {
            if view is CustomTextField
            {
                (view as! CustomTextField).Underline()
            }
        }
    }
    
    //    MARK:- Text field delegates
    
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
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

