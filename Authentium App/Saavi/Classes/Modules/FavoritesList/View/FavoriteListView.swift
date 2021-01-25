//
//  FavoriteListView.swift
//  Saavi
//
//  Created by Sukhpreet on 01/09/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class FavoriteListView: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    var arrFavoriteLists = Array<Dictionary<String,Any>>()
    var menuController : MenuHierarchyHandler?
    @IBOutlet weak var tableViewFavoriteListing : UITableView!
    @IBOutlet weak var btnAddNewFavList: CustomButton!
    @IBOutlet weak var lblNoFavList: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnSearch: CustomButton!
    @IBOutlet weak var btnScan: CustomButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableViewFavoriteListing.tableFooterView = UIView()

        if self.navigationController?.tabBarController is SaaviTabBarController
        {
            let tabBar = self.navigationController?.tabBarController as! SaaviTabBarController
            self.menuController = tabBar.menuController
        }
        Helper.shared.setNavigationTitle( viewController : self, title : "Favourite List")
        
        NotificationCenter.default.addObserver(self, selector: #selector(FavoriteListView.setDefaultNavigation), name: NSNotification.Name(rawValue: "cartCountChanged"), object: nil)
        self.customizeTopButton()
    }
    
    func customizeTopButton(){
        if AppFeatures.shared.isShowBarcode
        {
            self.btnScan.isHidden = false
        }
        self.btnSearch.backgroundColor = UIColor.primaryColor()
        self.btnScan.backgroundColor = UIColor.primaryColor2()
        self.btnScan.imageView?.tintColor = .white
        self.btnSearch.imageView?.tintColor = .white
        self.btnScan.setTitleColor(.white, for: .normal)
        self.btnSearch.setTitleColor(.white, for: .normal)
    }
    
    @IBAction func btnScanAction(_ sender: CustomButton) {
        
        let controller = self.storyboard!.instantiateViewController(withIdentifier: BarCodeScanView.storyBoardIdentifier)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnSearchAction(_ sender: CustomButton) {
        
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "SearchViewController")
        self.navigationController?.pushViewController(controller, animated: true)
    }

    @objc func setDefaultNavigation() -> Void
    {
        self.navigationItem.rightBarButtonItems = nil
        Helper.shared.createCartIcon(onController: self)
        Helper.shared.createLatestSpecialsBarButtonItem(onController: self)
        //Helper.shared.createSearchIcon(onController: self)
        Helper.shared.setNavigationTitleWithNilBackButton(withTitle: "", withLeftButton: .backButton, onController: self)

    }

    @objc func showCartScreen() -> Void
    {
        if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cartVCStoryboardID") as? CartView
        {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if AppFeatures.shared.isFavoriteList{
            self.getAllFavoriteLists()
            setDefaultNavigation()
        }else{
            self.showFavoriteList(pantryListID: 0 , favoriteListName:"Favourite List")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if AppFeatures.shared.isUserAllowedToAddPantryList == false
        {
            btnAddNewFavList.isHidden = true
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showFavoriteList(pantryListID:NSNumber, favoriteListName:String){
        let animate = pantryListID == 0 ? false:true
        if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderVCStoryboardId") as? OrderVC
        {
            destinationViewController.pantryListID = pantryListID
            destinationViewController.isShowingDefaultPantryList = false
            destinationViewController.isShowingFavoriteListing = true
            destinationViewController.screenTitle = favoriteListName
            self.navigationController?.pushViewController(destinationViewController, animated: animate)
        }
    }
    // MARK:- Table view data source and delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrFavoriteLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCellIdentifier", for: indexPath) as! CategorySelectionCollectionCell
        
        if self.arrFavoriteLists.count > 0
        {
            let responseDict = self.arrFavoriteLists[indexPath.row]
            
            if responseDict.keyExists(key: "PantryListName")
            {
                let categoryName = responseDict["PantryListName"]
                cell.textLabel?.text = categoryName as? String
                cell.textLabel?.textColor = UIColor.black
                cell.textLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if (self.arrFavoriteLists[indexPath.row]["PantryListID"] as? NSNumber) != nil
        {
            let pantryListID = (self.arrFavoriteLists[indexPath.row]["PantryListID"] as? NSNumber)!
            let productName = self.arrFavoriteLists[indexPath.row]["PantryListName"] as? String ?? ""
            self.showFavoriteList(pantryListID: pantryListID, favoriteListName:productName)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0 * Configration.scalingFactor()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let PantryListName = self.arrFavoriteLists[indexPath.row]["PantryListName"] as? String
            {
                
                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: "Are you sure you want to delete \(PantryListName) from favourites?", withCancelButtonTitle: "No", completion:{
                    
                    if self.arrFavoriteLists.count > 0
                    {
                        let responseDict = self.arrFavoriteLists[indexPath.row]
                        if responseDict.keyExists(key: "PantryListID")
                        {
                            let PantryListId = responseDict["PantryListID"]
                            self.deleteItemFromFavFavoriteList(indexPath: indexPath, id: PantryListId!)
                           // self.getAllFavoriteLists()
                        }
                    }
//                    else
//                    {
//                          self.showNoItemsLabel()
//                    }
                    
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        
    }
    
    
    // MARK: - Service Communication
    //p
    func deleteItemFromFavFavoriteList(indexPath:IndexPath,id:Any){
        let requestDic = [
            "PantryListID": id
            ] as Dictionary<String,Any>
        print(requestDic)
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestDic, strURL: SyncEngine.baseURL + SyncEngine.deleteItemFromFavoriteList) { (response: Any) in
            print(response)
            self.arrFavoriteLists.remove(at: indexPath.row)
            if self.arrFavoriteLists.count == 0{
                self.showNoItemsLabel()
            }
            DispatchQueue.main.async {
                self.tableViewFavoriteListing.deleteRows(at: [indexPath], with: .automatic)
                self.tableViewFavoriteListing.reloadData()
            }
        }
    }
    
    // MARK: - Service Communication
    func getAllFavoriteLists(){
        
       let serviceURL = SyncEngine.baseURL + SyncEngine.getCustomerPantryList
        self.arrFavoriteLists.removeAll()
        let requestToGetOrderDetails = [
            "CustomerID": UserInfo.shared.customerID!,
            ] as Dictionary<String,Any>
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestToGetOrderDetails, strURL: serviceURL) { (response : Any) in
            if response is Array<Dictionary<String,Any>>
            {
                self.arrFavoriteLists =  response as! Array<Dictionary<String,Any>>
                self.hideNoItemsLabel()
                if self.arrFavoriteLists.count == 0{
                    self.showNoItemsLabel()
                }
            }
         
            DispatchQueue.main.async(execute: {
                self.tableViewFavoriteListing.reloadData()
            })

        }
    }
    
    func showNoItemsLabel(){
        
        DispatchQueue.main.async{
            if self.view.viewWithTag(57) == nil{
                let label = Helper.shared.createLabelWithMessage(message: "No favourite list available.")
                label.tag = 57
                label.center = self.tableViewFavoriteListing.center
                self.tableViewFavoriteListing.addSubview(label)
            }
        }
    }
    
    func hideNoItemsLabel()
    {
        DispatchQueue.main.async {
            if let noRecordsLabel = self.tableViewFavoriteListing.viewWithTag(57) as? UILabel
            {
                noRecordsLabel.removeFromSuperview()
            }
            
        }
    }
    
    @IBAction func addNewFavouriteListAction(_ sender: UIButton) {
        if UserInfo.shared.customerOnHoldStatus==true && !AppFeatures.shared.isAllowOnHoldPlacingOrder {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                return
            })
        }
        else{
         if let favorietController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addFavoriteListPopupSroryID") as? AddFavoriteListView
         {
            favorietController.parentController = self
            favorietController.isCreatedByRepUser = false
         UIApplication.shared.keyWindow?.rootViewController?.present(favorietController, animated: false, completion: nil)
         }
        }
    }
    
    @objc func backBtnAction()
    {
        self.navigationController?.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Button Actions
    @IBAction func toggleProfileAction(_ sender: Any) {
        menuController?.showMeSideMenu()
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

extension FavoriteListView:UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.showSearchBar()
    }
}

