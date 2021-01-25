//
//  CategorySelectionVC.swift
//  Saavi
//
//  Created by Amandeep Kaur on 13/07/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class CategorySelectionVC: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    static let storyboardIdentifier = "categorySelectionVCStoryID"
    var arrCategories = Array<Dictionary<String,Any>>()
    var menuController : MenuHierarchyHandler?
    var isAddingToDefaultPantry : Bool = false
    var arrSubCategories : Array<Dictionary<String,Any>>?
    var subCatName : String?
    var parentCategoryId : NSNumber?
    
    @IBOutlet weak var lblNoList: UILabel!
    @IBOutlet weak var btnSearch: CustomButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnScan: CustomButton!
    
    // MARK:- View Lifecycle Handling
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // for removing extra seperator lines
        
        self.navigationItem.hidesBackButton = true

        self.tableView.tableFooterView = UIView()
        
        if self.navigationController?.tabBarController is SaaviTabBarController
        {
            let tabBar = self.navigationController?.tabBarController as! SaaviTabBarController
            self.menuController = tabBar.menuController
        }
        NotificationCenter.default.addObserver(self, selector: #selector(CategorySelectionVC.setDefaultNavigation), name: NSNotification.Name(rawValue: "cartCountChanged"), object: nil)
//        self.searchBar.tintColor = UIColor.baseBlueColor()
//        self.searchBar.barTintColor = UIColor.lightGreyColor()
//        let textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as? UITextField
//        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
//        textFieldInsideSearchBarLabel?.textColor = UIColor.darkGray
//        textFieldInsideSearchBarLabel?.font = UIFont.italicSystemFont(ofSize: 15.0)
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
    }
    
    
    @objc func showCartScreen() -> Void
    {
        if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cartVCStoryboardID") as? CartView
        {
            self.navigationController?.pushViewController(vc, animated: true)
        }
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
            destinationViewController.isAddingItemToDefaultPantry = self.isAddingToDefaultPantry
            self.navigationController?.pushViewController(destinationViewController, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool){
        
        super.viewWillAppear(animated)
       // self.searchBar.resignFirstResponder()
        if self.arrSubCategories == nil, arrCategories.count == 0{
            callProductCategoriesWebService()
        }
        self.tableView.reloadData()
        if self.isAddingToDefaultPantry == true{
            Helper.shared.setNavigationTitle( viewController : self, title : subCatName ?? "")
            Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
        }else{
            if self.arrSubCategories == nil{
                Helper.shared.setNavigationTitle( viewController : self, title : "Categories")
//                self.navigationItem.leftBarButtonItems = nil
                Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)

            }else{
                Helper.shared.setNavigationTitle( viewController : self, title : subCatName ?? "")
                Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
            }
        }
        setDefaultNavigation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isAddingToDefaultPantry == true{
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Table view data source and delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if arrSubCategories != nil
        {
            return arrSubCategories!.count
        }
        else
        {
            return arrCategories.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCellIdentifier", for: indexPath) as! CategorySelectionCollectionCell
        
        if arrSubCategories != nil //!AppFeatures.shared.isShowCategory
        {
            let responseDict = self.arrSubCategories![indexPath.row]
            if responseDict.keyExists(key: "CategoryName")
            {
                let categoryName = responseDict["CategoryName"]
                cell.textLabel?.text = categoryName as? String
                cell.textLabel?.textColor = UIColor.black
                cell.textLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
            }
        }
        else
        {
            let responseDict = self.arrCategories[indexPath.row]
            let key = AppFeatures.shared.isShowCategory ? "MCategoryName":"CategoryName"
            if responseDict.keyExists(key: key)
            {
                let categoryName = responseDict[key]
                cell.textLabel?.text = categoryName as? String
                cell.textLabel?.textColor = UIColor.black
                cell.textLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if AppFeatures.shared.isShowCategory == false{
            
            if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderVCStoryboardId") as? OrderVC
            {
                destinationViewController.categoryId = parentCategoryId
                destinationViewController.subCategoryId = self.arrCategories[indexPath.row]["CategoryID"] as? NSNumber
                if let categoryName = self.arrCategories[indexPath.row]["CategoryName"] as? String
                {
                    destinationViewController.screenTitle = categoryName
                }
                destinationViewController.isShowingDefaultPantryList = false
                destinationViewController.isShowingFavoriteListing = false
                destinationViewController.isAddingItemToDefaultPantry = self.isAddingToDefaultPantry
                self.navigationController?.pushViewController(destinationViewController, animated: true)
            }
        }else if AppFeatures.shared.IsShowSubCategory == true{
            
            if self.arrSubCategories == nil, let subCategories = arrCategories[indexPath.row]["SubCategories"] as? Array<Dictionary<String,Any>>, subCategories.count > 0
            {
                if let subCategoriesController = self.storyboard?.instantiateViewController(withIdentifier: CategorySelectionVC.storyboardIdentifier) as? CategorySelectionVC
                {
                    subCategoriesController.arrSubCategories = subCategories
                    subCategoriesController.isAddingToDefaultPantry = self.isAddingToDefaultPantry
                    subCategoriesController.subCatName = arrCategories[indexPath.row]["MCategoryName"] as? String
                    subCategoriesController.parentCategoryId = self.arrCategories[indexPath.row]["MCategoryId"] as? NSNumber
                    self.navigationController?.pushViewController(subCategoriesController, animated: true)
                }
            }
            else
            {
                if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderVCStoryboardId") as? OrderVC
                {
                    if self.arrSubCategories == nil && (self.arrCategories[indexPath.row]["MCategoryId"] as? NSNumber) != nil
                    {
                        destinationViewController.categoryId = self.arrCategories[indexPath.row]["MCategoryId"] as? NSNumber
                        if let categoryName = self.arrCategories[indexPath.row]["MCategoryName"] as? String
                        {
                            destinationViewController.screenTitle = categoryName
                        }
                    }
                    else
                    {
                        destinationViewController.categoryId = parentCategoryId
                        destinationViewController.subCategoryId = self.arrSubCategories![indexPath.row]["CategoryID"] as? NSNumber
                        if let categoryName = self.arrSubCategories![indexPath.row]["CategoryName"] as? String
                        {
                            destinationViewController.screenTitle = categoryName
                        }
                    }
                    destinationViewController.isShowingDefaultPantryList = false
                    destinationViewController.isShowingFavoriteListing = false
                    destinationViewController.isAddingItemToDefaultPantry = self.isAddingToDefaultPantry
                    self.navigationController?.pushViewController(destinationViewController, animated: true)
                }
            }
        }
        else
        {
            if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderVCStoryboardId") as? OrderVC
            {
                if self.arrSubCategories == nil && (self.arrCategories[indexPath.row]["MCategoryId"] as? NSNumber) != nil
                {
                    destinationViewController.categoryId = self.arrCategories[indexPath.row]["MCategoryId"] as? NSNumber
                    if let categoryName = self.arrCategories[indexPath.row]["MCategoryName"] as? String
                    {
                        destinationViewController.screenTitle = categoryName
                    }
                }
                else
                {
                    destinationViewController.categoryId = parentCategoryId
                    destinationViewController.subCategoryId = self.arrSubCategories![indexPath.row]["CategoryID"] as? NSNumber
                    if let categoryName = self.arrSubCategories![indexPath.row]["CategoryName"] as? String
                    {
                        destinationViewController.screenTitle = categoryName
                    }
                }
                destinationViewController.isShowingDefaultPantryList = false
                destinationViewController.isShowingFavoriteListing = false
                destinationViewController.isAddingItemToDefaultPantry = self.isAddingToDefaultPantry
                self.navigationController?.pushViewController(destinationViewController, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0 * Configration.scalingFactor()
    }
    
    // MARK: - Service Communication
    func callProductCategoriesWebService()
    {
        let requestParameters = NSMutableDictionary()
        requestParameters.setValue(false, forKey: "showSubOnly")
        requestParameters.setValue(UserInfo.shared.customerID!, forKey: "listCustomerId")
        
        let serviceURL = SyncEngine.baseURL + SyncEngine.ProductCategories
        self.arrCategories.removeAll()
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestParameters as! Dictionary<String, Any>, strURL: serviceURL) { (response : Any) in
            if response is Array<Dictionary<String,Any>>
            {
                self.arrCategories =  response as! Array<Dictionary<String,Any>>
            }
            if self.arrCategories.count == 0
            {
                self.lblNoList.isHidden = false
                self.lblNoList.text = "No category found."
            }
            else
            {
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
            
        }
    }
    
    @objc func backBtnAction()
    {

        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Button Actions
    @IBAction func toggleProfileAction(_ sender: Any) {
        menuController?.showMeSideMenu()
    }
}

class CategorySelectionCollectionCell: UITableViewCell {
    
}

extension CategorySelectionVC:UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.showSearchBar()
    }
}
