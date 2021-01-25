//
//  SignupViewController.swift
//  Saavi
//
//  Created by Sukhpreet on 16/06/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit
import GooglePlaces

class GenerateQuotePopupVC: UIViewController, UITextFieldDelegate,GMSAutocompleteViewControllerDelegate {
    
    //MARK: - - Outlets
    @IBOutlet weak var txtName : CustomTextField!
    @IBOutlet weak var txtBusinessName: CustomTextField!
    @IBOutlet weak var txtABN: CustomTextField!
    @IBOutlet weak var txtFieldPhoneNumber: CustomTextField!
    @IBOutlet weak var txtStreetAddress: CustomTextField!
    @IBOutlet weak var txtSuburb: CustomTextField!
    @IBOutlet weak var txtPostCode: CustomTextField!
    @IBOutlet weak var txtFieldEmalAddress: CustomTextField!
    
    @IBOutlet weak var btnRegister: CustomButton!

    @IBOutlet weak var sideicon_email: UIImageView!
    @IBOutlet weak var sideicon_phone: UIImageView!
    @IBOutlet weak var sideicon_business: UIImageView!
    @IBOutlet weak var sideicon_name: UIImageView!

    
    
    
    @IBOutlet var btnCancel: CustomButton!
    
    
    var activeTextField : UITextField?
    var latitude:Double = 0.00
    var longitude:Double = 0.00
    var products = Array<Dictionary<String,Any>>()
    
    
    @IBOutlet weak var sideicon_post: UIImageView!
    @IBOutlet weak var sideicon_abn: UIImageView!
    @IBOutlet weak var sideicon_post_code: UIImageView!
    @IBOutlet weak var sideicon_address: UIImageView!
    
    
    @IBAction func btnCancelAction(_ sender: Any) {
        dismiss(animated: true) {
            
        }
    }
    
    
    @IBAction func txtStreeetAddreeChange(_ sender: Any) {
        txtStreetAddress.resignFirstResponder()
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        // Set up the autocomplete filter.
        let filter = GMSAutocompleteFilter()
        filter.country = "au"
        acController.autocompleteFilter = filter
        present(acController, animated: true, completion: nil)
    }
    
   
    
    
   
    //MARK: - - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnRegister.layer.cornerRadius = 10.0 * Configration.scalingFactor()
        initializeSideIcons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.sharedManager().enable = true

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.sharedManager().enable = false

    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func initializeSideIcons()
    {
        btnRegister.isUserInteractionEnabled = true
        sideicon_business.tintColor = UIColor.lightGray
        sideicon_name.tintColor = UIColor.lightGray
        sideicon_email.tintColor = UIColor.lightGray
        sideicon_phone.tintColor = UIColor.lightGray
        sideicon_post.tintColor = UIColor.lightGray
        sideicon_post_code.tintColor = UIColor.lightGray
        sideicon_address.tintColor = UIColor.lightGray
        
       
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
        
        
        if textField == txtName || textField == txtBusinessName || textField == txtABN || textField == txtFieldPhoneNumber{
            self.animateViewMoving(up: true, moveValue: 150)
        }else{
            self.animateViewMoving(up: true, moveValue: 380)
        }
//       txtStreetAddress: CustomTextField!  if UIScreen.main.bounds.height < 570
//        {
//            self.view.frame = CGRect(x: 0, y: -30, width: self.view.frame.size.width, height: self.view.frame.size.height)
//        }
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
            sideicon_phone.tintColor = UIColor.baseBlueColor()
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
        if textField == txtName || textField == txtBusinessName || textField == txtABN || textField == txtFieldPhoneNumber{
            self.animateViewMoving(up: false, moveValue: 0)
        }else{
            self.animateViewMoving(up: false, moveValue: 0)
        }
//        if UIScreen.main.bounds.height < 570
//        {
//            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
//        }
        
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
       else if (txtBusinessName.text?.count)! < 3
        {
            txtBusinessName.becomeFirstResponder()
            txtBusinessName.textColor = UIColor.errorTextFieldColor()
            sideicon_business.tintColor = UIColor.errorTextFieldColor()
            Helper.shared.showAlertOnController( message: "Please enter a business name.", title: CommonString.alertTitle)
        }
        else if (txtFieldPhoneNumber.text?.count)! < 10 || (txtFieldPhoneNumber.text?.count)! > 12
        {
            txtFieldPhoneNumber.becomeFirstResponder()
            txtFieldPhoneNumber.textColor = UIColor.errorTextFieldColor()
            sideicon_phone.tintColor = UIColor.errorTextFieldColor()
            Helper.shared.showAlertOnController( message: "Please enter a valid phone number.", title: CommonString.alertTitle)
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
        let strUrl = SyncEngine.baseURL + SyncEngine.GanerateQuote
        
        var registrationDIc = [
            "Email": txtFieldEmalAddress.text!,
            "ContactName": txtName.text!,
            "Phone" : txtFieldPhoneNumber.text ?? "",
            "BusinessName" : txtBusinessName.text!,
            "Address":txtStreetAddress.text!,
            "Suburb":txtSuburb.text!,
            "PostalCode":txtPostCode.text!,
           
            ] as Dictionary<String,Any>
        
           registrationDIc["Products"]  = products
        
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
    
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        for component in place.addressComponents! {
            if(component.type == "postal_code"){
                txtPostCode.text = component.name
            }
            else if(component.type == "administrative_area_level_2"){
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
