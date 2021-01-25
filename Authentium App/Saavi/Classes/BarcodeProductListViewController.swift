//
//  BarcodeProductListViewController.swift
//  Saavi
//
//  Created by gomad on 20/05/19.
//  Copyright © 2019 Saavi. All rights reserved.
//

import UIKit
import Lightbox

protocol BarcodeListProtocols {
    func productFound(status:Bool)
}

class BarcodeProductListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var collectionView: UICollectionView!
    var productList = Array<Dictionary<String,Any>>()
    var thumbImage = #imageLiteral(resourceName: "ImagePlaceholder")
//    @IBOutlet weak var filtersScrollView: UIScrollView!
    var categoryId : NSNumber?
    var subCategoryId : NSNumber?
    var delegate:BarcodeListProtocols?
    var isShowingDefaultPantryList : Bool = true
    var isShowingFavoriteListing : Bool = false
    var filterID : NSNumber = 0
    var totalResults : NSNumber?
    var pantryListID : NSNumber = 0
    var screenTitle : String = ""
    var productId:String = ""
    @IBOutlet weak var pantryFiltersHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomLayoutContraint: NSLayoutConstraint!
    var pageNumber : Int = 1
    var defaultPantryPageNumber : Int = 1
    var txtFldActive = UITextField()
    @IBOutlet weak var btnAddItemsToDefaultPantry: CustomButton!
    
    //MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotificationPlaceOrder(notification:)), name: Notification.Name("UpdateCart"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotificationPlaceOrder(notification:)), name: Notification.Name("addToCart"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotificationPlaceOrder(notification:)), name: Notification.Name("UpdateSpecialPrice"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotificationPlaceOrder(notification:)), name: Notification.Name("placeOrder"), object: nil)
        self.navigationItem.hidesBackButton = true
        self.setDefaultNavigation()
        self.collectionView.register(UINib.init(nibName: "OrderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "OrderCollectionViewCell")
        callSearchProductWebService(with: self.productId.trimmingCharacters(in: .whitespacesAndNewlines))
        self.collectionView.reloadData()
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
        if notification.name.rawValue == "placeOrder" || notification.name.rawValue == "UpdateSpecialPrice" || notification.name.rawValue == "addToCart" || notification.name.rawValue == "UpdateCart"{
            
            DispatchQueue.main.async {
                if self.isShowingDefaultPantryList || self.isShowingFavoriteListing{
                    self.defaultPantryPageNumber = 1
                }
            }
        }
    }
    
    func setDefaultNavigation() -> Void
    {
        Helper.shared.setNavigationTitle(withTitle : "" ,withLeftButton :.backButton, onController: self)
        Helper.shared.setNavigationTitle(viewController: self, title: "Product Search")
    }
    
    override func viewWillLayoutSubviews() {
        //navigationController?.navigationBar.isTranslucent = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(OrderVC.refreshCount), name: NSNotification.Name(rawValue: "cartCountChanged"), object: nil)
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
        let cell : OrderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderCollectionViewCell", for: indexPath) as! OrderCollectionViewCell
        
        cell.showData(productList: self.productList, index: indexPath.item)
        
        cell.btnZoomThumbnail.tag = indexPath.item
        cell.btnZoomThumbnail.addTarget(self, action: #selector(self.btnZoomImageAction(_:)), for: .touchUpInside)
        cell.btnAddToFavourite.tintColor = UIColor.baseBlueColor()
        cell.txtQuantity.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonClicked))
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.swipeMoved))
        panGesture.delegate = self
        cell.containerView.addGestureRecognizer(panGesture)
        
        cell.imgVwMove.isHidden = true
        cell.cnstBtnMoveWidth.constant = 0.0
        
        if AppFeatures.shared.shouldShowLongDetail{
            let tapRecog = UITapGestureRecognizer(target: self, action: #selector(self.objTappedForDetails(_:)))
            tapRecog.delegate = self
            cell.lblDryOrder.addGestureRecognizer(tapRecog)
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
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        let sizeHeight = (UIDevice.current.userInterfaceIdiom == .phone ? 140.0 :(115.0  * VerticalSpacingConstraints.spacingConstant))
        
        return CGSize(width: 0.95 * self.view.bounds.size.width, height: (sizeHeight) + 10)
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
    
    func callSearchProductWebService(with searchText : String = "")
    {
        self.hideNoItemsLabel()
        let requestParameters = NSMutableDictionary()
        requestParameters.setValue(UserInfo.shared.customerID!, forKey: "CustomerID")
        requestParameters.setValue(UserInfo.shared.customerID!, forKey: "listCustomerId")
        requestParameters.setValue(((self.categoryId) != nil) ? self.categoryId : 0, forKey: "MainCategoryID")
        requestParameters.setValue(((self.subCategoryId) != nil) ? self.subCategoryId : 0, forKey: "SubCategoryID")
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
//                        self.showNoItemsLabel()
                        self.delegate?.productFound(status: false)
                    }
                    else
                    {
                        self.delegate?.productFound(status: true)
                        self.hideNoItemsLabel()
                    }
                    
                    if (response as! Dictionary<String,Any>).keyExists(key: "TotalResults"), let totalResults = (response as! Dictionary<String,Any>)["TotalResults"] as? NSNumber
                    {
                        self.totalResults = totalResults
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
                    self.delegate?.productFound(status: false)
//                    self.collectionView.reloadData()
//                    self.showNoItemsLabel()
//                    self.totalResults = 0
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
        
        /*   requestParameters.setValue(10, forKey: "PageSize")
         requestParameters.setValue(0, forKey: "PageIndex")
         requestParameters.setValue(pantryListID, forKey: "PantryListID")
         requestParameters.setValue(filterID, forKey: "FilterID")
         requestParameters.setValue(true, forKey: "ShowAll")
         requestParameters.setValue(UserInfo.shared.customerID, forKey:"CustomerID")
         requestParameters.setValue(UserInfo.shared.isSalesRepUser,  forKey:"isRepUser")*/
        
        let serviceURL = SyncEngine.baseURL + SyncEngine.GetDefaultPantry
        
        if defaultPantryPageNumber == 1{
            
            self.productList.removeAll()
            //self.allPantryItems.removeAll()
            self.collectionView.reloadData()
            
        }
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestParameters , strURL: serviceURL) { (response : Any) in
            if (response as? Dictionary<String,AnyObject>) != nil
            {
                if (response is Dictionary<String,Any>) && (response as! Dictionary<String,Any>).keyExists(key: "products"), let productListArray = (response as! Dictionary<String,Any>)["products"] as? Array<Dictionary<String,Any>>
                {
                    //                    for object in productListArray
                    //                    {
                    //                        if self.allPantryItems.contains(where: { (dic: Dictionary<String,Any>) -> Bool in
                    //                            object["ProductID"] as? NSNumber == object["ProductID"] as? NSNumber
                    //                        }) == false
                    //                        {
                    self.hideNoItemsLabel()
                    self.productList += productListArray
                    //self.allPantryItems += productListArray
                    //                        }else{
                    //
                    //                            self.hideNoItemsLabel()
                    //                            self.productList += productListArray
                    //                            self.allPantryItems += productListArray
                    //                        }
                    //}
                    
                    if (response as! Dictionary<String,Any>).keyExists(key: "TotalResults"), let totalResults = (response as! Dictionary<String,Any>)["TotalResults"] as? NSNumber
                    {
                        self.totalResults = totalResults
//                        DispatchQueue.main.async {
//
//                            if (self.filtersScrollView.viewWithTag(self.filterID as! Int) != nil)
//                            {
//                                for label in self.filtersScrollView.subviews
//                                {
//                                    if label is UILabel
//                                    {
//                                        label.removeFromSuperview()
//                                    }
//                                }
//                            }
//                        }
                    }
                }
                DispatchQueue.main.async(execute:
                    {
                        if let savedOrderId = ((response as? Dictionary<String,Any>)?["SavedOrder"]) as? NSNumber, Int(truncating: savedOrderId) > 0
                        {
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
//                        for label in self.filtersScrollView.subviews
//                        {
//                            if label is UILabel
//                            {
//                                label.removeFromSuperview()
//                            }
//                        }
                        self.collectionView.reloadData()
                })
            }
//            DispatchQueue.main.async {
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
//            }
        }
    }
    
    func showNoItemsLabel()
    {
        DispatchQueue.main.async
            {
                if self.view.viewWithTag(57) == nil
                {
                    let label = Helper.shared.createLabelWithMessage(message: "Product is not available.")
                    label.tag = 57
                    label.center = CGPoint.init(x: self.view.center.x, y: 50)
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
                    
                    if true
                    {
                        self.showBuyInPopup(productDetail: productDetail, actualIndex: actualIndex)
                        
                    }
                    else
                    {
                        self.showDeliveryTypePopup {
                            self.showBuyInPopup(productDetail: productDetail, actualIndex: actualIndex)
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
                                        self.checkOrderMultiplies(productDetail: product, actualIndex: actualIndex)
                                        break
                                    }
                                }
                            }
                        }
                    }
                }else {
                    
                    buyInPopup.showCommonAlertOnWindow(withTitle: "Important", withSuccessButtonTitle: "", withMessage: "Your order quantity is greater than  the stock on hand quantity of \(sohValue). Only the available quantity will be added to the cart.", withCancelButtonTitle: "Ok") {
                        
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

        if AppFeatures.shared.isOrderMultiples && arrayUomEach.contains((uomName?.uppercased())!.trimmingCharacters(in: .whitespacesAndNewlines)) {

            productDict["Quantity"] = unitToBedded
            DispatchQueue.main.async {
//                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: "This item can only be ordered in multiples of \(quantityPerUnit). We are adding \(unitToBedded.cleanValue) to the cart.", withCancelButtonTitle: "OK", completion: {

                    self.addProductToCart(productDetail: productDict, actualIndex: actualIndex)
//                })
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

        let objToFetch =  Helper.shared.getSelectedUOM(productDetail: productDetail)
        
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
        if Int(truncating: (requestDic["CartItem"] as! Dictionary<String,Any>)["Quantity"] as! NSNumber) > 1
        {
            let qtyStr = ((requestDic["CartItem"] as! Dictionary<String,Any>)["Quantity"] as! Double).cleanValue
            startStr = "\nOrder Qty: \(qtyStr)\nUOM: \(uomDesc)\n"
        }
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestDic, strURL: serviceURL) { (response : Any) in
            
            if let isAlreadyInCart = self.productList[actualIndex]["IsInCart"] as? Bool, isAlreadyInCart == false
            {
//                Helper.shared.showAlertOnController( message: startStr + " added to cart successfully", title: productDetail["ProductName"] as! String,hideOkayButton: true
                Helper.shared.showAlertOnController(message:"Added to cart successfully", title: "",hideOkayButton: true

                    
                )
                Helper.shared.dismissAddedToCartAlert()
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else
            {
//                Helper.shared.showAlertOnController(message: startStr + " updated in cart successfully", title: productDetail["ProductName"] as! String,hideOkayButton: true
                Helper.shared.showAlertOnController(message:"Updated in cart successfully", title: "",hideOkayButton: true

                )
                Helper.shared.dismissAddedToCartAlert()
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
                
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
            NotificationCenter.default.post(name:NSNotification.Name(rawValue: "addToCart"), object: nil)
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
       
        if self.isShowingDefaultPantryList || self.isShowingFavoriteListing
        {
            hideNoItemsLabel()
            //Check Once
            defaultPantryPageNumber = 1
            //self.getAllDefaultPantryItems(searchText: self.searchBar.text ?? "")
            
        }else{
            
            pageNumber = 1
            self.callSearchProductWebService()
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
       // self.isSearchingProduct = true
        /*if self.isShowingDefaultPantryList || self.isShowingFavoriteListing
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
         }*/
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
            
            defaultPantryPageNumber = 1
            self.getAllDefaultPantryItems(searchText:searchBar.text!)
            searchBar.resignFirstResponder()
            //            if isSearchingProduct == false{
            //                searchBar.resignFirstResponder()
            //            }
        }
    }
    
    //    MARK: - User Action Hanling -
    
    
    @objc func backBtnAction() -> Void
    {
//        if (isShowingDefaultPantryList && AppFeatures.shared.isParent && UserInfo.shared.isParent){
//
//            ChildListWireframe.makeChildListAsRoot()
//
//        }else if UIDevice.current.userInterfaceIdiom == .phone && UserInfo.shared.isSalesRepUser!{
//
//            self.navigationController?.navigationController?.popViewController(animated: true)
//
//        }else{
//
            self.navigationController?.popViewController(animated: true)
//        }
        
    }
    
    @objc func showQuantityPopupAction(_ sender : UIButton)
    {
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
                    //self.collectionView.isScrollEnabled = false
                    self.txtFldActive = cell.txtQuantity
                    self.txtFldActive.text = ""
                }
            }
            else
            {
                self.showDeliveryTypePopup {
                    
                    if AppFeatures.shared.IsShowQuantityPopup == true{
                        self.addProductToCart(index:index)
                       // self.shouldRefereshProducts = true
                    }
                    else{
                        let indexPath = IndexPath(item: index, section: 0)
                        
                        let cell = self.collectionView?.cellForItem(at: indexPath) as! OrderCollectionViewCell
                        cell.txtQuantity.becomeFirstResponder()
                        //self.collectionView.isScrollEnabled = false
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
                //self.collectionView.isScrollEnabled = false
            }
        }
    }
    
    
    func addProductToCart(index:Int){
        
        var product = productList[index]

        if let circularPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "circularQuantityStoryboardID") as? CircularQuantityPopup
        {
            circularPopup.quantityPerUnit = Helper.shared.getSelectedUomNameQuantity(product: product).quantity
            circularPopup.isEach =  Helper.shared.getSelectedUomNameQuantity(product: product).isEach
            
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
                circularPopup.circularSlider.currentValue = AppFeatures.shared.IsAllowDecimal ? 1.00: UserInfo.shared.isSalesRepUser! ? 1.00:1
                circularPopup.showCommonAlertOnWindow
                    {
                        product["Quantity"] = NSNumber(value: Double(circularPopup.txtFldQuantity.text!)!)
                        
                        self.checkMinAndMaxOrderQuantity(productValue: product, index: index, quantity: NSNumber(value: Double(circularPopup.txtFldQuantity.text!)!))
                        self.collectionView.reloadData()
                }
            }
            
            if let bool = product["IsInCart"] as? Bool, bool == true
            {
                circularPopup.btnAddToCart.setTitle("UPDATE CART", for: .normal)
            }
        }
    }
    
    @objc func objTappedForDetails (_ sender : Any?) -> Void
    {
        if sender is UITapGestureRecognizer, let cell = (sender as! UITapGestureRecognizer).view?.superview?.superview?.superview as? OrderCollectionViewCell
        {
            if let indexPath = self.collectionView.indexPath(for: cell)
            {
                let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderDescriptionView") as? OrderDescriptionView
                destinationViewController?.productID = (self.productList[indexPath.row]["ProductID"] as? NSNumber)!
                destinationViewController?.isMoveBack = true
                self.navigationController?.pushViewController(destinationViewController!, animated: true)
            }
        }
    }
    
    @objc func swipeMoved(_ gestureRecognizer : UIPanGestureRecognizer) -> Void
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
                gestureRecognizer.view?.superview?.backgroundColor = UIColor.primaryColor()
            }
            else
            {
                if AppFeatures.shared.isUserAllowedToAddItemsToPantryList == true
                {
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
            }
        }
        else if gestureRecognizer.state == .ended
        {
            if (gestureRecognizer.view?.frame.minX)! > (((gestureRecognizer.view?.frame.size.width)! - (gestureRecognizer.view?.frame.size.width)!/2.0) - 20.0)
            {
                print("add to cart.")
                
                if gestureRecognizer.view?.superview?.superview is OrderCollectionViewCell
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
            else if (gestureRecognizer.view?.frame.minX)! < ((0.0 - (gestureRecognizer.view?.frame.size.width)!/2.0) + 20.0)
            {
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
              //  self.shouldRefereshProducts = false
                orderDatePicker.modalPresentationStyle = .overCurrentContext
                self.present(orderDatePicker, animated: false, completion: nil)
                orderDatePicker.completionBlock = { (buttonPressed) -> Void in
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
    
    @IBAction func addItemToDefaultPantryAction(_ sender: Any)
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
            if let categoryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "categorySelectionVCStoryID") as? CategorySelectionVC
            {
                categoryVC.isAddingToDefaultPantry = AppFeatures.shared.isUserAllowedToAddItemsToDefaultPantry
                self.navigationController?.pushViewController(categoryVC, animated: true)
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
        
        if self.isShowingFavoriteListing == true{
            
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: "Do you want to delete this product?", withCancelButtonTitle: "No", completion: {
                
                self.removeItemFromFavoriteList(indexPath: indexPath!)
            })
            
        }else{
            
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
            defaultPantryPageNumber += 1
            var searchText = ""
            
            if self.navigationItem.titleView is UISearchBar
            {
                searchText = (self.navigationItem.titleView as! UISearchBar).text!
            }
            if !self.isShowingDefaultPantryList && !self.isShowingFavoriteListing
            {
                
                self.callSearchProductWebService(with: searchText)
            }else if self.isShowingDefaultPantryList || self.isShowingFavoriteListing{
                
                self.getAllDefaultPantryItems(searchText: searchText)
            }
        }
    }
    
    @objc func doneButtonClicked(_ textField: UITextField) {
        
       // self.collectionView.isScrollEnabled = true
        if textField == txtFldActive{
            var product = self.productList[textField.tag]
            
            let qtyDoubleValue:Double = (textField.text?.isEmpty)! ? 1.00:Double(textField.text!)!
            let qtyValue = qtyDoubleValue <= 0 ? 1.00:qtyDoubleValue
            product["Quantity"] = NSNumber(value: qtyValue)
            self.productList[textField.tag] = product
            product = self.productList[textField.tag]
            self.checkMinAndMaxOrderQuantity(productValue: product, index: textField.tag, quantity: NSNumber(value:qtyValue))
            //self.addProductToCartwithDatePicker(productDetail: product, actualIndex: textField.tag)
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //self.collectionView.isScrollEnabled = true
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
        else if UserInfo.shared.customerOnHoldStatus==true && !AppFeatures.shared.isAllowOnHoldPlacingOrder {
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


extension BarcodeProductListViewController: LightboxControllerPageDelegate {
    
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        
    }
}


extension BarcodeProductListViewController: LightboxControllerDismissalDelegate{
    
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
    }
}


