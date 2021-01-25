//
//  ForgotPassword.swift
//  Saavi
//
//  Created by Sukhpreet on 29/06/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class ForgotPassword: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var sideicon_email: UIImageView!
    @IBOutlet weak var txtFieldEmalAddress: CustomTextField!
    @IBOutlet weak var backBtn: UIButton!
    
    var presenter : ForgotPasswordPresenterProtocol?
    
    //    MARK: - VIEW LIFECYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideicon_email.image = #imageLiteral(resourceName: "icon_email_disable")
        sideicon_email.tintColor = UIColor.lightGray
        backBtn.tintColor = UIColor.baseBlueColor()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    //    MARK: - TEXT DELEGATES -
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if textField == txtFieldEmalAddress
        {
            sideicon_email.image = #imageLiteral(resourceName: "icon_email_disable")
            sideicon_email.tintColor = UIColor.baseBlueColor()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        textField.textColor = AppConfig.darkGreyColor()
        
        if textField == txtFieldEmalAddress
        {
            sideicon_email.image = #imageLiteral(resourceName: "icon_email_disable")
            sideicon_email.tintColor = UIColor.lightGray
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
            return newText.count<=50
        }
        
        return true
    }
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
        if txtFieldEmalAddress.text?.isValidEmailAddressFormat() == false
        {
            txtFieldEmalAddress.becomeFirstResponder()
            sideicon_email.image = #imageLiteral(resourceName: "icon_email_disable")
            txtFieldEmalAddress.textColor = UIColor.errorTextFieldColor()
            sideicon_email.tintColor = UIColor.errorTextFieldColor()
            Helper.shared.showAlertOnController( message: "Please enter a valid email address.", title: CommonString.alertTitle)
        }
        else
        {
            self.txtFieldEmalAddress.resignFirstResponder()
            presenter?.processForgotPasswordRequest(email: self.txtFieldEmalAddress.text!)
        }
    }
    @IBAction func backAction(_ sender: Any?)
    {
        presenter?.backAction()
    }
}


extension ForgotPassword : ForgotPasswordViewProtocol
{
    func showErrorAlert() {
        
    }
    
    func handleRequestProcessed()
    {
        DispatchQueue.main.async {
            let emailStr = String(format: "%@",self.txtFieldEmalAddress.text!)

            let alert = UIAlertController(title: "Mail Sent", message: "An email has been sent to \(emailStr). Please follow instructions and reset your password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.backAction(nil)
            })
            self.present(alert, animated: true)

        }

    }
}



/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */


