//
//  AddNotePopupVC.swift
//  Saavi
//
//  Created by goMad on 02/07/20.
//  Copyright © 2020 Saavi. All rights reserved.
//

import UIKit

class AddNotePopupVC: UIViewController, UITextFieldDelegate{
    
    
    
    
    @IBOutlet weak var titleAddNote: CustomTextField!
    
   
    @IBOutlet weak var btnBack: CustomButton!
    @IBOutlet weak var etNotes: UILabel!
    @IBOutlet weak var btnAddNote: CustomButton!
    
    typealias notedAddredCompleted = (_ status: DateButtonPressed?) -> Void
    
    // Handle completion if needed.
    var completionBlock :notedAddredCompleted? = nil
    

    //MARK: - - Life Cycle
       override func viewDidLoad() {
           super.viewDidLoad()
        
              titleAddNote.sizeToFit()
        
        
       //    btnAddNote.layer.cornerRadius = 10.0 * Configration.scalingFactor()
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
        
        
        if textField == titleAddNote {
            self.animateViewMoving(up: true, moveValue: 150)
        }else{
            self.animateViewMoving(up: true, moveValue: 380)
       
        }
}
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if textField == titleAddNote{
            self.animateViewMoving(up: false, moveValue: 0)
        }else{
            self.animateViewMoving(up: false, moveValue: 0)
        }
    }
       
       override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
           // Dispose of any resources that can be recreated.
       }
       
       
       
       
       @IBAction func signupUserAction(_ sender: Any) {
           
        
           
           if (titleAddNote.text?.count)! < 3
           {
               titleAddNote.becomeFirstResponder()
               titleAddNote.textColor = UIColor.errorTextFieldColor()
                Helper.shared.showAlertOnController( message: "Please enter a valid note.", title: CommonString.alertTitle)
           }
         
               
          
    
         
               
           else
           {
               
               self.callRegistrationWebService()
           }
       }
       
       
       func callRegistrationWebService()
       {
           let strUrl = SyncEngine.baseURL + SyncEngine.AddCustomerNotes
           let df = DateFormatter()
          df.dateFormat = "yyyy-MM-dd'T'hh:mm:ss.sssZ"
           var registrationDIc = [
               "Note": titleAddNote.text!,
               "CustomerID": UserInfo.shared.customerID!,
               "UserID": UserInfo.shared.userId!,
               "DateTime": df.string(from:Date())
              
               ] as Dictionary<String,Any>
           
              
              SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: registrationDIc, strURL: strUrl) { (response : Any) in
               DispatchQueue.main.async
                   {
                       
                       self.navigationController?.popViewController(animated: true)
                       self.dismiss(animated: true,completion: {
                           if self.completionBlock != nil
                           {
                               self.completionBlock!(.moveNext)
                           }
                       })
                
                       
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
        self.dismiss(animated: true,completion: nil)
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
