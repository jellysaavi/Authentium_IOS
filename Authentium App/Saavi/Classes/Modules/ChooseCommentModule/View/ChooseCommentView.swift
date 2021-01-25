//
//  ChooseCommentView.swift
//  Saavi
//
//  Created by Sukhpreet on 27/09/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class ChooseCommentView: UIViewController, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    var selectedIndex = -1
    
    /*Variables for adding comment*/
    @IBOutlet weak var lblTitleOfPopup: UILabel!
    @IBOutlet weak var txtVwComment: CustomTextView!
    @IBOutlet weak var btnAddComment: CustomButton!
    @IBOutlet weak var addNewCommentPopup: UIView!
    
    /*Variables for choosing comment*/
    @IBOutlet weak var chooseCommentPopupView: UIView!
    @IBOutlet weak var lblChooseComment: UILabel!
    @IBOutlet weak var tblVwCommentListing: UITableView!
    @IBOutlet weak var btnSubmitComment: CustomButton!
    @IBOutlet weak var btnAddNewComment: CustomButton!
    
    var senderView : CartView?
    var saleseRepSenderView : MyCartVC?
    var checkIfProduct : String?
    @IBOutlet weak var tableViewCommentListing : UITableView!
    
    var arrPreviousComments = Array<Dictionary<String,Any>>()
    var productId : NSNumber = 0
    var productDict :  Dictionary<String,Any> = [:]
    
    override func viewDidLoad() {
        
        if UserInfo.shared.isSalesRepUser == true{
            
        }
        
        lblTitleOfPopup.font = UIFont.SFUI_SemiBold(baseScaleSize: 20.0)
        addNewCommentPopup.layer.cornerRadius = 7.0 * Configration.scalingFactor()
        
        lblChooseComment.font = UIFont.SFUI_SemiBold(baseScaleSize: 20.0)
        chooseCommentPopupView.layer.cornerRadius = 7.0 * Configration.scalingFactor()
        
        self.txtVwComment.delegate = self
        
        self.tblVwCommentListing.tableFooterView = UIView()
        self.getComments()
        
        let tapReco : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hidePopupAction(reco:)))
        tapReco.numberOfTapsRequired  = 1
        tapReco.cancelsTouchesInView = false
        tapReco.delegate = self
        self.view.addGestureRecognizer(tapReco)
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.tableViewCommentListing.reloadData()
    }
    
    // MARK:- Table view data source and delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return arrPreviousComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCellIdentifier", for: indexPath) as! CategorySelectionCollectionCell
        
        if self.arrPreviousComments.count > 0
        {
            let responseDict = self.arrPreviousComments[indexPath.row]
            if responseDict.keyExists(key: "CommentDescription")
            {
                let categoryName = responseDict["CommentDescription"]
                cell.textLabel?.text = categoryName as? String
                cell.textLabel?.textColor = UIColor.black
                cell.textLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
            }
            if UserInfo.shared.isSalesRepUser == true && AppFeatures.shared.isAdvancedPantry == true{
                
                let commentID = self.senderView?.commentID == nil ? (self.saleseRepSenderView?.commentID ?? 0):self.senderView?.commentID
                
                if Int(truncating: self.productId) > 0 && selectedIndex == indexPath.row || self.arrPreviousComments[indexPath.row]["PCommentID"] as? NSNumber == commentID{
                    
                    selectedIndex = indexPath.row
                    let checkmark = UIImageView(image: UIImage(named: "checkbox_checked"))
                    checkmark.tintColor = UIColor.baseBlueColor()
                    cell.accessoryView = checkmark
                    
                }else if Int(truncating: self.productId) == 0 && selectedIndex == indexPath.row || self.arrPreviousComments[indexPath.row]["CommentID"] as? NSNumber == commentID
                {
                    selectedIndex = indexPath.row
                    let checkmark = UIImageView(image: UIImage(named: "checkbox_checked"))
                    checkmark.tintColor = UIColor.baseBlueColor()
                    cell.accessoryView = checkmark
                    
                }
                else
                {
                    let checkmark = UIImageView(image: UIImage(named: "checkbox_unchecked"))
                    cell.accessoryView = checkmark
                    checkmark.tintColor = UIColor.activeTextFieldColor()
                }
                
            }
            else{
                
                let commentID = self.senderView?.commentID == nil ? (self.saleseRepSenderView?.commentID ?? 0):self.senderView?.commentID
                
                if Int(truncating: self.productId) > 0 && selectedIndex == indexPath.row || self.arrPreviousComments[indexPath.row]["PCommentID"] as? NSNumber == commentID{
                    
                    selectedIndex = indexPath.row
                    let checkmark = UIImageView(image: UIImage(named: "checkbox_checked"))
                    checkmark.tintColor = UIColor.baseBlueColor()
                    cell.accessoryView = checkmark
                    
                }else if Int(truncating: self.productId) == 0 && selectedIndex == indexPath.row || self.arrPreviousComments[indexPath.row]["CommentID"] as? NSNumber == commentID
                {
                    selectedIndex = indexPath.row
                    let checkmark = UIImageView(image: UIImage(named: "checkbox_checked"))
                    checkmark.tintColor = UIColor.baseBlueColor()
                    cell.accessoryView = checkmark
                    
                }
                else
                {
                    let checkmark = UIImageView(image: UIImage(named: "checkbox_unchecked"))
                    cell.accessoryView = checkmark
                    checkmark.tintColor = UIColor.activeTextFieldColor()
                }
            }
        }
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        self.senderView?.commentID = 0
        self.saleseRepSenderView?.commentID = 0
        
        if Int(truncating: self.productId) > 0{
            
            if selectedIndex == indexPath.row{
                selectedIndex = -1
            }else{
                
                selectedIndex = indexPath.row
                
            }
        }else {
            
            if selectedIndex == indexPath.row{
                selectedIndex = -1
                
            }else{
                selectedIndex = indexPath.row
     
            }
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0 * Configration.scalingFactor()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        //        let deleteAction = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction, indexPath) in
        //            //TODO: edit the row at indexPath here
        //        }
        //        deleteAction.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            print("Deleted")
            //  print(arrPreviousComments)
            if let commentName = self.arrPreviousComments[indexPath.row]["CommentDescription"] as? String
            {
                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: "Are you sure you want to delete this comment?", withCancelButtonTitle: "No", completion:{
                    
                    if self.arrPreviousComments.count > 0
                    {
                        let responseDict = self.arrPreviousComments[indexPath.row]
                        if responseDict.keyExists(key: "CommentID")
                        {
                            let CommentID = responseDict["CommentID"]
                            self.deleteComment(indexPath: indexPath, id: CommentID!)
                            
                        }else if responseDict.keyExists(key: "PCommentID")
                        {
                            let CommentID = responseDict["PCommentID"]
                            self.deleteComment(indexPath: indexPath, id: CommentID!)
                        }
                    }
                })
            }
            
        }
    }
    
    
    // MARK: - Service Communication
    @objc func hidePopupAction(reco : UITapGestureRecognizer)
    {
        
        if self.txtVwComment.isFirstResponder
        {
            self.txtVwComment.endEditing(true)
        }
        else if addNewCommentPopup.isHidden == false
        {
            self.chooseCommentAction(nil)
        }
        else if reco.view == self.view
        {
            self.senderView?.commentID = nil
            self.senderView?.orderCommentID = nil
            self.saleseRepSenderView?.commentID = nil
            
            self.dismiss(animated: false, completion: nil)
            self.view.endEditing(true)
        }
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: self.chooseCommentPopupView))!  || (touch.view?.isDescendant(of: self.addNewCommentPopup))! || (touch.view?.isDescendant(of: self.tableViewCommentListing))!
        {
            return false
        }
        return true
    }
    
    @IBAction func addNewCommentAction(_ sender: Any?)
    {
        self.txtVwComment.text = ""
        self.addNewCommentPopup.isHidden = false
        self.chooseCommentPopupView.isHidden = true
        if let label = self.view.viewWithTag(57)
        {
            label.isHidden = true
        }
        
    }
    
    @IBAction func chooseCommentAction(_ sender: Any?)
    {
        if self.txtVwComment.isFirstResponder
        {
            self.txtVwComment.resignFirstResponder()
        }
        self.addNewCommentPopup.isHidden = true
        self.chooseCommentPopupView.isHidden = false
        if let label = self.view.viewWithTag(57)
        {
            label.isHidden = false
        }
        
    }
    
    @IBAction func submitNewCommentAction(_ sender: Any)
    {
        if txtVwComment.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != ""
        {
            self.callAddNewCommentAPI(commentText: txtVwComment.text)
        }
        else
        {
            Helper.shared.showAlertOnController( message: "Please add comment.", title: CommonString.alertTitle)
        }
    }
    
    @IBAction func submitChoosenCommentAction(_ sender: Any) {
        
        if UserDefaults.standard.value(forKey: "isSalesrep") as? Bool == true && AppFeatures.shared.isAdvancedPantry == true && UIDevice.current.userInterfaceIdiom == .pad {
            
            
            if (Int(truncating: self.productId) > 0) {
                
                self.dismiss(animated: false) {
                    
                    self.saleseRepSenderView?.commentID =  self.selectedIndex == -1 ? 0:self.arrPreviousComments[self.selectedIndex]["PCommentID"] as? NSNumber //self.arrPreviousComments[self.selectedIndex]["CommentID"] as? NSNumber
                    self.saleseRepSenderView?.updateCartItemObjWithObj(dic: self.productDict, index: self.saleseRepSenderView?.selectedIndexForComment ?? 0)
                    
                    self.dismiss(animated: false) {
                        
                        if let expectedHeight = (self.saleseRepSenderView?.textViewAddComment.text.heightOfText(withConstrainedWidth: (self.saleseRepSenderView?.textViewAddComment.frame.size.width)!, font: (self.saleseRepSenderView?.textViewAddComment.font)!))
                        {
                            self.saleseRepSenderView?.txtVwCommentHeightConstant.constant = ((expectedHeight > 40 * VerticalSpacingConstraints.spacingConstant) ? expectedHeight + 10.0 : 40.0 * VerticalSpacingConstraints.spacingConstant)
                        }
                        
                    }
                    
                }
                
            }else if selectedIndex >= 0, self.arrPreviousComments.count > selectedIndex{
                //  self.saleseRepSenderView?.commentString = self.arrPreviousComments[selectedIndex]["CommentDescription"] as? String
                //  self.saleseRepSenderView?.commentID = self.arrPreviousComments[selectedIndex]["CommentID"] as? NSNumber
                Helper.shared.customerAppendDic_List["CommentID"] = self.arrPreviousComments[selectedIndex]["CommentID"] as? NSNumber
                Helper.shared.customerAppendDic_List["InvoiceDescription"] = self.arrPreviousComments[selectedIndex]["CommentDescription"] as? String
                self.dismiss(animated: false) {
                    self.saleseRepSenderView?.textViewAddComment.text = self.arrPreviousComments[self.selectedIndex]["CommentDescription"] as? String
                    
                    if let expectedHeight = (self.saleseRepSenderView?.textViewAddComment.text.heightOfText(withConstrainedWidth: (self.saleseRepSenderView?.textViewAddComment.frame.size.width)!, font: (self.saleseRepSenderView?.textViewAddComment.font)!))
                    {
                        self.saleseRepSenderView?.txtVwCommentHeightConstant.constant = ((expectedHeight > 40 * VerticalSpacingConstraints.spacingConstant) ? expectedHeight + 10.0 : 40.0 * VerticalSpacingConstraints.spacingConstant)
                    }
                    self.saleseRepSenderView?.btn_clear.isHidden = false
                }
            }
            else
            {
                if self.arrPreviousComments.count > 0
                {
                    Helper.shared.showAlertOnController(message: "Please choose comment", title: CommonString.alertTitle)
                }
                else
                {
                    Helper.shared.showAlertOnController(message: "Please add new comment to continue", title: CommonString.alertTitle)
                }
            }
        }
        else{
            
            if (Int(truncating: self.productId) > 0) {
                
                self.dismiss(animated: false) {
                    
                    self.senderView?.commentID = self.selectedIndex == -1 ? 0:self.arrPreviousComments[self.selectedIndex]["PCommentID"] as? NSNumber
                    self.senderView?.updateCartItemObjWithObj(dic: self.productDict,quantityVal: (self.productDict["Quantity"] as? NSNumber as! Double))
                    
                    if let expectedHeight = (self.senderView?.textViewAddComment.text.heightOfText(withConstrainedWidth: (self.senderView?.textViewAddComment.frame.size.width)!, font: (self.senderView?.textViewAddComment.font)!))
                    {
                        self.senderView?.cnstViewCommentBoxHeight.constant = ((expectedHeight > 40 * VerticalSpacingConstraints.spacingConstant) ? expectedHeight + 10.0 : 40.0 * VerticalSpacingConstraints.spacingConstant)
                    }
                    
                }
                
            }else if selectedIndex >= 0, self.arrPreviousComments.count > selectedIndex{
                
                self.senderView?.commentString = self.arrPreviousComments[selectedIndex]["CommentDescription"] as? String
                self.senderView?.commentID = self.arrPreviousComments[selectedIndex]["CommentID"] as? NSNumber
                self.senderView?.orderCommentID = self.senderView?.commentID
                self.dismiss(animated: false) {
                    
                    self.senderView?.textViewAddComment.text = self.arrPreviousComments[self.selectedIndex]["CommentDescription"] as? String
                    self.senderView?.btnClearComment.isHidden = false
                    
                    
                    if let expectedHeight = (self.senderView?.textViewAddComment.text.heightOfText(withConstrainedWidth: (self.senderView?.textViewAddComment.frame.size.width)!, font: (self.senderView?.textViewAddComment.font)!))
                    {
                        self.senderView?.cnstViewCommentBoxHeight.constant = ((expectedHeight > 40 * VerticalSpacingConstraints.spacingConstant) ? expectedHeight + 10.0 : 40.0 * VerticalSpacingConstraints.spacingConstant)
                    }
                    
                }
            }
            else
            {
                if self.arrPreviousComments.count > 0
                {
                    Helper.shared.showAlertOnController( message: "Please choose comment", title: CommonString.alertTitle)
                }
                else
                {
                    Helper.shared.showAlertOnController( message: "Please add new comment to continue", title: CommonString.alertTitle)
                }
            }
        }
    }
    
    //MARK: - - Add New Comments
    func callAddNewCommentAPI(commentText : String)
    {
        var customerId = String()
        if UserDefaults.standard.value(forKey: "isSalesrep") as? Bool == true && AppFeatures.shared.isAdvancedPantry == true{
            customerId = UserInfo.shared.customerID!
        }
        else{
            customerId = UserInfo.shared.customerID!
        }
        let requestDic = [
            "CustomerID": customerId,
            "ProductID": self.productId,
            "IsProduct": Int(truncating: self.productId) > 0 ? true : false,
            "CommentDescription": commentText
            
            ] as Dictionary<String,Any>
        print(requestDic)
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestDic, strURL: SyncEngine.baseURL + SyncEngine.addNewOrderComment) { (response: Any) in
            DispatchQueue.main.async {
                self.chooseCommentAction(nil)
            }
            let dict = response as? NSDictionary
            let cmntId:Int = dict?.value(forKey: "CommentID") as? Int ?? 0
            self.getComments()
            
            //TODO: - - Set Comment ID here
            if UserDefaults.standard.value(forKey: "isSalesrep") as? Bool == true && AppFeatures.shared.isAdvancedPantry == true && UIDevice.current.userInterfaceIdiom == .pad {
            
                
                if (Int(truncating: self.productId) > 0) {
                    
                    self.saleseRepSenderView?.commentID = NSNumber.init(value:cmntId)
                    
                }else{
                
                    self.saleseRepSenderView?.commentID = NSNumber.init(value:cmntId)
                }
                
            }else {
                
                if (Int(truncating: self.productId) > 0) {
               
                    self.senderView?.commentID = NSNumber.init(value:cmntId)
                }else{
                    self.senderView?.commentID = NSNumber.init(value:cmntId)
                    self.senderView?.orderCommentID = self.senderView?.commentID
                }
                
            }

            /*if UserDefaults.standard.value(forKey: "isSalesrep") as? Bool == true && AppFeatures.shared.isAdvancedPantry == true{
                
                self.dismiss(animated: false) {
                    
                    if !(Int(truncating: self.productId) > 0){
                        
                        self.saleseRepSenderView?.textViewAddComment.text = commentText
                        self.saleseRepSenderView?.btn_clear.isHidden = false
                    }
                    
                    if let expectedHeight = (self.saleseRepSenderView?.textViewAddComment.text.heightOfText(withConstrainedWidth: (self.saleseRepSenderView?.textViewAddComment.frame.size.width)!, font: (self.saleseRepSenderView?.textViewAddComment.font)!))
                    {
                        self.saleseRepSenderView?.txtVwCommentHeightConstant.constant = ((expectedHeight > 33 * VerticalSpacingConstraints.spacingConstant) ? expectedHeight + 10.0 : 33.0 * VerticalSpacingConstraints.spacingConstant)
                    }
                }
            }
            else{
                self.dismiss(animated: false) {
                    
                    if !(Int(truncating: self.productId) > 0){
                        
                        self.senderView?.textViewAddComment.text = commentText
                        self.senderView?.btnClearComment.isHidden = false
                        
                    }
                    
                    if let expectedHeight = (self.senderView?.textViewAddComment.text.heightOfText(withConstrainedWidth: (self.senderView?.textViewAddComment.frame.size.width)!, font: (self.senderView?.textViewAddComment.font)!))
                    {
                        self.senderView?.txtVwCommentHeightConstant.constant = ((expectedHeight > 33 * VerticalSpacingConstraints.spacingConstant) ? expectedHeight + 10.0 : 33.0 * VerticalSpacingConstraints.spacingConstant)
                    }
                }
            }*/
        }
    }
    
    //MARK: - - Get Comments
    func getComments()
    {
        var customerId = String()
        if UserDefaults.standard.value(forKey: "isSalesrep") as? Bool == true && AppFeatures.shared.isAdvancedPantry == true{
            customerId = UserInfo.shared.customerID!
        }
        else{
            customerId = UserInfo.shared.customerID!
        }
        let requestDic = [
            "CustomerID":customerId,
            "ProductID": self.productId,
            "IsProduct": Int(truncating: self.productId) > 0 ? true : false
            ] as Dictionary<String,Any>
        print(requestDic)
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestDic, strURL: SyncEngine.baseURL + SyncEngine.getAllCommentsForOrder) { (response: Any) in
            if let comments = response as? Array<Dictionary<String,Any>>
            {
                self.arrPreviousComments = comments
                DispatchQueue.main.async {
                    if self.arrPreviousComments.count == 0
                    {
                        let lbl_noComments = Helper.shared.createLabelWithMessage(message: "No comments.")
                        lbl_noComments.center = self.view.center
                        lbl_noComments.tag = 57
                        self.view.addSubview(lbl_noComments)
                    }
                    else
                    {
                        self.getSelectedIndex()
                        if let noCpmmentLbl = self.view.viewWithTag(57)
                        {
                            noCpmmentLbl.removeFromSuperview()
                        }
                    }
                    self.tblVwCommentListing.reloadData()
                }
            }
        }
    }
    
    //MARK: - - Get selected Index of comment
    fileprivate func getSelectedIndex(){
    
        if Int(truncating: self.productId) > 0 {
            
            for i in 0..<self.arrPreviousComments.count{
                
                let commentID = self.senderView?.commentID == nil ? (self.saleseRepSenderView?.commentID ?? nil):self.senderView?.commentID
                
                let cmtID = self.arrPreviousComments[i]["PCommentID"] as? NSNumber
                if commentID == cmtID && commentID != nil{
                    self.selectedIndex = i
                }
                
            }
            
        }else if Int(truncating: self.productId) == 0 {
            
            for i in 0..<self.arrPreviousComments.count{
                
                let commentID = self.senderView?.commentID == nil ? (self.saleseRepSenderView?.commentID ?? nil):self.senderView?.commentID
                
                let cmtID = self.arrPreviousComments[i]["CommentID"] as? NSNumber
                if commentID == cmtID && commentID != nil{
                    self.selectedIndex = i
                }
                
            }
            
        }
    
    }
    
    //MARK: - - Delete Comment
    func deleteComment(indexPath:IndexPath,id:Any){
        let requestDic = [
            "CommentID":id,
            "IsProduct": Int(truncating: self.productId) > 0 ? true : false
            ] as Dictionary<String,Any>
        print(requestDic)
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestDic, strURL: SyncEngine.baseURL + SyncEngine.deleteComment) { (response: Any) in
            print(response)
            self.arrPreviousComments.remove(at: indexPath.row)
            DispatchQueue.main.async {
                self.tblVwCommentListing.deleteRows(at: [indexPath], with: .automatic)
                self.tblVwCommentListing.reloadData()
                DispatchQueue.main.async {
                    
                    if self.selectedIndex == indexPath.row{
                        self.selectedIndex = -1 
                    }
                    
                    if self.arrPreviousComments.count == 0
                    {
                        let lbl_noComments = Helper.shared.createLabelWithMessage(message: "No comments.")
                        lbl_noComments.center = self.view.center
                        lbl_noComments.tag = 57
                        self.view.addSubview(lbl_noComments)
                    }
                    else
                    {
                        if let noCpmmentLbl = self.view.viewWithTag(57)
                        {
                            noCpmmentLbl.removeFromSuperview()
                        }
                        self.saleseRepSenderView?.textViewAddComment.text = ""
                    }
                    self.tblVwCommentListing.reloadData()
                }
            }
        }
    }
    
    //    MARK:- Text view delegates
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        //let characterset = CharacterSet(charactersIn: " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        
//        let length = Int(truncating: self.productId) > 0 ? 50:25
//
//        if text == "\n"
//        {
//            textView.resignFirstResponder()
//            textView.endEditing(true)
//
//        }/*else if  text.rangeOfCharacter(from: characterset.inverted) != nil {
//            return false//print("could not handle special characters")
//        }*/
//        else{
//            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
//            return newText.count<=length
//        }
        
        return textView.text.count <= 160
        
    }
}

