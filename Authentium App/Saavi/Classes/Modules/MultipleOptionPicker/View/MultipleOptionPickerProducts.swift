//
//  MultipleOptionPicker.swift
//  Saavi
//
//  Created by Sukhpreet on 29/09/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class MultipleOptionPickerproducts: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    static let storyboardIdentifier = "multipleOptionPickerProducts"
    
    typealias successCompletionBlock = (_ selectedArrayIndex : Int) -> Void
    
    @IBOutlet weak var lblStaticPopupHeading: UILabel!
    @IBOutlet weak var tblViewOptions: UITableView!
    @IBOutlet weak var btnAcceptOption: CustomButton!
    @IBOutlet weak var btnDeclineOpition: CustomButton!
    @IBOutlet weak var popupBoundingBox: UIView!
    
    @IBOutlet weak var tblViewSuggestions: UITableView!
    var completionBlock :successCompletionBlock? = nil
    
    @IBOutlet weak var lbl2Contraints: NSLayoutConstraint!
    @IBOutlet weak var lblStaticContraints: NSLayoutConstraint!
    @IBOutlet weak var tblContraints: NSLayoutConstraint!
    @IBOutlet weak var lblHandlline: UILabel!
    var displayKeyName = ""
    var arrOptions = Array<Dictionary<String,Any>>()
    var arrOptions2 = Array<Dictionary<String,Any>>()
    
    var selectedIndex = -1
    var selectedSuggestionIndex = -1

    var noSelectionAlertMessage : String?
    
    var acceptBtnTitle = ""
    var declineBtnTitle = ""
    var popupTitle = ""
    
    //    MARK:- View Lifecyclex
    
    override func viewDidLoad() {
        
        tblViewOptions.backgroundColor = UIColor.white
        tblViewSuggestions.backgroundColor = UIColor.white

        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.lblStaticPopupHeading.font = UIFont.SFUI_SemiBold(baseScaleSize: 18.0)
        self.lblStaticPopupHeading.numberOfLines = 3
        self.lblHandlline.font = UIFont.SFUI_SemiBold(baseScaleSize: 18.0)
        
       // self.lblStaticPopupHeading.text = popupTitle
        self.btnAcceptOption.setTitle(acceptBtnTitle, for: .normal)
        self.btnDeclineOpition.setTitle(declineBtnTitle, for: .normal)
        
        self.tblViewOptions.reloadData()
        self.tblViewSuggestions.reloadData()
        
        
        if self.arrOptions.count == 0 {
            self.lblStaticPopupHeading.isHidden = true
            self.tblViewOptions.isHidden = true
           tblContraints.constant = 0
            lblStaticContraints.constant = 0
        }
        
        if self.arrOptions2.count == 0 {
            lblHandlline.isHidden = true
            tblViewSuggestions.isHidden = true
            lbl2Contraints.constant = 0
        }
    }
    
    //    MARK:- Show Popup
    func showMultipleOptionPickerOnWindow(forDisplayKeyName : String, withDataSource : Array<Dictionary<String,Any>>, withTitle : String, withSuccessButtonTitle : String, withCancelButtonTitle : String, withAlertMessage alertMessage : String?, withDataSource2 : Array<Dictionary<String,Any>>, completion:@escaping successCompletionBlock)
    {
        completionBlock = completion
        popupTitle = withTitle
        acceptBtnTitle = withSuccessButtonTitle
        declineBtnTitle = withCancelButtonTitle
        self.arrOptions = withDataSource
        self.arrOptions2 = withDataSource2
        self.displayKeyName = forDisplayKeyName
        self.noSelectionAlertMessage = alertMessage
        
       
        DispatchQueue.main.async {
            if #available(iOS 13.0, *) {
                let keyWindow = UIApplication.shared.connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .map({$0 as? UIWindowScene})
                    .compactMap({$0})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first
                keyWindow!.rootViewController?.present(self, animated: false, completion: {
                    self.tblViewOptions.reloadData()
                    self.tblViewSuggestions.reloadData()
                })
                
            } else {
                // Fallback on earlier versions
            }
            

        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
        //        self.view.removeFromSuperview()
    }
    
    @IBAction func submitAction(_ sender: Any) {
        var requestData = Array<Dictionary<String,Any>>()
        
        for data in self.arrOptions {
            
            if data["checked"] as? Bool == true {
                
            var product = Dictionary<String,Any>()
            product["CartItemID"] = 0
            product["CartID"] = 0
            product["ProductID"] = data["ProductID"]
            product["IsGstApplicable"]  = data["IsGST"] as? Bool ?? false
               product["Quantity"] = (data.keyExists(key: "Quantity") && data["Quantity"] as? NSNumber != nil && Float(truncating: data["Quantity"] as! NSNumber) != 0) ? (data["Quantity"] as! NSNumber) : 1
                
            product["Price"] = data["Price"]
            product["IsNoPantry"] = false
            product["UnitId"] = data["UOMID"]
            product["IsSpecialPrice"] =   data["IsSpecial"]
            
            requestData.append(product)
                
            }
        }
        
        for data in self.arrOptions2{
            
            if data["checked"] as? Bool == true {
            var product = Dictionary<String,Any>()
            product["CartItemID"] = 0
            product["CartID"] = 0
            product["ProductID"] = data["ProductID"]
            product["IsGstApplicable"]  = data["IsGST"] as? Bool ?? false
                product["Quantity"] = (data.keyExists(key: "Quantity") && data["Quantity"] as? NSNumber != nil && Float(truncating: data["Quantity"] as! NSNumber) != 0) ? (data["Quantity"] as! NSNumber) : 1
                product["Price"] = data["Price"]
            product["IsNoPantry"] = false
            product["UnitId"] = data["UOMID"]
            product["IsSpecialPrice"] =   data["IsSpecial"]
            
            requestData.append(product)
            }
        }
        
        if requestData.count > 0 {
        
        let customerId : String = UserInfo.shared.customerID ?? "0"
        let requestDic = [
            "CartID": 0,
            "InCart" : true,
            "CustomerID": customerId,
            "IsOrderPlpacedByRep": UserInfo.shared.isSalesRepUser!,
            "RunNo": "",
            "CommentLine": "",
            "PackagingSequence": 0,
            "SuggestiveCartItems": requestData,
            ] as [String : Any]
        
        
        
        let serviceURL = SyncEngine.baseURL + SyncEngine.addItemsToCart
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestDic, strURL: serviceURL) { (response : Any) in
            
            self.completionBlock!(self.selectedIndex)
            DispatchQueue.main.async {
            self.dismiss(animated: false, completion: nil)
            }}
       
        }
        else{
            completionBlock!(selectedIndex)
            DispatchQueue.main.async {
            self.dismiss(animated: false, completion: nil)
            }
        }
        
        
    }
    
    // MARK: - Popup Data Handling
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == tblViewOptions){
            return arrOptions.count}
        else{
            return arrOptions2.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCellIdentifier", for: indexPath) as! CategorySelectionCollectionCell
        if tableView  == tblViewOptions {
        cell.textLabel?.text = arrOptions[indexPath.row][displayKeyName] as? String
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
        
        if arrOptions[indexPath.row]["checked"] as? Bool == true
        {
            let checkmark = UIImageView(image: UIImage(named: "checkbox_checked"))
            checkmark.tintColor = UIColor.baseBlueColor()
            cell.accessoryView = checkmark
            cell.accessoryView?.tintColor = UIColor.baseBlueColor()
        }
        else
        {
            let checkmark = UIImageView(image: UIImage(named: "checkbox_unchecked"))
            checkmark.tintColor = UIColor.activeTextFieldColor()
            cell.accessoryView = checkmark
            cell.accessoryView?.tintColor = UIColor.activeTextFieldColor()
        }
        }
        else{
            cell.textLabel?.text = arrOptions2[indexPath.row][displayKeyName] as? String
            cell.textLabel?.textColor = UIColor.black
            cell.textLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
            
            if arrOptions2[indexPath.row]["checked"] as? Bool == true
            {
                let checkmark = UIImageView(image: UIImage(named: "checkbox_checked"))
                checkmark.tintColor = UIColor.baseBlueColor()
                cell.accessoryView = checkmark
                cell.accessoryView?.tintColor = UIColor.baseBlueColor()
            }
            else
            {
                let checkmark = UIImageView(image: UIImage(named: "checkbox_unchecked"))
                checkmark.tintColor = UIColor.activeTextFieldColor()
                cell.accessoryView = checkmark
                cell.accessoryView?.tintColor = UIColor.activeTextFieldColor()
            }
        }
        cell.backgroundColor = UIColor.white
              
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0 * VerticalSpacingConstraints.spacingConstant
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if( tableView == tblViewOptions){
            selectedIndex = indexPath.row
            if arrOptions[indexPath.row]["checked"] as? Bool == true {
                arrOptions[indexPath.row]["checked"] = false
            }
            else {
                arrOptions[indexPath.row]["checked"] = true
            }
            
        self.tblViewOptions.reloadData()
        }
        else{
            if arrOptions2[indexPath.row]["checked"] as? Bool == true {
                arrOptions2[indexPath.row]["checked"] = false
            }
            else {
                arrOptions2[indexPath.row]["checked"] = true
            }
            selectedSuggestionIndex = indexPath.row
        self.tblViewSuggestions.reloadData()
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



