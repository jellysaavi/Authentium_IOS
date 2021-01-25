//
//  InvoiceEmailGeneratorView.swift
//  Saavi
//
//  Created by Sukhpreet on 29/09/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class InvoiceEmailGeneratorView: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    static let invoiceEmailGeneratorStoryboardIdentifier = "invoiceEmailGeneratorStoryboardID"
    
    @IBOutlet weak var labelTitleOfPopup: UILabel!
    @IBOutlet weak var btnOk: CustomButton!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var txtFldEmail: CustomTextField!
    @IBOutlet weak var txtFldFrom: CustomTextField!
    @IBOutlet weak var txtFldTo: CustomTextField!

    let datePickerView = UIDatePicker()
    let datePickerView2 = UIDatePicker()
    
    var startDate = Date()
    var endDate = Date()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapReco : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hidePopupAction(reco:)))
        tapReco.numberOfTapsRequired  = 1
        tapReco.cancelsTouchesInView = false
        tapReco.delegate = self
        self.view.addGestureRecognizer(tapReco)

        labelTitleOfPopup.font = UIFont.SFUI_SemiBold(baseScaleSize: 18.0)
        popupView.layer.cornerRadius = 7.0 * Configration.scalingFactor()
        
        self.txtFldTo.applyBorder()
        self.txtFldFrom.applyBorder()
        self.txtFldEmail.applyBorder()

        datePickerView.datePickerMode = UIDatePickerMode.date
        txtFldFrom.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(datePickerValueFromChanged), for: UIControlEvents.valueChanged)

        datePickerView2.datePickerMode = UIDatePickerMode.date
        txtFldTo.inputView = datePickerView2
        datePickerView2.addTarget(self, action: #selector(datePickerValueToChanged), for: UIControlEvents.valueChanged)

        
        // Do any additional setup after loading the view.
    }
    
    @objc func datePickerValueFromChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        dateFormatter.timeStyle = DateFormatter.Style.none
        
        txtFldFrom.text = dateFormatter.string(from: sender.date)
        
    }

    @objc func datePickerValueToChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        dateFormatter.timeStyle = DateFormatter.Style.none
        
        txtFldTo.text = dateFormatter.string(from: sender.date)
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func hidePopupAction(reco : UITapGestureRecognizer)
    {
        if self.txtFldEmail.isEditing || self.txtFldFrom.isEditing || self.txtFldTo.isEditing
        {
            self.view.endEditing(true)
        }
        else if  reco.view == self.view
        {
            self.dismiss(animated: false, completion: nil)
            self.view.endEditing(true)
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == self.view
        {
            return true
        }
        return false
    }
    
    @IBAction func sendInvoicesToEmail(_ sender: CustomButton)
    {
        self.view.endEditing(true)
        if !(self.txtFldEmail.text?.isValidEmailAddressFormat())!
        {
            Helper.shared.showAlertOnController( message: "Please enter a valid email address.", title: CommonString.alertTitle)
        }
        else if txtFldFrom.text == ""
        {
            Helper.shared.showAlertOnController( message: "Please choose start date for invoices.", title: CommonString.alertTitle)
        }
        else if txtFldTo.text == ""
        {
            Helper.shared.showAlertOnController( message: "Please choose end date for invoices.", title: CommonString.alertTitle)
        }
        else
        {
            
            let requestURL = SyncEngine.baseURL + SyncEngine.getUserInvoices
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            let requestDic = [
                "Email": txtFldEmail.text!,
                "FromDate": dateFormatter.string(from: datePickerView.date),
                "TillDate": dateFormatter.string(from: datePickerView2.date),
                "CustomerID": UserInfo.shared.customerID!,
                "UserID": UserInfo.shared.userId!
            ]
            
            
            SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestDic, strURL: requestURL, completion: { (response : Any) in
                DispatchQueue.main.async {
                    Helper.shared.showAlertOnController(message: "Invoices sent to \(self.txtFldEmail.text!).", title: "Invoice Generated")
                    self.dismiss(animated: false, completion: nil)
                }
            })
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if textField == txtFldEmail
        {
            textField.keyboardType = .emailAddress
        }
        else if textField == txtFldFrom
        {
            datePickerView.maximumDate = Date()
            self.datePickerValueFromChanged(sender: datePickerView)
        }
        else if textField == txtFldTo
        {
            datePickerView2.minimumDate = datePickerView.date
            datePickerView2.maximumDate = Date()
            self.datePickerValueToChanged(sender: datePickerView2)
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text == "", string == " "
        {
            return false
        }
       else if (textField.text! as NSString).replacingCharacters(in: range, with: string).contains("  ")
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
    
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
