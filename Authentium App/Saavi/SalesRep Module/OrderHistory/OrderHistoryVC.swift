//
//  OrderHistoryVC.swift
//  Saavi
//
//  Created by Irmeen Sheikh on 08/03/18.
//  Copyright © 2018 Saavi. All rights reserved.
//

import UIKit

class OrderHistoryVC: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var lblNoHistory: UILabel!
    @IBOutlet weak var view_Header: UIView!
    @IBOutlet weak var lbl_Status: UILabel!
    @IBOutlet weak var lbl_Amount: UILabel!
    @IBOutlet weak var lbl_Number: UILabel!
    @IBOutlet weak var lbl_orderDate: UILabel!
    @IBOutlet weak var tbl_orderHistory: UITableView!
    var arrOrderHistoryItems = Array<Dictionary<String,Any>>()
    //var customerId : NSNumber = 0
    var customerArr_List = Dictionary<String,Any>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tbl_orderHistory.backgroundColor = UIColor.bgViewColor()
        self.view.backgroundColor = UIColor.bgViewColor()
        for view in view_Header.subviews
        {
            if view is UILabel
            {
                (view as! UILabel).font = UIFont.SFUI_Regular(baseScaleSize: 16.0)
            }
        }
        self.view_Header.backgroundColor = UIColor.baseBlueColor()
        self.getOrderHistoryItems() 
    }
    override func viewWillAppear(_ animated: Bool) {
        setDefaultNavigation()
    }
    @objc func backBtnAction()
    {
        self.navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOrderHistoryItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderHistoryCell") as? OrderHistoryCell
        cell?.contentView.backgroundColor =  UIColor.bgViewColor()
        if indexPath.section%2 == 0{
            cell?.lbl_ValueAmount.backgroundColor =  UIColor.evenRowColor()
            cell?.lbl_ValueStatus.backgroundColor =  UIColor.evenRowColor()
            cell?.lbl_ValueNumber.backgroundColor =  UIColor.evenRowColor()
            cell?.lbl_ValueOrderDate.backgroundColor =  UIColor.evenRowColor()
        }
        else{
            cell?.lbl_ValueAmount.backgroundColor =  UIColor.oddRowColor()
            cell?.lbl_ValueStatus.backgroundColor =  UIColor.oddRowColor()
            cell?.lbl_ValueNumber.backgroundColor =  UIColor.oddRowColor()
            cell?.lbl_ValueOrderDate.backgroundColor =  UIColor.oddRowColor()
        }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.zz"
        df.timeZone = TimeZone(abbreviation: "UTC")
        if self.arrOrderHistoryItems.count>0{
            
            let date = self.arrOrderHistoryItems[indexPath.row]["OrderDate"] as? String
            
            if(date?.count==19){
                df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                
            }
            
            if(date?.count==10){
                df.dateFormat = "yyyy-MM-dd"
                
            }
            
            if let date = self.arrOrderHistoryItems[indexPath.row]["OrderDate"] as? String, let actualDate = df.date(from: date)
            {
                df.dateFormat = "dd MMM yyyy"
                cell?.lbl_ValueOrderDate.text = df.string(from: actualDate)
            }
            else
            {
                cell?.lbl_ValueOrderDate.text = "-"
            }
            if let orderNumber = self.arrOrderHistoryItems[indexPath.row]["OrderNumber"] as? String
            {
                cell?.lbl_ValueNumber.text = orderNumber
            }
            else
            {
                cell?.lbl_ValueNumber.text = "-"
            }
            if let orderStatus = self.arrOrderHistoryItems[indexPath.row]["CheckOrderStatus"] as? String
            {
                cell?.lbl_ValueStatus.text = orderStatus
            }
            else
            {
                cell?.lbl_ValueStatus.text = "-"
            }
            if let price = self.arrOrderHistoryItems[indexPath.row]["Price"] as? Double{
                
                let price_final = Double(round(100*price)/100)

                let priceStr = String(format: "\(CommonString.currencyType)%.2f", price_final)
                cell?.lbl_ValueAmount.text = price <= 0 ? CommonString.marketprice:priceStr
            }
            else{
                cell?.lbl_ValueAmount.text = "-"
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Configration.scalingFactor() * 60.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let orderDetailVC = UIStoryboard.init(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "OrderDetailVC") as! OrderDetailVC
        //orderDetailVC.customerId = customerId
        if let orderID = self.arrOrderHistoryItems[indexPath.row]["CartID"] as? NSNumber
        {
            orderDetailVC.orderID = orderID
        }
        if let orderNumber = self.arrOrderHistoryItems[indexPath.row]["OrderNumber"] as? String
        {
            orderDetailVC.order_Number = orderNumber
        }
        self.navigationController?.pushViewController(orderDetailVC, animated: false)
    }
    
    //    MARK:- Server Communication
    //    func getOrderHistoryItems()
    //    {
    //        let serviceURL = SyncEngine.baseURL + SyncEngine.getUserOrderHistory
    //        SyncEngine.sharedInstance.sendGetRequestToServer(strURL: serviceURL) { (response : Any) in
    //            if let arrHistoryItems = response as? Array<Dictionary<String,Any>>
    //            {
    //                self.arrOrderHistoryItems.removeAll()
    //                self.arrOrderHistoryItems += arrHistoryItems
    //            }
    //            DispatchQueue.main.async {
    //                self.tbl_orderHistory.reloadData()
    //            }
    //        }
    //    }
    
    //MARK:- Navigation
    func setDefaultNavigation() -> Void
    {
        self.navigationItem.rightBarButtonItems = nil
        Helper.shared.createCartIcon(onController: self)
        Helper.shared.setNavigationTitle(viewController: self, title: CommonString.orderHistoryTitle)
        Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
    }
    
    @objc func showCartScreen() -> Void
    {
        if let vc = UIStoryboard.init(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "MyCartVC") as? MyCartVC
        {
            //vc.customerId = customerId
            // vc.customerAppend_dic = customerArr_List
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func getOrderHistoryItems()
    {
        let serviceURL = SyncEngine.baseURL + SyncEngine.getOrderHistoryRep
        let requestToGetOrderDetails = [
            "CustomerID": UserInfo.shared.customerID!
            ] as Dictionary<String,Any>
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestToGetOrderDetails, strURL: serviceURL) { (response : Any) in
            if let items = response as? Array<Dictionary<String,Any>>
            {
                self.arrOrderHistoryItems.removeAll()
                self.arrOrderHistoryItems += items
                
            }
            DispatchQueue.main.async {
                if self.arrOrderHistoryItems.count == 0
                {
                    self.lblNoHistory.isHidden = false
                }
                else
                {
                    
                    self.tbl_orderHistory.reloadData()
                    self.lblNoHistory.isHidden = true
                }
            }
        }
    }
}

class OrderHistoryCell: UITableViewCell {
    @IBOutlet weak var lbl_ValueOrderDate: customLabelGrey!
    @IBOutlet weak var lbl_ValueStatus: customLabelGrey!
    @IBOutlet weak var lbl_ValueAmount: customLabelGrey!
    @IBOutlet weak var lbl_ValueNumber: customLabelGrey!
    
}
