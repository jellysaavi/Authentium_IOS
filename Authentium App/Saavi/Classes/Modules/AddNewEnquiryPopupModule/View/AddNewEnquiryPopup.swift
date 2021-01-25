//
//  AddNewEnquiryPopup.swift
//  Saavi
//
//  Created by Sukhpreet on 05/09/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class AddNewEnquiryPopup: UIViewController, UIGestureRecognizerDelegate, UITextViewDelegate {
    @IBOutlet weak var lblTitleOfPopup: UILabel!
    @IBOutlet weak var txtVWEnquiryText: UITextView!
    @IBOutlet weak var btnSubmit: CustomButton!
    @IBOutlet weak var popupView: UIView!
    var parentView : UIViewController?
    
    var itemForEnquiry : Dictionary<String,Any>?
    
//    MARK:- View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblTitleOfPopup.font = UIFont.SFUI_SemiBold(baseScaleSize: 18.0)
        popupView.layer.cornerRadius = 7.0 * Configration.scalingFactor()
        txtVWEnquiryText.delegate = self

        let tapReco : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hidePopupAction(reco:)))
        tapReco.numberOfTapsRequired  = 1
        tapReco.cancelsTouchesInView = false
        tapReco.delegate = self
        self.view.addGestureRecognizer(tapReco)
        
        self.txtVWEnquiryText.text = "Enter Item Enquiry"
        self.txtVWEnquiryText.textColor = UIColor.lightGray
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    MARK:- Button Actions

    
    @IBAction func submitQueryAction(_ sender: CustomButton)
    {
        self.view.endEditing(true)
        if self.txtVWEnquiryText.text == "" || self.txtVWEnquiryText.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0 || self.txtVWEnquiryText.text == "Enter Item Enquiry"
        {
            Helper.shared.showAlertOnController( message: "Please add query", title: CommonString.alertTitle)
        }
        else
        {
            self.sendItemEnquiry()
        }
    }
    
    @objc func hidePopupAction(reco : UITapGestureRecognizer)
    {
        if self.txtVWEnquiryText.isFirstResponder
        {
            self.view.endEditing(true)
        }
        else if  reco.view == self.view
        {
            self.dismiss(animated: false, completion: nil)
            self.view.endEditing(true)
        }
    }
    
    //    MARK:- Gestures

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == self.view
        {
            return true
        }
        return false
    }
    
    //    MARK:- API Call

    
    func sendItemEnquiry()
    {
        if self.itemForEnquiry != nil, let productId = self.itemForEnquiry!["ProductID"] as? NSNumber
        {
        let requestParameters = [
            "CustomerID": UserInfo.shared.customerID!,
            "ProductID": productId,
            "Comment": txtVWEnquiryText.text,
            "UserID": UserInfo.shared.userId!
            ]  as [String : Any]
        
        let serviceURL = SyncEngine.baseURL + SyncEngine.sendItemEnquiry
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestParameters , strURL: serviceURL) { (response : Any) in
                self.view.endEditing(true)
            DispatchQueue.main.async {
                self.dismiss(animated: false, completion:{
                    if self.parentView != nil
                    {
                        Helper.shared.showAlertOnController(message: "We have received your query. Our representative will get back to you on this soon.", title: "Thanks")
                    }
                })
            }
        }
    }
    else
        {
            Helper.shared.showAlertOnController( message: "Invalid request", title: CommonString.alertTitle)
        }
    }

    
    //    MARK:- Text view delegates

    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text == "", text == " "
        {
            return false
        }
        else if (textView.text as NSString).replacingCharacters(in: range, with: text).contains("  ")
        {
            return false
        }
        else if text == "\n"
        {
            textView.resignFirstResponder()
            textView.endEditing(true)
        }
        else{
           let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            return newText.count<=200
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if textView.text == "Enter Item Enquiry"
        {
        self.txtVWEnquiryText.text = ""
        self.txtVWEnquiryText.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            self.txtVWEnquiryText.text = "Enter Item Enquiry"
            self.txtVWEnquiryText.textColor = UIColor.lightGray
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

}
