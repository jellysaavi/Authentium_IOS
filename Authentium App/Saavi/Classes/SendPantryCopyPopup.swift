//
//  SignupViewController.swift
//  Saavi
//
//  Created by Sukhpreet on 16/06/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit


class SendPantryCopyPopup: UIViewController, UITextFieldDelegate {
    
    //MARK: - - Outlets
    @IBOutlet weak var txtName : CustomTextField!
    @IBOutlet weak var txtFieldEmalAddress: CustomTextField!
    @IBOutlet weak var btnRegister: CustomButton!

    @IBOutlet weak var sideicon_email: UIImageView!
    @IBOutlet weak var sideicon_name: UIImageView!

    
  
    
    @IBOutlet var btnCancel: CustomButton!
    
   
    var activeTextField : UITextField?
    var latitude:Double = 0.00
    var longitude:Double = 0.00
    var pantryListId:NSNumber = 0
    var products = Array<Dictionary<String,Any>>()
    
    
    @IBAction func btnCancelAction(_ sender: Any) {
        dismiss(animated: true) {
            
        }
    }
    
    
    
    
   
    
    
    @IBAction func btnPrivateHomeDeliveryAction(_ sender: UIButton) {
        sender.isSelected.toggle()
      
    }
    //MARK: - - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnRegister.layer.cornerRadius = 10.0 * Configration.scalingFactor()
        initializeSideIcons()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func initializeSideIcons()
    {
        sideicon_name.tintColor = UIColor.lightGray
        sideicon_email.tintColor = UIColor.lightGray
        
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
       
           override func viewWillAppear(_ animated: Bool) {
               super.viewWillAppear(animated)
               IQKeyboardManager.sharedManager().enable = true

           }
           
           override func viewWillDisappear(_ animated: Bool) {
               super.viewWillDisappear(animated)
               IQKeyboardManager.sharedManager().enable = false

           }
        
        func animateViewMoving (up:Bool, moveValue :CGFloat){
            let movementDuration:TimeInterval = 0.3
            let movement:CGFloat = ( up ? -moveValue : moveValue)

            UIView.beginAnimations("animateView", context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(movementDuration)
            self.view.frame = CGRect(x: 0, y: movement, width: self.view.frame.size.width, height: self.view.frame.size.height)
            UIView.commitAnimations()
        }
        
      
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        
        if textField == txtName || textField == txtFieldEmalAddress {
             self.animateViewMoving(up: true, moveValue: 150)
         }else{
             self.animateViewMoving(up: true, moveValue: 380)
        
         }
        
        if UIScreen.main.bounds.height < 570
        {
            self.view.frame = CGRect(x: 0, y: -30, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
        
        else if textField == txtName
        {
            sideicon_name.tintColor = UIColor.baseBlueColor()
        }
        else if textField == txtFieldEmalAddress
        {
            sideicon_email.tintColor = UIColor.baseBlueColor()
        }
        else if textField == txtFieldEmalAddress
        {
            sideicon_email.tintColor = UIColor.baseBlueColor()
        }
       
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        
        if textField == txtName || textField == txtFieldEmalAddress {
                       self.animateViewMoving(up: false, moveValue: 0)
                   }else{
                       self.animateViewMoving(up: false, moveValue: 0)
                   }
        if UIScreen.main.bounds.height < 570
        {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
        
        textField.textColor = AppConfig.darkGreyColor()
        
       
        if textField == txtName
        {
            sideicon_name.tintColor = UIColor.lightGray
        }
        else if textField == txtFieldEmalAddress
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
    
    
    @IBAction func signupUserAction(_ sender: Any) {
        
        self.view.endEditing(true)
        
        
        if (txtName.text?.count)! < 3
        {
            txtName.becomeFirstResponder()
            txtName.textColor = UIColor.errorTextFieldColor()
            sideicon_name.tintColor = UIColor.errorTextFieldColor()
            Helper.shared.showAlertOnController( message: "Please enter a valid name.", title: CommonString.alertTitle)
        }
      
            
       
        else if txtFieldEmalAddress.text?.isValidEmailAddressFormat() == false
        {
            txtFieldEmalAddress.becomeFirstResponder()
            txtFieldEmalAddress.textColor = UIColor.errorTextFieldColor()
            sideicon_email.tintColor = UIColor.errorTextFieldColor()
            Helper.shared.showAlertOnController( message: "Please enter a valid email address.", title: CommonString.alertTitle)
        }
      
      
            
        else
        {
            
            self.callRegistrationWebService()
        }
    }
    
    
    func callRegistrationWebService()
    {
        let strUrl = SyncEngine.baseURL + SyncEngine.SendProductPantryList
        
        var registrationDIc = [
            "Email": txtFieldEmalAddress.text!,
            "ContactName": txtName.text!,
            "PantryListId": pantryListId
           
            ] as Dictionary<String,Any>
        
           
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: registrationDIc, strURL: strUrl) { (response : Any) in
            DispatchQueue.main.async
                {
                    
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true) {
                        
                    }
            }
        }
    }
    
    
    //    @IBAction func btnPrivateHomeDeliveryAction(_ sender: UIButton) {
    //
    //        sender.isSelected.toggle()
    //        btnExistingAccount.isSelected.toggle();
    //    }
    
   
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
    
    
    @IBAction func goBackAction(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
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
