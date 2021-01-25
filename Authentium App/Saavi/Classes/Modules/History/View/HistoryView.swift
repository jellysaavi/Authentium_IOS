//
//  HistoryVC.swift
//  Saavi
//
//  Created by Sukhpreet SIngh on 29/09/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class HistoryView : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblViewOrderHistoryItems: UITableView!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var lblNoHistory: UILabel!
    @IBOutlet weak var lblStatusHeader: UILabel!
    @IBOutlet weak var lblNumberHeader: UILabel!
    @IBOutlet weak var lblOrderDateHeader: UILabel!
    
    var arrOrderHistoryItems = Array<Dictionary<String,Any>>()
    
    
    
    //    MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblViewOrderHistoryItems.tableFooterView = UIView()
        Helper.shared.setNavigationTitle( viewController : self, title : "Order History")
        
        for view in headerView.subviews
        {
            if view is UILabel
            {
                (view as! UILabel).font = UIFont.SFUI_Regular(baseScaleSize: 16.0)
            }
        }
        if AppFeatures.shared.isShowOrderStatus == true &&  AppFeatures.shared.isCheckDelivery == true{
            lblStatusHeader.text = "DELIVERY STATUS"
        }
        else if AppFeatures.shared.isShowOrderStatus == true {
            lblStatusHeader.text = "STATUS"
        }
        else if  AppFeatures.shared.isCheckDelivery == true{
            lblStatusHeader.text = "DELIVERY STATUS"
        }
        NotificationCenter.default.addObserver(self, selector: #selector(HistoryView.setDefaultNavigation), name: NSNotification.Name(rawValue: "cartCountChanged"), object: nil)
        // Do any additional setup after loading the view.
    }
    @objc func showHelpAction(){
        
        SyncEngine.sharedInstance.sendGetRequestToServer(strURL: SyncEngine.baseURL + SyncEngine.GetHelp + "OrderHistory") { (response: Any) in
            
            print(response)
            
            if let responseDic = response as? Dictionary<String,Any>
            {
                print(responseDic)
                SaaviActionHelp.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage:responseDic["Description"] as! String!, withCancelButtonTitle: "OK", completion:{
                    
                })
                
                
                
            }
            
        }
    }
    
    @objc func backBtnAction()
    {
        
        self.navigationController?.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func setDefaultNavigation() -> Void
    {
        self.navigationItem.rightBarButtonItems = nil
        Helper.shared.createCartIcon(onController: self)
        Helper.shared.createLatestSpecialsBarButtonItem(onController: self)
         Helper.shared.createHelpButtonItem(onController: self)
    }
    
    @objc func showCartScreen() -> Void
    {
        if UserInfo.shared.customerOnHoldStatus == true && !AppFeatures.shared.isAllowOnHoldPlacingOrder
        {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                return
            })
        }
        else{
            if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cartVCStoryboardID") as? CartView
            {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setDefaultNavigation()
        self.getOrderHistoryItems()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    MARK:- Table View Handling
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOrderHistoryItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderHistoryCellReuseIdentifier") as? HistoryTableViewCell
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone(abbreviation: "UTC")
        if AppFeatures.shared.showOrderDateInHistory == true, let date = self.arrOrderHistoryItems[indexPath.row]["OrderDate"] as? String, let actualDate = df.date(from: date)
        {
            df.dateFormat = "dd MMM yyyy"
            cell?.lblDescription.text = df.string(from: actualDate)
        }
        else
        {
            cell?.lblDescription.text = "-"
        }
        
        if let orderNumber = self.arrOrderHistoryItems[indexPath.row]["OrderNumber"] as? String
        {
            cell?.lblOrderNumber.text = orderNumber
        }
        else
        {
            cell?.lblOrderNumber.text = "-"
        }
        if AppFeatures.shared.isShowOrderStatus == true &&  AppFeatures.shared.isCheckDelivery == true{
            if let orderStatus = self.arrOrderHistoryItems[indexPath.row]["CheckOrderStatus"] as? String
            {
                cell?.lblOrderStatus.text = orderStatus
            }
            else
            {
                cell?.lblOrderStatus.text = "-"
            }
        }
        else if AppFeatures.shared.isShowOrderStatus == true {
            if let orderStatus = self.arrOrderHistoryItems[indexPath.row]["OrderStatusDesc"] as? String
            {
                cell?.lblOrderStatus.text = orderStatus
            }
            else
            {
                cell?.lblOrderStatus.text = "-"
            }
        }
        else if  AppFeatures.shared.isCheckDelivery == true{
            if let orderStatus = self.arrOrderHistoryItems[indexPath.row]["CheckOrderStatus"] as? String
            {
                cell?.lblOrderStatus.text = orderStatus
            }
            else
            {
                cell?.lblOrderStatus.text = "-"
            }
        }
        else{
            cell?.lblOrderStatus.text = "-"
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Configration.scalingFactor() * 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cartVCStoryboardID") as? CartView
        {
            vc.isShowingOrderDetails = true
            if let orderID = self.arrOrderHistoryItems[indexPath.row]["CartID"] as? NSNumber
            {
                vc.orderID = orderID
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //    MARK:- Server Communication
    func getOrderHistoryItems()
    {
        let serviceURL = SyncEngine.baseURL + SyncEngine.getUserOrderHistory
        let requestToGetOrderDetails = [
            "CustomerID": UserInfo.shared.customerID!,
            ] as Dictionary<String,Any>
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestToGetOrderDetails, strURL: serviceURL) { (response : Any) in
            if let arrHistoryItems = response as? Array<Dictionary<String,Any>>
            {
                self.arrOrderHistoryItems.removeAll()
                self.arrOrderHistoryItems += arrHistoryItems
            }
            DispatchQueue.main.async {
                if self.arrOrderHistoryItems.count == 0
                {
                    self.lblNoHistory.isHidden = false
                }
                else
                {
                    self.lblNoHistory.isHidden = true
                    
                    self.tblViewOrderHistoryItems.reloadData()
                }
            }
            
        }
        
    }
    
    
    @IBAction func toggleProfileAction(_ sender: Any) {
        (self.navigationController?.tabBarController as! SaaviTabBarController).menuController?.showMeSideMenu()
    }
    
    @objc func showLatestSpecialsAction()
    {
        
        if let walkthrough = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: WhatsNewVC.storyboardID) as? WhatsNewVC{
            walkthrough.isFromTab = false
            self.navigationController?.pushViewController(walkthrough, animated: true)
        }
    }
    
    @objc func showSearchBar() -> Void
    {
        if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderVCStoryboardId") as? OrderVC
        {
            destinationViewController.isSearchingProduct = true
            destinationViewController.isShowingDefaultPantryList = false
            self.navigationController?.pushViewController(destinationViewController, animated: false)
        }
    }
    
}

