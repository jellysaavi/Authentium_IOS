//
//  SignupViewController.swift
//  Saavi
//
//  Created by Sukhpreet on 16/06/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit
import GooglePlaces

class SignupViewController: UIViewController, UITextFieldDelegate,GMSAutocompleteViewControllerDelegate {
    
    //MARK: - - Outlets
    @IBOutlet weak var txtName : CustomTextField!
    @IBOutlet weak var txtFieldEmalAddress: CustomTextField!
    @IBOutlet weak var txtBusinessName: CustomTextField!
    @IBOutlet weak var txtFieldPhoneNumber: CustomTextField!
    @IBOutlet weak var txtFieldPassword: CustomTextField!
    @IBOutlet weak var txtFieldConfirmPassword: CustomTextField!
    @IBOutlet weak var btnRegister: CustomButton!
    @IBOutlet weak var btnTermsAndPrivacy: UIButton!
    @IBOutlet weak var btnPrivacyPolicy: UIButton!
    @IBOutlet weak var termsPrivacySeprator: UILabel!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var sideicon_email: UIImageView!
    @IBOutlet weak var sideicon_phone: UIImageView!
    @IBOutlet weak var sideicon_password: UIImageView!
    @IBOutlet weak var sideicon_confirmPassword: UIImageView!
    @IBOutlet weak var sideicon_business: UIImageView!
    @IBOutlet weak var sideicon_name: UIImageView!
    @IBOutlet weak var btnExistingAccount: UIButton!
    @IBOutlet weak var btnPrivateHomeDelivery: UIButton!
    
    @IBOutlet weak var txtABN: CustomTextField!
    
    @IBOutlet weak var txtStreetAddress: CustomTextField!
    
    @IBOutlet var checkbox_mailing: UIButton!

    @IBOutlet weak var txtPostCode: CustomTextField!
    
    @IBOutlet weak var txtSuburb: CustomTextField!
    
    var activeTextField : UITextField?
    var latitude:Double = 0.00
    var longitude:Double = 0.00
    var isMailingSelected = Bool()

    
   
    @IBOutlet weak var sideicon_post_code: UIImageView!
    @IBOutlet weak var sideicon_post: UIImageView!
    @IBOutlet weak var sideicon_abn: UIImageView!
    
    @IBOutlet weak var sideicon_address: UIImageView!
    
    
    @IBAction func txtStreetAddressTextchange(_ sender: Any) {
        txtStreetAddress.resignFirstResponder()
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        // Set up the autocomplete filter.
        let filter = GMSAutocompleteFilter()
        filter.country = "au"
        acController.autocompleteFilter = filter
        present(acController, animated: true, completion: nil)
    }
    
    
    @IBAction func btnPrivateHomeDeliveryAction(_ sender: UIButton) {
        sender.isSelected.toggle()
        btnExistingAccount.isSelected.toggle();
    }
    //MARK: - - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnRegister.layer.cornerRadius = 10.0 * Configration.scalingFactor()
        btnTermsAndPrivacy.titleLabel?.font = UIFont.Roboto_Light(baseScaleSize: 15.0)
        btnPrivacyPolicy.titleLabel?.font = UIFont.Roboto_Light(baseScaleSize: 15.0)
        termsPrivacySeprator.font = UIFont.Roboto_Light(baseScaleSize: 15.0)
        back_btn.tintColor = UIColor.baseBlueColor()
        initializeSideIcons()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func initializeSideIcons()
    {
        sideicon_business.tintColor = UIColor.lightGray
        sideicon_name.tintColor = UIColor.lightGray
        sideicon_email.tintColor = UIColor.lightGray
        sideicon_phone.tintColor = UIColor.lightGray
        sideicon_password.tintColor = UIColor.lightGray
        sideicon_confirmPassword.tintColor = UIColor.lightGray
        sideicon_password.tintColor = UIColor.lightGray
        sideicon_abn.tintColor = UIColor.lightGray
        sideicon_post.tintColor = UIColor.lightGray
        sideicon_post.tintColor = UIColor.lightGray
        sideicon_address.tintColor = UIColor.lightGray
       
        btnExistingAccount.isSelected.toggle()
        
        checkbox_mailing.setImage(UIImage(named: "check1"), for: .normal)
        isMailingSelected = true

        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField = textField
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if UIScreen.main.bounds.height < 570
        {
            self.view.frame = CGRect(x: 0, y: -30, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
        if textField == txtBusinessName
        {
            sideicon_business.tintColor = UIColor.baseBlueColor()
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
        else if textField == txtFieldPhoneNumber
        {
            if txtFieldPhoneNumber.text?.count == 0{
                txtFieldPhoneNumber.text = "0"
            }
            sideicon_phone.tintColor = UIColor.baseBlueColor()
        }
        else if textField == txtFieldPassword
        {
            sideicon_password.tintColor = UIColor.baseBlueColor()
        }
        else if textField == txtFieldConfirmPassword
        {
            sideicon_confirmPassword.tintColor = UIColor.baseBlueColor()
        }
        else if textField == txtABN
        {
            sideicon_abn.tintColor = UIColor.baseBlueColor()
        }
        else if textField == txtStreetAddress
        {
            sideicon_address.tintColor = UIColor.baseBlueColor()
        }
    
        else if textField == txtSuburb
        {
            sideicon_post.tintColor = UIColor.baseBlueColor()
        }
        else if textField == txtPostCode
        {
            sideicon_post_code.tintColor = UIColor.baseBlueColor()
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if UIScreen.main.bounds.height < 570
        {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
        
        textField.textColor = AppConfig.darkGreyColor()
        
        if textField == txtBusinessName
        {
            sideicon_business.tintColor = UIColor.lightGray
        }
        else if textField == txtName
        {
            sideicon_name.tintColor = UIColor.lightGray
        }
        else if textField == txtFieldEmalAddress
        {
            sideicon_email.tintColor = UIColor.lightGray
        }
        else if textField == txtFieldPhoneNumber
        {
            sideicon_phone.tintColor = UIColor.lightGray
        }
        else if textField == txtFieldPassword
        {
            sideicon_password.tintColor = UIColor.lightGray
        }
        else if textField == txtFieldConfirmPassword
        {
            txtFieldPassword.textColor = UIColor.errorTextFieldColor()
            txtFieldConfirmPassword.textColor = UIColor.errorTextFieldColor()
            sideicon_confirmPassword.tintColor = UIColor.lightGray
            sideicon_password.tintColor = UIColor.lightGray
        }
        else if textField == txtABN
        {
            sideicon_abn.tintColor = UIColor.lightGray
        }
        else if textField == txtStreetAddress
        {
            sideicon_address.tintColor = UIColor.lightGray
        }
        
        else if textField == txtSuburb
        {
            sideicon_post.tintColor = UIColor.lightGray
        }
        else if textField == txtPostCode
        {
            sideicon_post_code.tintColor = UIColor.lightGray
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
            if textField == txtFieldPassword || textField == txtFieldConfirmPassword {
                return newText.count<=25
            }else if textField == txtFieldPhoneNumber{
            return newText.count<=10
                
            }
            else if textField == txtPostCode{
            return newText.count<=4
            }
            else if textField == txtABN{
            return newText.count<=11
            }
            else{
                return newText.count<=50
            }
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
            else if (txtFieldPhoneNumber.text?.count)! < 10 || !(txtFieldPhoneNumber.text?.starts(with: "0"))!
                   {
                       txtFieldPhoneNumber.becomeFirstResponder()
                       txtFieldPhoneNumber.textColor = UIColor.errorTextFieldColor()
                       sideicon_phone.tintColor = UIColor.errorTextFieldColor()
                       Helper.shared.showAlertOnController( message: "Invalid mobile number. Please ensure it is exactly 10 numbers and it should start with a 0", title: CommonString.alertTitle)
                   }
        else if (txtStreetAddress.text?.count)! < 2
        {
            txtStreetAddress.becomeFirstResponder()
            txtStreetAddress.textColor = UIColor.errorTextFieldColor()
            sideicon_address.tintColor = UIColor.errorTextFieldColor()
            Helper.shared.showAlertOnController( message: "Please enter a valid street address.", title: CommonString.alertTitle)
        }
        else if (txtSuburb.text?.count)! < 2
        {
            txtSuburb.becomeFirstResponder()
            txtSuburb.textColor = UIColor.errorTextFieldColor()
            sideicon_post.tintColor = UIColor.errorTextFieldColor()
            Helper.shared.showAlertOnController( message: "Please enter a valid suburb name.", title: CommonString.alertTitle)
        }
        else if (txtPostCode.text?.count)! < 2
        {
            txtPostCode.becomeFirstResponder()
            txtPostCode.textColor = UIColor.errorTextFieldColor()
            sideicon_post_code.tintColor = UIColor.errorTextFieldColor()
            Helper.shared.showAlertOnController( message: "Please enter a valid Post Code.", title: CommonString.alertTitle)
        }
        else if (txtBusinessName.text?.count)! < 2
        {
            txtBusinessName.becomeFirstResponder()
            txtBusinessName.textColor = UIColor.errorTextFieldColor()
            sideicon_business.tintColor = UIColor.errorTextFieldColor()
            Helper.shared.showAlertOnController( message: "Please enter a valid business name.", title: CommonString.alertTitle)
        }
        else if txtFieldEmalAddress.text?.isValidEmailAddressFormat() == false
        {
            txtFieldEmalAddress.becomeFirstResponder()
            txtFieldEmalAddress.textColor = UIColor.errorTextFieldColor()
            sideicon_email.tintColor = UIColor.errorTextFieldColor()
            Helper.shared.showAlertOnController( message: "Please enter a valid email address.", title: CommonString.alertTitle)
        }
       
            
        else if (txtFieldPassword.text?.count)! < 8
        {
            txtFieldPassword.becomeFirstResponder()
            txtFieldPassword.textColor = UIColor.errorTextFieldColor()
            sideicon_password.tintColor = UIColor.errorTextFieldColor()
            Helper.shared.showAlertOnController( message: "Password should contain minimum 8 characters.", title: CommonString.alertTitle)
        }
        else if txtFieldPassword.text?.isValidPassword() == false
        {
            txtFieldPassword.becomeFirstResponder()
            txtFieldPassword.textColor = UIColor.errorTextFieldColor()
            sideicon_password.tintColor = UIColor.errorTextFieldColor()
            Helper.shared.showAlertOnController( message: "Password should contain atleast one uppercase letter, one special character and one number.", title: CommonString.alertTitle)
        }
        else if btnPrivateHomeDelivery.isSelected
        {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: "Are you a Private Home Delivery customer?", withCancelButtonTitle: "No") {
                
                self.txtFieldPassword.textColor = AppConfig.darkGreyColor()
                self.sideicon_password.tintColor = UIColor.lightGray
                
                self.callRegistrationWebService()
            }
        }
            
        else
        {
            txtFieldPassword.textColor = AppConfig.darkGreyColor()
            sideicon_password.tintColor = UIColor.lightGray
            
            self.callRegistrationWebService()
        }
    }
    
    
    func callRegistrationWebService()
    {
        let strUrl = SyncEngine.baseURL + SyncEngine.Register
        
        let registrationDIc = [
            "Email": txtFieldEmalAddress.text!,
            "Password": txtFieldPassword.text!,
            "ConfirmPassword": txtFieldPassword.text!,
            "FirstName": txtName.text!,
            "LastName": "",
            "DeviceToken": "",
            "DeviceType": "iPhone",
            "UserTypeID": 4,
            "UserName": "",
            "Phone" : txtFieldPhoneNumber.text ?? "",
            "BusinessName" : txtBusinessName.text!,
            "ExistingAccount":self.btnPrivateHomeDelivery.isSelected,
            "ABN":txtABN.text!,
            "StreetAddress":txtStreetAddress.text!,
            "Suburb":txtSuburb.text!,
            "Postcode":txtPostCode.text!,
            "Latitude":latitude,
            "Longitude":longitude,
            "JoinMailingList":isMailingSelected
            ] as Dictionary<String,Any>
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: registrationDIc, strURL: strUrl) { (response : Any) in
            DispatchQueue.main.async
                {
                    
                    self.navigationController?.popViewController(animated: true)
                    Helper.shared.showAlertOnController( message: "Registered successfully.", title: CommonString.app_name, hideOkayButton: true)
                    Helper.shared.dismissAlert()
            }
        }
    }
    
    @IBAction func btnExistingAccountAction(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        btnPrivateHomeDelivery.isSelected.toggle();
    }
    //    @IBAction func btnPrivateHomeDeliveryAction(_ sender: UIButton) {
    //
    //        sender.isSelected.toggle()
    //        btnExistingAccount.isSelected.toggle();
    //    }
    
    @IBAction func termsAndConditionAction(_ sender: Any)
    {
        if let termsAncConditions = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "saaviWebViewStoryboardID") as? SaaviWebView
        {
            let navController = UINavigationController(rootViewController: termsAncConditions)
            if let htmlFilePath = Bundle.main.url(forResource: "TermsOfUse", withExtension: "html")?.absoluteString
            {
                termsAncConditions.urlAddress = htmlFilePath
                termsAncConditions.senderView = nil
                self.present(navController, animated: true, completion: nil)
                Helper.shared.setNavigationTitle(withTitle: "Terms & Conditions", withLeftButton: .backButton, onController: termsAncConditions)
                //termsAncConditions.saaviWebView.scalesPageToFit = false
            }
        }
    }
    
    @IBAction func privacyPolicyAction(_ sender: UIButton?)
    {
        if let privacyPolicy = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "saaviWebViewStoryboardID") as? SaaviWebView
        {
            let navController = UINavigationController(rootViewController: privacyPolicy)
            if let htmlFilePath = Bundle.main.url(forResource: "PrivacyPolicy", withExtension: "html")?.absoluteString
            {
                privacyPolicy.urlAddress = htmlFilePath
                Helper.shared.setNavigationTitle(withTitle: "Privacy Policy", withLeftButton: .backButton, onController: privacyPolicy)
                self.present(navController, animated: true, completion: nil)
                //privacyPolicy.saaviWebView.scalesPageToFit = false
            }
        }
    }
    
    @IBAction func CheckboxMailingButton(_ sender: UIButton)
    {
        if isMailingSelected == true
        {
            checkbox_mailing.setImage(UIImage(named: "unCheck1"), for: .normal)
            isMailingSelected = false
        }
        else
        {
            checkbox_mailing.setImage(UIImage(named: "check1"), for: .normal)
            isMailingSelected = true

        }
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
        
        // ATTRIBUTED PLACEHOLDERS FOR TEXT FIELDS
        let myString:NSString = "First Name and Last Name*"
        var myMutableString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(string: myString as
            String, attributes: [NSAttributedStringKey.font:UIFont(name: "Roboto-Italic", size: 18.0)!])
        myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedStringKey.font:UIFont(name: "Roboto-Italic", size: 18.0)!])
        myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSRange(location:24,length:1))
        txtName.attributedPlaceholder = myMutableString
        
        let myString_phone:NSString = "Mobile or Phone Number*"
        var myMutableString_phone = NSMutableAttributedString()
        myMutableString_phone = NSMutableAttributedString(string: myString_phone as
            String, attributes: [NSAttributedStringKey.font:UIFont(name: "Roboto-Italic", size: 18.0)!])
        myMutableString_phone = NSMutableAttributedString(string: myString_phone as String, attributes: [NSAttributedStringKey.font:UIFont(name: "Roboto-Italic", size: 18.0)!])
        myMutableString_phone.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSRange(location:22,length:1))
        txtFieldPhoneNumber.attributedPlaceholder = myMutableString_phone
        
        let myString_address:NSString = "Street Address*"
        var myMutableString_address = NSMutableAttributedString()
        myMutableString_address = NSMutableAttributedString(string: myString_address as
            String, attributes: [NSAttributedStringKey.font:UIFont(name: "Roboto-Italic", size: 18.0)!])
        myMutableString_address = NSMutableAttributedString(string: myString_address as String, attributes: [NSAttributedStringKey.font:UIFont(name: "Roboto-Italic", size: 18.0)!])
        myMutableString_address.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSRange(location:14,length:1))
        txtStreetAddress.attributedPlaceholder = myMutableString_address
        
        let myString_suburb:NSString = "Suburb*"
        var myMutableString_suburb = NSMutableAttributedString()
        myMutableString_suburb = NSMutableAttributedString(string: myString_suburb as
            String, attributes: [NSAttributedStringKey.font:UIFont(name: "Roboto-Italic", size: 18.0)!])
        myMutableString_suburb = NSMutableAttributedString(string: myString_suburb as String, attributes: [NSAttributedStringKey.font:UIFont(name: "Roboto-Italic", size: 18.0)!])
        myMutableString_suburb.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSRange(location:6,length:1))
        txtSuburb.attributedPlaceholder = myMutableString_suburb
        
        let myString_pcode:NSString = "Post Code*"
        var myMutableString_pcode = NSMutableAttributedString()
        myMutableString_pcode = NSMutableAttributedString(string: myString_pcode as
            String, attributes: [NSAttributedStringKey.font:UIFont(name: "Roboto-Italic", size: 18.0)!])
        myMutableString_pcode = NSMutableAttributedString(string: myString_pcode as String, attributes: [NSAttributedStringKey.font:UIFont(name: "Roboto-Italic", size: 18.0)!])
        myMutableString_pcode.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSRange(location:9,length:1))
        txtPostCode.attributedPlaceholder = myMutableString_pcode
        
        let myString_email:NSString = "Email*"
        var myMutableString_email = NSMutableAttributedString()
        myMutableString_email = NSMutableAttributedString(string: myString_email as
            String, attributes: [NSAttributedStringKey.font:UIFont(name: "Roboto-Italic", size: 18.0)!])
        myMutableString_email = NSMutableAttributedString(string: myString_email as String, attributes: [NSAttributedStringKey.font:UIFont(name: "Roboto-Italic", size: 18.0)!])
        myMutableString_email.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSRange(location:5,length:1))
        txtFieldEmalAddress.attributedPlaceholder = myMutableString_email

        let myString_pass:NSString = "Password*"
        var myMutableString_pass = NSMutableAttributedString()
        myMutableString_pass = NSMutableAttributedString(string: myString_pass as
            String, attributes: [NSAttributedStringKey.font:UIFont(name: "Roboto-Italic", size: 18.0)!])
        myMutableString_pass = NSMutableAttributedString(string: myString_pass as String, attributes: [NSAttributedStringKey.font:UIFont(name: "Roboto-Italic", size: 18.0)!])
        myMutableString_pass.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSRange(location:8,length:1))
        txtFieldPassword.attributedPlaceholder = myMutableString_pass
        
        
        let myString_bName:NSString = "Business Name*"
        var myMutableString_bName = NSMutableAttributedString()
        myMutableString_bName = NSMutableAttributedString(string: myString_bName as
            String, attributes: [NSAttributedStringKey.font:UIFont(name: "Roboto-Italic", size: 18.0)!])
        myMutableString_bName = NSMutableAttributedString(string: myString_bName as String, attributes: [NSAttributedStringKey.font:UIFont(name: "Roboto-Italic", size: 18.0)!])
        myMutableString_bName.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSRange(location:13,length:1))
        txtBusinessName.attributedPlaceholder = myMutableString_bName
        
        let myString_abn:NSString = "ABN (Optional)"
        var myMutableString_abn = NSMutableAttributedString()
        myMutableString_abn = NSMutableAttributedString(string: myString_abn as
            String, attributes: [NSAttributedStringKey.font:UIFont(name: "Roboto-Italic", size: 18.0)!])
        myMutableString_abn = NSMutableAttributedString(string: myString_abn as String, attributes: [NSAttributedStringKey.font:UIFont(name: "Roboto-Italic", size: 18.0)!])
        txtABN.attributedPlaceholder = myMutableString_abn

        
    }
    
    
    @IBAction func goBackAction(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
        Helper.shared.logOutUser()
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        print(place.addressComponents)
        
        for component in place.addressComponents! {
            print(component.type)
            if(component.type == "postal_code"){
                txtPostCode.text = component.name
            }
            else if(component.type == "locality"){
                txtSuburb.text = component.name
            }
        }
        txtStreetAddress.text = place.name
        // Dismiss the GMSAutocompleteViewController when something is selected
        dismiss(animated: true, completion: nil)
        
        latitude = place.coordinate.latitude
        longitude = place.coordinate.longitude
        
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // Handle the error
        print("Error: ", error.localizedDescription)
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        // Dismiss when the user canceled the action
        dismiss(animated: true, completion: nil)
    }
    
}
