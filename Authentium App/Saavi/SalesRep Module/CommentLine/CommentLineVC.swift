//
//  CommentLineVC.swift
//  Saavi
//
//  Created by Irmeen Sheikh on 20/02/18.
//  Copyright © 2018 Saavi. All rights reserved.
//

import UIKit

class CommentLineVC: UIViewController,UITextViewDelegate {
    
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var view_main: UIView!
    @IBOutlet weak var lbl_PickingSlip: UILabel!
    @IBOutlet weak var lbl_addInvoice: UILabel!
    @IBOutlet weak var txtView_addToInvoice: UITextView!
    @IBOutlet weak var txtView_pickingSlip: UITextView!
    @IBOutlet weak var btn_Send: CustomButton!
    @IBOutlet weak var btn_Cancel: CustomButton!
    //var customerId :NSNumber = 0
    var senderView : PantryListVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view_main.backgroundColor = UIColor.lightGreyColor()
        view_main.layer.cornerRadius =  7.0 * Configration.scalingFactor()
        
        txtView_pickingSlip.text = "Add Comment"
        txtView_addToInvoice.text = "Add Comment"
        txtView_addToInvoice.textColor = UIColor.lightGray
        txtView_pickingSlip.textColor = UIColor.lightGray
        txtView_pickingSlip.font = UIFont.Roboto_Italic(baseScaleSize: 14)
        txtView_addToInvoice.font = UIFont.Roboto_Italic(baseScaleSize: 14)
        
        lbl_title.font = UIFont.Roboto_Bold(baseScaleSize: 18.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if txtView_addToInvoice.textColor == UIColor.lightGray && txtView_addToInvoice.isFirstResponder{
            txtView_addToInvoice.text = nil
            txtView_addToInvoice.textColor = UIColor.black
            txtView_addToInvoice.font = UIFont.Roboto_Regular(baseScaleSize: 14)
        }
        else if txtView_pickingSlip.textColor == UIColor.lightGray && txtView_pickingSlip.isFirstResponder {
            txtView_pickingSlip.text = nil
            txtView_pickingSlip.textColor = UIColor.black
            txtView_pickingSlip.font = UIFont.Roboto_Regular(baseScaleSize: 14)
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if txtView_addToInvoice.text.isEmpty {
            txtView_addToInvoice.text = "Add Comment"
            txtView_addToInvoice.textColor = UIColor.lightGray
            txtView_addToInvoice.font = UIFont.Roboto_Italic(baseScaleSize: 14)
        }
        else if txtView_pickingSlip.text.isEmpty  {
            txtView_pickingSlip.text = "Add Comment"
            txtView_pickingSlip.textColor = UIColor.lightGray
            txtView_pickingSlip.font = UIFont.Roboto_Italic(baseScaleSize: 14)
        }
    }
    
    @IBAction func Send_Action(_ sender: Any) {
        txtView_validations()
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
            return newText.count<=100
        }
        return true
    }
    
    
    
    func txtView_validations()
    {
        if txtView_pickingSlip.text == "Add Comment" || txtView_pickingSlip.text == "", txtView_addToInvoice.text == "Add Comment" || txtView_addToInvoice.text == ""
        {
            print("empty")
            Helper.shared.showAlertOnController( message: CommonString.addCommentString, title: CommonString.alertTitle)
        }
        else if txtView_addToInvoice.text != "" || txtView_addToInvoice.text != "Add Comment", txtView_pickingSlip.text == "" || txtView_pickingSlip.text == "Add Comment"
        {
            print("isInvoice true")
            callAddNewCommentAPI(invoiceText : txtView_addToInvoice.text, pickSlipText: "")
        }
        else if txtView_pickingSlip.text != "" || txtView_pickingSlip.text != "Add Comment", txtView_addToInvoice.text == "Add Comment" || txtView_addToInvoice.text == ""
        {
            print("isInvoice false")
            callAddNewCommentAPI(invoiceText : "", pickSlipText: txtView_pickingSlip.text)
        }
        else if txtView_addToInvoice.text != "", txtView_pickingSlip.text != "", txtView_addToInvoice.text != "Add Comment", txtView_pickingSlip.text != "Add Comment"
        {
            callAddNewCommentAPI(invoiceText : txtView_addToInvoice.text, pickSlipText: txtView_pickingSlip.text)
            print("isinvoice true and invoice False")
        }
    }
    //MARK:-Web Service
    
    func callAddNewCommentAPI(invoiceText : String? , pickSlipText : String?)
    {
        if invoiceText != "" , pickSlipText != ""
        {
            print("isinvoice true and invoice False")
            let requestArr = [
                [ "CustomerID": UserInfo.shared.customerID!,
                  "IsInvoice": true,
                  "CommentDescription": invoiceText as Any
                ],
                [ "CustomerID": UserInfo.shared.customerID!,
                  "IsInvoice": false,
                  "CommentDescription": pickSlipText as Any
                ]
                ]as Array<Dictionary<String,Any>>
            
            SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestArr, strURL: SyncEngine.baseURL + SyncEngine.AddCommentsRep) { (response: Any) in
                DispatchQueue.main.async {
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.commentAddedString, withCancelButtonTitle: "OK", completion: {
                        Helper.shared.customerAppendDic_List["PickingSlipDescription"] = self.txtView_pickingSlip.text
                        Helper.shared.customerAppendDic_List["InvoiceDescription"] = self.txtView_addToInvoice.text
                        if (response as! Dictionary<String,Any>).keyExists(key: "CommentID"), let commentId = (response as! Dictionary<String,Any>)["CommentID"] as? NSNumber
                        {
                            Helper.shared.customerAppendDic_List["CommentID"] = commentId
                        }
                        if (response as! Dictionary<String,Any>).keyExists(key: "UnloadCommentID"), let unloadCommentId = (response as! Dictionary<String,Any>)["UnloadCommentID"] as? NSNumber
                        {
                            Helper.shared.customerAppendDic_List["UnloadCommentID"] = unloadCommentId
                        }
                        self.senderView?.index = -1
                        self.senderView?.clctn_Features.reloadData()
                        self.dismiss(animated: false, completion: nil)
                    })
                }
            }
        }
        else
        {
            var requestDic = Array<Dictionary<String,Any>>()
            if pickSlipText != "" {
                requestDic = [[
                    "CustomerID": UserInfo.shared.customerID!,
                    "IsInvoice": false,
                    "CommentDescription": pickSlipText as Any
                    ] ]
            }
            else{
                requestDic = [[
                    "CustomerID": UserInfo.shared.customerID!,
                    "IsInvoice": true,
                    "CommentDescription": invoiceText as Any
                    ]]
            }
            SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestDic, strURL: SyncEngine.baseURL + SyncEngine.AddCommentsRep) { (response: Any) in
                DispatchQueue.main.async {
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.commentAddedString, withCancelButtonTitle: "OK", completion: {
                        if pickSlipText != "" {
                            Helper.shared.customerAppendDic_List["PickingSlipDescription"] = self.txtView_pickingSlip.text
                        }
                        else{
                            Helper.shared.customerAppendDic_List["InvoiceDescription"] = self.txtView_addToInvoice.text
                        }
                        if (response as! Dictionary<String,Any>).keyExists(key: "CommentID"), let commentId = (response as! Dictionary<String,Any>)["CommentID"] as? NSNumber
                        {
                            Helper.shared.customerAppendDic_List["CommentID"] = commentId
                        }
                        if (response as! Dictionary<String,Any>).keyExists(key: "UnloadCommentID"), let unloadCommentId = (response as! Dictionary<String,Any>)["UnloadCommentID"] as? NSNumber
                        {
                            Helper.shared.customerAppendDic_List["UnloadCommentID"] = unloadCommentId
                        }
                        self.senderView?.index = -1
                        self.senderView?.clctn_Features.reloadData()
                        self.dismiss(animated: false, completion: nil)
                    })
                }
            }
        }
    }
    
    @IBAction func Cancel_Action(_ sender: Any) {
        self.dismiss(animated: false, completion: {
            self.senderView?.index = -1
            self.senderView?.clctn_Features.reloadData()
        })
    }
    
    
}
