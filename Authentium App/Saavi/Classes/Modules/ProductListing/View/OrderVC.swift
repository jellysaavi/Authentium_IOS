 //
 //  OrderVC.swift
 //  Saavi
 //
 //  Created by Sukhpreet on 29/06/17.
 //  Copyright © 2017 Saavi. All rights reserved.
 //
 
 import UIKit
 import Lightbox
 
 class OrderVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var collectionView: UICollectionView!
    var productList = Array<Dictionary<String,Any>>()
    var thumbImage = #imageLiteral(resourceName: "ImagePlaceholder")
    @IBOutlet weak var filtersScrollView: UIScrollView!
    var categoryId : NSNumber?
    var subCategoryId : NSNumber?
    var isShowingDefaultPantryList : Bool = true
    var isShowingFavoriteListing : Bool = false
    var filterID : NSNumber = 0
    var arrFilters = Array<Dictionary<String,Any>>()
    var totalResults : NSNumber?
    @IBOutlet weak var btnSearch: CustomButton!
    @IBOutlet weak var btnScan: CustomButton!
    // var allPantryItems = Array<Dictionary<String,Any>>()
    var menuController : MenuHierarchyHandler?
    var pantryListID : NSNumber = 0
    var screenTitle : String = ""
    @IBOutlet weak var pantryFiltersHeight: NSLayoutConstraint!
    var isShowingSaveBtn : Bool = false
    @IBOutlet weak var bottomLayoutContraint: NSLayoutConstraint!
    var pageNumber : Int = 1
    var defaultPantryPageNumber : Int = 1
    var savedOrderId : NSNumber?
    var RecurringCartId : NSNumber?
    var isAddingItemToDefaultPantry : Bool = false
    var isSearchingProduct : Bool = false
    var isComingFromRecurringCart : Bool = false
    var shouldRefereshProducts = true
    @IBOutlet weak var searchBar: UISearchBar!
    //var searchBar = UISearchBar()
    var txtFldActive = UITextField()
    @IBOutlet weak var btnAddItemsToDefaultPantry: CustomButton!
    
    //MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.isComingFromRecurringCart == true)
        {
            self.navigationItem.rightBarButtonItems = nil
            self.navigationItem.leftBarButtonItems = nil
            Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
            self.btnAddItemsToDefaultPantry.isHidden = true
            Helper.shared.setNavigationTitle( viewController : self, title : "Add Recurring Item")

        }
        else
        {
            if AppFeatures.shared.isUserAllowedToAddItemsToDefaultPantry, isShowingDefaultPantryList
            {
                bottomLayoutContraint.constant = 50.0
                self.btnAddItemsToDefaultPantry.isHidden = false
            }
            else
            {
                bottomLayoutContraint.constant = 50.0
                self.btnAddItemsToDefaultPantry.isHidden = false
            }
        }

        
        if UserDefaults.standard.value(forKey: "isComeFirstTime") as? Bool == true {
            self.moveOnCategorySelectionScreen(onClickButton: false)
        }
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotificationPlaceOrder(notification:)), name: Notification.Name("UpdateCart"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotificationPlaceOrder(notification:)), name: Notification.Name("addToCart"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotificationPlaceOrder(notification:)), name: Notification.Name("UpdateSpecialPrice"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotificationPlaceOrder(notification:)), name: Notification.Name("placeOrder"), object: nil)
        self.navigationItem.hidesBackButton = true
        self.setDefaultNavigation()
        if isShowingDefaultPantryList == true
        {
            if self.navigationController?.tabBarController is SaaviTabBarController
            {
                let tabBar = self.navigationController?.tabBarController as! SaaviTabBarController
                self.menuController = tabBar.menuController
            }
        }
        
        if AppFeatures.shared.isShowProductClasses == false
        {
            pantryFiltersHeight.constant = 0.0
        }
        else
        {
            if isSearchingProduct == true
            {
                pantryFiltersHeight.constant = 0.0
            }
            else if (isShowingFavoriteListing || isShowingDefaultPantryList)
            {
                pantryFiltersHeight.constant = self.view.frame.size.height * (50.0/667.0)
            }
            else
            {
                pantryFiltersHeight.constant = 0.0
            }
        }
        
        if (self.isShowingDefaultPantryList || self.isShowingFavoriteListing), isSearchingProduct == false
        {
            if AppFeatures.shared.canSortPantry == true
            {
                let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
                self.collectionView.addGestureRecognizer(longPressGesture)
            }
        }
        
        self.callAllFiltersAPI()
        self.searchBar.tintColor = UIColor.baseBlueColor()
        self.searchBar.barTintColor = UIColor.lightGreyColor()
        let textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as? UITextField
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = UIColor.darkGray
        textFieldInsideSearchBarLabel?.font = UIFont.italicSystemFont(ofSize: 15.0)
        self.collectionView.register(UINib.init(nibName: "OrderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "OrderCollectionViewCell")
        
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
        
        if (self.isComingFromRecurringCart == true)
        {
            self.tabBarController?.tabBar.isHidden = true
            self.btnScan.isHidden = true
            self.btnSearch.isHidden = true
        }
        
        
    }
    
    @objc func methodOfReceivedNotification(notification: Notification){
        
        if productList.count>0{
            for i in 0..<productList.count{
                var dict = productList[i]
                if dict["ProductID"] as? NSNumber == notification.userInfo!["ProductID"] as? NSNumber{
                    if notification.name.rawValue == "UpdateCart"{
                        dict["Quantity"] = "0.0"
                        dict["IsInCart"] = false
                    }else if notification.name.rawValue == "addToCart"{
                        dict["Quantity"] = notification.userInfo!["Quantity"]!
                        dict["IsInCart"] = true
                        dict["UOMID"] = notification.userInfo!["UOMID"] as? NSNumber
                    }
                    productList[i] = dict
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    @objc func methodOfReceivedNotificationPlaceOrder(notification: Notification){
        if notification.name.rawValue == "placeOrder" || notification.name.rawValue == "UpdateSpecialPrice" || notification.name.rawValue == "addToCart"{
            
            DispatchQueue.main.async {
                if self.isShowingDefaultPantryList || self.isShowingFavoriteListing{
                    self.defaultPantryPageNumber = 1
                    self.getAllDefaultPantryItems(searchText: self.searchBar.text ?? "")
                }
            }
        }else if notification.name.rawValue == "UpdateCart"{
            let dict = notification.userInfo
            let productId = dict!["ProductID"] as? Int
            let index = self.productList.index(where: {($0["ProductID"] as! Int) == productId})
            if index != nil {
                self.productList[index!]["IsInCart"] = false
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func setDefaultNavigation() -> Void
    {
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.leftBarButtonItems = nil
        self.navigationItem.hidesBackButton = true
        // add check for latest specials manage feature here.
        Helper.shared.createCartIcon(onController: self)
        Helper.shared.createLatestSpecialsBarButtonItem(onController: self)
        Helper.shared.createHelpButtonItem(onController: self)
        // Helper.shared.createSearchIcon(onController: self)
        
        if (isShowingFavoriteListing || isShowingDefaultPantryList) && AppFeatures.shared.copyPantryEnabled == true
        {
            Helper.shared.createCopyPantryItem(onController: self)
        }
        
        if savedOrderId != nil && AppFeatures.shared.saveOrderPermitted && isShowingDefaultPantryList
        {
            
            let saveBtn = UIButton(type: .custom)
            //saveBtn.setImage(#imageLiteral(resourceName: "ic_saved_orders"), for: .normal)
            let image = UIImage(named: "ic_saved_orders")?.withRenderingMode(.alwaysTemplate)
            saveBtn.setImage(image, for: .normal)
            saveBtn.tintColor = AppConfig.redColor()
            saveBtn.frame = CGRect(x: 0, y: 0, width: 34, height: 44)
            saveBtn.imageView?.contentMode = .scaleAspectFit
            saveBtn.addTarget(self, action: #selector(self.showSavedOrderAlert(_:)), for: .touchUpInside)
            saveBtn.tag = Int(truncating: savedOrderId!)
            let barBtn = UIBarButtonItem(customView: saveBtn)
            self.navigationItem.rightBarButtonItems?.append(barBtn)
            
        }
        if isShowingDefaultPantryList == false
        {
            Helper.shared.setNavigationTitle( viewController : self, title : self.screenTitle)
            if AppFeatures.shared.isFavoriteList{
                Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
            }
        }
        else
        {
            Helper.shared.setNavigationTitle( viewController : self, title : "Order")
            if AppFeatures.shared.isParent && UserInfo.shared.isParent && !UserInfo.shared.isSalesRepUser!
            {
                if AppFeatures.shared.isShowAccount{
                    Helper.shared.setNavigationTitle(withTitle: ["",""], withLeftButtons: [.backButton,.profileButton], onController: self)
                }else {
                    
                    Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
                }
                
            }else if UIDevice.current.userInterfaceIdiom == .phone && UserInfo.shared.isSalesRepUser!{
                
                if AppFeatures.shared.isShowAccount{
                    Helper.shared.setNavigationTitle(withTitle: ["",""], withLeftButtons: [.backButton,.profileButton], onController: self)
                }else{
                    
                    Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
                }
                
            }else{
                
                if AppFeatures.shared.isNonFoodVersion == false
                {
                    Helper.shared.setNavigationTitle( viewController : self, title : "Order")
                }
                else
                {
                    Helper.shared.setNavigationTitle( viewController : self, title : "Favourites")
                }
                if AppFeatures.shared.isShowAccount{
                    Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .profileButton, onController: self)
                }else{
                    let saveBtn = UIButton(type: .custom)
                    saveBtn.setTitle("Logout", for: .normal)
                    saveBtn.setTitleColor(UIColor.baseBlueColor(), for: .normal)
                    saveBtn.titleLabel?.font =  UIFont(name: "Helvetica-Bold", size: 17)

                    //saveBtn.tintColor = AppConfig.redColor()
                    saveBtn.frame = CGRect(x: 0, y: 0, width: 34, height: 44)
                    saveBtn.imageView?.contentMode = .scaleAspectFit
                    saveBtn.addTarget(self, action: #selector(self.logoutButtonAction(_:)), for: .touchUpInside)
                    let barBtn = UIBarButtonItem(customView: saveBtn)
                    self.navigationItem.leftBarButtonItem = barBtn
                }
            }
        }
        if isShowingDefaultPantryList == false && self.isSearchingProduct == true
        {
            Helper.shared.setNavigationTitle( viewController : self, title : "Search")
            Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
            self.searchBar.becomeFirstResponder()
        }
        
        
        if (self.isComingFromRecurringCart == true)
        {
            self.navigationItem.rightBarButtonItems = nil
            self.navigationItem.leftBarButtonItems = nil
            Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
            self.btnAddItemsToDefaultPantry.isHidden = true
            Helper.shared.setNavigationTitle( viewController : self, title : "Add Recurring Item")
        }

    }
    
    @objc func logoutButtonAction(_ sender:UIButton){
        if UserInfo.shared.isSalesRepUser == true
        {
            if UIDevice.current.userInterfaceIdiom == .phone{
                Helper.shared.logout()
            }else{
                AppFeatures.shared.isTargetMarketing = false
                AppFeatures.shared.showNoticeboardPdf = false
                self.navigationController?.navigationController?.popViewController(animated: true)
            }
        }
        else
        {
            Helper.shared.logout()
        }
    }
    
    override func viewWillLayoutSubviews() {
        //navigationController?.navigationBar.isTranslucent = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if self.isShowingDefaultPantryList{
            if self.productList.count == 0 && (self.navigationItem.titleView is UISearchBar) == false{
                defaultPantryPageNumber = 1
                self.getAllDefaultPantryItems(searchText: self.searchBar.text ?? "")
                
            }else if AppFeatures.shared.isProductAdded{
                
                AppFeatures.shared.isProductAdded = false
                self.productList.removeAll()
                defaultPantryPageNumber = 1
                self.getAllDefaultPantryItems(searchText: self.searchBar.text ?? "")
                
            }
        }
        else if isShowingFavoriteListing
        {
            if productList.count == 0
            {
                defaultPantryPageNumber = 1
                self.getAllDefaultPantryItems(searchText: self.searchBar.text ?? "")
                Helper.shared.setNavigationTitle( viewController : self, title : self.screenTitle)
                Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
            }
        }
        else
        {
            if isSearchingProduct == false, shouldRefereshProducts == true
            {
                callSearchProductWebService()
            }
        }
        self.collectionView.reloadData()
        filtersScrollView.layer.borderWidth = 0.5 * Configration.scalingFactor()
        filtersScrollView.layer.borderColor = UIColor.baseBlueColor().withAlphaComponent(0.4).cgColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(OrderVC.refreshCount), name: NSNotification.Name(rawValue: "cartCountChanged"), object: nil)
        self.callAPIToUpdateCartNumber()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func deleteFromFavorite(_ sender: UIButton) {
        
        let indexPath = IndexPath.init(row: sender.tag, section: 0)
        
        //        let tapLocation = gesture.location(in: self.collectionView).x
        //        let sortButtonPoint = self.collectionView.frame.size.width - self.collectionView.frame.size.width/4
        
        if self.isShowingFavoriteListing{
            
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: "Do you want to delete this product?", withCancelButtonTitle: "No", completion: {
                
                self.removeItemFromFavoriteList(indexPath: indexPath)
            })
        }
        
    }
    
    @IBAction func btnScanAction(_ sender: CustomButton) {
        
        let controller = self.storyboard!.instantiateViewController(withIdentifier: BarCodeScanView.storyBoardIdentifier)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnSearchAction(_ sender: CustomButton) {
        
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "SearchViewController")
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func btnFavoriteAction(_ sender:UIButton){
        
        if AppFeatures.shared.isUserAllowedToAddItemsToPantryList == true
        {
            //let cell = gestureRecognizer.view?.superview?.superview as! DryOrdersCollectionCell
            let point: CGPoint = sender.convert(.zero, to: collectionView)
            if let indexPath = collectionView!.indexPathForItem(at: point) {
                let cell = collectionView!.cellForItem(at: indexPath) as! OrderCollectionViewCell
                
                let obj = self.productList[(collectionView.indexPath(for: cell)?.row)!]
                if let proId = obj["ProductID"] as? NSNumber
                {
                    if UserInfo.shared.isGuest == true
                    {
                        SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.guestUser, withCancelButtonTitle: "OK", completion: {
                            Helper.shared.logoutAsGuest()
                            return
                        })
                    }
                    else if UserInfo.shared.isSalesRepUser == false && UserInfo.shared.customerOnHoldStatus == true && !AppFeatures.shared.isAllowOnHoldPlacingOrder
                    {
                        SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                            return
                        })
                    }
                    else{
                        if let isPantryItem =  obj["IsInPantry"] as? Bool, isPantryItem == true{
                            // Remove from favourite
                            self.deleteItemFromFavorite(index: (collectionView.indexPath(for: cell)?.row)!)
                        }else{
                            //Add to favourite
                            self.addProductToFavoriteList(productID: proId, index: (collectionView.indexPath(for: cell)?.row)!)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - CollectionView datasource and delegate methods -
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return productList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell : OrderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderCollectionViewCell", for: indexPath) as! OrderCollectionViewCell
        
        cell.showData(productList: self.productList, index: indexPath.item)
        
        if(self.isComingFromRecurringCart == true)
        {
            cell.txtQuantity.text = "0"
        }
        
        cell.btnZoomThumbnail.tag = indexPath.item
        cell.btnZoomThumbnail.addTarget(self, action: #selector(self.btnZoomImageAction(_:)), for: .touchUpInside)
        cell.btnAddToFavourite.tintColor = UIColor.baseBlueColor()
        cell.txtQuantity.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonClicked))
        
        if (self.isShowingDefaultPantryList || self.isShowingFavoriteListing) && AppFeatures.shared.canSortPantry{
            
            cell.imgVwMove.isHidden = false
            cell.cnstBtnMoveWidth.constant = 18.0
        }
        
        if let recoganizes = cell.lblDryOrder.gestureRecognizers{
            for gesture in recoganizes{
                cell.lblDryOrder.removeGestureRecognizer(gesture)
            }
        }
        
        if let recoganizes = cell.containerView.gestureRecognizers{
            for gesture in recoganizes{
                cell.containerView.removeGestureRecognizer(gesture)
            }
        }
        
        if let recoganizes = cell.productImage.gestureRecognizers{
            for gesture in recoganizes{
                cell.productImage.removeGestureRecognizer(gesture )
            }
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.swipeMoved))
        panGesture.delegate = self
        cell.containerView.addGestureRecognizer(panGesture)
        
        if AppFeatures.shared.shouldShowLongDetail{
            let tapRecog = UITapGestureRecognizer(target: self, action: #selector(self.objTappedForDetails(_:)))
            tapRecog.delegate = self
            cell.lblDryOrder.addGestureRecognizer(tapRecog)
            let tapRecog1 = UITapGestureRecognizer(target: self, action: #selector(self.objTappedForDetails(_:)))
            tapRecog1.delegate = self
            cell.productImage.addGestureRecognizer(tapRecog1)
        }
        
        if AppFeatures.shared.isDynamicUOM{
            cell.btnChangeUOM.isHidden = false
            cell.btnChangeUOM.tag = indexPath.item
            cell.btnChangeUOM.addTarget(self, action: #selector(self.uOMChanged(sender:)), for: .touchUpInside)
            if let obj = productList[indexPath.item]["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1{
                cell.arrowUOMDropdown.constant = 10.0
            }else{
                cell.arrowUOMDropdown.constant = 0.0
            }
        }else{
            cell.btnChangeUOM.removeTarget(self, action: nil, for: .allEvents)
            cell.btnChangeUOM.isHidden = true
        }
        
        cell.btnShowQuantityPopup.tag = indexPath.item
        cell.btnShowQuantityPopup.addTarget(self, action: #selector(showQuantityPopupAction(_:)), for: .touchUpInside)
        
        cell.txtQuantity.delegate = self
        cell.btnTrash.isHidden = !self.isShowingFavoriteListing
        cell.btnTrash.tag = indexPath.item
        cell.cnstTrashBtnWidth.constant = self.isShowingFavoriteListing ? 18.0:0.0
        cell.btnTrash.addTarget(self, action: #selector(self.deleteFromFavorite), for: .touchUpInside)
        cell.btnAddToFavourite.tag = indexPath.item
        cell.btnAddToFavourite.addTarget(self, action: #selector(self.btnFavoriteAction), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        let sizeHeight = (UIDevice.current.userInterfaceIdiom == .phone ? 140.0 :(115.0  * VerticalSpacingConstraints.spacingConstant))
        
        if AppFeatures.shared.shouldShowBrandNameInProductList && AppFeatures.shared.isShowSupplier
        {
            return CGSize(width: 0.95 * self.view.bounds.size.width, height: (sizeHeight) + 35)
        }
        else if AppFeatures.shared.shouldShowBrandNameInProductList && !AppFeatures.shared.isShowSupplier
        {
            return CGSize(width: 0.95 * self.view.bounds.size.width, height: (sizeHeight) + 23)
        }
        else if !AppFeatures.shared.shouldShowBrandNameInProductList && AppFeatures.shared.isShowSupplier
        {
            return CGSize(width: 0.95 * self.view.bounds.size.width, height: (sizeHeight) + 23)
        }
        else
        {
            return CGSize(width: 0.95 * self.view.bounds.size.width, height: (sizeHeight) + 10)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
    {
        if self.isShowingDefaultPantryList || self.isShowingFavoriteListing
        {
            if(productList.count > 0)
            {
                for i in 0..<productList.count{
                    let productDescDic = productList[i]
                    if(productDescDic.count > 0){
                        // print("\(productDescDic["ProductName"])!")
                    }
                }
            }
            return true
        }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        print("Source : \(sourceIndexPath.item), Destination : \(destinationIndexPath.item)")
        let objToMove = self.productList[sourceIndexPath.item]
        
        if sourceIndexPath.row < destinationIndexPath.row
        {
            for i in sourceIndexPath.item...destinationIndexPath.item
            {
                if i == destinationIndexPath.item
                {
                    self.productList[i] = objToMove
                }
                else
                {
                    self.productList[i] = self.productList[i+1]
                }
            }
        }
        else
        {
            var i = sourceIndexPath.item
            repeat
            {
                self.productList[i] = self.productList[i-1]
                i = i-1
            }
                while(i > destinationIndexPath.item)
            
            productList[destinationIndexPath.item] = objToMove
            
            /* for i in sourceIndexPath.item...destinationIndexPath.item
             {
             if i == destinationIndexPath.item
             {
             self.productList[i] = objToMove
             }
             else
             {
             self.productList[i-1] = self.productList[i]
             }
             }*/
        }
        
        
        
        
        /*     let objAtSource = self.productList[sourceIndexPath.row]
         let objAtDestination = self.productList[destinationIndexPath.row]
         
         self.productList[sourceIndexPath.row] = objAtDestination
         self.productList[destinationIndexPath.row] = objAtSource
         collectionView.reloadItems(at: [sourceIndexPath, destinationIndexPath])
         */
        var reqArr = Array<Any>()
        if(productList.count > 0)
        {
            for i in 0..<productList.count{
                let productDescDic = productList[i]
                if(productDescDic.count > 0){
                    reqArr.append(productDescDic["ProductID"]!)
                }
            }
        }
        
        
        
        var pantryID : NSNumber = 0
        if let id = Int(exactly: self.pantryListID), id > 0
        {
            pantryID = self.pantryListID
        }
        else if let id = objToMove["PantryListID"] as? NSNumber
        {
            pantryID = id
        }
        
        if isShowingDefaultPantryList
        {
            self.setPantryItemsSortOrder(reqArr: reqArr, pantryListId: pantryID)
        }
        else{
            self.setPantryItemsSortOrder(reqArr: reqArr, pantryListId: pantryID)
        }
    }
    
    @objc func refreshCount()
    {
        if !(self.navigationItem.titleView is UISearchBar)
        {
            self.setDefaultNavigation()
        }
    }
    
    //MARK: - - Zoom image
    @IBAction func btnZoomImageAction(_ sender: UIButton) {
        
        let cell = self.collectionView.cellForItem(at: IndexPath.init(row: sender.tag, section: 0)) as? OrderCollectionViewCell
        self.thumbImage = (cell?.imgVwProductSmall.image)!
        let images = [LightboxImage(image: self.thumbImage,text: "")]
        
        let controller = LightboxController(images: images)
        
        controller.pageDelegate = self
        controller.dismissalDelegate = self
        
        controller.dynamicBackground = true
        
        present(controller, animated: true, completion: nil)
        
    }
    
    //MARK: - Webservice Handling -
    func setPantryItemsSortOrder(reqArr:Array<Any>,pantryListId:NSNumber){
        
        let requestParameter = ["PantryListID": pantryListId,
                                "ProductID": reqArr] as [String : Any]
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestParameter, strURL: SyncEngine.baseURL + SyncEngine.setPantryItemsSortOrder) { (response: Any) in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        }
    }
    
    func callSearchProductWebService(with searchText : String = ""){
        
        let catId = self.isSearchingProduct ? 0:((self.categoryId) != nil) ? self.categoryId : 0 // if
        let subCatID = self.isSearchingProduct ? 0:((self.subCategoryId) != nil) ? self.subCategoryId :0//
        self.hideNoItemsLabel()
        let requestParameters = NSMutableDictionary()
        requestParameters.setValue(UserInfo.shared.customerID!, forKey: "CustomerID")
        requestParameters.setValue(UserInfo.shared.customerID!, forKey: "listCustomerId")
        requestParameters.setValue(catId, forKey: "MainCategoryID")
        requestParameters.setValue(subCatID, forKey: "SubCategoryID")
        requestParameters.setValue(self.filterID, forKey: "FilterID")
        requestParameters.setValue(searchText, forKey: "Searchtext")
        requestParameters.setValue(false, forKey: "IsSpecial")
        requestParameters.setValue(10, forKey: "PageSize")
        requestParameters.setValue(pageNumber-1, forKey: "PageIndex")
        requestParameters.setValue(UserInfo.shared.isSalesRepUser, forKey: "IsRepUser")
        
        let serviceURL = SyncEngine.baseURL + SyncEngine.SearchProductsList
        
        if pageNumber == 1
        {
            self.productList.removeAll()
            self.collectionView.reloadData()
        }
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestParameters as! Dictionary<String, Any>, strURL: serviceURL) { (response : Any) in
            if (response as? Dictionary<String,AnyObject>) != nil
            {
                if (response is Dictionary<String,Any>) && (response as! Dictionary<String,Any>).keyExists(key: "products"), let productListArray = (response as! Dictionary<String,Any>)["products"] as? Array<Dictionary<String,Any>>
                {
                    self.productList += productListArray
                    
                    if self.productList.count == 0
                    {
                        self.showNoItemsLabel()
                    }else{
                        self.hideNoItemsLabel()
                    }
                    
                    if (response as! Dictionary<String,Any>).keyExists(key: "TotalResults"), let totalResults = (response as! Dictionary<String,Any>)["TotalResults"] as? NSNumber
                    {
                        self.totalResults = totalResults
                        // self.showFilterCountBadge()
                    }
                }
                
                DispatchQueue.main.async(execute:
                    {
                        
                        self.collectionView.reloadData()
                        
                })
            }
            else
            {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.showNoItemsLabel()
                    self.totalResults = 0
                    //self.showFilterCountBadge()
                }
            }
        }
    }
    fileprivate func showFilterCountBadge(){
        
        DispatchQueue.main.async {
            
            if (self.filtersScrollView.viewWithTag(self.filterID as! Int) != nil)
            {
                for label in self.filtersScrollView.subviews
                {
                    if label is UILabel
                    {
                        label.removeFromSuperview()
                    }
                }
                
                for label in self.filtersScrollView.subviews
                {
                    if label is UIButton
                    {
                        if let btn = (label.viewWithTag(self.filterID as! Int)) as? UIButton
                        {
                            let centerPoint = CGPoint(x: btn.frame.maxX, y: btn.frame.minY)
                            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                            label.backgroundColor = UIColor.red
                            label.font = UIFont.SFUI_SemiBold(baseScaleSize: 12.0)
                            label.textColor = UIColor.white
                            label.text = "\(self.totalResults!)"
                            label.sizeToFit()
                            let expectedWidth = label.frame.size.width + 10.0
                            label.frame = CGRect(x: 0, y: 0, width: expectedWidth, height: expectedWidth)
                            label.layer.cornerRadius = expectedWidth/2.0
                            label.clipsToBounds = true
                            label.textAlignment = NSTextAlignment.center
                            self.filtersScrollView.addSubview(label)
                            self.filtersScrollView.clipsToBounds=true
                            label.center = centerPoint
                            label.bringSubview(toFront: self.filtersScrollView)
                        }
                    }
                }
            }
        }
    }
    func callAllFiltersAPI(){
        
        if self.arrFilters.count == 0 && AppFeatures.shared.isShowProductClasses && (self.isShowingFavoriteListing || self.isShowingDefaultPantryList)
        {
            DispatchQueue.global(qos: .background).async {
                
                self.getAllProductFilters()
            }
        }
    }
    
    
    func getAllProductFilters()
    {
        let serviceUrl = SyncEngine.baseURL + SyncEngine.GetAllFilters
        
        SyncEngine.sharedInstance.sendGetRequestToServer(strURL: serviceUrl) { (response : Any) in
            
            if response is Array<Dictionary<String,Any>> && (response as! Array<Dictionary<String,Any>>).count > 0
            {
                self.arrFilters = (response as! Array<Dictionary<String,Any>>)
                var x : CGFloat = 10.0
                DispatchQueue.main.async {
                    for i in 0...self.arrFilters.count-1
                    {
                        
                        let button = UIButton(type: .custom)
                        let name = (self.arrFilters[i]["FilterName"] as? String)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
                        button.setTitle(name.uppercased(), for: .normal)
                        button.setTitleColor(UIColor.lightGray, for: .normal)
                        button.titleLabel?.font = UIFont.Roboto_Regular(baseScaleSize: 18.0)
                        button.sizeToFit()
                        button.frame = CGRect(x: x, y: 15, width: button.frame.size.width * 1.5, height: self.filtersScrollView.frame.size.height-15)
                        button.addTarget(self, action: #selector(self.handleFilterSelection(_:)), for: .touchUpInside)
                        button.setTitleColor(UIColor.white, for: .selected)
                        button.tag = ((self.arrFilters[i]["FilterID"] as? NSNumber) as! Int)
                        self.filtersScrollView.addSubview(button)
                        x = x + button.frame.size.width + 5
                        self.filtersScrollView.contentSize = CGSize(width: x, height: self.filtersScrollView.frame.size.height)
                        
                        if button.tag == 0
                        {
                            button.isSelected = true
                            button.backgroundColor = UIColor.primaryColor()
                        }
                    }
                }
            }
        }
    }
    
    
    func getAllDefaultPantryItems(searchText:String) -> Void
    {
        var requestParameters = Dictionary<String,Any>()
        requestParameters["PageSize"] = 10
        requestParameters["PageIndex"] = defaultPantryPageNumber-1
        requestParameters["PantryListID"] = pantryListID
        requestParameters["FilterID"] = filterID
        requestParameters["ShowAll"] = false
        requestParameters["CustomerID"] = UserInfo.shared.customerID ?? "0"
        requestParameters["isRepUser"] = UserInfo.shared.isSalesRepUser
        requestParameters["Searchtext"] = searchText
        if self.isShowingFavoriteListing{
            requestParameters["PantryType"] = "F"
        }
        
        let serviceURL = SyncEngine.baseURL + SyncEngine.GetDefaultPantry
        
        if defaultPantryPageNumber == 1{
            
            self.productList.removeAll()
            self.collectionView.reloadData()
        }
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestParameters , strURL: serviceURL) { (response : Any) in
            if (response as? Dictionary<String,AnyObject>) != nil
            {
                if (response is Dictionary<String,Any>) && (response as! Dictionary<String,Any>).keyExists(key: "products"), let productListArray = (response as! Dictionary<String,Any>)["products"] as? Array<Dictionary<String,Any>>
                {
                    
                    self.hideNoItemsLabel()
                    self.productList += productListArray
                    
                    if (response as! Dictionary<String,Any>).keyExists(key: "TotalResults"), let totalResults = (response as! Dictionary<String,Any>)["TotalResults"] as? NSNumber
                    {
                        self.totalResults = totalResults
                        DispatchQueue.main.async {
                            
                            if (self.filtersScrollView.viewWithTag(self.filterID as! Int) != nil)
                            {
                                for label in self.filtersScrollView.subviews
                                {
                                    if label is UILabel
                                    {
                                        label.removeFromSuperview()
                                    }
                                }
                            }
                        }
                        
                        self.showFilterCountBadge()

                    }
                }
                DispatchQueue.main.async(execute:
                    {
                        if let savedOrderId = ((response as? Dictionary<String,Any>)?["SavedOrder"]) as? NSNumber, Int(truncating: savedOrderId) > 0
                        {
                            self.savedOrderId = savedOrderId
                            self.setDefaultNavigation()
                        }
                        self.collectionView.reloadData()
                        
                })
            }
                
            else
            {
                DispatchQueue.main.async(execute:
                    {
                        self.totalResults = 0
                        self.showNoItemsLabel()
                        for label in self.filtersScrollView.subviews
                        {
                            if label is UILabel
                            {
                                label.removeFromSuperview()
                            }
                        }
                        self.collectionView.reloadData()
                })
            }
            DispatchQueue.main.async {
                //                if let btn = (self.filtersScrollView.viewWithTag(self.filterID as! Int)) as? UIButton
                //                {
                //                    let centerPoint = CGPoint(x: btn.frame.maxX, y: btn.frame.minY)
                //                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                //                    label.font = UIFont.SFUI_SemiBold(baseScaleSize: 12.0)
                //                    label.backgroundColor = UIColor.red
                //                    label.textColor = UIColor.white
                //                    label.text = "\(self.totalResults!)"
                //                    label.sizeToFit()
                //                    let expectedWidth = label.frame.size.width + 10.0
                //                    label.frame = CGRect(x: 0, y: 0, width: expectedWidth, height: expectedWidth)
                //                    label.layer.cornerRadius = expectedWidth/2.0
                //                    label.clipsToBounds = true
                //                    label.textAlignment = NSTextAlignment.center
                //                    self.filtersScrollView.addSubview(label)
                //                    label.center = centerPoint
                //                    //  self.view.sendSubview(toBack: self.filtersScrollView)
                //                    self.filtersScrollView.bringSubview(toFront: label)
                //                }
            }
        }
    }
    
    func showNoItemsLabel()
    {
        DispatchQueue.main.async
            {
                if self.view.viewWithTag(57) == nil
                {
                    let label = Helper.shared.createLabelWithMessage(message: "No items found.")
                    label.tag = 57
                    label.center = self.view.center
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
    func addProductToRecurringCart(productDetail : Dictionary<String, Any>, actualIndex : Int = -1, quantityVal: Int = 0){
       
        let requestDic = [
            "RecurrProdID": 0,
            "RecurrID": RecurringCartId!,
            "ProductID": productDetail["ProductID"]!,
            "Quantity": quantityVal as NSNumber,
            ] as [String : Any]
        
        let serviceURL = SyncEngine.baseURL + SyncEngine.updateRecurringCartItem
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestDic, strURL: serviceURL) { (response : Any) in
            
            Helper.shared.showAlertOnController(message:"Added to recurring cart successfully", title: "",hideOkayButton: true
            )
            Helper.shared.dismissAddedToCartAlert()

        }
    }
    
    func checkMinAndMaxOrderQuantity(productValue : Dictionary<String, Any>, index : Int ,quantity:NSNumber){
        
        if (self.isComingFromRecurringCart == true)
        {
            self.addProductToRecurringCart(productDetail: self.productList[index], actualIndex: index, quantityVal: Int(truncating: quantity))
            return
        }

        
        if UserInfo.shared.isGuest == true
        {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.guestUser, withCancelButtonTitle: "OK", completion: {
                Helper.shared.logoutAsGuest()
                return
            })
        }
        else if UserInfo.shared.customerOnHoldStatus == true && !AppFeatures.shared.isAllowOnHoldPlacingOrder{
            
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                return
            })
        }else{
            var productDetail = productValue
            if productDetail["Quantity"]  as? NSNumber == nil{
                productDetail["Quantity"] = 1.0
            }
            
            let minQty = (productDetail["MinOQ"] as? Int ?? 0)
            let maxQty = (productDetail["MaxOQ"] as? Int ?? 0)
            let qtyPerUnit = Helper.shared.getPackSize(dic: productValue)
            
            if AppFeatures.shared.isMinOrderQuantity == true && AppFeatures.shared.isMaxOrderQuantity == true {
                if (Int(truncating: NSNumber(value: minQty))/qtyPerUnit) > Int(truncating: (productDetail["Quantity"] as? NSNumber)!) && NSNumber(value: minQty) != 0
                {
                    let msgString = "This item has a minimum order quantity of \( Int(truncating: NSNumber(value: minQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: minQty))) \("units to cart ?")"
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                        self.productList[index]["Quantity"] = minQty/qtyPerUnit
                        // self.collectionView.reloadData()
                        //   product["Quantity"] = NSNumber(value: Int(circularPopup.txtFldQuantity.text!)!)
                        //self.productList[index] = product
                        self.addProductToCartwithDatePicker(productDetail: self.productList[index], actualIndex: index)
                    })
                }
                else if (Int(truncating: NSNumber(value: maxQty))/qtyPerUnit) < Int(truncating: (productDetail["Quantity"] as? NSNumber)!) && NSNumber(value: maxQty) != 0
                {
                    let msgString = "This item has a maximum order quantity of \( Int(truncating: NSNumber(value: maxQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: maxQty))) \("units to cart ?")"
                    
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                        self.productList[index]["Quantity"] = maxQty/qtyPerUnit
                        // self.collectionView.reloadData()
                        self.addProductToCartwithDatePicker(productDetail: self.productList[index], actualIndex: index)
                    })
                }
                else{
                    self.productList[index]["Quantity"] = quantity
                    self.addProductToCartwithDatePicker(productDetail: productDetail, actualIndex: index)
                }
            }
            else if  AppFeatures.shared.isMinOrderQuantity == true {
                
                if (Int(truncating: NSNumber(value: minQty))/qtyPerUnit) > Int(truncating: (productDetail["Quantity"] as? NSNumber)!) && NSNumber(value: minQty) != 0
                {
                    let msgString = "This item has a minimum order quantity of \( Int(truncating: NSNumber(value: minQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: minQty))) \("units to cart ?")"
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                        self.productList[index]["Quantity"] = minQty/qtyPerUnit
                        //  self.collectionView.reloadData()
                        self.addProductToCartwithDatePicker(productDetail: self.productList[index], actualIndex: index)
                    })
                }
                else if  AppFeatures.shared.isMaxOrderQuantity == true {
                    if (Int(truncating: NSNumber(value: maxQty))/qtyPerUnit) < Int(truncating: (productDetail["Quantity"] as? NSNumber)!) && NSNumber(value: maxQty) != 0
                    {
                        let msgString = "This item has a maximum order quantity of \( Int(truncating: NSNumber(value: maxQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: maxQty))) \("units to cart ?")"
                        
                        SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                            self.productList[index]["Quantity"] = maxQty/qtyPerUnit
                            // self.collectionView.reloadData()
                            self.addProductToCartwithDatePicker(productDetail: self.productList[index], actualIndex: index)
                        })
                    }
                }
                else{
                    self.productList[index]["Quantity"] = quantity
                    self.addProductToCartwithDatePicker(productDetail: productDetail, actualIndex: index)
                }
                
            }
            else if  AppFeatures.shared.isMaxOrderQuantity == true {
                if (Int(truncating: NSNumber(value: maxQty))/qtyPerUnit) < Int(truncating: (productDetail["Quantity"] as? NSNumber)!) && NSNumber(value: maxQty) != 0
                {
                    let msgString = "This item has a maximum order quantity of \( Int(truncating: NSNumber(value: maxQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: maxQty))) \("units to cart ?")"
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                        self.productList[index]["Quantity"] = maxQty/qtyPerUnit
                        // self.collectionVw_itemDescription.reloadData()
                        self.addProductToCartwithDatePicker(productDetail:self.productList[index], actualIndex: index)
                    })
                }
                else{
                    self.productList[index]["Quantity"] = quantity
                    self.addProductToCartwithDatePicker(productDetail: productDetail, actualIndex: index)
                }
            }
            else{
                self.productList[index]["Quantity"] = quantity
                self.addProductToCartwithDatePicker(productDetail: productDetail, actualIndex: index)
            }
        }
    }
    
    func addProductToCartwithDatePicker ( productDetail : Dictionary<String, Any>, actualIndex : Int = -1)
    {
        let stockQuantity = productDetail["StockQuantity"] as? Double ?? 0.0
        
        if stockQuantity != 0.0 {
            
            if UserInfo.shared.isGuest == true
            {
                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.guestUser, withCancelButtonTitle: "OK", completion: {
                    Helper.shared.logoutAsGuest()
                    return
                })
            }
            else if UserInfo.shared.isSalesRepUser == false && UserInfo.shared.customerOnHoldStatus == true && !AppFeatures.shared.isAllowOnHoldPlacingOrder
            {
                //   return
                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                    return
                })
            }
            else{
                
                if AppFeatures.shared.IsDatePickerEnabled == true {
                    
                    if true{
                        self.showBuyInPopup(productDetail: productDetail, actualIndex: actualIndex)
                        
                    }else{
                        self.showDeliveryTypePopup {
                            self.showBuyInPopup(productDetail: productDetail, actualIndex: actualIndex)
                            self.shouldRefereshProducts = true
                        }
                    }
                }else {
                    
                    self.showBuyInPopup(productDetail: productDetail, actualIndex: actualIndex)
                }
            }
        }else {
            Helper.shared.showAlertOnController( message: "No stock available", title: CommonString.alertTitle)
        }

    }
    
    func showBuyInPopup( productDetail : Dictionary<String, Any>, actualIndex : Int = -1){
        DispatchQueue.main.async {
            
            let isBuyIn = productDetail["BuyIn"] as? Bool
            if /*AppFeatures.shared.isBuyIn*/ isBuyIn == true{
                
                if let buyInPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BuyInViewController") as? BuyInViewController
                {
                    
                    buyInPopup.showCommonAlertOnWindow {
                        
                        self.backOrder(productDetail: productDetail, actualIndex: actualIndex)
                        
                    }
                }
                
            }else{
                
                self.backOrder(productDetail: productDetail, actualIndex: actualIndex)
            }
        }
    }
    
    func backOrder( productDetail : Dictionary<String, Any>, actualIndex : Int = -1){
        
        let sohValue = productDetail["StockQuantity"] as? Double ?? 0.0
        var qtyValue = Double(truncating:(productDetail["Quantity"] as? NSNumber) ?? 0.0)
        qtyValue = qtyValue == 0.0 ? 1.0:qtyValue
        var qtyPerUnit = 1.0
        
        var arrPrices : Array<Dictionary<String,Any>>?
        if let prices = productDetail["DynamicUOM"] as? Array<Dictionary<String,Any>>
        {
            arrPrices = prices
        }else if let prices = productDetail["Prices"] as? Array<Dictionary<String,Any>>{
            arrPrices = prices
        }
        else if let prices = productDetail["Prices"] as? Dictionary<String,Any>
        {
            arrPrices = [prices]
        }
        
        if let obj = productDetail["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1{
            
            var index : Int = 0
            if let selectedIndex = productDetail["selectedIndex"] as? Int
            {
                index = selectedIndex
            }else if index + 1 < obj.count{
                
                let testIndex = arrPrices?.index(where: { (testdic : Dictionary<String, Any>) -> Bool in
                    testdic["UOMID"] as? NSNumber == productDetail["UOMID"] as? NSNumber
                })
                if (testIndex != nil)
                {
                    index = testIndex!
                }
            }
            if (arrPrices != nil), arrPrices!.count > 0
            {
                let objToFetch = arrPrices![index]
                if let packSize = objToFetch["QuantityPerUnit"] as? Int {
                    
                    qtyPerUnit = Double(packSize)
                    qtyValue = qtyValue * Double(packSize)
                }
            }
        }
        
        var product = productDetail
        if !AppFeatures.shared.isBackOrder{
            product["Quantity"] = qtyValue
            self.checkOrderMultiplies(productDetail: product, actualIndex: actualIndex)
        }else if sohValue > qtyValue{
            product["Quantity"] = qtyValue
            self.checkOrderMultiplies(productDetail: product, actualIndex: actualIndex)
        }else{
            
            if let buyInPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:SaaviActionAlert.storyboardIdentifier) as? SaaviActionAlert
            {
                if sohValue <= 0{
                    
                    buyInPopup.showCommonAlertOnWindow(withTitle: "Important", withSuccessButtonTitle: "", withMessage: "Sorry, this product is out of stock at this moment.", withCancelButtonTitle: "Ok") {
                        product["Quantity"] = 1.0
                        self.productList[actualIndex] = product
                        self.collectionView.reloadData()
                    }
                }else if sohValue < qtyPerUnit || (sohValue < qtyValue && qtyPerUnit != 1) {
                    
                    buyInPopup.showCommonAlertOnWindow(withTitle: "Important", withSuccessButtonTitle: "", withMessage: "Sorry, there are only \(sohValue) units available. Only this quantity will be added to the cart", withCancelButtonTitle: "Ok") {
                        if let obj = productDetail["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1{
                            
                            for index in 0..<arrPrices!.count
                            {
                                let objToFetch = arrPrices![index]
                                if let packSize = objToFetch["QuantityPerUnit"] as? Int {
                                    
                                    if packSize == 1{
                                        product["selectedIndex"] = index
                                        product["Quantity"] = sohValue
                                        self.productList[actualIndex] = product
                                        self.collectionView.reloadData()
                                        //                                        self.checkOrderMultiplies(productDetail: product, actualIndex: actualIndex)
                                        self.addProductToCart(productDetail: productDetail, actualIndex: actualIndex)
                                        break
                                    }
                                }
                            }
                        }
                    }
                }else {
                    
                    buyInPopup.showCommonAlertOnWindow(withTitle: "Important", withSuccessButtonTitle: "", withMessage: "Your order quantity is greater than the stock on hand quantity of \(sohValue). Only the available quantity will be added to the cart.", withCancelButtonTitle: "Ok") {
                        
                        product["Quantity"] = Int(sohValue/qtyPerUnit)
                        self.productList[actualIndex] = product
                        self.collectionView.reloadData()
                        //                        self.checkOrderMultiplies(productDetail: product, actualIndex: actualIndex)
                        self.addProductToCart(productDetail: productDetail, actualIndex: actualIndex, quantityVal :  Int(sohValue/qtyPerUnit))
                    }
                }
            }
        }
    }
    
        func checkOrderMultiplies(productDetail : Dictionary<String, Any>, actualIndex : Int = -1){
    
            var productDict = productDetail
            var unitToBedded = (productDetail.keyExists(key: "Quantity") && productDetail["Quantity"] as? Double != nil && Float(truncating: productDetail["Quantity"] as! NSNumber) != 0) ? (productDetail["Quantity"] as! Double) : 1
    
            let objToFetch = Helper.shared.getSelectedUOM(productDetail: productDetail)
            let arrayUomEach = ["EA","EACH"]
            let uomName = objToFetch["UOMDesc"] as? String
            let quantityPerUnit = objToFetch["QuantityPerUnit"] as? Int ?? 0
    
            unitToBedded = Helper.shared.calculateQuantityMultiplier(units: unitToBedded,quantityPerUnit:quantityPerUnit)
    
            productDict["Quantity"] = unitToBedded
            if AppFeatures.shared.isOrderMultiples && arrayUomEach.contains((uomName?.uppercased())!.trimmingCharacters(in: .whitespacesAndNewlines)) {
    
                DispatchQueue.main.async {
//                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: "This item can only be ordered in multiples of \(quantityPerUnit). We are adding \(unitToBedded.cleanValue) to the cart.", withCancelButtonTitle: "OK", completion: {
    
                        self.addProductToCart(productDetail: productDict, actualIndex: actualIndex)
//                    })
                }
            }else{
                self.addProductToCart(productDetail: productDetail, actualIndex: actualIndex)
            }
        }
    
    //MARK: - - Add to Cart
    func addProductToCart(productDetail : Dictionary<String, Any>, actualIndex : Int = -1, quantityVal: Int = 0){
        
        var quantity : Int = 0
        if quantityVal == 0 {
            quantity = Int(truncating: (productDetail.keyExists(key: "Quantity") && productDetail["Quantity"] as? NSNumber != nil && Float(truncating: productDetail["Quantity"] as! NSNumber) != 0) ? (productDetail["Quantity"] as! NSNumber) : 1)
        }else{
            quantity = quantityVal
        }
        
        let objToFetch = Helper.shared.getSelectedUOM(productDetail: productDetail)
        
        let requestDic = [
            "CartID": 0,
            "CustomerID": UserInfo.shared.customerID! ,
            "IsOrderPlpacedByRep": UserInfo.shared.isSalesRepUser!,
            "RunNo": "",
            "CommentLine": "",
            "PackagingSequence": 0,
            "CartItem": [
                "CartItemID": 0,
                "CartID":0,
                "ProductID": productDetail["ProductID"],
                "IsGstApplicable" : productDetail["IsGST"] as? Bool ?? false,
                "Quantity": quantity as NSNumber,
                "Price": objToFetch["Price"],
                "IsNoPantry": false,
                "UnitId": objToFetch["UOMID"]
            ]
            ] as [String : Any]
        
        let serviceURL = SyncEngine.baseURL + SyncEngine.addItemsToCart
        
        var uomDesc:String = ""
        
        switch objToFetch["UOMDesc"] as? String {
        case "EA","ea","Ea","EACH","each","Each":
            uomDesc = Int(truncating: (requestDic["CartItem"] as! Dictionary<String,Any>)["Quantity"] as! NSNumber) > 1 ? "units":"unit"
            break
        case "CARTON","Carton","carton":
            uomDesc = Int(truncating: (requestDic["CartItem"] as! Dictionary<String,Any>)["Quantity"] as! NSNumber) > 1 ? "cartons":"carton"
            break
        default:
            uomDesc = objToFetch["UOMDesc"] as? String ?? "EACH"
            break
        }
        
        
        var startStr = "Order Qty:1.00 UOM:\(uomDesc)"
        if Double(truncating: (requestDic["CartItem"] as! Dictionary<String,Any>)["Quantity"] as! NSNumber) > 1.0
        {
            let qtyStr = ((requestDic["CartItem"] as! Dictionary<String,Any>)["Quantity"] as! Double).cleanValue
            startStr = "\nOrder Qty: \(qtyStr)\nUOM: \(uomDesc)\n"
        }
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestDic, strURL: serviceURL) { (response : Any) in
            
            if let isAlreadyInCart = self.productList[actualIndex]["IsInCart"] as? Bool, isAlreadyInCart == false
            {

//                Helper.shared.showAlertOnController(message: startStr + " added to cart successfully", title: productDetail["ProductName"] as! String,hideOkayButton: true
                Helper.shared.showAlertOnController(message:"Added to cart successfully", title: "",hideOkayButton: true

                )
                Helper.shared.dismissAddedToCartAlert()
            }
            else
            {

//                Helper.shared.showAlertOnController(message: startStr + " updated in cart successfully", title: productDetail["ProductName"] as! String,hideOkayButton: true
                Helper.shared.showAlertOnController(message:"Updated in cart successfully", title: "",hideOkayButton: true

                )
                Helper.shared.dismissAddedToCartAlert()
            }
            
            
            if actualIndex > -1
            {
                self.productList[actualIndex] = productDetail
                self.productList[actualIndex]["IsInCart"] = true
                
                if quantityVal != 0 {
                    self.productList[actualIndex]["Quantity"] = quantityVal
                }

                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
            
            self.callAPIToUpdateCartNumber()
        }
    }
    
    func callAPIToUpdateCartNumber()
    {
        let request = [
            "CartID": 0,
            "IsSavedOrder": false,
            "UserID": UserInfo.shared.userId!,
            "CustomerID": UserInfo.shared.customerID!,
            "isRepUser": UserInfo.shared.isSalesRepUser as Any
            ] as [String : Any]
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: request, strURL: SyncEngine.baseURL + SyncEngine.getCartCount, withIndicator: false) { (response : Any) in
            if let obj = response as? Dictionary<String,Any>, let cartCount = obj["Count"] as? NSNumber
            {
                DispatchQueue.main.async {
                    Helper.shared.cartCount = Int(truncating: cartCount)
                    self.setDefaultNavigation()
                }
            }
        }
    }
    
    
    //    MARK: - Search Bar Delegate -
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        self.isSearchingProduct = true
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        //self.navigationItem.titleView = nil
        self.isSearchingProduct = false
        //self.setDefaultNavigation()
        self.searchBar.text = ""
        if self.isShowingFavoriteListing && self.pantryListID != 0{
            hideNoItemsLabel()
            defaultPantryPageNumber = 1
            self.getAllDefaultPantryItems(searchText: "")
        }else if !isShowingDefaultPantryList && (self.categoryId != 0 && self.categoryId != nil) && ( self.subCategoryId != 0 && self.subCategoryId != nil){
            hideNoItemsLabel()
            pageNumber = 1
            self.callSearchProductWebService(with: searchBar.text!)
            searchBar.resignFirstResponder()
        }else if !isShowingDefaultPantryList{
            self.navigationController?.popViewController(animated: false)
        }else if self.isShowingDefaultPantryList || self.isShowingFavoriteListing
        {
            hideNoItemsLabel()
            defaultPantryPageNumber = 1
            self.getAllDefaultPantryItems(searchText: "")
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.isSearchingProduct = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        if !searchBar.text!.isEmpty{
            
            hideNoItemsLabel()
            pageNumber = 1
            self.callSearchProductWebService(with: searchBar.text!)
            searchBar.resignFirstResponder()
        }
    }
    
    //    MARK: - User Action Hanling -
    
    @objc func handleFilterSelection(_ sender : UIButton)
    {
        let isAlreadySelected : Bool = sender.isSelected
        
        if (sender.superview is UIScrollView) && isAlreadySelected == false
        {
            let parent = sender.superview as! UIScrollView
            
            for view in parent.subviews{
                
                if view is UIButton
                {
                    (view as! UIButton).isSelected = false
                    (view as! UIButton).backgroundColor = UIColor.clear
                }
            }
            self.filterID = sender.tag as NSNumber
        }
        
        if isAlreadySelected == false
        {
            for label in self.filtersScrollView.subviews
            {
                if label is UILabel
                {
                    label.removeFromSuperview()
                }
            }
            
            pageNumber = 1
            defaultPantryPageNumber = 1
            if let searchBar = self.navigationItem.titleView as? UISearchBar
            {
                searchBar.text = ""
            }
            sender.isSelected = true
            sender.backgroundColor = UIColor.primaryColor()
            
            if isShowingDefaultPantryList
            {
                self.getAllDefaultPantryItems(searchText: self.searchBar.text ?? "")
            }
            else if isShowingFavoriteListing
            {
                self.getAllDefaultPantryItems(searchText: self.searchBar.text ?? "")
            }
            else
            {
                self.callSearchProductWebService()
            }
            
            // Move the filter and make it visible.
            
            UIView.animate(withDuration: 0.5, animations: {
                if sender.frame.maxX > (self.filtersScrollView.contentOffset.x + self.filtersScrollView.frame.size.width)
                {
                    self.filtersScrollView.contentOffset = CGPoint(x: sender.frame.maxX - self.filtersScrollView.frame.size.width + 20.0, y: 0)
                }
                else if sender.frame.minX < self.filtersScrollView.contentOffset.x
                {
                    self.filtersScrollView.contentOffset = CGPoint(x: sender.frame.minX - 10.0, y: 0)
                }
            })
        }
    }
    
    @objc func backBtnAction() -> Void
    {
        if (self.isComingFromRecurringCart == true)
        {
            self.tabBarController?.tabBar.isHidden = false
            self.navigationController?.popViewController(animated: true)
            return
        }

        if (isShowingDefaultPantryList && AppFeatures.shared.isParent && UserInfo.shared.isParent){
            
            ChildListWireframe.makeChildListAsRoot()
            
        }else if UIDevice.current.userInterfaceIdiom == .phone && UserInfo.shared.isSalesRepUser! &&  (isShowingDefaultPantryList && !isSearchingProduct){
            
            self.navigationController?.navigationController?.popViewController(animated: true)
            
        }else if !isShowingDefaultPantryList{
            self.navigationController?.popViewController(animated: false)
        }else if self.isSearchingProduct{
            
            self.searchBar.showsCancelButton = false
            self.searchBar.resignFirstResponder()
            self.isSearchingProduct = false
            self.searchBar.text = ""
            self.pageNumber = 1
            self.callSearchProductWebService()
        }else {
            self.navigationController?.popViewController(animated: !isSearchingProduct)
        }
    }
    
    @objc func showQuantityPopupAction(_ sender : UIButton)
    {
        if (self.isComingFromRecurringCart == true)
        {
            let index:Int = sender.tag
            self.addProductToCart(index:index)
            return
        }
        
        let productDetail = self.productList[sender.tag]
        
        let stockQuantity = productDetail["StockQuantity"] as? Double ?? 0.0
        
        if stockQuantity != 0.0 {
            
            let index:Int = sender.tag
            if AppFeatures.shared.IsDatePickerEnabled == true {
                
                if true
                {
                    if AppFeatures.shared.IsShowQuantityPopup == true{
                        self.addProductToCart(index:index)
                    }
                    else{
                        let indexPath = IndexPath(item: index, section: 0)
                        
                        let cell = self.collectionView?.cellForItem(at: indexPath) as! OrderCollectionViewCell
                        cell.txtQuantity.becomeFirstResponder()
                        self.collectionView.isScrollEnabled = false
                        self.txtFldActive = cell.txtQuantity
                        self.txtFldActive.text = ""
                    }
                }
                else
                {
                    self.showDeliveryTypePopup {
                        
                        if AppFeatures.shared.IsShowQuantityPopup == true{
                            self.addProductToCart(index:index)
                            self.shouldRefereshProducts = true
                        }
                        else{
                            let indexPath = IndexPath(item: index, section: 0)
                            
                            let cell = self.collectionView?.cellForItem(at: indexPath) as! OrderCollectionViewCell
                            cell.txtQuantity.becomeFirstResponder()
                            self.collectionView.isScrollEnabled = false
                            self.txtFldActive = cell.txtQuantity
                            self.txtFldActive.text = ""
                        }
                    }
                }
            }
            else{
                
                if AppFeatures.shared.IsShowQuantityPopup == true{
                    
                    self.addProductToCart(index:index)
                }else{
                    
                    let indexPath = IndexPath(item: index, section: 0)
                    let cell = self.collectionView?.cellForItem(at: indexPath) as! OrderCollectionViewCell
                    self.txtFldActive = cell.txtQuantity
                    self.txtFldActive.text = ""
                    self.txtFldActive.becomeFirstResponder()
                    self.collectionView.isScrollEnabled = false
                }
            }
        }else {
            Helper.shared.showAlertOnController( message: "No stock available", title: CommonString.alertTitle)
        }

    }
    
    
    func addProductToCart(index:Int){
        
        var product = productList[index]
        
        if let circularPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "circularQuantityStoryboardID") as? CircularQuantityPopup
        {
            circularPopup.quantityPerUnit = Helper.shared.getSelectedUomNameQuantity(product: product).quantity
            circularPopup.isEach =  Helper.shared.getSelectedUomNameQuantity(product: product).isEach
            
            if (self.isComingFromRecurringCart == true)
            {
                circularPopup.circularSlider.currentValue = AppFeatures.shared.IsAllowDecimal ? 0.00: UserInfo.shared.isSalesRepUser! ? 0.00:1
                circularPopup.showCommonAlertOnWindow
                    {
                        product["Quantity"] = NSNumber(value: Double(circularPopup.txtFldQuantity.text!)!)
                        //  self.productList[index.row] = product
                        
                        self.checkMinAndMaxOrderQuantity(productValue: product, index: index, quantity: NSNumber(value: Double(circularPopup.txtFldQuantity.text!)!))
                        
                        self.collectionView.reloadData()
                        //   self.showBuyInPopup(productDetail: product, actualIndex: index.row)
                }
                return
            }

            
            if product.keyExists(key: "Quantity"), let number = product["Quantity"] as? NSNumber
            {
                
                circularPopup.circularSlider.currentValue = Float(truncating: number)
                circularPopup.currentQuantity = "\(Double(truncating: number))"
                circularPopup.showCommonAlertOnWindow
                    {
                        product["Quantity"] = NSNumber(value: Double(circularPopup.txtFldQuantity.text!)!)
                        self.checkMinAndMaxOrderQuantity(productValue: product, index: index, quantity: NSNumber(value: Double(circularPopup.txtFldQuantity.text!)!))
                        self.collectionView.reloadData()
                }
            }
            else
            {
                circularPopup.circularSlider.currentValue = AppFeatures.shared.IsAllowDecimal ? 0.00: UserInfo.shared.isSalesRepUser! ? 0.00:1
                circularPopup.showCommonAlertOnWindow
                    {
                        product["Quantity"] = NSNumber(value: Double(circularPopup.txtFldQuantity.text!)!)
                        //  self.productList[index.row] = product
                        
                        self.checkMinAndMaxOrderQuantity(productValue: product, index: index, quantity: NSNumber(value: Double(circularPopup.txtFldQuantity.text!)!))
                        
                        self.collectionView.reloadData()
                        //   self.showBuyInPopup(productDetail: product, actualIndex: index.row)
                }
            }
            
            if let bool = product["IsInCart"] as? Bool, bool == true
            {
                circularPopup.btnAddToCart.setTitle("UPDATE CART", for: .normal)
            }
            
        }
        
    }
    
    //    @objc func showSearchBar() -> Void
    //    {
    //        if isShowingDefaultPantryList == false
    //        {
    //            Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
    //            Helper.shared.setNavigationTitle(viewController: self, title: "Search")
    //            Helper.shared.createCartIcon(onController: self)
    //            self.searchBar.becomeFirstResponder()
    //        }
    //    }
    
    @objc func objTappedForDetails (_ sender : Any?) -> Void
    {
        if sender is UITapGestureRecognizer, let cell = (sender as! UITapGestureRecognizer).view?.superview?.superview?.superview as? OrderCollectionViewCell
        {
            if let indexPath = self.collectionView.indexPath(for: cell)
            {
                let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderDescriptionView") as? OrderDescriptionView
                destinationViewController?.productID = (self.productList[indexPath.row]["ProductID"] as? NSNumber)!
                self.navigationController?.pushViewController(destinationViewController!, animated: true)
            }
        }
    }
    
    @objc func swipeMoved(_ gestureRecognizer : UIPanGestureRecognizer) -> Void
    {
        
        if  gestureRecognizer.state == .changed {
            
            let translation = gestureRecognizer.translation(in: self.view)
            print(translation.x)
            if (gestureRecognizer.view?.frame.origin.x)! + translation.x > CGFloat(0){
                
                if ((gestureRecognizer.view?.center.x)! + translation.x) <  (gestureRecognizer.view?.bounds.width)!{
                    
                    UIView.transition(with: self.view, duration: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                        gestureRecognizer.view!.center = CGPoint(x: (gestureRecognizer.view!.center.x + translation.x) > (gestureRecognizer.view?.bounds.width)! ? (gestureRecognizer.view?.bounds.width)! : (gestureRecognizer.view!.center.x + translation.x) , y: gestureRecognizer.view!.center.y )
                    }, completion: { (finished: Bool) -> () in
                        
                        // completion
                        
                    })
                }
                gestureRecognizer.view?.superview?.backgroundColor = UIColor.primaryColor()
            }else{
                
                gestureRecognizer.view?.superview?.backgroundColor = UIColor.primaryColor()
                if (gestureRecognizer.view?.center.x)! > 0.0
                {
                    UIView.transition(with: self.view, duration: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                        gestureRecognizer.view!.center = CGPoint(x: (gestureRecognizer.view!.center.x + translation.x) < 0.0 ? 0.0 : (gestureRecognizer.view!.center.x + translation.x) , y: gestureRecognizer.view!.center.y )
                    }, completion: { (finished: Bool) -> () in
                        // completion
                    })
                }
            }
        }else if gestureRecognizer.state == .ended {
            
            if (gestureRecognizer.view?.frame.minX)! > (((gestureRecognizer.view?.frame.size.width)! - (gestureRecognizer.view?.frame.size.width)!/2.0) - 20.0) {
                
                print("add to cart.")
                
                if gestureRecognizer.view?.superview?.superview is OrderCollectionViewCell
                {
                    let cell = gestureRecognizer.view?.superview?.superview as! OrderCollectionViewCell
                    let obj = self.productList[(collectionView.indexPath(for: cell)?.row)!]
                    if obj["IsAvailable"] as? Bool == true
                    {
                        
                        var quantity = Double(exactly:(obj["Quantity"] as? NSNumber) ?? 0.0) ?? 0.0
//                        let quantityPerUnit = Double(exactly:(obj["QuantityPerUnit"] as? NSNumber) ?? 0.0) ?? 0.0

                        var qtyPerUnit = 0.0
                        
                        var arrPrices : Array<Dictionary<String,Any>>?
                        if let prices = obj["DynamicUOM"] as? Array<Dictionary<String,Any>>
                        {
                            arrPrices = prices
                        }else if let prices = obj["Prices"] as? Array<Dictionary<String,Any>>{
                            arrPrices = prices
                        }
                        else if let prices = obj["Prices"] as? Dictionary<String,Any>
                        {
                            arrPrices = [prices]
                        }

                        let objToFetch = arrPrices![0]
                        if let packSize = objToFetch["QuantityPerUnit"] as? Int {
                            qtyPerUnit = Double(packSize)
                        }

                        var product = obj
                        if quantity > 0.0{
                            quantity = quantity + qtyPerUnit
                        }
                        product["Quantity"] = quantity
                        
                        self.checkMinAndMaxOrderQuantity(productValue: product, index: (collectionView.indexPath(for: cell)?.row)!, quantity: NSNumber(value:quantity))
                    }
                    else{
                        Helper.shared.showAlertOnController(message: "Product is not available", title: CommonString.alertTitle)
                    }
                }
            }else if (gestureRecognizer.view?.frame.minX)! < ((0.0 - (gestureRecognizer.view?.frame.size.width)!/2.0) + 20.0){
                
                print("add to fav")
                let cell = gestureRecognizer.view?.superview?.superview as! OrderCollectionViewCell
                let obj = self.productList[(collectionView.indexPath(for: cell)?.row)!]
                if let proId = obj["ProductID"] as? NSNumber
                {
                    
                    let cell = gestureRecognizer.view?.superview?.superview as! OrderCollectionViewCell
                    let obj = self.productList[(collectionView.indexPath(for: cell)?.row)!]
                    if obj["IsAvailable"] as? Bool == true
                    {
                        var quantity = Double(exactly:(obj["Quantity"] as? NSNumber) ?? 0.0) ?? 0.0
                       
                        var qtyPerUnit = 0.0
                        var arrPrices : Array<Dictionary<String,Any>>?
                        if let prices = obj["DynamicUOM"] as? Array<Dictionary<String,Any>>
                        {
                            arrPrices = prices
                        }else if let prices = obj["Prices"] as? Array<Dictionary<String,Any>>{
                            arrPrices = prices
                        }
                        else if let prices = obj["Prices"] as? Dictionary<String,Any>
                        {
                            arrPrices = [prices]
                        }
                        let objToFetch = arrPrices![0]
                        if let packSize = objToFetch["QuantityPerUnit"] as? Int {
                            qtyPerUnit = Double(packSize)
                        }

                        var product = obj
                        if quantity > 0.0{
                            quantity = quantity + qtyPerUnit
                        }
                        product["Quantity"] = quantity
                        self.checkMinAndMaxOrderQuantity(productValue: product, index: (collectionView.indexPath(for: cell)?.row)!, quantity: NSNumber(value:quantity))
                    }
                    else{
                        Helper.shared.showAlertOnController(message: "Product is not available", title: CommonString.alertTitle)
                    }
                }
            }
            
            UIView.transition(with: self.view, duration: 0.3, options: UIViewAnimationOptions.curveEaseIn, animations: {
                gestureRecognizer.view!.frame = (gestureRecognizer.view?.bounds)!
            }, completion: { (finished: Bool) -> () in
            })
        }
        gestureRecognizer.setTranslation(CGPoint.zero, in: gestureRecognizer.view?.superview)
        
    }
    
    func showDeliveryTypePopup(withCompletion completion : @escaping dateSelectionCompleted)->Void{
        
        DispatchQueue.main.async {
            
            if let receiveOrderPopup = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReceiveOrderPopupVC") as? ReceiveOrderPopupVC
            {
                receiveOrderPopup.modalPresentationStyle = .overCurrentContext
                self.present(receiveOrderPopup, animated: false, completion: nil)
                receiveOrderPopup.completionBlock = { (buttonPressed, deliveyType) -> Void in
                    
                    if buttonPressed == .moveNext {
                        UserInfo.shared.isDelivery = deliveyType == DeliveryType.pickUp ? false : true
                        self.showDatePicker {
                            completion()
                        }
                    }
                }
            }
            
        }
    }
    
    
    func showDatePicker(withCompletion completion : @escaping dateSelectionCompleted) -> Void
    {
        if Helper.shared.isDateSelected() == false
        {
            if let orderDatePicker = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "datePickerStoryID") as? DatePickerView
            {
                self.shouldRefereshProducts = false
                orderDatePicker.modalPresentationStyle = .overCurrentContext
                self.present(orderDatePicker, animated: false, completion: nil)
                orderDatePicker.completionBlock = {(buttonPressed) -> Void in
                    if buttonPressed! != .backORFinishLator{
                        completion()
                    }
                }
            }
            return
        }
    }
    
    func addProductToFavoriteList(productID : NSNumber,index:Int)
    {
        if AppFeatures.shared.isFavoriteList{
            if let chooseFavorite = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "choosefavouriteListPopupStoryboardIdentifier") as? ChooseFavouriteListPopup{
                chooseFavorite.productID = productID
                chooseFavorite.productID = productID
                chooseFavorite.showCommonAlertOnWindow(completion: { (isFav : Bool) in
                    self.productList[index]["IsInPantry"] = isFav
                    self.collectionView.reloadData()
                })
            }
        }else{
            self.addItemToDefaultPantry(productID: productID, index: index)
        }
    }
    
    func addItemToDefaultPantry(productID : NSNumber? ,index:Int){
        
        if productID != nil{
            let requestObj = [
                "PantryListID": 0,
                "ProductID": productID!,
                "Quantity": 0,
                "PantryType" : "F",
                "CustomerID":UserInfo.shared.customerID!
                ] as [String:Any]
            
            let serviceURL = SyncEngine.baseURL + SyncEngine.addItemToPantryList
            
            SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestObj, strURL: serviceURL) { (response : Any) in
                DispatchQueue.main.async {
                    
                    self.productList[index]["IsInPantry"] = true
                    self.collectionView.reloadData()
                    Helper.shared.showAlertOnController(message: "Product added successfully.", title: CommonString.app_name,hideOkayButton: true)
                    Helper.shared.dismissAlert()
                }
            }
        }
    }
    
    //MARK: - Delete item from Favorite list
    @objc func deleteItemFromFavorite(index: Int) {
        
        let indexPath = IndexPath.init(row: index, section: 0)
        
        //        if self.isShowingFavoriteListing{
        
        SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: "Do you want to un-follow this product?", withCancelButtonTitle: "No", completion: {
            
            self.removeItemFavoriteList(indexPath: indexPath)
        })
        //        }
    }
    
    private func removeItemFavoriteList(indexPath: IndexPath){
        
        let product = self.productList[indexPath.item]
        var pantryListItemID : Int = 0
        if product["PantryListItemID"] != nil{
            pantryListItemID = product["PantryListItemID"] as! Int
        }
        else if product["PantryItemID"] != nil{
            pantryListItemID = product["PantryItemID"] as! Int
        }
        let pantryListID = product["PantryListID"] ?? 0

        let dict = ["PantryItemID": pantryListItemID,
                    "PantryListID": pantryListID,
                    "CustomerID": UserInfo.shared.customerID!]
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: dict, strURL: SyncEngine.baseURL + SyncEngine.deleteItemFromFavorite) { (response) in
            
            self.productList[indexPath.item]["IsInPantry"] = false
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    @objc func copyPantryListAction(){
        
        if UserInfo.shared.isGuest == true
        {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.guestUser, withCancelButtonTitle: "OK", completion: {
                Helper.shared.logoutAsGuest()
                return
            })
        }
        else if UserInfo.shared.customerOnHoldStatus==true && !AppFeatures.shared.isAllowOnHoldPlacingOrder {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                return
            })
        }else{
            if let favorietController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addFavoriteListPopupSroryID") as? AddFavoriteListView{
                favorietController.parentController = self
                favorietController.isCopyingExistingPantry = true
                favorietController.isCreatedByRepUser = false
                if Int(truncating: self.pantryListID) > 0{
                    favorietController.pantryListToBeCopiedId = pantryListID
                    UIApplication.shared.keyWindow?.rootViewController?.present(favorietController, animated: false, completion: nil)
                }else{
                    if self.productList.count > 0 , let pantryid = self.productList[0]["PantryListID"] as? NSNumber{
                        if AppFeatures.shared.isNonFoodVersion{
                            favorietController.titleOfPopup = "Please enter new name for copied favourite list."
                        }else{
                            favorietController.titleOfPopup = "Please enter new name for copied pantry list."
                        }
                        favorietController.pantryListToBeCopiedId = pantryid
                        UIApplication.shared.keyWindow?.rootViewController?.present(favorietController, animated: false, completion: nil)
                    }else{
                        if AppFeatures.shared.isNonFoodVersion == true
                        {
                            Helper.shared.showAlertOnController(message: "Could not copy empty favourite list.", title: CommonString.alertTitle)
                        }else{
                            Helper.shared.showAlertOnController(message: "Could not copy empty pantry list.", title: CommonString.alertTitle)
                        }
                    }
                }
            }
        }
    }
    
    @objc func handleEnquiryPopupTap(_ button : UIButton) -> Void
    {
        if UserInfo.shared.isGuest == true
        {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.guestUser, withCancelButtonTitle: "OK", completion: {
                Helper.shared.logoutAsGuest()
                return
            })
        }
        else if UserInfo.shared.customerOnHoldStatus==true && !AppFeatures.shared.isAllowOnHoldPlacingOrder {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                return
            })
        }
        else{
            let objForEnquiry = productList[button.tag]
            if let enquiryPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:"addEnquiryPopupSroryID") as? AddNewEnquiryPopup
            {
                enquiryPopup.itemForEnquiry = objForEnquiry
                enquiryPopup.parentView = self
                UIApplication.shared.keyWindow?.rootViewController?.present(enquiryPopup, animated: false, completion: nil)
            }
        }
    }
    
    @objc func showSavedOrderAlert(_ button : UIButton)
    {
        if UserInfo.shared.isGuest == true
        {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.guestUser, withCancelButtonTitle: "OK", completion: {
                Helper.shared.logoutAsGuest()
                return
            })
        }
        else if UserInfo.shared.customerOnHoldStatus==true && !AppFeatures.shared.isAllowOnHoldPlacingOrder {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                return
            })
        }
        else{
            let savedOrderAlert = UIAlertController(title: CommonString.app_name, message: "You have a saved order. Do you want to amend saved order or delete it?", preferredStyle: .alert)
            let savedOrderID = button.tag
            savedOrderAlert.addAction(UIAlertAction(title: "Amend saved order", style: .default, handler: { (action : UIAlertAction) in
                if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cartVCStoryboardID") as? CartView
                {
                    let request = [
                        "UserID": UserInfo.shared.userId!,
                        "CustomerID": UserInfo.shared.customerID!,
                        "OrderID": self.savedOrderId!,
                        "AppendToSavedOrder": true,
                        "IsPlacedByRep": UserInfo.shared.isSalesRepUser!
                        ] as [String:Any]
                    
                    SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: request, strURL: SyncEngine.baseURL + SyncEngine.reorderItems, completion: { (response : Any) in
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 1), execute: {
                            self.navigationController?.pushViewController(vc, animated: true)
                        })
                    })
                }
            }))
            savedOrderAlert.addAction(UIAlertAction(title: "Delete saved order", style: .destructive, handler: { (action : UIAlertAction) in
                self.deleteSaveOrder(orderID: savedOrderID)
            }))
            
            savedOrderAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action : UIAlertAction) in
                
            }))
            self.present(savedOrderAlert, animated: true, completion: nil)
        }
    }
    
    func deleteSaveOrder(orderID : Int)
    {
        let request = [
            "orderID": orderID
            ] as [String : Any]
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: request, strURL: SyncEngine.baseURL + SyncEngine.deleteSavedOrder) { (response : Any) in
            self.savedOrderId = nil
            Helper.shared.showAlertOnController(message: "Order deleted successfully.", title: CommonString.app_name,hideOkayButton: true)
            Helper.shared.dismissAlert()
            DispatchQueue.main.async {
                self.setDefaultNavigation()
            }
        }
    }
    
    
    @objc func showLatestSpecialsAction(){
        
        if let walkthrough = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: WhatsNewVC.storyboardID) as? WhatsNewVC{
            walkthrough.isFromTab = false
            self.navigationController?.pushViewController(walkthrough, animated: true)
        }
    }
    
    func deleteOrderFromServer(){
        
        SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: "Delete saved order?", withSuccessButtonTitle: "Yes", withMessage: "Are you sure you want to delete saved order. This cannot be undone.", withCancelButtonTitle: "No")
        {
            
        }
    }
    
    //MARK: - View By Category Button Action
    @IBAction func addItemToDefaultPantryAction(_ sender: Any)
    {
        self.moveOnCategorySelectionScreen(onClickButton: true)
    }
    
    func moveOnCategorySelectionScreen(onClickButton: Bool) {
        UserDefaults.standard.set(false, forKey: "isComeFirstTime")
        
        
         if UserInfo.shared.customerOnHoldStatus==true && !AppFeatures.shared.isAllowOnHoldPlacingOrder {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                return
            })
        }
        else{
            if let categoryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "categorySelectionVCStoryID") as? CategorySelectionVC
            {
                categoryVC.isAddingToDefaultPantry = AppFeatures.shared.isUserAllowedToAddItemsToDefaultPantry
                if onClickButton {
                    self.navigationController?.pushViewController(categoryVC, animated: true)
                }else{
                   // self.navigationController?.pushViewController(categoryVC, animated: false)
                }
            }
        }
        
    }
    
    //MARK: - - deleteItemFromFavoriteList
    private func removeItemFromFavoriteList(indexPath:IndexPath){
        
        let product = self.productList[indexPath.item]
        let itemID = product["PantryItemID"] ?? 0
        let dict = ["PantryItemID":itemID,"PantryListID":self.pantryListID]
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: dict, strURL: SyncEngine.baseURL + SyncEngine.deleteItemFromFavorite) { (response) in
            
            self.productList.remove(at: indexPath.item)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK:- Gesture Handling -
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UITapGestureRecognizer
        {
            if gestureRecognizer.view is UITextField || otherGestureRecognizer.view is UITextField
            {
                return false
            }
            return true
        }
        else if gestureRecognizer.view is UITextField
        {
            return true
        }
        return false
    }
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        
        let indexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView))
        
        //        let tapLocation = gesture.location(in: self.collectionView).x
        //        let sortButtonPoint = self.collectionView.frame.size.width - self.collectionView.frame.size.width/4
        //
        //        if self.isShowingFavoriteListing{
        //
        //            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: "Do you want to delete this product?", withCancelButtonTitle: "No", completion: {
        //
        //                self.removeItemFromFavoriteList(indexPath: indexPath!)
        //            })
        //
        //        }else{
        
        switch(gesture.state) {
            
        case .began:
            guard let selectedIndexPath = indexPath else {
                break
            }
            self.collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            self.collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            self.collectionView.endInteractiveMovement()
        default:
            self.collectionView.cancelInteractiveMovement()
        }
        //        }
    }
    //    MARK:- Scroll View -
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate
        {
            self.handlePaginationIfRequired(scrollView:  scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        self.handlePaginationIfRequired(scrollView:  scrollView)
    }
    
    func handlePaginationIfRequired(scrollView: UIScrollView)
    {
        if scrollView.contentSize.height < (scrollView.contentOffset.y + scrollView.frame.size.height + 5.0), totalResults != nil, Int(truncating: self.totalResults!) > self.productList.count
        {
            let searchText = self.searchBar.text ?? ""
            if self.isSearchingProduct{
                pageNumber += 1
                self.callSearchProductWebService(with: searchText)
            }else if !self.isShowingDefaultPantryList && !self.isShowingFavoriteListing{
                pageNumber += 1
                self.callSearchProductWebService(with: searchText)
            }else if self.isShowingDefaultPantryList || self.isShowingFavoriteListing{
                defaultPantryPageNumber += 1
                self.getAllDefaultPantryItems(searchText: searchText)
            }
        }
    }
    
    @objc func doneButtonClicked(_ textField: UITextField) {
        
        self.collectionView.isScrollEnabled = true
        if textField == txtFldActive{
            var product = self.productList[textField.tag]
            
            let qtyDoubleValue:Double = (textField.text?.isEmpty)! ? 0.00:Double(textField.text!)!
            let qtyValue = qtyDoubleValue <= 0 ? 0.00:qtyDoubleValue
            product["Quantity"] = NSNumber(value: qtyValue)
            self.productList[textField.tag] = product
            product = self.productList[textField.tag]
            self.checkMinAndMaxOrderQuantity(productValue: product, index: textField.tag, quantity: NSNumber(value:qtyValue))
            //self.addProductToCartwithDatePicker(productDetail: product, actualIndex: textField.tag)
        }
        
    }
    @objc func showHelpAction(){
        
        SyncEngine.sharedInstance.sendGetRequestToServer(strURL: SyncEngine.baseURL + SyncEngine.GetHelp + "DefaultPantry") { (response: Any) in
            
            print(response)
            
            if let responseDic = response as? Dictionary<String,Any>
            {
                print(responseDic)
                SaaviActionHelp.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage:responseDic["Description"] as! String!, withCancelButtonTitle: "OK", completion:{
                    
                })
                
                
                
            }
            
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.collectionView.isScrollEnabled = true
        if textField == self.txtFldActive{
            
            self.txtFldActive.text = ((textField.text?.isEmpty)!) ? (AppFeatures.shared.IsAllowDecimal ? 0.00.cleanValue: UserInfo.shared.isSalesRepUser! ? 0.00.cleanValue:"0"):textField.text
            self.collectionView.reloadData()
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtFldActive{
            if !UserInfo.shared.isSalesRepUser! && !AppFeatures.shared.IsAllowDecimal{
                if  string == "."{
                    return false
                }
            }
            
            let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
            guard let oldText = textField.text, let r = Range(range, in: oldText) else {
                return true
            }
            
            let newText = oldText.replacingCharacters(in: r, with: string)
            let isNumeric = newText.isEmpty || (Double(newText) != nil)
            let numberOfDots = newText.components(separatedBy: ".").count - 1
            
            let numberOfDecimalDigits: Int
            if let dotIndex = newText.index(of: ".") {
                numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
            } else {
                numberOfDecimalDigits = 0
            }
            let numberOfValidDigits : Int
            if newText.index(of: ".") != nil {
                // numberOfDigits = newText.distance(from: newText.startIndex, to: dotIndex)
                numberOfValidDigits = 8
            } else {
                numberOfValidDigits = 5
            }
            
            
            //return newString.count < 9 || isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2
            if newString.count > numberOfValidDigits
            {
                return false
            }
            else
            {
                return isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2
            }
        }
        return true
        
    }
    
    @objc func showCartScreen() -> Void
    {
        if UserInfo.shared.isGuest == true
        {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.guestUser, withCancelButtonTitle: "OK", completion: {
                Helper.shared.logoutAsGuest()
                return
            })
        }
        else if UserInfo.shared.customerOnHoldStatus == true && !AppFeatures.shared.isAllowOnHoldPlacingOrder{
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
    
    func updateCartItemObjWithObj(dic : Dictionary<String,Any>)
    {
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: dic, strURL: SyncEngine.baseURL + SyncEngine.updateCartItem) { (response : Any) in
            
        }
    }
    
    @objc func uOMChanged(sender : UIButton)
    {
        if let obj = self.productList[sender.tag]["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1
        {
            var index : Int = 0
            if let selectedIndex = self.productList[sender.tag]["selectedIndex"] as? Int
            {
                index = selectedIndex
            }
            
            if index + 1 < obj.count
            {
                var objToChange = self.productList[sender.tag]
                objToChange["selectedIndex"] = index + 1
                self.productList[sender.tag] = objToChange
                self.collectionView.reloadData()
            }
            else
            {
                var objToChange = productList[sender.tag]
                objToChange["selectedIndex"] = 0
                self.productList[sender.tag] = objToChange
                self.collectionView.reloadData()
            }
            
        }
    }
 }
 
 class WeekHistoryCollectionCell : UICollectionViewCell
 {
    @IBOutlet weak var labelInfo : UILabel!
    
    override func awakeFromNib()
    {
        self.labelInfo.font = UIFont.SFUI_Regular(baseScaleSize: 13.0)
    }
 }
 
 
 extension OrderVC: LightboxControllerPageDelegate ,LightboxControllerDismissalDelegate{
    
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        
    }
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
    }
 }
 
 
