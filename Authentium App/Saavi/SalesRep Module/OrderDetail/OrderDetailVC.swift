//
//  OrderDetailVC.swift
//  Saavi
//
//  Created by Irmeen Sheikh on 14/03/18.
//  Copyright © 2018 Saavi. All rights reserved.
//

import UIKit

class OrderDetailVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var lbl_CustomerName: customLabel!
    @IBOutlet weak var lbl_SelectHeader: UILabel!
    @IBOutlet weak var lbl_AmountHeader: UILabel!
    @IBOutlet weak var lbl_NPHeader: UILabel!
    @IBOutlet weak var lbl_SOHHeader: UILabel!
    @IBOutlet weak var lbl_UOMHeader: UILabel!
    @IBOutlet weak var lbl_QTYHeader: UILabel!
    @IBOutlet weak var lbl_DescHeader: UILabel!
    @IBOutlet weak var tbl_OrderDescription: UITableView!
    var orderID : NSNumber? = 0
    var tempCartID : NSNumber = 0
    var orderDetailArr = Array<Dictionary<String,Any>>()
   // var customerId :NSNumber = 0
    var selectedIndexPathArray = Array<Int>()
    var cartCount : Int = 0
    var order_Number: String?
    @IBOutlet var country_world_wide_lbl: UIView!
    @IBOutlet weak var view_Header: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.bgViewColor()
        self.tbl_OrderDescription.backgroundColor = UIColor.bgViewColor()
        self.getOrderDetails()
        self.lbl_CustomerName.text = UserInfo.shared.name
        setDefaultNavigation()
        self.view_Header.backgroundColor = UIColor.baseBlueColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- Navigation
    func setDefaultNavigation() -> Void
    {
        self.navigationItem.rightBarButtonItems = nil
        Helper.shared.createCartIcon(onController: self)
        Helper.shared.createHelpButtonItem(onController: self)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.baseBlueColor()]
        if order_Number != nil
        {
            if (order_Number?.contains("/ -"))!
            {
                let newString = order_Number?.replacingOccurrences(of: "/ -", with: "", options: .literal, range: nil)
                self.title = CommonString.orderDetailsTitle + newString!
            }
            else
            {
                self.title = CommonString.orderDetailsTitle + order_Number!
            }
        }
        Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
    }
    @objc func backBtnAction()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    //    MARK:- Table View Handling
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderDetailArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDetailCell") as? OrderDetailCell
        cell?.contentView.backgroundColor = UIColor.bgViewColor()
        if indexPath.row % 2 == 0{
            cell?.view_bg.backgroundColor = UIColor.oddRowColor()
        }
        else{
            cell?.view_bg.backgroundColor = UIColor.evenRowColor()
        }
        let objToBeShownInRow = self.orderDetailArr[indexPath.row]
        cell?.lbl_Description.text = (objToBeShownInRow["ProductName"] as? String)
        
        if let quantity = objToBeShownInRow["Quantity"] as? Double
        {
            cell?.lbl_QTY.text = quantity.cleanValue
        }
        if objToBeShownInRow.keyExists(key: "StockQuantity"), let StockQuantity = objToBeShownInRow["StockQuantity"] as? Double{
            cell?.lbl_SOH.text = String(format: "%.0f", StockQuantity)
        }
        if let isGST =  objToBeShownInRow["IsNoPantry"] as? Bool, isGST == true
        {
            cell?.btn_NP.setImage(#imageLiteral(resourceName: "check1"), for: .normal)
            cell?.btn_NP.tintColor = UIColor.baseBlueColor()
        }
        else{
            cell?.btn_NP.setImage(#imageLiteral(resourceName: "unCheck1"), for: .normal)
            cell?.btn_NP.tintColor = UIColor.activeTextFieldColor()
        }
        cell?.btn_UOM.tag = indexPath.row
        cell?.arrowUOMDropdown.constant = 0.0
        if objToBeShownInRow.keyExists(key: "OrderUnitName"), let orderUnitName = objToBeShownInRow["OrderUnitName"] as? String{
            cell?.lbl_Each.text = orderUnitName
        }
        if objToBeShownInRow.keyExists(key: "Price"),let price = objToBeShownInRow["Price"] as? Double
        {
            let price_final = Double(round(100*price)/100)
            
            let priceStr = String(format: "\(CommonString.currencyType)%.2f", price_final)
            cell?.lbl_Amount.text = price_final <= 0 ? CommonString.marketprice:priceStr
        }
        
        // cell?.btn_UOM.addTarget(self, action: #selector(self.uOMChanged(sender:)), for: .touchUpInside)
        //        if let obj = objToBeShownInRow["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1
        //        {
        //            cell?.arrowUOMDropdown.constant = 10.0
        //        }
        //        else
        //        {
        //            cell?.arrowUOMDropdown.constant = 0.0
        //        }
        //        var arrPrices : Array<Dictionary<String,Any>>?
        //        if let prices = objToBeShownInRow["DynamicUOM"] as? Array<Dictionary<String,Any>>
        //        {
        //            arrPrices = prices
        //        }
        //        else if let prices = objToBeShownInRow["Prices"] as? Array<Dictionary<String,Any>>
        //        {
        //            arrPrices = prices
        //        }
        //        else if var prices = objToBeShownInRow["Prices"] as? Dictionary<String,Any>
        //        {
        //            prices["UOMDesc"] = objToBeShownInRow["UOMDesc"] as? String
        //            prices["UOMID"] = objToBeShownInRow["UOMID"] as? NSNumber
        //            arrPrices = [prices]
        //        }
        //        if (arrPrices != nil), arrPrices!.count > 0
        //        {
        //            var selectedIndex = 0
        //            if let index = objToBeShownInRow["selectedIndex"] as? Int
        //            {
        //                selectedIndex = index
        //            }
        //            let objToFetch = arrPrices![selectedIndex]
        //            if let price = objToFetch["Price"] as? Double{
        //                let priceStr = String(format: "$%.2f", price)
        //                cell?.lbl_Amount.text = priceStr
        //                if objToFetch["UOMDesc"] as? String != nil{
        //                cell?.lbl_Each.text = objToFetch["UOMDesc"] as? String
        //                }
        //                else{
        //                cell?.lbl_Each.text = "-"
        //                }
        //            }
        //            else{
        //                 cell?.lbl_Amount.text = "-"
        //                cell?.lbl_Each.text = "-"
        //            }
        //        }
        cell?.btn_Select.tag = indexPath.row
        cell?.btn_Select.addTarget(self, action: #selector(self.reorderProductsSelectionChanged(sender:)), for: UIControlEvents.touchUpInside)
        if let selectedProdId = self.orderDetailArr[indexPath.row]["ProductID"] as? Int
        {
            if selectedIndexPathArray.contains(selectedProdId)
            {
                cell?.btn_Select.setImage(#imageLiteral(resourceName: "check1"), for: .normal)
                cell?.btn_Select.tintColor = UIColor.baseBlueColor()
            }
            else
            {
                cell?.btn_Select.setImage(#imageLiteral(resourceName: "unCheck1"), for: .normal)
                cell?.btn_Select.tintColor = UIColor.activeTextFieldColor()
            }
        }
        
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    @objc func showHelpAction(){
        
        SyncEngine.sharedInstance.sendGetRequestToServer(strURL: SyncEngine.baseURL + SyncEngine.GetHelp + "Reorder") { (response: Any) in
            
            print(response)
            
            if let responseDic = response as? Dictionary<String,Any>
            {
                print(responseDic)
                SaaviActionHelp.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage:responseDic["Description"] as! String!, withCancelButtonTitle: "OK", completion:{
                    
                })
                
                
                
            }
            
        }
    }
    
    //MARK:- UOM change method
    func uOMChanged(sender : UIButton)
    {
        if let obj = self.orderDetailArr[sender.tag]["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1
        {
            var index : Int = 0
            if let selectedIndex = self.orderDetailArr[sender.tag]["selectedIndex"] as? Int
            {
                index = selectedIndex
            }
            
            if index + 1 < obj.count
            {
                var objToChange = self.orderDetailArr[sender.tag]
                objToChange["selectedIndex"] = index + 1
                self.orderDetailArr[sender.tag] = objToChange
                self.tbl_OrderDescription.reloadData()
            }
            else
            {
                var objToChange = orderDetailArr[sender.tag]
                objToChange["selectedIndex"] = 0
                self.orderDetailArr[sender.tag] = objToChange
                self.tbl_OrderDescription.reloadData()
            }
            
        }
    }
    
    @IBAction func Action_Reorder(_ sender: Any) {
        self.reorderItemsInCart()
    }
    
    func getOrderDetails()
    {
        let serviceURL = SyncEngine.baseURL + SyncEngine.getOrderItems
        let requestToGetOrderDetails = [
            "CustomerID": UserInfo.shared.customerID!,
            "OrderID": self.orderID!,
            "UserID": 0,
            "IsOrderHistory": true
            ] as Dictionary<String,Any>
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestToGetOrderDetails, strURL: serviceURL) { (response : Any) in
            if let items = response as? Array<Dictionary<String,Any>>
            {
                self.orderDetailArr += items
                DispatchQueue.main.async {
                    self.tbl_OrderDescription.reloadData()
                }
                if self.orderDetailArr.count > 0
                {
                    self.tempCartID = (self.orderDetailArr[0]["CartID"] as? NSNumber)!
                }
            }
        }
    }
    
    
    func reorderItemsInCart()
    {
        if selectedIndexPathArray.count > 0
        {
            let requestURL = SyncEngine.baseURL + SyncEngine.reorderItems
            let requestDic = [
                "UserID": UserInfo.shared.userId!,
                "CustomerID": UserInfo.shared.customerID!,
                "OrderID": orderID!,
                "AppendToSavedOrder": false,
                "IsPlacedByRep": true,
                "Products" : self.selectedIndexPathArray
                ] as [String : Any]
            
            SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestDic, strURL: requestURL) { (response :  Any) in
                
                self.selectedIndexPathArray.removeAll()
                self.tbl_OrderDescription.reloadData()
                DispatchQueue.main.async {
                    self.callAPIToUpdateCartNumber()
                    self.showCartScreen()
//                    Helper.shared.showAlertOnController( message: "\(self.selectedIndexPathArray.count) items added to cart", title: CommonString.app_name,hideOkayButton: false)
                    Helper.shared.showAlertOnController( message: "\(self.selectedIndexPathArray.count) items added to cart", title: CommonString.app_name)
                    Helper.shared.dismissAlert()
                }
            }
        }
        else
        {
            Helper.shared.showAlertOnController( message: CommonString.selectReorderItemsString, title: CommonString.app_name)
        }
        
    }
    
    func callAPIToUpdateCartNumber()
    {
        let request = [
            "CartID": 0,
            "IsSavedOrder": false,
            "UserID": UserInfo.shared.userId!,
            "CustomerID": UserInfo.shared.customerID!,
            "isRepUser" : UserInfo.shared.isSalesRepUser!,
            ] as [String : Any]
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: request, strURL: SyncEngine.baseURL + SyncEngine.getCartCountRep, withIndicator: false) { (response : Any) in
            if let obj = response as? Dictionary<String,Any>, let cartCount = obj["Count"] as? NSNumber
            {
                DispatchQueue.main.async {
                    Helper.shared.cartCount = Int(truncating: cartCount)
                    self.setDefaultNavigation()
                    // self.showCartScreen()
                }
            }
        }
    }
    @objc func reorderProductsSelectionChanged(sender : UIButton)
    {
        if let selectedProdId = self.orderDetailArr[sender.tag]["ProductID"] as? Int
        {
            
            if selectedIndexPathArray.contains(selectedProdId)
            {
                if let index = selectedIndexPathArray.index(of: selectedProdId)
                {
                    selectedIndexPathArray.remove(at: index)
                }
            }
            else
            {
                selectedIndexPathArray.append(selectedProdId)
            }
            self.tbl_OrderDescription.reloadData()
        }
    }
    @objc func showCartScreen() -> Void
    {
        if Helper.shared.cartCount == 0{
            Helper.shared.showAlertOnController( message: CommonString.noItemsAddedCartString, title: CommonString.app_name)
        }
        else{
            if let vc = UIStoryboard.init(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "MyCartVC") as? MyCartVC
            {
                //let custId:Int = Int(UserInfo.shared.customerID!)!
                
                //vc.customerId = NSNumber.init(value:custId)
                //  vc.customerAppend_dic = customerAppendDic_List
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

class OrderDetailCell: UITableViewCell {
    
    @IBOutlet weak var view_bg: UIView!
    @IBOutlet weak var lbl_Description: UILabel!
    @IBOutlet weak var lbl_QTY: UILabel!
    @IBOutlet weak var lbl_Each: customLabelGrey!
    @IBOutlet weak var btn_UOM: UIButton!
    @IBOutlet weak var lbl_SOH: UILabel!
    @IBOutlet weak var btn_NP: UIButton!
    @IBOutlet weak var lbl_Amount: customLabelGrey!
    @IBOutlet weak var btn_Select: UIButton!
    @IBOutlet weak var arrowUOMDropdown: NSLayoutConstraint!
    
}

