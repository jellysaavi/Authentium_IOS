 //
 //  OrderVC.swift
 //  Saavi
 //
 //  Created by Sukhpreet on 29/06/17.
 //  Copyright © 2017 Saavi. All rights reserved.
 //
 
 import UIKit
 
 class OrderVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate{
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    var productList = Array<Dictionary<String,Any>>()
    @IBOutlet weak var filtersScrollView: UIScrollView!
    var categoryId : NSNumber?
    var subCategoryId : NSNumber?
    var isShowingDefaultPantryList : Bool = true
    var isShowingFavoriteListing : Bool = false
    var filterID : NSNumber = 0
    var arrFilters = Array<Dictionary<String,Any>>()
    var totalResults : NSNumber?
    var allPantryItems = Array<Dictionary<String,Any>>()
    var menuController : MenuHierarchyHandler?
    var pantryListID : NSNumber = 0
    var screenTitle : String = ""
    @IBOutlet weak var pantryFiltersHeight: NSLayoutConstraint!
    var isShowingSaveBtn : Bool = false
    @IBOutlet weak var bottomLayoutContraint: NSLayoutConstraint!
    var pageNumber : Int = 1
    var savedOrderId : NSNumber?
    var isAddingItemToDefaultPantry : Bool = false
    var isSearchingProduct : Bool = false
    var shouldRefereshProducts = true
    @IBOutlet weak var btnAddItemsToDefaultPantry: CustomButton!
    
    //MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                pantryFiltersHeight.constant = self.view.frame.size.height * (40.0/667.0)
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
        
        if AppFeatures.shared.isUserAllowedToAddItemsToDefaultPantry, isShowingDefaultPantryList
        {
            bottomLayoutContraint.constant = 50.0
            self.btnAddItemsToDefaultPantry.isHidden = false
        }
        else
        {
            bottomLayoutContraint.constant = 0.0
            self.btnAddItemsToDefaultPantry.isHidden = true
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
                    }
                    else if notification.name.rawValue == "addToCart"{
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
        if notification.name.rawValue == "placeOrder" || notification.name.rawValue == "UpdateSpecialPrice" || notification.name.rawValue == "addToCart" || notification.name.rawValue == "UpdateCart"{
            getAllDefaultPantryItems()
        }
        
    }
    
    func setDefaultNavigation() -> Void
    {
        self.navigationItem.rightBarButtonItems = nil
        
        if !isSearchingProduct{
            
            // add check for latest specials manage feature here.
            Helper.shared.createLatestSpecialsBarButtonItem(onController: self)
            Helper.shared.createCartIcon(onController: self)
            Helper.shared.createSearchIcon(onController: self)
            
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
                Helper.shared.setNavigationTitle(withTitle: self.screenTitle, withLeftButton: .backButton, onController: self)
            }
            else
            {
                
                if UIDevice.current.userInterfaceIdiom == .phone && UserInfo.shared.isSalesRepUser!
                {
                    Helper.shared.setNavigationTitle(withTitle: ["   ","Pantry"], withLeftButtons: [.backButton,.profileButton], onController: self)
                    
                }else{
                    
                    if AppFeatures.shared.isNonFoodVersion == false
                    {
                        Helper.shared.setNavigationTitle(withTitle: "Pantry", withLeftButton: .profileButton, onController: self)
                    }
                    else
                    {
                        Helper.shared.setNavigationTitle(withTitle: "Favourites", withLeftButton: .profileButton, onController: self)
                    }
                }
            }
        }
        else
        {
            Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
            self.showSearchBar()
        }
    }
    override func viewWillLayoutSubviews() {
        //navigationController?.navigationBar.isTranslucent = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if self.isShowingDefaultPantryList
        {
            
            if self.productList.count == 0 && (self.navigationItem.titleView is UISearchBar) == false
            {
                self.getAllDefaultPantryItems()
                
            }else if AppFeatures.shared.isProductAdded{
                
                AppFeatures.shared.isProductAdded = false
                self.productList.removeAll()
                self.getAllDefaultPantryItems()
                
            }
        }
        else if isShowingFavoriteListing
        {
            if productList.count == 0
            {
                self.getAllDefaultPantryItems()
                Helper.shared.setNavigationTitle(withTitle: self.screenTitle, withLeftButton: .backButton, onController: self)
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBottomLayoutConstraintWithNotification(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateBottomLayoutConstraintWithNotification(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OrderVC.refreshCount), name: NSNotification.Name(rawValue: "cartCountChanged"), object: nil)
        
        
        
//        if isSearchingProduct == false
//        {
//            self.callAPIToUpdateCartNumber()
//        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        
    }
    
    @objc func updateBottomLayoutConstraintWithNotification(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        if let keyboardEndFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect
        {
            if keyboardEndFrame.origin.y == UIScreen.main.bounds.size.height
            {
                if AppFeatures.shared.isUserAllowedToAddItemsToDefaultPantry, isShowingDefaultPantryList
                {
                    bottomLayoutContraint.constant = 50.0
                }
                else
                {
                    bottomLayoutContraint.constant = 0.0
                }
            }
            else
            {
                let bottom = keyboardEndFrame.height - 49.0
                bottomLayoutContraint.constant = bottom
            }
        }
        
        /*
         if let searchBar = self.navigationItem.titleView as? UISearchBar
         {
         searchBar.text = ""
         }*/
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - CollectionView datasource and delegate methods -
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return productList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell : DryOrdersCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "orderCollectionCellID", for: indexPath) as! DryOrdersCollectionCell
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
       
        cell.btnAddToFavourite.tintColor = UIColor.baseBlueColor()
        if let recoganizes = cell.containerView.gestureRecognizers
        {
            for gesture in recoganizes
            {
                cell.containerView.removeGestureRecognizer(gesture)
            }
        }
        
        if AppFeatures.shared.shouldShowLongDetail
        {
            let tapRecog = UITapGestureRecognizer(target: self, action: #selector(self.objTappedForDetails(_:)))
            tapRecog.delegate = self
            cell.containerView.addGestureRecognizer(tapRecog)
        }
        
        if AppFeatures.shared.shouldHighlightStock
        {
            //cell.btnAvailable.isHidden = false
            cell.availImgWidthConstant.constant = 18.0
            cell.availTrailingConstant.constant = 5.0
        }
        else
        {
            //  cell.btnAvailable.isHidden = true
            cell.availImgWidthConstant.constant = 0
            cell.availTrailingConstant.constant = 0
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.swipeMoved(sender:)))
        panGesture.delegate = self
        cell.containerView.addGestureRecognizer(panGesture)
        
        if(productList.count > 0)
        {
            var productDescDic = productList[indexPath.row]
            if(productDescDic.count > 0)
            {
                cell.lblDryOrder.text = ((productDescDic)["ProductName"] as? String)?.capitalized
                cell.productCode.text = "CODE : \(String(describing: (productDescDic)["ProductCode"] as! String))"
                
                if AppFeatures.shared.isHighlightRewardItem
                {
                    if let isCountrywideReward =  productDescDic["IsCountrywideRewards"] as? Bool, isCountrywideReward == true
                    {
                        cell.lblDryOrder.textColor = UIColor.addToCartGreenColor()
                    }
                    else
                    {
                        cell.lblDryOrder.textColor = UIColor.baseBlueColor()
                    }
                }
                else{
                    cell.lblDryOrder.textColor = UIColor.baseBlueColor()
                }
                
                
                var arrPrices : Array<Dictionary<String,Any>>?
                if let prices = productDescDic["DynamicUOM"] as? Array<Dictionary<String,Any>>
                {
                    arrPrices = prices
                }
                else if let prices = productDescDic["Prices"] as? Array<Dictionary<String,Any>>
                {
                    arrPrices = prices
                }
                else if let prices = productDescDic["Prices"] as? Dictionary<String,Any>
                {
                    arrPrices = [prices]
                }
                
                
                if (arrPrices != nil), arrPrices!.count > 0
                {
                    var selectedIndex = 0
                    let testIndex = arrPrices?.index(where: { (testdic : Dictionary<String, Any>) -> Bool in
                        testdic["UOMID"] as? NSNumber == productDescDic["UOMID"] as? NSNumber
                    })
                    if (testIndex != nil) && (productDescDic["selectedIndex"] == nil)
                    {
                        productDescDic["selectedIndex"] = testIndex
                    }
                    
                    if let index = productDescDic["selectedIndex"] as? Int
                    {
                        selectedIndex = index
                    }
                    let objToFetch = arrPrices![selectedIndex]
                    if let price = objToFetch["Price"] as? Double
                    {
                        if AppFeatures.shared.shouldShowProductPrice //, let price = (productDescDic)["Price"] as? Double
                        {
                            let priceStr = String(format: "$%.2f", price)
                            cell.lblCompanyPrice.text = priceStr
                            cell.LblUomDescription.text = objToFetch["UOMDesc"] as? String
                        }
                        else
                        {
                            cell.lblCompanyPrice.text = ""
                            cell.LblUomDescription.text = objToFetch["UOMDesc"] as? String
                        }
                        if UserInfo.shared.isSalesRepUser == true{
                            
                            if objToFetch["IsSpecial"] as? Bool == true && objToFetch["IsPromotional"] as? Bool == true{
                                cell.lblCompanyPrice.textColor = UIColor.red
                            }
                            else if objToFetch["IsSpecial"] as? Bool == true{
                                cell.lblCompanyPrice.textColor = UIColor.red
                            }
                            else if objToFetch["IsPromotional"] as? Bool == true{
                                cell.lblCompanyPrice.textColor = UIColor.promotionalProductYellowColor()
                            }
                            else{
                                cell.lblCompanyPrice.textColor = UIColor.baseBlueColor()
                            }
                        }
                        else{
                            cell.lblCompanyPrice.textColor = UIColor.baseBlueColor()
                        }
                    }
                }
                else
                {
                    cell.lblCompanyPrice.text = ""
                    cell.LblUomDescription.text = productDescDic["UOMDesc"] as? String
                }
                
                if AppFeatures.shared.isShowSupplier == true
                {
                    cell.lblSupplierName.text = ((productDescDic["Supplier"] as? String) != "") ? (productDescDic["Supplier"] as? String) : "N/A"
                    cell.codeLeadingConstraint.constant = 10.0 * HorizontalSpacingConstraints.spacingConstant
                }
                else
                {
                    cell.lblSupplierName.text = ""
                    cell.codeLeadingConstraint.constant = 0.0
                }
                
                if let quantity = productDescDic["StockQuantity"] as? Double, quantity > 0.0 && AppFeatures.shared.shouldHighlightStock
                {
                    cell.btnAvailable.setTitle("", for: .normal)
                    cell.btnAvailable.setImage(#imageLiteral(resourceName: "check_available"), for: .normal)
                }
                else
                {
                    cell.btnAvailable.setTitle("", for: .normal)
                    cell.btnAvailable.setImage(#imageLiteral(resourceName: "NotAvailable"), for: .normal)
                }
                
                cell.btnShowQuantityPopup.tag = indexPath.row
                cell.btnShowQuantityPopup.addTarget(self, action: #selector(showQuantityPopupAction(_:)), for: .touchUpInside)
                
                cell.txtQuantity.delegate = self
                
                debugPrint("Price===",productDescDic["Quantity"])
                if productDescDic.keyExists(key: "Quantity"), let number = productDescDic["Quantity"] as? NSNumber, Float(truncating: number) != 0.0
                {
                    let quantityStr = ((Double(truncating: number))*100).rounded()/100 //"\(Int(truncating: number))"
                    cell.txtQuantity.text = String.init(format: "%.2f", quantityStr)  //"\(Double(truncating: number).rounded(toPlaces:2))"  //
                }
                else
                {
                    cell.txtQuantity.text = "1.00"
                }
                if AppFeatures.shared.isUserAllowedToAddItemsToPantryList == true
                {
                    if let isPantryItem =  productDescDic["IsInPantry"] as? Bool, isPantryItem == true
                    {
                        cell.btnAddToFavourite.isSelected = true
                    }
                    else
                    {
                        cell.btnAddToFavourite.isSelected = false
                    }
                    cell.favBtnWidthConstant.constant = 18.0
                }
                else{
                    cell.favBtnWidthConstant.constant = 0.0
                }
                
                if let isCartItem =  productDescDic["IsInCart"] as? Bool, isCartItem == true
                {
                    cell.btnAddToCart.isSelected = true
                }
                else
                {
                    cell.btnAddToCart.isSelected = false
                }
                
                if AppFeatures.shared.isItemEnquiryPopup == true
                {
                    cell.btnInfoEnquiry.isHidden = false
                    cell.btnInfoEnquiry.tintColor = UIColor.baseBlueColor()
                    cell.btnInfoEnquiry.addTarget(self, action: #selector(handleEnquiryPopupTap(_:)), for: UIControlEvents.touchDown)
                    cell.btnInfoEnquiry.tag = indexPath.row
                }
                else
                {
                    cell.btnInfoEnquiry.isHidden = true
                }
                
                
                if AppFeatures.shared.isDynamicUOM
                {
                    cell.btnChangeUOM.isHidden = false
                    cell.btnChangeUOM.tag = indexPath.row
                    cell.btnChangeUOM.addTarget(self, action: #selector(self.uOMChanged(sender:)), for: .touchUpInside)
                    if let obj = self.productList[indexPath.row]["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1
                    {
                        cell.arrowUOMDropdown.constant = 10.0
                    }
                    else
                    {
                        cell.arrowUOMDropdown.constant = 0.0
                    }
                }
                else
                {
                    cell.btnChangeUOM.removeTarget(self, action: nil, for: .allEvents)
                    cell.btnChangeUOM.isHidden = true
                }
                
                cell.productImage.tintColor = UIColor.baseBlueColor()
                if AppFeatures.shared.shoudlShowProductImages == true, let images = productDescDic["ProductImages"] as? Array<Dictionary<String,Any>>, images.count > 0
                {
                    let originalString:String = (images[0]["ImageName"]! as! String)
                    let urlString:String = originalString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
                    
                    cell.productImage.setImageWith(URL(string: urlString), placeholderImage: #imageLiteral(resourceName: "ImagePlaceholder"))
                }
                else
                {
                    cell.productImage.image = #imageLiteral(resourceName: "ImagePlaceholder")
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        let sizeHeight = (UIDevice.current.userInterfaceIdiom == .phone ? 120.0 :(98.0  * VerticalSpacingConstraints.spacingConstant))
        
        return CGSize(width: 0.95 * self.view.bounds.size.width, height: (sizeHeight) + 5)
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
                        print("\(productDescDic["ProductName"])!")
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
    
    //MARK: - Webservice Handling -
    
    
    func setPantryItemsSortOrder(reqArr:Array<Any>,pantryListId:NSNumber)
    {
        
        let requestParameter = ["PantryListID": pantryListId,
                                "ProductID": reqArr] as [String : Any]
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestParameter, strURL: SyncEngine.baseURL + SyncEngine.setPantryItemsSortOrder) { (response: Any) in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        }
    }
    
    func callSearchProductWebService(with searchText : String = "")
    {
        self.hideNoItemsLabel()
        let requestParameters = NSMutableDictionary()
        requestParameters.setValue(UserInfo.shared.customerID!, forKey: "CustomerID")
        requestParameters.setValue(((self.categoryId) != nil) ? self.categoryId : 0, forKey: "MainCategoryID")
        requestParameters.setValue(((self.subCategoryId) != nil) ? self.subCategoryId : 0, forKey: "SubCategoryID")
        requestParameters.setValue(self.filterID, forKey: "FilterID")
        requestParameters.setValue(searchText, forKey: "Searchtext")
        requestParameters.setValue(false, forKey: "IsSpecial")
        requestParameters.setValue(50, forKey: "PageSize")
        requestParameters.setValue(pageNumber-1, forKey: "PageIndex")
        
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
                    }
                    else
                    {
                        self.hideNoItemsLabel()
                    }
                    
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
                                if let btn = (self.filtersScrollView.viewWithTag(self.filterID as! Int)) as? UIButton
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
                                    label.center = centerPoint
                                    self.filtersScrollView.bringSubview(toFront: label)
                                    
                                }
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async(execute:
                    {
                        self.collectionView.reloadData()
                        self.callAllFiltersAPI()
                })
            }
            else
            {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.showNoItemsLabel()
                    
                   self.callAllFiltersAPI()
                }
            }
        }
    }
    
    func callAllFiltersAPI(){
        
        if self.arrFilters.count == 0 && AppFeatures.shared.isShowProductClasses && (self.isShowingFavoriteListing || self.isShowingDefaultPantryList)
        {
            self.getAllProductFilters()
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
                        button.setTitle((self.arrFilters[i]["FilterName"] as? String)?.uppercased(), for: .normal)
                        button.setTitleColor(UIColor.lightGray, for: .normal)
                        button.titleLabel?.font = UIFont.Roboto_Regular(baseScaleSize: 18.0)
                        button.sizeToFit()
                        button.frame = CGRect(x: x, y: 0, width: button.frame.size.width * 1.5, height: self.filtersScrollView.frame.size.height)
                        button.addTarget(self, action: #selector(self.handleFilterSelection(_:)), for: .touchUpInside)
                        button.setTitleColor(UIColor.white, for: .selected)
                        button.tag = ((self.arrFilters[i]["FilterID"] as? NSNumber) as! Int)
                        self.filtersScrollView.addSubview(button)
                        x = x + button.frame.size.width + 10
                        self.filtersScrollView.contentSize = CGSize(width: x, height: self.filtersScrollView.frame.size.height)
                        
                        if button.tag == 0
                        {
                            button.isSelected = true
                            button.backgroundColor = UIColor.baseBlueColor()
                        }
                    }
                }
            }
        }
    }
    
    
    func getAllDefaultPantryItems() -> Void
    {
        var requestParameters = Dictionary<String,Any>()
        requestParameters["PageSize"] = 50
        requestParameters["PageIndex"] = 0
        requestParameters["PantryListID"] = pantryListID
        requestParameters["FilterID"] = filterID
        requestParameters["ShowAll"] = true
        requestParameters["CustomerID"] = UserInfo.shared.customerID ?? "0"
        requestParameters["isRepUser"] = UserInfo.shared.isSalesRepUser
        
        /*   requestParameters.setValue(10, forKey: "PageSize")
         requestParameters.setValue(0, forKey: "PageIndex")
         requestParameters.setValue(pantryListID, forKey: "PantryListID")
         requestParameters.setValue(filterID, forKey: "FilterID")
         requestParameters.setValue(true, forKey: "ShowAll")
         requestParameters.setValue(UserInfo.shared.customerID, forKey:"CustomerID")
         requestParameters.setValue(UserInfo.shared.isSalesRepUser,  forKey:"isRepUser")*/
        
        let serviceURL = SyncEngine.baseURL + SyncEngine.GetDefaultPantry
        
        self.productList.removeAll()
        self.allPantryItems.removeAll()
        self.collectionView.reloadData()
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestParameters , strURL: serviceURL) { (response : Any) in
            if (response as? Dictionary<String,AnyObject>) != nil
            {
                if (response is Dictionary<String,Any>) && (response as! Dictionary<String,Any>).keyExists(key: "products"), let productListArray = (response as! Dictionary<String,Any>)["products"] as? Array<Dictionary<String,Any>>
                {
                    for object in productListArray
                    {
                        if self.allPantryItems.contains(where: { (dic: Dictionary<String,Any>) -> Bool in
                            object["ProductID"] as? NSNumber == object["ProductID"] as? NSNumber
                        }) == false
                        {
                            self.hideNoItemsLabel()
                            self.productList += productListArray
                            self.allPantryItems += productListArray
                        }
                    }
                    
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
                       self.callAllFiltersAPI()
                })
            }
                
            else
            {
                DispatchQueue.main.async(execute:
                    {
                        
                        self.callAllFiltersAPI()
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
                if let btn = (self.filtersScrollView.viewWithTag(self.filterID as! Int)) as? UIButton
                {
                    let centerPoint = CGPoint(x: btn.frame.maxX, y: btn.frame.minY)
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                    label.font = UIFont.SFUI_SemiBold(baseScaleSize: 12.0)
                    label.backgroundColor = UIColor.red
                    label.textColor = UIColor.white
                    label.text = "\(self.totalResults!)"
                    label.sizeToFit()
                    let expectedWidth = label.frame.size.width + 10.0
                    label.frame = CGRect(x: 0, y: 0, width: expectedWidth, height: expectedWidth)
                    label.layer.cornerRadius = expectedWidth/2.0
                    label.clipsToBounds = true
                    label.textAlignment = NSTextAlignment.center
                    self.filtersScrollView.addSubview(label)
                    label.center = centerPoint
                    //  self.view.sendSubview(toBack: self.filtersScrollView)
                    self.filtersScrollView.bringSubview(toFront: label)
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
    
    func checkMinAndMaxOrderQuantity(productValue : Dictionary<String, Any>, index : Int ,quantity:NSNumber){
        if UserInfo.shared.customerOnHoldStatus == true
        {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                return
            })
        }
        else{
            var productDetail = productValue
            if productDetail["Quantity"]  as? NSNumber == nil{
                productDetail["Quantity"] = 1.0
            }
            //            if productDetail["MinOQ"] as? NSNumber == 0.0{
            //               productDetail["MinOQ"] = 1.0
            //            }
            if AppFeatures.shared.isMinOrderQuantity == true && AppFeatures.shared.isMaxOrderQuantity == true {
                if Double(truncating: (productDetail["MinOQ"] as? NSNumber)!) > Double(truncating: (productDetail["Quantity"] as? NSNumber)!) && productDetail["MinOQ"] as? NSNumber != 0.0
                {
                    let msgString = "This item has a minimum order quantity of \( Int(truncating: (productDetail["MinOQ"] as? NSNumber)!)). \("Do you want to add") \( Int(truncating: (productDetail["MinOQ"] as? NSNumber)!)) \("units to cart ?")"
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                        self.productList[index]["Quantity"] = productDetail["MinOQ"]
                        // self.collectionView.reloadData()
                        //   product["Quantity"] = NSNumber(value: Int(circularPopup.txtFldQuantity.text!)!)
                        //self.productList[index] = product
                        self.addProductToCart(productDetail: self.productList[index], actualIndex: index)
                    })
                }
                else if Double(truncating: (productDetail["MaxOQ"] as? NSNumber)!) < Double(truncating: (productDetail["Quantity"] as? NSNumber)!) && productDetail["MaxOQ"] as? NSNumber != 0.0
                {
                    let msgString = "This item has a maximum order quantity of \( Int(truncating: (productDetail["MaxOQ"] as? NSNumber)!)). \("Do you want to add") \( Int(truncating: (productDetail["MaxOQ"] as? NSNumber)!)) \("units to cart ?")"
                    
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                        self.productList[index]["Quantity"] = productDetail["MaxOQ"]
                        // self.collectionView.reloadData()
                        self.addProductToCart(productDetail: self.productList[index], actualIndex: index)
                    })
                }
                else{
                    self.productList[index]["Quantity"] = quantity
                    self.addProductToCart(productDetail: productDetail, actualIndex: index)
                }
            }
            else if  AppFeatures.shared.isMinOrderQuantity == true {
                if Double(truncating: (productDetail["MinOQ"] as? NSNumber)!) > Double(truncating: (productDetail["Quantity"] as? NSNumber)!) && productDetail["MinOQ"] as? NSNumber != 0.0
                {
                    let msgString = "This item has a minimum order quantity of \( Int(truncating: (productDetail["MinOQ"] as? NSNumber)!)). \("Do you want to add") \( Int(truncating: (productDetail["MinOQ"] as? NSNumber)!)) \("units to cart ?")"
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                        self.productList[index]["Quantity"] = productDetail["MinOQ"]
                        //  self.collectionView.reloadData()
                        self.addProductToCart(productDetail: self.productList[index], actualIndex: index)
                    })
                }
                else if  AppFeatures.shared.isMaxOrderQuantity == true {
                    if Double(truncating: (productDetail["MaxOQ"] as? NSNumber)!) < Double(truncating: (productDetail["Quantity"] as? NSNumber)!) && productDetail["MaxOQ"] as? NSNumber != 0.0
                    {
                        let msgString = "This item has a maximum order quantity of \( Int(truncating: (productDetail["MaxOQ"] as? NSNumber)!)). \("Do you want to add") \( Int(truncating: (productDetail["MaxOQ"] as? NSNumber)!)) \("units to cart ?")"
                        
                        SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                            self.productList[index]["Quantity"] = productDetail["MaxOQ"]
                            // self.collectionView.reloadData()
                            self.addProductToCart(productDetail: self.productList[index], actualIndex: index)
                        })
                    }
                }
                else{
                    self.productList[index]["Quantity"] = quantity
                    self.addProductToCart(productDetail: productDetail, actualIndex: index)
                }
            }
            else if  AppFeatures.shared.isMaxOrderQuantity == true {
                if Double(truncating: (productDetail["MaxOQ"] as? NSNumber)!) < Double(truncating: (productDetail["Quantity"] as? NSNumber)!) && productDetail["MaxOQ"] as? NSNumber != 0.0
                {
                    let msgString = "This item has a maximum order quantity of \( Int(truncating: (productDetail["MaxOQ"] as? NSNumber)!)). \("Do you want to add") \( Int(truncating: (productDetail["MaxOQ"] as? NSNumber)!)) \("units to cart ?")"
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                        self.productList[index]["Quantity"] = productDetail["MaxOQ"]
                        // self.collectionVw_itemDescription.reloadData()
                        self.addProductToCart(productDetail:self.productList[index], actualIndex: index)
                    })
                }
                else{
                    self.productList[index]["Quantity"] = quantity
                    self.addProductToCart(productDetail: productDetail, actualIndex: index)
                }
            }
            else{
                self.productList[index]["Quantity"] = quantity
                self.addProductToCart(productDetail: productDetail, actualIndex: index)
            }
        }
    }
    
    func addProductToCart ( productDetail : Dictionary<String, Any>, actualIndex : Int = -1)
    {
        
        
        if UserInfo.shared.customerOnHoldStatus == true
        {
            //   return
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                return
            })
        }
        else{
            if Helper.shared.isDateSelected() == true
            {
                print(productDetail)
                var arrPrices : Array<Dictionary<String,Any>>?
                if let prices = productDetail["DynamicUOM"] as? Array<Dictionary<String,Any>>
                {
                    arrPrices = prices
                }
                else if var prices = productDetail["Prices"] as? Dictionary<String,Any>
                {
                    prices["UOMDesc"] = productDetail["UOMDesc"] as? String
                    prices["UOMID"] = productDetail["UOMID"] as? NSNumber
                    arrPrices = [prices]
                }
                var selectedIndex = 0
                
                if (arrPrices != nil), arrPrices!.count > 0
                {
                    let testIndex = arrPrices?.index(where: { (testdic : Dictionary<String, Any>) -> Bool in
                        testdic["UOMID"] as? NSNumber == productDetail["UOMID"] as? NSNumber
                    })
                    
                    if let index = productDetail["selectedIndex"] as? Int
                    {
                        selectedIndex = index
                    }
                    else if testIndex != nil
                    {
                        selectedIndex = testIndex!
                    }
                    let objToFetch = arrPrices![selectedIndex]
                    
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
                            "Quantity": (productDetail.keyExists(key: "Quantity") && productDetail["Quantity"] as? NSNumber != nil && Float(truncating: productDetail["Quantity"] as! NSNumber) != 0) ? (productDetail["Quantity"] as! NSNumber) : 1,
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
                        uomDesc = objToFetch["UOMDesc"] as! String
                        break
                    }
                    
                    
                    var startStr = "1 \(uomDesc)"
                    if Int(truncating: (requestDic["CartItem"] as! Dictionary<String,Any>)["Quantity"] as! NSNumber) > 1
                    {
                        startStr = "\((requestDic["CartItem"] as! Dictionary<String,Any>)["Quantity"] as! NSNumber) \(uomDesc)"
                    }
                    
                    SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestDic, strURL: serviceURL) { (response : Any) in
                        
                        if let isAlreadyInCart = self.productList[actualIndex]["IsInCart"] as? Bool, isAlreadyInCart == false
                        {
                            Helper.shared.showAlertOnController(controller: self , message: startStr + " added to cart successfully", title: productDetail["ProductName"] as! String
                            )
                        }
                        else
                        {
                            Helper.shared.showAlertOnController(controller: self , message: startStr + " updated in cart successfully", title: productDetail["ProductName"] as! String
                            )
                        }
                        
                        
                        if actualIndex > -1
                        {
                            self.productList[actualIndex]["IsInCart"] = true
                            
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        }
                        
                        self.callAPIToUpdateCartNumber()
                    }
                }
            }
            else
            {
                self.showDatePicker {
                    self.addProductToCart(productDetail: productDetail, actualIndex: actualIndex)
                    self.shouldRefereshProducts = true
                }
            }
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
                    if !(self.navigationItem.titleView is UISearchBar)
                    {
                        self.setDefaultNavigation()
                    }
                }
            }
        }
    }
    
    
    //    MARK: - Search Bar Delegate -
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        self.navigationItem.titleView = nil
        self.setDefaultNavigation()
        
        if self.isShowingDefaultPantryList
        {
            hideNoItemsLabel()
            self.productList = self.allPantryItems
            self.collectionView.reloadData()
            
        }else if isShowingFavoriteListing{
            
        }else{
            
            pageNumber = 1
            self.callSearchProductWebService()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if self.isShowingDefaultPantryList || self.isShowingFavoriteListing
        {
            if searchText == ""{
                
                hideNoItemsLabel()
                self.productList = self.allPantryItems
            }
            else{
                
                let filteredResults = self.allPantryItems.filter { (dic : Dictionary<String, Any>) -> Bool in
                    if let productname = dic["ProductName"] as? String, let productcode = dic["ProductCode"] as? String
                    {
                        return productname.lowercased().contains(searchText.lowercased()) || productcode.lowercased().contains(searchText.lowercased())
                    }
                    return false
                }
                if filteredResults.count==0{
                    
                    showNoItemsLabel()
                    self.productList = filteredResults
                }
                else{
                    
                    hideNoItemsLabel()
                    self.productList = filteredResults
                }
                
            }
            self.collectionView.reloadData()
        }
        else
        {
            if searchText == ""{
                
                hideNoItemsLabel()
                self.productList.removeAll()
                self.collectionView.reloadData()
            }
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        //        if self.isShowingDefaultPantryList
        //        {
        //            self.productList = self.allPantryItems
        //            self.collectionView.reloadData()
        //        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        if !isShowingFavoriteListing && !isShowingDefaultPantryList{
            
            pageNumber = 1
            self.callSearchProductWebService(with: searchBar.text!)
            searchBar.resignFirstResponder()
            
        }
        else{
            
            if isSearchingProduct == false{
                searchBar.resignFirstResponder()
            }
        }
    }
    
    //    MARK: - User Action Hanling -
    
    @objc func handleFilterSelection(_ sender : UIButton)
    {
        let isAlreadySelected : Bool = sender.isSelected
        
        if (sender.superview is UIScrollView) && isAlreadySelected == false
        {
            let parent = sender.superview as! UIScrollView
            
            for view in parent.subviews
            {
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
            if let searchBar = self.navigationItem.titleView as? UISearchBar
            {
                searchBar.text = ""
            }
            sender.isSelected = true
            sender.backgroundColor = UIColor.baseBlueColor()
            if isShowingDefaultPantryList
            {
                self.getAllDefaultPantryItems()
            }
            else if isShowingFavoriteListing
            {
                self.getAllDefaultPantryItems()
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
        
        if UIDevice.current.userInterfaceIdiom == .phone && UserInfo.shared.isSalesRepUser! &&  (isShowingDefaultPantryList && !isSearchingProduct)
        {
            self.navigationController?.navigationController?.popViewController(animated: true)
            
        }else{
            
            self.navigationController?.popViewController(animated: !isSearchingProduct)
        }
    }
    
    @objc func showQuantityPopupAction(_ sender : UIButton)
    {
        let index:Int = sender.tag
        
        if Helper.shared.isDateSelected() == true
        {
            self.addProductToCart(index:index)
        }
        else
        {
            self.showDatePicker {
                self.addProductToCart(index:index)
                self.shouldRefereshProducts = true
            }
        }
    }
    
    
    func addProductToCart(index:Int){
        
        var product = productList[index]
        if let circularPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "circularQuantityStoryboardID") as? CircularQuantityPopup
        {
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
                circularPopup.circularSlider.currentValue = 1.0
                circularPopup.showCommonAlertOnWindow
                    {
                        product["Quantity"] = NSNumber(value: Double(circularPopup.txtFldQuantity.text!)!)
                        //  self.productList[index.row] = product
                        
                        self.checkMinAndMaxOrderQuantity(productValue: product, index: index, quantity: NSNumber(value: Double(circularPopup.txtFldQuantity.text!)!))
                        
                        self.collectionView.reloadData()
                        //   self.addProductToCart(productDetail: product, actualIndex: index.row)
                }
            }
            
            if let bool = product["IsInCart"] as? Bool, bool == true
            {
                circularPopup.btnAddToCart.setTitle("UPDATE CART", for: .normal)
            }
            
        }
        
    }
    
    @objc func showSearchBar() -> Void
    {
        if isShowingDefaultPantryList == false
        {
            Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
        }
        else
        {
            Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .profileButton, onController: self)
        }
        self.navigationItem.rightBarButtonItems = nil
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        let cancelSearchBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(searchBarCancelButtonClicked(_:)))
        if self.isSearchingProduct == false
        {
            self.navigationItem.setRightBarButton(cancelSearchBarButtonItem, animated: true)
        }
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        self.navigationItem.titleView = searchBar
    }
    
    
    @objc func objTappedForDetails (_ sender : Any?) -> Void
    {
        if sender is UITapGestureRecognizer, let cell = (sender as! UITapGestureRecognizer).view?.superview?.superview as? DryOrdersCollectionCell
        {
            if let indexPath = self.collectionView.indexPath(for: cell)
            {
                let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderDescriptionView") as? OrderDescriptionView
                destinationViewController?.productID = (self.productList[indexPath.row]["ProductID"] as? NSNumber)!
                self.navigationController?.pushViewController(destinationViewController!, animated: true)
            }
        }
    }
    
    @objc func swipeMoved(sender : Any?) -> Void
    {
        if sender is UIPanGestureRecognizer, let gestureRecognizer = sender as? UIPanGestureRecognizer
        {
            if  gestureRecognizer.state == .changed {
                
                let translation = gestureRecognizer.translation(in: self.view)
                print(translation.x)
                if (gestureRecognizer.view?.frame.origin.x)! + translation.x > CGFloat(0)
                {
                    if ((gestureRecognizer.view?.center.x)! + translation.x) <  (gestureRecognizer.view?.bounds.width)!
                    {
                        UIView.transition(with: self.view, duration: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                            gestureRecognizer.view!.center = CGPoint(x: (gestureRecognizer.view!.center.x + translation.x) > (gestureRecognizer.view?.bounds.width)! ? (gestureRecognizer.view?.bounds.width)! : (gestureRecognizer.view!.center.x + translation.x) , y: gestureRecognizer.view!.center.y )
                        }, completion: { (finished: Bool) -> () in
                            
                            // completion
                            
                        })
                    }
                    gestureRecognizer.view?.superview?.backgroundColor = UIColor.addToCartGreenColor()
                }
                else
                {
                    if AppFeatures.shared.isUserAllowedToAddItemsToPantryList == true
                    {
                        gestureRecognizer.view?.superview?.backgroundColor = UIColor.baseBlueColor()
                        if (gestureRecognizer.view?.center.x)! > 0.0
                        {
                            UIView.transition(with: self.view, duration: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                                gestureRecognizer.view!.center = CGPoint(x: (gestureRecognizer.view!.center.x + translation.x) < 0.0 ? 0.0 : (gestureRecognizer.view!.center.x + translation.x) , y: gestureRecognizer.view!.center.y )
                            }, completion: { (finished: Bool) -> () in
                                // completion
                            })
                        }
                    }
                }
            }
            else if gestureRecognizer.state == .ended
            {
                if (gestureRecognizer.view?.frame.minX)! > (((gestureRecognizer.view?.frame.size.width)! - (gestureRecognizer.view?.frame.size.width)!/2.0) - 20.0)
                {
                    print("add to cart.")
                    
                    if gestureRecognizer.view?.superview?.superview is DryOrdersCollectionCell
                    {
                        let cell = gestureRecognizer.view?.superview?.superview as! DryOrdersCollectionCell
                        let obj = self.productList[(collectionView.indexPath(for: cell)?.row)!]
                        if obj["IsAvailable"] as? Bool == true
                        {
                            self.checkMinAndMaxOrderQuantity(productValue: obj, index: (collectionView.indexPath(for: cell)?.row)!, quantity: (obj["Quantity"] as? NSNumber) ?? 1.0)
                        }
                        else{
                            Helper.shared.showAlertOnController(controller: self, message: "Product is not available", title: CommonString.alertTitle)
                        }
                    }
                }
                else if (gestureRecognizer.view?.frame.minX)! < ((0.0 - (gestureRecognizer.view?.frame.size.width)!/2.0) + 20.0)
                {
                    print("add to fav")
                    let cell = gestureRecognizer.view?.superview?.superview as! DryOrdersCollectionCell
                    let obj = self.productList[(collectionView.indexPath(for: cell)?.row)!]
                    if let proId = obj["ProductID"] as? NSNumber
                    {
                        
                        if UserInfo.shared.customerOnHoldStatus == true
                        {
                            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                                return
                            })
                        }
                        else{
                            self.addProductToFavoriteList(productID: proId, index: (collectionView.indexPath(for: cell)?.row)!)
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
    }
    
    
    func showDatePicker(withCompletion completion : @escaping dateSelectionCompleted) -> Void
    {
        if Helper.shared.isDateSelected() == false
        {
            if let orderDatePicker = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "datePickerStoryID") as? DatePickerView
            {
                self.shouldRefereshProducts = false
                self.present(orderDatePicker, animated: false, completion: nil)
                orderDatePicker.completionBlock = {
                    completion()
                }
            }
            return
        }
    }
    
    func addProductToFavoriteList(productID : NSNumber,index:Int)
    {
        if self.isAddingItemToDefaultPantry == false
        {
            if let chooseFavorite = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "choosefavouriteListPopupStoryboardIdentifier") as? ChooseFavouriteListPopup
            {
                chooseFavorite.productID = productID
                chooseFavorite.productID = productID
                chooseFavorite.showCommonAlertOnWindow(completion: { (isFav : Bool) in
                    self.productList[index]["IsInPantry"] = isFav
                    self.collectionView.reloadData()
                })
            }
        }
        else
        {
            self.addItemToDefaultPantry(productID: productID, index: index)
        }
    }
    
    func addItemToDefaultPantry(productID : NSNumber? ,index:Int)
    {
        if productID != nil
        {
            let requestObj = [
                "PantryListID": 0,
                "ProductID": productID!,
                "Quantity": 1,
                "CustomerID" :UserInfo.shared.customerID!
                ] as [String:Any]
            
            let serviceURL = SyncEngine.baseURL + SyncEngine.addItemToPantryList
            SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestObj, strURL: serviceURL) { (response : Any) in
                DispatchQueue.main.async {
                    //  Helper.shared.showAlertOnController(controller: self, message: "Product added successfully.", title: CommonString.app_name)
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: "Product added successfully.", withCancelButtonTitle: "OK", completion: {
                        AppFeatures.shared.isProductAdded = true
                        self.productList[index]["IsInPantry"] = true
                        self.collectionView.reloadData()
                        
                    })
                }
            }
        }
        else
        {
            Helper.shared.showAlertOnController(controller: self, message: "Please choose favourite list.", title: CommonString.alertTitle)
        }
    }
    
    @objc func copyPantryListAction()
    {
        if UserInfo.shared.customerOnHoldStatus==true {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                return
            })
        }
        else{
            if let favorietController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addFavoriteListPopupSroryID") as? AddFavoriteListView
            {
                favorietController.parentController = self
                favorietController.isCopyingExistingPantry = true
                favorietController.isCreatedByRepUser = false
                if Int(truncating: self.pantryListID) > 0
                {
                    favorietController.pantryListToBeCopiedId = pantryListID
                    UIApplication.shared.keyWindow?.rootViewController?.present(favorietController, animated: false, completion: nil)
                }
                else
                {
                    if self.productList.count > 0 , let pantryid = self.productList[0]["PantryListID"] as? NSNumber
                    {
                        if AppFeatures.shared.isNonFoodVersion
                        {
                            favorietController.titleOfPopup = "Please enter new name for copied favourite list."
                        }
                        else
                        {
                            favorietController.titleOfPopup = "Please enter new name for copied pantry list."
                        }
                        favorietController.pantryListToBeCopiedId = pantryid
                        UIApplication.shared.keyWindow?.rootViewController?.present(favorietController, animated: false, completion: nil)
                    }
                    else
                    {
                        if AppFeatures.shared.isNonFoodVersion == true
                        {
                            Helper.shared.showAlertOnController(controller: self, message: "Could not copy empty favourite list.", title: CommonString.alertTitle)
                        }
                        else
                        {
                            Helper.shared.showAlertOnController(controller: self, message: "Could not copy empty pantry list.", title: CommonString.alertTitle)
                        }
                    }
                }
                
                
            }
        }
    }
    
    @objc func handleEnquiryPopupTap(_ button : UIButton) -> Void
    {
        if UserInfo.shared.customerOnHoldStatus==true {
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
        if UserInfo.shared.customerOnHoldStatus==true {
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
            Helper.shared.showAlertOnController(controller: self, message: "Order deleted successfully.", title: CommonString.app_name)
            DispatchQueue.main.async {
                self.setDefaultNavigation()
            }
        }
    }
    
    
    @objc func showLatestSpecialsAction()
    {
        if let walkthrough = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Walkthrough.storyboardID) as? Walkthrough
        {
            walkthrough.isShowingLatestSpecial = true
            self.navigationController?.tabBarController?.navigationController?.pushViewController(walkthrough, animated: true)
        }
    }
    
    func deleteOrderFromServer()
    {
        SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: "Delete saved order?", withSuccessButtonTitle: "Yes", withMessage: "Are you sure you want to delete saved order. This cannot be undone.", withCancelButtonTitle: "No")
        {
            
        }
    }
    
    @IBAction func addItemToDefaultPantryAction(_ sender: Any)
    {
        if UserInfo.shared.customerOnHoldStatus==true {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                return
            })
        }
        else{
            if let categoryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "categorySelectionVCStoryID") as? CategorySelectionVC
            {
                categoryVC.isAddingToDefaultPantry = AppFeatures.shared.isUserAllowedToAddItemsToDefaultPantry
                self.navigationController?.pushViewController(categoryVC, animated: true)
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
        switch(gesture.state) {
            
        case .began:
            guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
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
            pageNumber += 1
            var searchText = ""
            if self.navigationItem.titleView is UISearchBar
            {
                searchText = (self.navigationItem.titleView as! UISearchBar).text!
            }
            if !self.isShowingDefaultPantryList && !self.isShowingFavoriteListing
            {
                self.callSearchProductWebService(with: searchText)
            }
        }
    }
    
    
    //    MARK:- Text Field Delegation -
    
    @objc func showCartScreen() -> Void
    {
        if UserInfo.shared.customerOnHoldStatus==true {
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
 
 //MARK: -
 class DryOrdersCollectionCell : UICollectionViewCell
 {
    @IBOutlet weak var LblUomDescription: UILabel!
    @IBOutlet weak var lblCompanyPrice: UILabel!
    @IBOutlet weak var lblDryOrder : UILabel!
    @IBOutlet weak var lblSupplierName: UILabel!
    @IBOutlet weak var productCode: UILabel!
    @IBOutlet weak var btnAvailable: UIButton!
    @IBOutlet weak var txtQuantity: UITextField!
    @IBOutlet weak var btnAddToFavourite: UIButton!
    @IBOutlet weak var btnIncreaseQuantity: UIButton!
    @IBOutlet weak var productImage: UIImageView!
    //    @IBOutlet weak var lblDescriptionOfProduct: UILabel!
    @IBOutlet weak var btnAddToCart: UIButton!
    //    @IBOutlet weak var lblStock: UILabel!
    @IBOutlet weak var containerView: UIView!
    //    @IBOutlet weak var weekHistoryCollectionView: UICollectionView!
    @IBOutlet weak var btnInfoEnquiry: UIButton!
    @IBOutlet weak var btnChangeUOM: UIButton!
    @IBOutlet weak var btnShowQuantityPopup: UIButton!
    //    @IBOutlet weak var dropDownArrow: UIButton!
    @IBOutlet weak var codeLeadingConstraint: HorizontalSpacingConstraints!
    @IBOutlet weak var arrowUOMDropdown: NSLayoutConstraint!
    @IBOutlet weak var imageWidthConstant: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var favBtnWidthConstant: NSLayoutConstraint!
    @IBOutlet weak var availImgWidthConstant: NSLayoutConstraint!
    
    @IBOutlet weak var availTrailingConstant: HorizontalSpacingConstraints!
    
    var parentView : OrderVC?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addShadowToCell()
        self.adjustFontSizeAsPerScreen()
    }
    
    
    func addShadowToCell(){
        
        self.contentView.layer.cornerRadius = 2.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        self.layer.shadowRadius = 3.0
        self.layer.shadowOpacity = 0.2
        self.layer.masksToBounds = false
    }
    
    
    func adjustFontSizeAsPerScreen() -> Void
    {
        self.lblDryOrder.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
        self.lblCompanyPrice.font = UIFont.SFUI_SemiBold(baseScaleSize: 18.0)
        
        self.lblSupplierName.font = UIFont.SFUI_Regular(baseScaleSize: 15.0)
        self.productCode.font = UIFont.SFUI_Regular(baseScaleSize: 15.0)
        self.LblUomDescription.font = UIFont.SFUI_Regular(baseScaleSize: 15.0)
        
        self.btnAvailable.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 14.0)
        self.btnIncreaseQuantity.titleLabel?.font = UIFont.Roboto_Medium(baseScaleSize: 13.0)
        /*self.btnDecreaseQuantity.titleLabel?.font = UIFont.Roboto_Medium(baseScaleSize: 10.0)*/
        
        self.txtQuantity.font = UIFont.Roboto_Medium(baseScaleSize: 15.0)
        
        self.txtQuantity.layer.borderWidth = 1.0
        self.btnIncreaseQuantity.layer.borderWidth = 1.0
        self.btnIncreaseQuantity.layer.borderColor = UIColor.baseBlueColor().cgColor
        self.txtQuantity.layer.borderColor = UIColor.baseBlueColor().cgColor
        self.btnIncreaseQuantity.backgroundColor = UIColor.baseBlueColor()
        self.btnIncreaseQuantity.setTitleColor(UIColor.white, for: .normal)
        
        if AppFeatures.shared.shoudlShowProductImages == false
        {
            self.removeConstraint(imageWidthConstant)
            self.removeConstraint(imageHeightConstraint)
            self.addConstraint(NSLayoutConstraint(item: productImage, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0))
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
 

 
 extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
 }
