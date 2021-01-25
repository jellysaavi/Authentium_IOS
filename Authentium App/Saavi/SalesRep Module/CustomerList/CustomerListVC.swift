 //
 //  CustomerListVC.swift
 //  Saavi
 //
 //  Created by Irmeen Sheikh on 12/02/18.
 //  Copyright © 2018 Saavi. All rights reserved.
 //
 
 import UIKit
 
 class CustomerListVC: UIViewController ,UICollectionViewDelegate ,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UISearchBarDelegate{
    
    // let arrHeader = [["name":"ID No."],["name":"Customers"],["name":"Mobile No."],["name":"Terms"],["name":"A/c Type"],["name":"YTD Sales"],["name":"MTD Sales"],["name":"PREV Sales"],["name":"Outstanding"],["name":"Overdue"],["name":"Balance"],["name":"Order Place"]]
    let arrHeader = [["name":"ID No."],
                     ["name":"Customers"],
                     ["name":"Mobile No."],
                     ["name":"A/C Type"],
                     ["name":"YTD Sales"],
                     ["name":"MTD Sales"],
                     ["name":"LAST Sales"],
                     ["name":"Current"],
                     ["name":"Overdue"],
                     ["name":"Balance"],
                     ["name":"Place Order"]]
    
    @IBOutlet weak var btn_ShowAll: UIButton!
    @IBOutlet weak var clctn_Detail: UICollectionView!
    @IBOutlet weak var lbl_Customers: UILabel!
    
    var customerList = Array<Dictionary<String,Any>>()
    var allcustomers = Array<Dictionary<String,Any>>()
    var getRepCustomerDic = Dictionary<String,Any>()
    var heightForCell = CGFloat()
    var pageNumber : Int = 1
    var totalResults : NSNumber?
    var allResults : NSNumber?
    var isSearchingCustomer : Bool = false
    var runNumbersArr = Array<Any>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.bgViewColor()
        self.clctn_Detail.backgroundColor = UIColor.bgViewColor()
        setDefaultNavigation()
        self.getRepCustomerList(searchText: "")
        self.lbl_Customers.font = UIFont.Roboto_Medium(baseScaleSize: 25.0)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UserInfo.shared.customerID = UserInfo.shared.salesRepCustID
        UserInfo.shared.customerOnHoldStatus = UserInfo.shared.customerRepOnHoldStatus
        Helper.shared.cartCount = 0
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func setDefaultNavigation() -> Void
    {
        let searchBtn = UIButton(type: .custom)
        let image = UIImage(named: "search")
        searchBtn.setImage(image, for: .normal)
        searchBtn.tintColor = UIColor.baseBlueColor()
        searchBtn.frame = CGRect(x: 0, y: 0, width: 34, height: 44)
        searchBtn.imageView?.contentMode = .scaleAspectFit
        searchBtn.addTarget(self, action: #selector(self.showSearchBar), for: .touchUpInside)
        //searchBtn.tag = Int(savedOrderId!)
        
        let logoutBtn = UIButton(type: .custom)
        logoutBtn.setImage(#imageLiteral(resourceName: "icon_profile"), for: .normal)
        logoutBtn.tintColor = UIColor.baseBlueColor()
        logoutBtn.frame = CGRect(x: 0, y: 0, width: 34, height: 44)
        logoutBtn.imageView?.contentMode = .scaleAspectFit
        logoutBtn.addTarget(self, action: #selector(self.showLogout(_:)), for: .touchUpInside)
        let barBtn = UIBarButtonItem(customView: searchBtn)
        let barBtn2 = UIBarButtonItem(customView: logoutBtn)
        self.navigationItem.rightBarButtonItems = [barBtn2, barBtn]
        
        
        if AppFeatures.shared.isAdvancedPantry == true &&  AppFeatures.shared.isRepProductBrowsing == true
        {
            Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
        }
       
        Helper.shared.setNavigationTitle(viewController: self, title: CommonString.selectCustomerTitle)
    }
    
    @objc func backBtnAction()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func showLogout(_ button : UIButton)
    {
       Helper.shared.logout()
    }
    
    @objc func showSearchBar() -> Void
    {
        self.navigationItem.rightBarButtonItems = nil
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        let cancelSearchBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(searchBarCancelButtonClicked(_:)))
        cancelSearchBarButtonItem.tintColor = UIColor.baseBlueColor()
        if self.isSearchingCustomer == false
        {
            self.navigationItem.setRightBarButton(cancelSearchBarButtonItem, animated: true)
        }
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        isSearchingCustomer = true
        self.navigationItem.titleView = searchBar
    }
    
    //    MARK: - Search Bar Delegate -
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        self.navigationItem.titleView = nil
        self.setDefaultNavigation()
        isSearchingCustomer = false
        self.hideNoItemsLabel()
        self.view.endEditing(true)
        self.totalResults = self.allResults
        self.customerList = self.allcustomers
        self.clctn_Detail.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == ""
        {
            // hideNoItemsLabel()
            self.customerList.removeAll()
            self.clctn_Detail.reloadData()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if searchBar.text == "", text == " "
        {
            return false
        }
        else{
            return true
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        if isSearchingCustomer == true
        {
            searchBar.resignFirstResponder()
        }
        pageNumber = 1
        self.view.endEditing(true)
        self.customerList.removeAll()
        self.getRepCustomerList(searchText: searchBar.text!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- CollectionView delegate and datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if customerList.count>0{
            return customerList.count+1
        }
        else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if AppFeatures.shared.isAdvancedPantry == true
        {
            return arrHeader.count
        }
        else
        {
            return arrHeader.count-1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        if indexPath.section == 0
        {
            //            if indexPath.item != (arrHeader.count-1)
            //            {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailsCell", for: indexPath) as! DetailsCell
            cell.lbl_Detail.text = arrHeader[indexPath.item]["name"]
            cell.lbl_Detail.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.lbl_Detail.backgroundColor = UIColor.baseBlueColor()
            cell.lbl_Detail.font = UIFont.Roboto_Medium(baseScaleSize: 13.0)
            cell.lbl_Detail.textAlignment = .center
            return cell
            //            }
            //            else
            //            {
            //                let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemButtonCell", for: indexPath) as! ItemButtonCell
            //
            //                cell.btn_PantryItems.setTitle(arrHeader[indexPath.item]["name"], for: .normal)
            //                cell.btn_PantryItems.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            //                cell.View_bg.backgroundColor = UIColor.baseBlueColor()
            //                cell.btn_PantryItems.titleLabel?.font = UIFont.Roboto_Medium(baseScaleSize: 13.0)
            //                return cell
            //            }
        }
            
        else{
            if indexPath.item != (arrHeader.count-1)
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailsCell", for: indexPath) as! DetailsCell
                cell.lbl_Detail.font = UIFont.Roboto_Regular(baseScaleSize: 13.0)
                cell.lbl_Detail.text = ""
                if indexPath.section%2 == 0{
                    cell.lbl_Detail.backgroundColor = UIColor.evenRowColor()
                }
                else{
                    cell.lbl_Detail.backgroundColor  = UIColor.oddRowColor()
                }
                cell.lbl_Detail.textColor = UIColor.darkGreyColor()
                setValuesInTable(cell: cell, indexPath: IndexPath(item: indexPath.item, section:indexPath.section))
                return cell
            }
            else
            {
                let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemButtonCell", for: indexPath) as! ItemButtonCell
                cell.btn_PantryItems.setTitleColor(UIColor.baseBlueColor(), for: .normal)
                cell.btn_PantryItems.setTitle("PANTRY ITEMS", for: .normal)
                cell.btn_PantryItems.titleLabel?.adjustsFontSizeToFitWidth = true
                cell.btn_PantryItems.tag = indexPath.section-1
                cell.btn_PantryItems.addTarget(self, action: #selector(self.openPantryList), for: .touchUpInside)
                if indexPath.section%2 == 0{
                    cell.View_bg.backgroundColor =  UIColor.evenRowColor()
                }
                else{
                    cell.View_bg.backgroundColor = UIColor.oddRowColor()
                }
                return cell
            }
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        var height : CGFloat = 0.0
        if indexPath.section == 0
        {
            height = 40.0 * VerticalSpacingConstraints.spacingConstant
        }
        else
        {
            height = 60.0 * VerticalSpacingConstraints.spacingConstant
        }
        
        if AppFeatures.shared.isAdvancedPantry == true
        {
            if indexPath.item == (arrHeader.count-1)
            {
                return CGSize(width: (collectionView.bounds.size.width/CGFloat(arrHeader.count)-(11.0/8.0))+11.0, height: height)
            }
            else{
                return CGSize(width: (collectionView.bounds.size.width/CGFloat(arrHeader.count)-(11.0/8.0))-1.0, height: height)
            }
        }
        else
        {
            return CGSize(width: collectionView.bounds.size.width/CGFloat(arrHeader.count-1)-(11.0/7.0), height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if AppFeatures.shared.isAdvancedPantry == false
        {
            DispatchQueue.main.async {
                if let testVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "menuHierarchyHandlerStoryID") as? MenuHierarchyHandler
                {
                    let customerDic = self.customerList[indexPath.section-1] as Dictionary<String,Any>
                    if customerDic.keyExists(key: "CustomerID"), let customId = customerDic["CustomerID"] as? NSNumber{
                        UserInfo.shared.customerID = String(describing: customId)
                    }
                    
                    
                    let dict = customerDic["DefaultOrderInfo"] as? NSDictionary
                    
                    let daysArray = dict?.value(forKeyPath: "Result.permittedDays") as? NSArray
                    
                    Helper.shared.nextOrderDates = dict?.value(forKeyPath: "Result.orderDates") as? Array<String>
                    
                    
                    if (daysArray?.count)! > 0{
                        
                        Helper.shared.allowedWeekdaysForDelivery = daysArray as? Array<String>
                        
                    }else{
                        
                        Helper.shared.allowedWeekdaysForDelivery = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
                    }
                    
//                    if ((customerDic["DefaultOrderInfo"] as? Dictionary<String,Any>)?["permittedDays"] as? Array<String>) != nil && ((customerDic["DefaultOrderInfo"] as? Dictionary<String,Any>)?["permittedDays"] as! Array<String>).count > 0
//                    {
//                        Helper.shared.allowedWeekdaysForDelivery = (customerDic["DefaultOrderInfo"] as? Dictionary<String,Any>)?["permittedDays"] as? Array<String>
//                    }
//                    else
//                    {
//                        Helper.shared.allowedWeekdaysForDelivery = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
//                    }
                    
                    if let allowedSundays = (customerDic["DefaultOrderInfo"] as? Dictionary<String,Any>)?["sundayOrdering"] as? Bool, allowedSundays == true
                    {
                        AppFeatures.shared.isSundayOrderingEnabled = allowedSundays
                        if Helper.shared.allowedWeekdaysForDelivery?.contains("sunday") == false
                        {
                            Helper.shared.allowedWeekdaysForDelivery?.append("sunday")
                        }
                    }
                    else
                    {
                        AppFeatures.shared.isSundayOrderingEnabled = false
                    }
                    
                    SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: ["userID" : UserInfo.shared.userId!,"CustomerID" :UserInfo.shared.customerID!,"IsRepUser" : UserInfo.shared.isSalesRepUser!], strURL: SyncEngine.baseURL + SyncEngine.getCustomerFeatures, completion: { (response : Any) in
                        Helper.shared.processCustomerfeatureRequest(withResponse: response)
                        DispatchQueue.main.async {
                            self.navigationController?.isNavigationBarHidden = true
                            self.navigationController?.pushViewController(testVC, animated: true)
                        }
                    })
                }
            }
        }
    }
    
    @objc func openPantryList(sender:UIButton){
        
        let pantryListVc = UIStoryboard.init(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "PantryListVC") as? PantryListVC
        let customerDic = customerList[sender.tag] as Dictionary<String,Any>
        if customerDic.keyExists(key: "CustomerID"), let customId = customerDic["CustomerID"] as? NSNumber{
            //pantryListVc?.customerID = customId
            UserInfo.shared.customerID = "\(customId)"
            pantryListVc?.customerListDic = customerDic
            pantryListVc?.getRepCustomerDic_list = getRepCustomerDic
            pantryListVc?.runNumberList = runNumbersArr
        }
        // Allowed days
        
        let dict = customerDic["DefaultOrderInfo"] as? NSDictionary
        UserInfo.shared.customerOnHoldStatus = customerDic[ "DebtorOnHold"] as? Bool ?? false
        let daysArray = dict?.value(forKeyPath: "Result.permittedDays") as? NSArray
        
        Helper.shared.nextOrderDates = dict?.value(forKeyPath: "Result.orderDates") as? Array<String>
        
        if (daysArray?.count)! > 0{
            
            Helper.shared.allowedWeekdaysForDelivery = daysArray as? Array<String>
            
        }else{
            
            Helper.shared.allowedWeekdaysForDelivery = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
        }
        
        if let allowedSundays = (customerDic["DefaultOrderInfo"] as? Dictionary<String,Any>)?["sundayOrdering"] as? Bool, allowedSundays == true
        {
            AppFeatures.shared.isSundayOrderingEnabled = allowedSundays
            if Helper.shared.allowedWeekdaysForDelivery?.contains("sunday") == false
            {
                Helper.shared.allowedWeekdaysForDelivery?.append("sunday")
            }
        }
        else
        {
            AppFeatures.shared.isSundayOrderingEnabled = false
            
        }
        Helper.shared.nextOrderDates = dict?.value(forKeyPath: "Result.orderDates") as? Array<String>
        
        if  Helper.shared.customerAppendDic_List.keyExists(key: "RunNo"){
            Helper.shared.customerAppendDic_List.removeValue(forKey: "RunNo")
        }
        if customerDic.keyExists(key: "RunNo"), let runnumber = customerDic["RunNo"] as? String{
            
            AppFeatures.shared.defaultRunNumber = runnumber
        }
        self.navigationController?.pushViewController(pantryListVc!, animated: true)
    }
    
    func setValuesInTable(cell:DetailsCell,indexPath:IndexPath){
        if indexPath.section != 0
        {
            if customerList.count>0{
                let customerDic = customerList[indexPath.section-1]
                if indexPath.item == 0{
                    
                    if customerDic.keyExists(key: "AlphaCode"), let customId = customerDic["AlphaCode"] as? String{
                        cell.lbl_Detail.text = String(describing: customId)
                    }
                    else{
                        cell.lbl_Detail.text = ""
                    }
                }
                if indexPath.item == 1{
                    if customerDic.keyExists(key: "CustomerName"), let customName = customerDic["CustomerName"] as? String{
                        cell.lbl_Detail.text = customName
                        self.heightForCell = Helper.shared.heightForView(text: customName, font: UIFont.Roboto_Medium(baseScaleSize: 13.0), width: cell.lbl_Detail.frame.size.width)
                    }
                    else{
                        cell.lbl_Detail.text = ""
                    }
                }
                if indexPath.item == 2{
                    if customerDic.keyExists(key: "Phone1"), let phnNo = customerDic["Phone1"] as? String{
                        cell.lbl_Detail.text = phnNo
                    }
                    else{
                        cell.lbl_Detail.text = ""
                    }
                }
                if indexPath.item == 3{
                    if customerDic.keyExists(key: "AccountType"), let accType = customerDic["AccountType"] as? String{
                        cell.lbl_Detail.text = accType
                    }
                    else{
                        cell.lbl_Detail.text = ""
                    }
                }
                if indexPath.item == 4{
                    if customerDic.keyExists(key: "YTDSales"), let ytdSales = customerDic["YTDSales"] as? Double{
                        let ytdSalesStr = String(format: "\(CommonString.currencyType)%.2f", ytdSales)
                        cell.lbl_Detail.text = ytdSalesStr
                    }
                    else{
                        cell.lbl_Detail.text = ""
                    }
                }
                if indexPath.item == 5{
                    if customerDic.keyExists(key: "MTDSales"), let mtdSales = customerDic["MTDSales"] as? Double{
                        let mtdSalesStr = String(format: "\(CommonString.currencyType)%.2f", mtdSales)
                        cell.lbl_Detail.text = mtdSalesStr
                    }
                    else{
                        cell.lbl_Detail.text = ""
                    }
                }
                if indexPath.item == 6{
                    if customerDic.keyExists(key: "PrevMonth"), let prevMonthSales = customerDic["PrevMonth"] as? Double{
                        let prevMonthSalesStr = String(format: "\(CommonString.currencyType)%.2f", prevMonthSales)
                        cell.lbl_Detail.text = prevMonthSalesStr
                    }
                    else{
                        cell.lbl_Detail.text = ""
                    }
                }
                if indexPath.item == 7{
                    if customerDic.keyExists(key: "CurrentBalance"), let outstanding = customerDic["CurrentBalance"] as? Double{
                        let outstandingStr = String(format: "\(CommonString.currencyType)%.2f", outstanding)
                        cell.lbl_Detail.text = outstandingStr
                    }
                    else{
                        cell.lbl_Detail.text = ""
                    }
                }
                if indexPath.item == 8{
                    if customerDic.keyExists(key: "OverDueBalance"), let overDue = customerDic["OverDueBalance"] as? Double{
                        let overDueStr = String(format: "\(CommonString.currencyType)%.2f", overDue)
                        cell.lbl_Detail.text = overDueStr
                    }
                    else{
                        cell.lbl_Detail.text = ""
                    }
                }
                if indexPath.item == 9{
                    if customerDic.keyExists(key: "TotalBalance"), let balance = customerDic["TotalBalance"] as? Double{
                        let balanceStr = String(format: "\(CommonString.currencyType)%.2f", balance)
                        cell.lbl_Detail.text = balanceStr
                    }
                    else{
                        cell.lbl_Detail.text = ""
                    }
                }
            }
        }
    }
    
    //MARK:- ShowAll button Action
    
    @IBAction func showAllAction(_ sender: Any) {
        //        let pantryListVc = self.storyboard?.instantiateViewController(withIdentifier: "CustomerInfoVC") as? CustomerInfoVC
        //        self.navigationController?.pushViewController(pantryListVc!, animated: true)
    }
    
    //MARK:- Web Service to get customer list
    func getRepCustomerList(searchText:String){
        let requestParameters = NSMutableDictionary()
        requestParameters.setValue(UserInfo.shared.customerID!, forKey: "CustomerID")
        requestParameters.setValue(searchText, forKey: "Searchtext")
        requestParameters.setValue(20, forKey: "PageSize")
        requestParameters.setValue(pageNumber-1, forKey: "PageIndex")
        requestParameters.setValue(true, forKey: "Debug")
        let serviceURL = SyncEngine.baseURL + SyncEngine.getRepCustomers
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestParameters as! Dictionary<String, Any>, strURL: serviceURL) { (response : Any) in
            if (response as? Dictionary<String,Any>) != nil
            {
                self.getRepCustomerDic = (response as? Dictionary<String,Any>)!
                if (response is Dictionary<String,Any>) && (response as! Dictionary<String,Any>).keyExists(key: "Customers"), let customerListArray = (response as! Dictionary<String,Any>)["Customers"] as? Array<Dictionary<String,Any>>
                {
                    self.customerList += customerListArray
                    self.allcustomers += customerListArray
                }
                DispatchQueue.main.async(execute:
                    {
                        self.clctn_Detail.reloadData()
                        if self.customerList.count==0{
                            self.showNoItemsLabel()
                            
                        }
                        else{
                            self.hideNoItemsLabel()
                        }
                })
                if (response as! Dictionary<String,Any>).keyExists(key: "TotalResults"), let totalResults = (response as! Dictionary<String,Any>)["TotalResults"] as? NSNumber
                {
                    self.totalResults = totalResults
                    if searchText == ""{
                        self.allResults = totalResults
                    }
                }
                if (response as! Dictionary<String,Any>).keyExists(key: "RunNumbers"), let runNumbers = (response as! Dictionary<String,Any>)["RunNumbers"] as? Array<Any>
                {
                    self.runNumbersArr = runNumbers
                }
            }
        }
        
    }
    func showNoItemsLabel()
    {
        DispatchQueue.main.async
            {
                if self.view.viewWithTag(57) == nil
                {
                    self.lbl_Customers.text = ""
                    let label = Helper.shared.createLabelWithMessage(message: "No result found.")
                    label.tag = 57
                    label.center = self.clctn_Detail.center
                    self.view.addSubview(label)
                }
        }
    }
    
    func hideNoItemsLabel()
    {
        self.lbl_Customers.text = "Customers"
        DispatchQueue.main.async {
            if let noRecordsLabel = self.view.viewWithTag(57) as? UILabel
            {
                noRecordsLabel.removeFromSuperview()
            }
            
        }
    }
    
    //    MARK:- Scroll View -
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate
        {
            if scrollView == clctn_Detail {
                self.handlePaginationIfRequired(scrollView:  scrollView)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        if scrollView == clctn_Detail{
            self.handlePaginationIfRequired(scrollView:  scrollView)
        }
    }
    
    func handlePaginationIfRequired(scrollView: UIScrollView)
    {
        if scrollView.contentSize.height < (scrollView.contentOffset.y + scrollView.frame.size.height + 5.0), totalResults != nil, Int(truncating: self.totalResults!) > self.customerList.count
        {
            pageNumber += 1
            var searchText = ""
            if self.navigationItem.titleView is UISearchBar
            {
                searchText = (self.navigationItem.titleView as! UISearchBar).text!
            }
            
            //  if isSearchingCustomer == true{
            if searchText != ""{
                self.getRepCustomerList(searchText: searchText)
            }
            else{
                self.getRepCustomerList(searchText: "")
            }
            // }
        }
    }
    
 }
 
 class ItemButtonCell: UICollectionViewCell {
    @IBOutlet weak var btn_PantryItems: UIButton!
    @IBOutlet weak var View_bg: UIView!
    
    override func awakeFromNib() {
        //self.btn_PantryItems.layer.borderWidth = 1.0
        self.btn_PantryItems.layer.borderColor = UIColor.baseBlueColor().withAlphaComponent(0.5).cgColor
        //self.btn_PantryItems.layer.cornerRadius = 5.0
        self.btn_PantryItems.titleLabel?.font = UIFont.Roboto_Regular(baseScaleSize: 11.0)
        //  self.btn_PantryItems.titleLabel?.textColor = UIColor.baseBlueColor()
        
    }
 }
 
 class DetailsCell: UICollectionViewCell {
    @IBOutlet weak var lbl_Detail: UILabel!
    
 }
 
 
 

