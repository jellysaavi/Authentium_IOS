//
//  SaaviActionAlert.swift
//  Saavi
//
//  Created by Sukhpreet on 06/10/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit
import GooglePlaces

class AddAddressVC: UIViewController,UITextFieldDelegate,GMSAutocompleteViewControllerDelegate {
    
    static let storyboardIdentifier = "AddAddressVC"
    static let shared = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddAddressVC") as! AddAddressVC
    
    typealias proceedCompletionBlock = (_ totalCart : Double , _ discount :Double) -> Void
    
    @IBOutlet weak var lblStaticPopupHeading: UILabel!
    
    
    @IBOutlet weak var tfSteetAddress: CustomTextField!
    
    @IBOutlet weak var btnCancel: CustomButton!
    @IBOutlet weak var btnOK: CustomButton!
    @IBOutlet weak var iconPostCode: UIImageView!
    @IBOutlet weak var iconStreetAddress: UIImageView!
    @IBOutlet weak var tfMobile: CustomTextField!
    @IBOutlet weak var etPostCode: CustomTextField!
    @IBOutlet weak var tfSuburb: CustomTextField!
    @IBOutlet weak var iconSuburb: UIImageView!
    
    @IBOutlet weak var tfContactName: CustomTextField!
    @IBOutlet weak var iconPhone: UIImageView!
    
    @IBOutlet weak var iconContactName: UIImageView!
    var completionBlock :proceedCompletionBlock? = nil
    
    @IBAction func StreetAddressAction(_ sender: Any) {
        self.tfSteetAddress.resignFirstResponder()
               let acController = GMSAutocompleteViewController()
               acController.delegate = self
               // Set up the autocomplete filter.
               let filter = GMSAutocompleteFilter()
               filter.country = "au"
               acController.autocompleteFilter = filter
               present(acController, animated: true, completion: nil)
    }
    @IBOutlet weak var popupBoundingBox: UIView!
    var acceptBtnTitle = ""
    var declineBtnTitle = ""
    var popupTitle = ""
    var popupMessage = ""
    var hideOkayButton = false
    var cartId :NSNumber = 0.0
    var latitude:Double = 0.00
    var longitude:Double = 0.00
    
    //    MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        DispatchQueue.main.async {
            self.lblStaticPopupHeading.font = UIFont.SFUI_SemiBold(baseScaleSize: 17.0)
            self.popupBoundingBox.layer.cornerRadius = 7.0 * Configration.scalingFactor()
            self.popupBoundingBox.layer.borderWidth = 0.7
            self.popupBoundingBox.layer.borderColor = UIColor.baseBlueColor().cgColor
            self.lblStaticPopupHeading.textColor = UIColor.black
            self.initializeSideIcons()
           
        }
    }
    
    func initializeSideIcons()
      {
          tfMobile.delegate = self
          
          iconSuburb.tintColor = UIColor.lightGray
          iconPostCode.tintColor = UIColor.lightGray
          iconStreetAddress.tintColor = UIColor.lightGray
          iconPhone.tintColor = UIColor.lightGray
          iconContactName.tintColor = UIColor.lightGray
           }
    override func viewDidDisappear(_ animated: Bool) {
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    MARK:- Button Actions
    
    @IBAction func cancelActioin(_ sender: Any) {
        if self.presentingViewController != nil
               {
                   self.dismiss(animated: false, completion: nil)
                self.completionBlock!(0.0,0.0)
                   print("Dismissed from window")
               }
               else
               {
                   self.view.removeFromSuperview()
                self.completionBlock!(0.0,0.0)
                   print("Removed from on window")
               }
               
               if acceptBtnTitle == ""
               {
                   self.completionBlock!(0.0,0.0)
               }
    }
    
    
    @IBAction func submitAction(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if (tfContactName.text?.count)! < 3
              {
                  tfContactName.becomeFirstResponder()
                  tfContactName.textColor = UIColor.errorTextFieldColor()
                  iconContactName.tintColor = UIColor.errorTextFieldColor()
                  Helper.shared.showAlertOnController( message: "Please enter a valid name.", title: CommonString.alertTitle)
              }
        else if (tfMobile.text?.count)! < 10 || !(tfMobile.text?.starts(with: "0"))!
            {
                tfMobile.becomeFirstResponder()
                tfMobile.textColor = UIColor.errorTextFieldColor()
                tfMobile.tintColor = UIColor.errorTextFieldColor()
                
                    Helper.shared.showAlertOnController( message: "Invalid mobile number. Please ensure it is exactly 10 numbers and it should start with a 0", title: CommonString.alertTitle)
            }
              else if (tfSteetAddress.text?.count)! < 2
              {
                  tfSteetAddress.becomeFirstResponder()
                  tfSteetAddress.textColor = UIColor.errorTextFieldColor()
                  iconStreetAddress.tintColor = UIColor.errorTextFieldColor()
                  Helper.shared.showAlertOnController( message: "Please enter a valid street address.", title: CommonString.alertTitle)
              }
              else if (tfSuburb.text?.count)! < 2
              {
                  tfSuburb.becomeFirstResponder()
                  tfSuburb.textColor = UIColor.errorTextFieldColor()
                  iconSuburb.tintColor = UIColor.errorTextFieldColor()
                  Helper.shared.showAlertOnController( message: "Please enter a valid suburb name.", title: CommonString.alertTitle)
              }
              else if (etPostCode.text?.count)! < 2
              {
                  etPostCode.becomeFirstResponder()
                  etPostCode.textColor = UIColor.errorTextFieldColor()
                  iconPostCode.tintColor = UIColor.errorTextFieldColor()
                  Helper.shared.showAlertOnController( message: "Please enter a valid Post Code.", title: CommonString.alertTitle)
        }
        else{
            let strUrl = SyncEngine.baseURL + SyncEngine.addAddress
             let registrationDIc = [
                "ContactName": tfContactName.text!,
                "UserTypeID": 4,
                "Phone":tfMobile.text!,
                "StreetAddress":tfSteetAddress.text!,
                "Suburb":tfSuburb.text!,
                "Postcode":etPostCode.text!,
                "CustomerID": UserInfo.shared.customerID
                 ] as Dictionary<String,Any>
            
            SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: registrationDIc, strURL: strUrl) { (response : Any) in
                DispatchQueue.main.async
                    {
                        
                        if let obj = response as? Dictionary<String,Any>, let cartCount = obj["AddressID"] as? NSNumber
                                   {
                                           UserInfo.shared.justAdded = cartCount
                                         
                                   }
                        
                        
                        if self.presentingViewController != nil
                                  {
                                    
                                      self.dismiss(animated: false, completion: nil)
                                      print("Dismissed from window")
                                  }
                                  else
                                  {
                                      self.view.removeFromSuperview()
                                      print("Removed from on window")
                                  }
                        
                        self.completionBlock!(1.0,1.0)
                        
                }
            }
        }
        
    }
    
    
    func reinitializeVariables()
    {
        
    }
    
    
    func showCommonAlertOnWindow(cartID: NSNumber ,completion:@escaping proceedCompletionBlock)
    {
        completionBlock = completion
         DispatchQueue.main.async {
        if UIApplication.shared.keyWindow?.rootViewController?.presentedViewController == nil
        {
            UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: false, completion: {})
        }
        else
        {
            UIApplication.shared.keyWindow?.addSubview(self.view)
            UIApplication.shared.keyWindow?.bringSubview(toFront: self.view)
        }
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if UIScreen.main.bounds.height < 570
        {
            self.view.frame = CGRect(x: 0, y: -30, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
        if textField == tfContactName
        {
            iconContactName.tintColor = UIColor.baseBlueColor()
        }
        else if textField == tfMobile
        {
            if tfMobile.text?.count == 0{
                tfMobile.text = "0"
            }
            iconPhone.tintColor = UIColor.baseBlueColor()
        }
        else if textField == tfSteetAddress
        {
            iconStreetAddress.tintColor = UIColor.baseBlueColor()
        }
        else if textField == tfSuburb
        {
            iconSuburb.tintColor = UIColor.baseBlueColor()
        }
        else if textField == etPostCode
        {
            iconPostCode.tintColor = UIColor.baseBlueColor()
        }
       
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if UIScreen.main.bounds.height < 570
        {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
        
        textField.textColor = AppConfig.darkGreyColor()
        
        if textField == tfContactName
        {
            iconContactName.tintColor = UIColor.lightGray
        }
        else if textField == tfMobile
        {
            iconPhone.tintColor = UIColor.lightGray
        }
        else if textField == tfSteetAddress
        {
            iconStreetAddress.tintColor = UIColor.lightGray
        }
        else if textField == tfSuburb
        {
            iconSuburb.tintColor = UIColor.lightGray
        }
        else if textField == etPostCode
        {
            iconPostCode.tintColor = UIColor.lightGray
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
            if textField == tfMobile{
                return newText.count<=10
            }
            else{
                return newText.count<=50
            }
            
        }
        
        return true
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
          
          print(place.addressComponents)
          
          for component in place.addressComponents! {
              print(component.type)
              if(component.type == "postal_code"){
                  etPostCode.text = component.name
              }
              else if(component.type == "locality"){
                  tfSuburb.text = component.name
              }
          }
          tfSteetAddress.text = place.name
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

