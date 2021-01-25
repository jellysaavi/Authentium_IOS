//
//  ExternalDocVC.swift
//  Saavi
//
//  Created by Priya on 15/03/18.
//  Copyright © 2018 Saavi. All rights reserved.
//

import UIKit

class ExternalDocVC: UIViewController, UITextViewDelegate {
    @IBOutlet weak var contentTxtView: UITextView!
    var isSpecialProductReq : Bool = false
    var senderView : PantryListVC?
    @IBOutlet weak var lblTitleOfPopup: UILabel!
    @IBOutlet weak var btnOk: CustomButton!
    @IBOutlet weak var btnCancel: CustomButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if isSpecialProductReq
        {
            self.lblTitleOfPopup.text = "Special Product Request"
            self.btnOk.setTitle("Send", for: .normal)
            self.btnCancel.setTitle("Cancel", for: .normal)
            contentTxtView.text = CommonString.detailHere
            
        }else{
            
            if Helper.shared.customerAppendDic_List.keyExists(key: "ExtDoc"), let extDocument = Helper.shared.customerAppendDic_List["ExtDoc"] as? String{
                if extDocument != ""
                {
                    contentTxtView.textColor = UIColor.black
                    contentTxtView.text = extDocument
                }
                else{
                    contentTxtView.text = CommonString.detailHere
                }
                
            }
            else
            {
                contentTxtView.text = CommonString.detailHere
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelAction(_ sender: Any)
    {
        self.dismiss(animated: false, completion:
            {
                if self.isSpecialProductReq == false
                {
                    let customerCell = self.senderView?.clctn_CustomerDetail.cellForItem(at: IndexPath(item: 6, section:0)) as? CustomerDetailCell
                    customerCell?.txtFld_CustomerName.text = "N/A"
                    Helper.shared.customerAppendDic_List["ExtDoc"] = ""
                }
        })
    }
    
    
    @IBAction func sendAction(_ sender: Any)
    {
        if isSpecialProductReq == false
        {
            self.dismiss(animated: false, completion: {
                let customerCell = self.senderView?.clctn_CustomerDetail.cellForItem(at: IndexPath(item: 6, section:0)) as? CustomerDetailCell
                
                if self.contentTxtView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "" && self.contentTxtView.text != CommonString.detailHere{
                    
                    Helper.shared.customerAppendDic_List["ExtDoc"] = self.contentTxtView.text
                    customerCell?.txtFld_CustomerName.text = "ADDED"
                    
                }
                else{
                    customerCell?.txtFld_CustomerName.text = "N/A"
                    Helper.shared.customerAppendDic_List["ExtDoc"] = ""
                }
                
            })
        }
        else
        {
            // Call API for Special Prod and Dismiss.
            
            if contentTxtView.text == CommonString.detailHere || contentTxtView.text.trimmingCharacters(in: .whitespacesAndNewlines).count == 0
            {
                Helper.shared.showAlertOnController( message: "Please enter product details.", title: CommonString.app_name)
                return
            }
            
            let url  = SyncEngine.baseURL + SyncEngine.specialRequestProductRequest
            var request = [
                "CustomerID": UserInfo.shared.customerID!,
                "Details": contentTxtView.text!
                ] as [String: Any]
            
            if UserInfo.shared.isSalesRepUser == true
            {
                request["RepUserID"] = UserInfo.shared.userId!
            }
            self.view.endEditing(true)
            SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: request, strURL: url, completion: { (response : Any) in
                DispatchQueue.main.async
                {
                    self.dismiss(animated: false, completion: {
                        Helper.shared.showAlertOnController( message: "We have received your product request. We will get back to you soon.", title: CommonString.app_name)
                    })
                }
            })
        }
    }
    
}

//MARK: - - TextView Delegates
extension ExternalDocVC{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if contentTxtView.textColor == UIColor.lightGray && contentTxtView.isFirstResponder
        {
            contentTxtView.text = nil
            contentTxtView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if contentTxtView.text.isEmpty
        {
            contentTxtView.text = CommonString.detailHere
            contentTxtView.textColor = UIColor.lightGray
        }
    }
    
    //    MARK:- Text view delegates
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let characterset = CharacterSet(charactersIn: " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        
        if text == "\n"
        {
            textView.resignFirstResponder()
            textView.endEditing(true)
            
        }else if  text.rangeOfCharacter(from: characterset.inverted) != nil {
            return false//print("could not handle special characters")
        }
        else{
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            return newText.count<=1000
        }
        
        return true
        
    }
    
}
