//
//  CustomerListIphoneViewController.swift
//  Saavi
//
//  Created by goMad Infotech on 14/11/18.
//  Copyright © 2018 Saavi. All rights reserved.
//

import UIKit

class CustomerListIphoneViewController: UIViewController,CustomerListViewProtocol {
    
    //MARK: - - Outlets
    @IBOutlet weak var lblRepUsername: UILabel!
    @IBOutlet weak var tblVwCustomerList: UITableView!
    var isSearchingCustomer : Bool = false
    var customerList = Array<Dictionary<String,Any>>()
    var allcustomers = Array<Dictionary<String,Any>>()
    var getRepCustomerDic = Dictionary<String,Any>()
    var heightForCell = CGFloat()
    var pageNumber : Int = 1
    var totalResults : Int?
    var allResults : Int?
    var runNumbersArr = Array<Any>()
    
    //Presenter Object
    
    var presenter : CustomerListViewPresenterProtocol?
    var present : CustomerListViewPresenter?
    
    //MARK: - - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        self.commonInit()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        UserInfo.shared.customerID = UserInfo.shared.salesRepCustID
        Helper.shared.cartCount = 0
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    fileprivate func commonInit(){
        
        self.setDefaultNavigation()
        self.getRepCustomerList(searchText: "")
        self.tblVwCustomerList.tableFooterView = UIView()
        var attributedString = NSMutableAttributedString()
        
        attributedString = NSMutableAttributedString(attributedString: self.setAttributedText(text: "Rep Name: ", fontName: "SFUIDisplay-Regular", color: .gray))
        attributedString.append(self.setAttributedText(text: UserInfo.shared.name!, fontName: "SFUIDisplay-Bold", color: .baseBlueColor()))
        
        self.lblRepUsername.attributedText = attributedString//repText //attributedString
        
        
    }
    
    fileprivate func setAttributedText(text:String,fontName:String,color:UIColor)->NSAttributedString{
        
        let font = UIFont.init(name:fontName , size: 18)
        let attributes = [NSAttributedStringKey.font: font,NSAttributedStringKey.foregroundColor:color]
        return NSAttributedString(string: text, attributes: attributes as [NSAttributedStringKey : Any])
        
    }
    
    
    @objc func backBtnAction() -> Void{
        
        Helper.shared.logout()
        
    }

    fileprivate func setDefaultNavigation() -> Void
    {
        let searchBtn = UIButton(type: .custom)
        let image = UIImage(named: "search")
        searchBtn.setImage(image, for: .normal)
        searchBtn.tintColor = UIColor.baseBlueColor()
        searchBtn.frame = CGRect(x: 0, y: 44, width: 34, height: 44)
        searchBtn.imageView?.contentMode = .scaleAspectFit
        searchBtn.addTarget(self, action: #selector(self.showSearchBar), for: .touchUpInside)
        
        let barBtn = UIBarButtonItem(customView: searchBtn)
        self.navigationItem.rightBarButtonItems = [barBtn]
        
        let logoutBtn = UIButton(type: .custom)
        logoutBtn.setTitle("Logout", for: .normal)
        logoutBtn.setTitleColor(UIColor.baseBlueColor(), for: .normal)
        logoutBtn.titleLabel?.font =  UIFont(name: "Helvetica-Bold", size: 17)
        logoutBtn.tintColor = UIColor.baseBlueColor()
        logoutBtn.frame = CGRect(x: 0, y: 44, width: 34, height: 44)
        logoutBtn.imageView?.contentMode = .scaleAspectFit
        logoutBtn.addTarget(self, action: #selector(self.backBtnAction), for: .touchUpInside)
        
        let barLogoutBtn = UIBarButtonItem(customView: logoutBtn)
        self.navigationItem.leftBarButtonItems = [barLogoutBtn]
        
        Helper.shared.setNavigationTitle(viewController: self, title: CommonString.selectCustomerTitle)
        
    }
    
    @objc fileprivate func showSearchBar() -> Void
    {
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.leftBarButtonItems = nil
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        let cancelSearchBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(searchBarCancelButtonClicked(_:)))
        if self.isSearchingCustomer == false
        {
            self.navigationItem.setRightBarButton(cancelSearchBarButtonItem, animated: true)
        }
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        isSearchingCustomer = true
        self.navigationItem.titleView = searchBar
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
            if (response as? Dictionary<String,Any>) != nil{
                self.getRepCustomerDic = (response as? Dictionary<String,Any>)!
                if (response is Dictionary<String,Any>) && (response as! Dictionary<String,Any>).keyExists(key: "Customers"), let customerListArray = (response as! Dictionary<String,Any>)["Customers"] as? Array<Dictionary<String,Any>>
                {
                    self.customerList += customerListArray
                    self.allcustomers += customerListArray
                }
                DispatchQueue.main.async(execute:
                    {
                        self.tblVwCustomerList.reloadData()
                        if self.customerList.count==0{
                            self.showNoItemsLabel()
                            
                        }
                        else{
                            self.hideNoItemsLabel()
                        }
                })
                if (response as! Dictionary<String,Any>).keyExists(key: "TotalResults"), let totalResults = (response as! Dictionary<String,Any>)["TotalResults"] as? NSNumber
                {
                    self.totalResults = totalResults as? Int
                    if searchText == ""{
                        self.allResults = totalResults as? Int
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
                    let label = Helper.shared.createLabelWithMessage(message: "No result found.")
                    label.tag = 57
                    label.center = self.tblVwCustomerList.center
                    self.view.addSubview(label)
                }
        }
    }
    
    func hideNoItemsLabel()
    {
        DispatchQueue.main.async {
            if let noRecordsLabel = self.view.viewWithTag(57) as? UILabel
            {
                noRecordsLabel.removeFromSuperview()
            }
            
        }
    }
    
    //MARK: - - Move to Account Screen {}
    @objc func moveToAccountScreen(_ sender:UIButton){
        
        self.movetoHomeScreen(index: sender.tag, toAccont: true)
    }
    
    func movetoHomeScreen(index:Int,toAccont:Bool){
        
        DispatchQueue.main.async {
            if let testVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "menuHierarchyHandlerStoryID") as? MenuHierarchyHandler
            {
                let customerDic = self.customerList[index] as Dictionary<String,Any>
                if customerDic.keyExists(key: "CustomerID"), let customId = customerDic["CustomerID"] as? NSNumber{
                    UserInfo.shared.customerID = String(describing: customId)
                }
                
                let dict = customerDic["DefaultOrderInfo"] as? NSDictionary
                
                let daysArray = dict?.value(forKeyPath: "Result.permittedDays") as? NSArray
                //Helper.shared.nextOrderDates =
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
                
                SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: ["userID" : UserInfo.shared.userId!,"CustomerID" :UserInfo.shared.customerID!,"IsRepUser" : UserInfo.shared.isSalesRepUser!], strURL: SyncEngine.baseURL + SyncEngine.getCustomerFeatures, completion: { (response : Any) in
                    Helper.shared.processCustomerfeatureRequest(withResponse: response)
                    DispatchQueue.main.async {
                        
                        if toAccont{
                            UserDefaults.standard.set(false, forKey: "isComeFirstTime")
                            testVC.index = 1
                            self.navigationController?.isNavigationBarHidden = true
                            self.navigationController?.pushViewController(testVC, animated: true)
                        }else{
                            UserDefaults.standard.set(true, forKey: "isComeFirstTime")
                            self.navigationController?.isNavigationBarHidden = true
                            self.navigationController?.pushViewController(testVC, animated: false)
                        }
                    }
                })
            }
        }
    }
}

//MARK: - - tableView Delegates and datasources
extension CustomerListIphoneViewController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerIphoneTableViewCell") as? CustomerIphoneTableViewCell
        let customerDetail  = customerList[indexPath.row]
        cell?.lblCustmerName.text = customerDetail["CustomerName"] as? String
        cell?.btnAccount.tag = indexPath.row
        cell?.btnAccount.addTarget(self, action: #selector(self.moveToAccountScreen), for: .touchUpInside)
//        if AppFeatures.shared.isShowAccount{
//            cell?.btnAccount.isHidden = false
//        }else{
            cell?.btnAccount.isHidden = true
//        }
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.movetoHomeScreen(index: indexPath.row, toAccont: false)
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate
        {
            if scrollView == self.tblVwCustomerList {
                self.handlePaginationIfRequired(scrollView:  scrollView)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        if scrollView == self.tblVwCustomerList{
            self.handlePaginationIfRequired(scrollView:  scrollView)
        }
    }
    
    func handlePaginationIfRequired(scrollView: UIScrollView)
    {
        if scrollView.contentSize.height < (scrollView.contentOffset.y + scrollView.frame.size.height + 5.0), totalResults != nil,  self.totalResults! > self.customerList.count
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


extension CustomerListIphoneViewController:UISearchBarDelegate{
    
   
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let uiButton = searchBar.value(forKey: "cancelButton") as? UIButton
        uiButton?.setTitleColor(UIColor.baseBlueColor(), for: .normal)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        self.navigationItem.titleView = nil
        self.navigationItem.leftBarButtonItems = nil
        self.setDefaultNavigation()
        isSearchingCustomer = false
        self.hideNoItemsLabel()
        self.view.endEditing(true)
        self.totalResults = self.allResults
        self.customerList = self.allcustomers
        self.tblVwCustomerList.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == ""
        {
            hideNoItemsLabel()
            self.customerList.removeAll()
            self.tblVwCustomerList.reloadData()
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
    
}
