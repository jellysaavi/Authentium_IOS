//
//  CustomerInfoVC.swift
//  Saavi
//
//  Created by Irmeen Sheikh on 19/02/18.
//  Copyright © 2018 Saavi. All rights reserved.
//

import UIKit

class CustomerInfoVC: UIViewController ,UITableViewDelegate,UITableViewDataSource{

    var customerInfo1Arr = [["Key":"Alpha Code:"],["Key":"Customer:"],["Key":"Name:"],["Key":"ABN:"],["Key":"Address1:"],["Key":"Address2:"],["Key":"Suburb:"]]
    var customerInfo2Arr = [["Key":"Post Code:"],["Key":"Contact Name:"],["Key":"Phone1:"],["Key":"Phone2:"],["Key":"Fax:"],["Key":"Email:"],["Key":"Salesman Code:"]]
     var financialInfo2Arr = [["Key":"Credit Limit:"],["Key":"Price Code:"],["Key":"30 Days Balance:"],["Key":"60 Days Balance:"],["Key":"90 Days Balance:"],["Key":"Overdue Balance:"],["Key":"Balance:"]]
    
    @IBOutlet weak var tbl_customInfo1: UITableView!
    @IBOutlet weak var tbl_customInfo2: UITableView!
    @IBOutlet weak var tbl_financialInfo: UITableView!
    @IBOutlet weak var lbl_Heading: UILabel!
    @IBOutlet weak var view_bottom: UIView!
    @IBOutlet weak var view_border1: UIView!
    @IBOutlet weak var view_border2: UIView!
    @IBOutlet weak var btn_Ok: UIButton!
    @IBOutlet weak var view_main: UIView!
    @IBOutlet weak var lbl_financialInfo: UILabel!
    @IBOutlet weak var lbl_customInfo: UILabel!
    var senderView : PantryListVC?
    var customerInfoData = Dictionary<String,Any>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view_main.backgroundColor = UIColor.lightGreyColor()
        lbl_financialInfo.backgroundColor = UIColor.lightGreyColor()
        lbl_customInfo.backgroundColor = UIColor.lightGreyColor()
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    @IBAction func Ok_Action(_ sender: Any) {
         self.dismiss(animated: false, completion: {
            self.senderView?.index = -1
            self.senderView?.clctn_Features.reloadData()
         })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tbl_customInfo1 {
            return customerInfo1Arr.count
        }
       else if tableView == tbl_customInfo2 {
            return customerInfo2Arr.count
        }
      else if tableView == tbl_financialInfo {
            return financialInfo2Arr.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomInfoCell") as? CustomInfoCell
        
        if tableView == tbl_customInfo1 {
            
            cell?.lbl_Key.text = customerInfo1Arr[indexPath.row]["Key"]
            cell?.lbl_Key.textColor = UIColor.baseBlueColor()
            cell?.lbl_Key.font = UIFont.Roboto_Regular(baseScaleSize: 15.0)
            cell?.lbl_Value.font = UIFont.Roboto_Regular(baseScaleSize: 15.0)
            if customerInfoData.count>0{
                
                if indexPath.row == 0
                {
                    if customerInfoData.keyExists(key: "AlphaCode"), let alphaCode = customerInfoData["AlphaCode"] as? String{
                        cell?.lbl_Value.text = alphaCode
                        
                    }
                }
                
                if indexPath.row == 1
                {
                    if customerInfoData.keyExists(key: "CustomerName"), let customerName = customerInfoData["CustomerName"] as? String{
                        cell?.lbl_Value.text = customerName.isEmpty ? "N/A":customerName
                        
                    }
                }
                if indexPath.row == 2
                {
                    if customerInfoData.keyExists(key: "Firstname"), let name = customerInfoData["Firstname"] as? String{
                        cell?.lbl_Value.text = name.isEmpty ? "N/A":name
                        
                    }
                }
                if indexPath.row == 3
                {
                    if customerInfoData.keyExists(key: "ABN"), let aBN = customerInfoData["ABN"] as? String{
                        cell?.lbl_Value.text = aBN.isEmpty ? "N/A":aBN
                        
                    }
                }
                if indexPath.row == 4
                {
                    if customerInfoData.keyExists(key: "Address1"), let address1 = customerInfoData["Address1"] as? String{
                        cell?.lbl_Value.text = address1.isEmpty ? "N/A":address1
                        
                    }
                }
                if indexPath.row == 5
                {
                    if customerInfoData.keyExists(key: "Address2"), let address2 = customerInfoData["Address2"] as? String{
                        cell?.lbl_Value.text = address2.isEmpty ? "N/A":address2
                        
                    }
                }
                
                if indexPath.row == 6
                {
                    if customerInfoData.keyExists(key: "Suburb"), let suburb = customerInfoData["Suburb"] as? String{
                        cell?.lbl_Value.text = suburb.isEmpty ? "N/A":suburb
                        
                    }
                }
                
            }
        }
        if tableView == tbl_customInfo2 {
            cell?.lbl_Key.text = customerInfo2Arr[indexPath.row]["Key"]
            cell?.lbl_Key.textColor = UIColor.baseBlueColor()
            cell?.lbl_Key.font = UIFont.Roboto_Regular(baseScaleSize: 15.0)
            cell?.lbl_Value.font = UIFont.Roboto_Regular(baseScaleSize: 15.0)
            if customerInfoData.count>0{
                
                if indexPath.row == 0
                {
                    if customerInfoData.keyExists(key: "PostCode"), let postCode = customerInfoData["PostCode"] as? String{
                        cell?.lbl_Value.text = postCode.isEmpty ? "N/A":postCode
                        UserInfo.shared.postcode = postCode
                        
                    }
                }
                
                if indexPath.row == 1
                {
                    if customerInfoData.keyExists(key: "ContactName"), let contactName = customerInfoData["ContactName"] as? String{
                        cell?.lbl_Value.text = contactName.isEmpty ? "N/A":contactName
                        
                    }
                }
                if indexPath.row == 2
                {
                    if customerInfoData.keyExists(key: "Phone1"), let phone1 = customerInfoData["Phone1"] as? String{
                        cell?.lbl_Value.text = phone1.isEmpty ? "N/A":phone1
                        
                    }
                }
                if indexPath.row == 3
                {
                    if customerInfoData.keyExists(key: "Phone2"), let phone2 = customerInfoData["Phone2"] as? String{
                        cell?.lbl_Value.text = phone2.isEmpty ? "N/A":phone2
                        
                    }
                }
                if indexPath.row == 4
                {
                    if customerInfoData.keyExists(key: "Fax"), let fax = customerInfoData["Fax"] as? String{
                        cell?.lbl_Value.text = fax.isEmpty ? "N/A":fax
                        
                    }
                }
                
                if indexPath.row == 5
                {
                    if customerInfoData.keyExists(key: "Email"), let email = customerInfoData["Email"] as? String{
                        cell?.lbl_Value.text = email.isEmpty ? "N/A":email
                        
                    }
                }
                
                if indexPath.row == 6
                {
                    if customerInfoData.keyExists(key: "SalesmanCode"), let salesmanCode = customerInfoData["SalesmanCode"] as? String{
                        cell?.lbl_Value.text = salesmanCode.isEmpty ? "N/A":salesmanCode
                        
                    }
                }
            }
        }
        if tableView == tbl_financialInfo {
            cell?.lbl_Key.text = financialInfo2Arr[indexPath.row]["Key"]
            cell?.lbl_Key.textColor = UIColor.baseBlueColor()
            cell?.lbl_Key.font = UIFont.Roboto_Regular(baseScaleSize: 15.0)
            cell?.lbl_Value.font = UIFont.Roboto_Regular(baseScaleSize: 15.0)
            if customerInfoData.count>0{
                
                if indexPath.row == 0
                {
                    if customerInfoData.keyExists(key: "CreditLimit"), let creditLimit = customerInfoData["CreditLimit"] as? String{
            
                        cell?.lbl_Value.text = "\(CommonString.currencyType)\(creditLimit)"
                    }
                }
                
                if indexPath.row == 1
                {
                    if customerInfoData.keyExists(key: "PriceLevel"), let priceCode = customerInfoData["PriceLevel"] as? String{
                        cell?.lbl_Value.text = priceCode.isEmpty ? "N/A":priceCode
                        
                    }
                }
                if indexPath.row == 2
                {
                    if customerInfoData.keyExists(key: "BalancePeriod1"), let balancePeriod1 = customerInfoData["BalancePeriod1"] as? Double{
                        
                        cell?.lbl_Value.text = String.init(format: "\(CommonString.currencyType)%.2f", balancePeriod1) //"$\(balancePeriod1)"
                        
                    }
                }
                if indexPath.row == 3
                {
                    if customerInfoData.keyExists(key: "BalancePeriod2"), let balancePeriod2 = customerInfoData["BalancePeriod2"] as? Double{
                        cell?.lbl_Value.text = String.init(format: "\(CommonString.currencyType)%.2f", balancePeriod2)//"$\(balancePeriod2)"
                        
                    }
                }
                if indexPath.row == 4
                {
                    if customerInfoData.keyExists(key: "BalancePeriod3"), let balancePeriod3 = customerInfoData["BalancePeriod3"] as? Double{
                        cell?.lbl_Value.text = String.init(format: "\(CommonString.currencyType)%.2f", balancePeriod3)//"$\(balancePeriod3)"
                        
                    }
                }
                if indexPath.row == 5
                {
                    if customerInfoData.keyExists(key: "OverDueBalance"), let overDueBalance = customerInfoData["OverDueBalance"] as? Double{
                        cell?.lbl_Value.text = String.init(format: "\(CommonString.currencyType)%.2f", overDueBalance)//"$\(overDueBalance)"
                        
                    }
                }
                
                if indexPath.row == 6
                {
                    if customerInfoData.keyExists(key: "TotalBalance"), let balance = customerInfoData["TotalBalance"] as? Double{
                        cell?.lbl_Value.text = String.init(format: "\(CommonString.currencyType)%.2f", balance)//"$\(balance)"
                        
                    }
                }
            }
        }
        
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tbl_customInfo1 {
            return tableView.frame.size.height/CGFloat(customerInfo1Arr.count)
        }
        else if tableView == tbl_customInfo2 {
            return tableView.frame.size.height/CGFloat(customerInfo2Arr.count)
        }
        else if tableView == tbl_financialInfo {
            return tableView.frame.size.height/CGFloat(financialInfo2Arr.count)
        }
        else{
            return 5
        }
    }

}

class CustomInfoCell: UITableViewCell {
    @IBOutlet weak var lbl_Key: UILabel!
    
    @IBOutlet weak var lbl_Value: UILabel!
}
