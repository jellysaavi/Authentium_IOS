//
//  WhatsNewVC.swift
//  Saavi
//
//  Created by goMad Infotech on 16/07/19.
//  Copyright © 2019 Saavi. All rights reserved.
//

import UIKit
import Lightbox

class WhatsNewVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UITextFieldDelegate{
    static let storyboardID = "WhatsNewVCStoryboardId"

    @IBOutlet weak var collectionView: UICollectionView!
    var thumbImage = #imageLiteral(resourceName: "ImagePlaceholder")
    var menuController : MenuHierarchyHandler?
    var pantryListID : NSNumber = 0
    @IBOutlet weak var bottomLayoutContraint: NSLayoutConstraint!
    var pageNumber : Int = 1
    var txtFldActive = UITextField()
    @IBOutlet weak var btnAddItemsToDefaultPantry: CustomButton!
    var arrLatestSpecial = Array<Dictionary<String,Any>>()
    var isFromTab:Bool = true
    //MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false

        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotificationPlaceOrder(notification:)), name: Notification.Name("UpdateCart"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotificationPlaceOrder(notification:)), name: Notification.Name("addToCart"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotificationPlaceOrder(notification:)), name: Notification.Name("UpdateSpecialPrice"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotificationPlaceOrder(notification:)), name: Notification.Name("placeOrder"), object: nil)
        self.navigationItem.hidesBackButton = true
        self.setDefaultNavigation()

        self.collectionView.register(UINib.init(nibName: "OrderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "OrderCollectionViewCell")
        self.callLatestSpecialWebService()
        self.callAPIToUpdateCartNumber()
    }
    
    @objc func methodOfReceivedNotification(notification: Notification){
        
        if arrLatestSpecial.count>0{
            for i in 0..<arrLatestSpecial.count{
                var dict = arrLatestSpecial[i]
                if dict["ProductID"] as? NSNumber == notification.userInfo!["ProductID"] as? NSNumber{
                    if notification.name.rawValue == "UpdateCart"{
                        dict["Quantity"] = "0.0"
                        dict["IsInCart"] = false
                    }else if notification.name.rawValue == "addToCart"{
                        dict["Quantity"] = notification.userInfo!["Quantity"]!
                        dict["IsInCart"] = true
                        dict["UOMID"] = notification.userInfo!["UOMID"] as? NSNumber
                    }
                    arrLatestSpecial[i] = dict
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    @objc func methodOfReceivedNotificationPlaceOrder(notification: Notification){
       
    }
    
    func setDefaultNavigation() -> Void{
        
        if !isFromTab{
            
            Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
        }
        self.navigationItem.rightBarButtonItems = nil
        Helper.shared.createCartIcon(onController: self)
        Helper.shared.setNavigationTitle(viewController: self, title: "New Products")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
  
        NotificationCenter.default.addObserver(self, selector: #selector(OrderVC.refreshCount), name: NSNotification.Name(rawValue: "cartCountChanged"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @objc func btnFavoriteAction(_ sender:UIButton){
        
        if AppFeatures.shared.isUserAllowedToAddItemsToPantryList == true
        {
            //let cell = gestureRecognizer.view?.superview?.superview as! DryOrdersCollectionCell
            let point: CGPoint = sender.convert(.zero, to: collectionView)
            if let indexPath = collectionView!.indexPathForItem(at: point) {
                let cell = collectionView!.cellForItem(at: indexPath) as! OrderCollectionViewCell
                
                let obj = self.arrLatestSpecial[(collectionView.indexPath(for: cell)?.row)!]
                if let proId = obj["ProductID"] as? NSNumber
                {
                    if UserInfo.shared.isSalesRepUser == false && UserInfo.shared.customerOnHoldStatus == true && !AppFeatures.shared.isAllowOnHoldPlacingOrder
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
                            // Add to favourite
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
        return self.arrLatestSpecial.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell : OrderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderCollectionViewCell", for: indexPath) as! OrderCollectionViewCell
        
        cell.adjustFontSizeAsPerScreen()
        
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
        
        cell.imgVwMove.isHidden = true
        cell.cnstBtnMoveWidth.constant = 0.0
        
        if AppFeatures.shared.shouldShowLongDetail{
            let tapRecog = UITapGestureRecognizer(target: self, action: #selector(self.objTappedForDetails(_:)))
            tapRecog.delegate = self
            cell.lblDryOrder.addGestureRecognizer(tapRecog)
            let tapRecog1 = UITapGestureRecognizer(target: self, action: #selector(self.objTappedForDetails(_:)))
            tapRecog1.delegate = self
            cell.productImage.addGestureRecognizer(tapRecog1)
        }
        
        //cell.btnZoomThumbnail.tag = indexPath.item
       // cell.btnZoomThumbnail.addTarget(self, action: #selector(self.btnZoomImageAction(_:)), for: .touchUpInside)
        cell.btnAddToFavourite.tintColor = UIColor.baseBlueColor()
        cell.txtQuantity.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonClicked))
        cell.btnShowQuantityPopup.tag = indexPath.row
        cell.btnShowQuantityPopup.addTarget(self, action: #selector(showQuantityPopupAction(_:)), for: .touchUpInside)
        
        if AppFeatures.shared.shouldHighlightStock{
            
            cell.btnAvailable.isHidden = false
            cell.cnstBtnAvailableWidth.constant = 18.0
        }else{
            cell.btnAvailable.isHidden = true
            cell.cnstBtnAvailableWidth.constant = 0.0
        }
        
        if let isAvailable = self.arrLatestSpecial[indexPath.row]["IsAvailable"] as? Bool
        {
            cell.btnAvailable.setTitle("", for: .normal)
            cell.btnAvailable.setImage(#imageLiteral(resourceName: "check_available"), for: .normal)
        }
        else
        {
            cell.btnAvailable.setTitle("", for: .normal)
            cell.btnAvailable.setImage(#imageLiteral(resourceName: "NotAvailable"), for: .normal)
        }
        
        let desc1 = self.arrLatestSpecial[indexPath.row]["ProductName"] as? String ?? ""
        let desc2 = self.arrLatestSpecial[indexPath.row]["Description2"] as? String ?? ""
        let desc3 = self.arrLatestSpecial[indexPath.row]["Description3"] as? String ?? ""
        var features = ""
        if !desc1.isEmpty{
            features += "\(desc1)"
        }
        if !desc2.isEmpty{
            features += "\n\(desc2)"
        }
        if !desc3.isEmpty{
            features += "\n\(desc3)"
        }
        cell.lblDryOrder.text = features
        
        if let productCode = self.arrLatestSpecial[indexPath.row]["ProductCode"] as? String, productCode != ""{
            cell.productCode.text = productCode
        }else{
            cell.productCode.text = ""
        }
        
        var arrPrices : Array<Dictionary<String,Any>>?
        if let prices = self.arrLatestSpecial[indexPath.row]["DynamicUOM"] as? Array<Dictionary<String,Any>>
        {
            arrPrices = prices
        }else if let prices = self.arrLatestSpecial[indexPath.row]["Prices"] as? Array<Dictionary<String,Any>>{
            arrPrices = prices
        }else if var prices = self.arrLatestSpecial[indexPath.row]["Prices"] as? Dictionary<String,Any>{
            arrPrices = [prices]
        }
        cell.btnAddToFavourite.imageView?.tintColor = UIColor.yellowStarColor()
        if self.arrLatestSpecial[indexPath.row].keyExists(key: "Quantity"), let number = self.arrLatestSpecial[indexPath.row]["Quantity"] as? NSNumber, Float(truncating: number) != 0.0
        {
            let quantityStr = ((Double(truncating: number))*100).rounded()/100
            cell.txtQuantity.text =  quantityStr.cleanValue
        }
        else{
            cell.txtQuantity.text =  AppFeatures.shared.IsAllowDecimal ? 0.00.cleanValue: UserInfo.shared.isSalesRepUser! ? 0.00.cleanValue:"0"
        }
        
        var selectedIndex = 0
        if (arrPrices != nil), arrPrices!.count > 0{
            let testIndex = arrPrices?.index(where: { (testdic : Dictionary<String, Any>) -> Bool in
                testdic["UOMID"] as? NSNumber == self.arrLatestSpecial[indexPath.row]["UOMID"] as? NSNumber
            })
            
            if testIndex != nil
            {
                selectedIndex = testIndex!
            }
            
            if let index = self.arrLatestSpecial[indexPath.row]["selectedIndex"] as? Int
            {
                selectedIndex = index
            }
            let objToFetch = arrPrices![selectedIndex]
            if let price = objToFetch["Price"] as? Double
            {
                if AppFeatures.shared.shouldShowProductPrice
                {
                    let price_final = Double(round(100*price)/100)

                    let priceStr = String(format: "\(CommonString.currencyType)%.2f", price_final)
                    cell.lblCompanyPrice.text = price <= 0 ? CommonString.marketprice:priceStr
                    cell.LblUomDescription.text = objToFetch["UOMDesc"] as? String
                }
                else{
                    cell.lblCompanyPrice.text  = ""
                    cell.LblUomDescription.text = objToFetch["UOMDesc"] as? String
                }
                
                if !AppFeatures.shared.isDynamicUOM {
                    cell.LblUomDescription.text =  self.arrLatestSpecial[indexPath.row]["UOMDesc"] as? String
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
            cell.LblUomDescription.textColor = UIColor.gray
            let dict = self.arrLatestSpecial[indexPath.row]
            if dict.keyExists(key: "LastOrderUOMID"),let lastUom = dict["LastOrderUOMID"] as? Int, lastUom == objToFetch["UOMID"] as? Int, lastUom > 0{
                cell.LblUomDescription.textColor = UIColor.gray
            }
            cell.lblPackSize.isHidden = true
            if let packSize = objToFetch["QuantityPerUnit"] as? Int,AppFeatures.shared.isShowPackSize == true{
                cell.lblPackSize.isHidden = false
                cell.lblPackSize.text = "[CTN QTY: \(packSize)]"
            }
        }else{
            cell.lblCompanyPrice.text = ""
            cell.LblUomDescription.text = self.arrLatestSpecial[indexPath.row]["UOMDesc"] as? String
        }
        
        if AppFeatures.shared.isUserAllowedToAddItemsToPantryList == true
        {
            if let isPantryItem =  arrLatestSpecial[indexPath.row]["IsInPantry"] as? Bool, isPantryItem
            {
                cell.btnAddToFavourite.isSelected = true
                cell.btnAddToFavourite.tintColor = UIColor.baseBlueColor()
            }else{
                cell.btnAddToFavourite.isSelected = false
                cell.btnAddToFavourite.tintColor = UIColor.activeTextFieldColor()
            }
            cell.cnstBtnFavoriteWidth.constant = 20.0
        }
        else{
            cell.cnstBtnFavoriteWidth.constant = 0.0
        }
        
        if let isCartItem =  arrLatestSpecial[indexPath.row]["IsInCart"] as? Bool, isCartItem == true
        {
            cell.btnAddToCart.isSelected = true
            cell.btnAddToCart.setImage(#imageLiteral(resourceName: "LS_green-cart"), for: .normal)
        }else{
            cell.btnAddToCart.isSelected = false
            cell.btnAddToCart.setImage(#imageLiteral(resourceName: "LS_add_to_cart"), for: .normal)
        }
        cell.btnAddToFavourite.tag = indexPath.row
        cell.btnAddToFavourite.addTarget(self, action: #selector(self.btnFavoriteAction), for: .touchUpInside)
        cell.btnAddToCart.tag = indexPath.row
        cell.btnAddToCart.addTarget(self, action: #selector(showQuantityPopupAction(_:)), for: .touchUpInside)
        
        if AppFeatures.shared.isDynamicUOM
        {
            cell.btnChangeUOM.isHidden = false
            cell.btnChangeUOM.tag = indexPath.row
            cell.btnChangeUOM.addTarget(self, action: #selector(self.uOMChanged(sender:)), for: .touchUpInside)
            if let obj = self.arrLatestSpecial[indexPath.row]["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1 {
                cell.arrowUOMDropdown.constant = 7.0
            } else {
                cell.arrowUOMDropdown.constant = 0.0
            }
        }
        else
        {
            cell.btnChangeUOM.removeTarget(self, action: nil, for: .allEvents)
            cell.btnChangeUOM.isHidden = true
        }
        
        if AppFeatures.shared.shouldHighlightStock == true
        {
            cell.btnAvailable.setTitle("", for: .normal)
            cell.btnAvailable.setImage(#imageLiteral(resourceName: "check_available"), for: .normal)
        }
        else
        {
            cell.btnAvailable.setTitle("", for: .normal)
            cell.btnAvailable.setImage(#imageLiteral(resourceName: "NotAvailable"), for: .normal)
        }
        
//        if self.arrLatestSpecial[indexPath.row]["IsStatusIN"] as? Bool == true{
//
//            cell.lblDryOrder.textColor = UIColor.blue
//        }
//        else if AppFeatures.shared.isHighlightRewardItem
//        {
//            if let isCountrywideReward =  self.arrLatestSpecial[indexPath.row]["IsCountrywideRewards"] as? Bool, isCountrywideReward == true
//            {
//                cell.lblDryOrder.textColor = UIColor.init(hex: "#b0cf00")
//            }
//            else
//            {
//                cell.lblDryOrder.textColor = UIColor.baseBlueColor()
//            }
//        }
//        else{
//            cell.lblDryOrder.textColor = UIColor.baseBlueColor()
//        }
        
        if AppFeatures.shared.shouldShowBrandNameInProductList
        {
            cell.brandLbl.text = self.arrLatestSpecial[indexPath.row]["Brand"] as? String
        }
        if AppFeatures.shared.isShowSupplier
        {
            cell.lblSupplierName.text = self.arrLatestSpecial[indexPath.row]["Supplier"] as? String
        }

        
        if AppFeatures.shared.isHighlightRewardItem
        {
            if let isCountrywideReward =  self.arrLatestSpecial[indexPath.row]["IsCountrywideRewards"] as? Bool, isCountrywideReward == true
            {
                cell.lblDryOrder.textColor = UIColor.init(hex: "#b0cf00")
            }
            else
            {
                cell.lblDryOrder.textColor = UIColor.baseBlueColor()
            }
        }
        else
        {
            cell.lblDryOrder.textColor = UIColor.baseBlueColor()
        }
        if let isBuyIn =  self.arrLatestSpecial[indexPath.row]["BuyIn"] as? Bool, isBuyIn == true
        {
            cell.lblDryOrder.textColor = UIColor.init(hex: "#2a99f3")
        }


        
        cell.productImage.tintColor = UIColor.baseBlueColor()
        cell.productImage.contentMode = .scaleToFill
      
        cell.lblStatus.layer.cornerRadius = 8
        if let new = self.arrLatestSpecial[indexPath.row]["IsNew"] as? Bool, new == true {
            cell.lblStatus.isHidden = false
            cell.lblStatus.text = "NEW"
            cell.lblStatus.backgroundColor = UIColor.primaryColor()
        }else if let new = self.arrLatestSpecial[indexPath.row]["IsOnSale"] as? Bool, new == true {
            cell.lblStatus.isHidden = false
            cell.lblStatus.text = "SALE"
            cell.lblStatus.backgroundColor = UIColor.primaryColor2()
        }else if let new = self.arrLatestSpecial[indexPath.row]["IsBackSoon"] as? Bool, new == true {
            cell.lblStatus.isHidden = false
            cell.lblStatus.text = "INCOMING"
            cell.lblStatus.backgroundColor = UIColor.primaryColor3()
        }else{
            cell.lblStatus.text = ""
            cell.lblStatus.isHidden = true
        }
        cell.btnTrash.isHidden = true
        cell.cnstTrashBtnWidth.constant = 0.0
        cell.imgVwMove.isHidden = true
        cell.cnstBtnMoveWidth.constant = 0.0
        
        if AppFeatures.shared.shoudlShowProductImages == true
        {
            let imgDict = self.arrLatestSpecial[indexPath.row] as? Dictionary<String,Any>
            
            if let arrImages = imgDict!["ProductImages"] as? Array<Dictionary<String,Any>>{
                
                if arrImages.count > 0{
                    
                    let originalString:String = arrImages[0]["ImageName"]! as! String
                    let urlString:String = originalString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
                    
                    cell.productImage.setImageWith(URL(string: urlString), placeholderImage: #imageLiteral(resourceName: "ImagePlaceholder"), options: .continueInBackground)
                    cell.productImage.tintColor = UIColor.baseBlueColor()
                }
            }
        }
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
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
    
        
    }
    
    @objc func refreshCount()
    {
        if !(self.navigationItem.titleView is UISearchBar)
        {
            self.setDefaultNavigation()
        }
    }
    
    //MARK: - Webservice Handling -
    func callLatestSpecialWebService()
    {
        let requestParameters = [
            "CustomerID": UserInfo.shared.customerID!,
            "MainCategoryID": 0,
            "SubCategoryID": 0,
            "FilterID": 0,
            "Searchtext": "",
            "IsSpecial": true,
            "PageSize": 10,
            "PageIndex": 0,
            "UserID": UserInfo.shared.userId!
            ]  as [String : Any]
        
        let serviceURL = SyncEngine.baseURL + SyncEngine.getLatestSpecial
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestParameters , strURL: serviceURL) { (response : Any) in
            if response is  Dictionary<String,Any>
            {
                //self.arrLatestSpecial.removeAll()
                let arr = response as! Dictionary<String,Any>
                self.arrLatestSpecial = arr["LatestSpecials"] as! [Dictionary<String, Any>]
            }
            if self.arrLatestSpecial.count == 0 {
                DispatchQueue.main.async(execute: {
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                    label.text = "No product available"
                    label.font = UIFont.SFUI_SemiBold(baseScaleSize: 20.0)
                    label.textColor = UIColor.gray
                    label.sizeToFit()
                    label.center = self.view.center
                    self.view.addSubview(label)
                })
            }
            
            DispatchQueue.main.async(execute: {
                self.collectionView.reloadData()
                self.setDefaultNavigation()
            })
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
    
    func checkMinAndMaxOrderQuantity(productValue : Dictionary<String, Any>, index : Int){
        if  !UserInfo.shared.isSalesRepUser! && UserInfo.shared.customerOnHoldStatus == true && !AppFeatures.shared.isAllowOnHoldPlacingOrder
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
            
            let minQty = (productDetail["MinOQ"] as? Int ?? 0)
            let maxQty = (productDetail["MaxOQ"] as? Int ?? 0)
            let qtyPerUnit = Int(Helper.shared.getPackSize(dic: productValue))
            
            if AppFeatures.shared.isMinOrderQuantity == true && AppFeatures.shared.isMaxOrderQuantity == true {
                if (Int(truncating: NSNumber(value: minQty))/qtyPerUnit) > Int(truncating: (productDetail["Quantity"] as? NSNumber)!) && NSNumber(value: minQty) != 0
                {
                    let msgString = "This item has a minimum order quantity of \( Int(truncating: NSNumber(value: minQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: minQty))) \("units to cart ?")"
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                        self.arrLatestSpecial[index]["Quantity"] = minQty/qtyPerUnit
                        // self.specialsCollectionView.reloadData()
                        self.addProductToCartwithDatePicker(productDetail: self.arrLatestSpecial[index], actualIndex: index)
                    })
                }
                else if (Int(truncating: NSNumber(value: maxQty))/qtyPerUnit) < Int(truncating: (productDetail["Quantity"] as? NSNumber)!) && NSNumber(value: maxQty) != 0
                {
                    let msgString = "This item has a maximum order quantity of \( Int(truncating: NSNumber(value: maxQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: maxQty))) \("units to cart ?")"
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                        self.arrLatestSpecial[index]["Quantity"] = maxQty/qtyPerUnit
                        //self.specialsCollectionView.reloadData()
                        self.addProductToCartwithDatePicker(productDetail: self.arrLatestSpecial[index], actualIndex: index)
                    })
                }
                else{
                    self.addProductToCartwithDatePicker(productDetail: productDetail, actualIndex: index)
                }
            }
            else if  AppFeatures.shared.isMinOrderQuantity == true {
                if (Int(truncating: NSNumber(value: minQty))/qtyPerUnit) > Int(truncating: (productDetail["Quantity"] as? NSNumber)!) && NSNumber(value: minQty) != 0
                {
                    let msgString = "This item has a minimum order quantity of \( Int(truncating: NSNumber(value: minQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: minQty))) \("units to cart ?")"
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                        self.arrLatestSpecial[index]["Quantity"] = minQty/qtyPerUnit
                        //  self.specialsCollectionView.reloadData()
                        self.addProductToCartwithDatePicker(productDetail: self.arrLatestSpecial[index], actualIndex: index)
                    })
                }
                else if  AppFeatures.shared.isMaxOrderQuantity == true {
                    if (Int(truncating: NSNumber(value: maxQty))/qtyPerUnit) < Int(truncating: NSNumber(value: maxQty)) && NSNumber(value: maxQty) != 0
                    {
                        let msgString = "This item has a maximum order quantity of \( Int(truncating: NSNumber(value: maxQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: maxQty))) \("units to cart ?")"
                        
                        SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                            self.arrLatestSpecial[index]["Quantity"] = maxQty/qtyPerUnit
                            //  self.specialsCollectionView.reloadData()
                            self.addProductToCartwithDatePicker(productDetail: self.arrLatestSpecial[index], actualIndex: index)
                        })
                    }
                }
                else{
                    self.addProductToCartwithDatePicker(productDetail: productDetail, actualIndex: index)
                }
            }
            else if  AppFeatures.shared.isMaxOrderQuantity == true {
                if (Int(truncating: NSNumber(value: maxQty))/qtyPerUnit) < Int(truncating: (productDetail["Quantity"] as? NSNumber)!) && NSNumber(value: maxQty) != 0
                {
                    let msgString = "This item has a maximum order quantity of \( Int(truncating: NSNumber(value: maxQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: maxQty))) \("units to cart ?")"
                    
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                        self.arrLatestSpecial[index]["Quantity"] = maxQty/qtyPerUnit
                        // self.specialsCollectionView.reloadData()
                        self.addProductToCartwithDatePicker(productDetail:self.arrLatestSpecial[index], actualIndex: index)
                    })
                }
                else{
                    self.addProductToCartwithDatePicker(productDetail: productDetail, actualIndex: index)
                }
            }
            else{
                self.addProductToCartwithDatePicker(productDetail: productDetail, actualIndex: index)
            }
        }
    }
    
    func addProductToCartwithDatePicker ( productDetail : Dictionary<String, Any>, actualIndex : Int = -1)
    {
        let stockQuantity = productDetail["StockQuantity"] as? Double ?? 0.0
        
        if stockQuantity != 0.0 {
            
            if UserInfo.shared.isSalesRepUser == false && UserInfo.shared.customerOnHoldStatus == true && !AppFeatures.shared.isAllowOnHoldPlacingOrder
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
    
    @objc func showCartScreen() -> Void
    {
        if UserInfo.shared.customerOnHoldStatus == true && !AppFeatures.shared.isAllowOnHoldPlacingOrder{
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
    
    func showBuyInPopup( productDetail : Dictionary<String, Any>, actualIndex : Int = -1){
        
        let isBuyIn = productDetail["BuyIn"] as? Bool
        if /*AppFeatures.shared.isBuyIn*/ isBuyIn == true{
            
            if let buyInPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BuyInViewController") as? BuyInViewController
            {
                
                buyInPopup.showCommonAlertOnWindow {
                    
                    self.backOrder(productDetail: productDetail, actualIndex: actualIndex)
                    
                }
            }
            
        }else {
            self.backOrder(productDetail: productDetail, actualIndex: actualIndex)
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
        }
        else if let prices = productDetail["Prices"] as? Array<Dictionary<String,Any>>
        {
            arrPrices = prices
        }
        else if let prices = productDetail["Prices"] as? Dictionary<String,Any>
        {
            arrPrices = [prices]
        }
        
        if let obj = productDetail["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1
        {
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
        }else {
            
            if let buyInPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:SaaviActionAlert.storyboardIdentifier) as? SaaviActionAlert
            {
                if sohValue <= 0{
                    
                    buyInPopup.showCommonAlertOnWindow(withTitle: "Important", withSuccessButtonTitle: "", withMessage: "Sorry, this product is out of stock at this moment.", withCancelButtonTitle: "Ok") {
                        product["Quantity"] = 1.0
                        self.arrLatestSpecial[actualIndex] = product
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
                                        self.arrLatestSpecial[actualIndex] = product
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
                        self.arrLatestSpecial[actualIndex] = product
                        self.collectionView.reloadData()
                        self.checkOrderMultiplies(productDetail: product, actualIndex: actualIndex)
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
    func addProductToCart( productDetail : Dictionary<String, Any>, actualIndex : Int = -1){
        
        
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
                "Quantity": (productDetail.keyExists(key: "Quantity")) ? (productDetail["Quantity"] as! NSNumber == 0 ? 1.00:productDetail["Quantity"] as! NSNumber) : 1.00,
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
            
            if let isAlreadyInCart = self.arrLatestSpecial[actualIndex]["IsInCart"] as? Bool, isAlreadyInCart == false
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
                self.arrLatestSpecial[actualIndex] = productDetail
                self.arrLatestSpecial[actualIndex]["tempQuantity"] = 1 as NSNumber
                self.arrLatestSpecial[actualIndex]["IsInCart"] = true
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
    
    @objc func backBtnAction() -> Void
    {
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func showQuantityPopupAction(_ sender : UIButton)
    {
        let productDetail = self.arrLatestSpecial[sender.tag]
        
        let stockQuantity = productDetail["StockQuantity"] as? Double ?? 0.0
        
        if stockQuantity != 0.0 {
            
            let indexPath = IndexPath(item: sender.tag, section: 0)
            if AppFeatures.shared.IsDatePickerEnabled == true {
                
                if true
                {
                    
                    self.updateQuantity(indexPath:indexPath)
                }
                else
                {
                    self.showDeliveryTypePopup {
                        
                        self.updateQuantity(indexPath:indexPath)
                    }
                }
            }else {
                
                self.updateQuantity(indexPath:indexPath)
            }
        }else {
            Helper.shared.showAlertOnController( message: "No stock available", title: CommonString.alertTitle)
        }

    }
    
    func updateQuantity(indexPath: IndexPath){
        
        if UserInfo.shared.isGuest == true
        {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.guestUser, withCancelButtonTitle: "OK", completion: {
                Helper.shared.logoutAsGuest()
                return
            })
        }

        let cell = self.collectionView?.cellForItem(at: indexPath) as? OrderCollectionViewCell
        
        if cell != nil
        {
            if let index = self.collectionView.indexPath(for: cell!)
            {
                print(index)
                var product = self.arrLatestSpecial[index.row]

                if let circularPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "circularQuantityStoryboardID") as? CircularQuantityPopup
                {
                    circularPopup.quantityPerUnit = Helper.shared.getSelectedUomNameQuantity(product: product).quantity
                    circularPopup.isEach =  Helper.shared.getSelectedUomNameQuantity(product: product).isEach
                    if product.keyExists(key: "Quantity")
                    {
                        circularPopup.circularSlider.currentValue = Float(truncating: (( product["Quantity"]) as? NSNumber)!)
                        circularPopup.currentQuantity = "\(Double(truncating: (( product["Quantity"]) as? NSNumber)!))"
                        
                        circularPopup.showCommonAlertOnWindow
                            {
                                product["Quantity"] = NSNumber(value: Double(circularPopup.txtFldQuantity.text!)!)
                                self.arrLatestSpecial[index.row] = product
                                self.checkMinAndMaxOrderQuantity(productValue: product, index: index.row)
                                self.collectionView.reloadData()
                        }
                    }
                    else
                    {
                        circularPopup.circularSlider.currentValue = 1.0
                        circularPopup.showCommonAlertOnWindow
                            {
                                product["Quantity"] = NSNumber(value: Double(circularPopup.txtFldQuantity.text!)!)
                                self.arrLatestSpecial[index.row] = product
                                self.collectionView.reloadData()
                        }
                    }
                    if let bool = product["IsInCart"] as? Bool, bool == true
                    {
                        circularPopup.btnAddToCart.setTitle("UPDATE CART", for: .normal)
                    }
                }
            }
        }
    }
    
//    func addProductToCart(index:Int){
//
//        var product = arrLatestSpecial[index]
//        if let circularPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "circularQuantityStoryboardID") as? CircularQuantityPopup
//        {
//            if product.keyExists(key: "Quantity"), let number = product["Quantity"] as? NSNumber
//            {
//                circularPopup.circularSlider.currentValue = Float(truncating: number)
//                circularPopup.currentQuantity = "\(Double(truncating: number))"
//                circularPopup.showCommonAlertOnWindow
//                    {
//                        product["Quantity"] = NSNumber(value: Double(circularPopup.txtFldQuantity.text!)!)
//                        self.checkMinAndMaxOrderQuantity(productValue: product, index: index, quantity: NSNumber(value: Double(circularPopup.txtFldQuantity.text!)!))
//                        self.collectionView.reloadData()
//                }
//            }
//            else
//            {
//                circularPopup.circularSlider.currentValue = AppFeatures.shared.IsAllowDecimal ? 0.00: UserInfo.shared.isSalesRepUser! ? 0.00:1
//                circularPopup.showCommonAlertOnWindow
//                    {
//                        product["Quantity"] = NSNumber(value: Double(circularPopup.txtFldQuantity.text!)!)
//
//
//                        self.checkMinAndMaxOrderQuantity(productValue: product, index: index, quantity: NSNumber(value: Double(circularPopup.txtFldQuantity.text!)!))
//
//                        self.collectionView.reloadData()
//                }
//            }
//
//            if let bool = product["IsInCart"] as? Bool, bool == true
//            {
//                circularPopup.btnAddToCart.setTitle("UPDATE CART", for: .normal)
//            }
//
//        }
//
//    }
  
    @objc func objTappedForDetails (_ sender : Any?) -> Void
    {
        if sender is UITapGestureRecognizer, let cell = (sender as! UITapGestureRecognizer).view?.superview?.superview?.superview as? OrderCollectionViewCell
        {
            if let indexPath = self.collectionView.indexPath(for: cell)
            {
                let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderDescriptionView") as? OrderDescriptionView
                destinationViewController?.productID = (self.arrLatestSpecial[indexPath.row]["ProductID"] as? NSNumber)!
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
                gestureRecognizer.view?.superview?.backgroundColor = UIColor.addToCartGreenColor()
            }
            else
            {
                
                    gestureRecognizer.view?.superview?.backgroundColor = UIColor.addToCartGreenColor()
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
        else if gestureRecognizer.state == .ended
        {
            if (gestureRecognizer.view?.frame.minX)! > (((gestureRecognizer.view?.frame.size.width)! - (gestureRecognizer.view?.frame.size.width)!/2.0) - 20.0)
            {
                print("add to cart.")
                
                if gestureRecognizer.view?.superview?.superview is OrderCollectionViewCell
                {
                    let cell = gestureRecognizer.view?.superview?.superview as! OrderCollectionViewCell
                    let obj = self.arrLatestSpecial[(collectionView.indexPath(for: cell)?.row)!]
                    if obj["IsAvailable"] as? Bool == true
                    {
                        
                        var quantity = Double(exactly:(obj["Quantity"] as? NSNumber) ?? 0.0) ?? 0.0
                        var product = obj
                        if quantity > 0.0{
                            quantity += quantity
                        }
                        product["Quantity"] = quantity
                        
                        self.checkMinAndMaxOrderQuantity(productValue: product, index: (collectionView.indexPath(for: cell)?.row)!)
                    }
                    else{
                        Helper.shared.showAlertOnController(message: "Product is not available", title: CommonString.alertTitle)
                    }
                }
            }
            else if (gestureRecognizer.view?.frame.minX)! < ((0.0 - (gestureRecognizer.view?.frame.size.width)!/2.0) + 20.0)
            {
                print("add to cart.")
                
                if gestureRecognizer.view?.superview?.superview is OrderCollectionViewCell
                {
                    let cell = gestureRecognizer.view?.superview?.superview as! OrderCollectionViewCell
                    let obj = self.arrLatestSpecial[(collectionView.indexPath(for: cell)?.row)!]
                    if obj["IsAvailable"] as? Bool == true
                    {
                        
                        var quantity = Double(exactly:(obj["Quantity"] as? NSNumber) ?? 0.0) ?? 0.0
                        var product = obj
                        if quantity > 0.0{
                            quantity += quantity
                        }
                        product["Quantity"] = quantity
                        
                        self.checkMinAndMaxOrderQuantity(productValue: product, index: (collectionView.indexPath(for: cell)?.row)!)
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
    
    //MARK: - Add product in Favorite list
    func addProductToFavoriteList(productID : NSNumber,index:Int){
        
        if UserInfo.shared.customerOnHoldStatus == true && !AppFeatures.shared.isAllowOnHoldPlacingOrder
        {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                return
            })
        }
        else{
            
            if AppFeatures.shared.isFavoriteList{
                if let chooseFavorite = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "choosefavouriteListPopupStoryboardIdentifier") as? ChooseFavouriteListPopup
                {
                    if let proId = self.arrLatestSpecial[index]["ProductID"] as? NSNumber
                    {
                        chooseFavorite.productID = proId
                        chooseFavorite.showCommonAlertOnWindow(completion: { (isFav : Bool) in
                            self.arrLatestSpecial[index]["IsInPantry"] = isFav
                            self.collectionView.reloadData()
                        })
                    }
                }
            }else{
                self.addItemToDefaultPantry(productID: productID, index: index)
            }
        }
    }
    
    func addItemToDefaultPantry(productID : NSNumber? ,index:Int)
    {
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
                    
                    self.arrLatestSpecial[index]["IsInPantry"] = true
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
        
                self.removeItemFromFavoriteList(indexPath: indexPath)
            })
//        }
    }
    
    private func removeItemFromFavoriteList(indexPath:IndexPath){
        
        let product = self.arrLatestSpecial[indexPath.item]
        let pantryListItemID = product["PantryListItemID"] ?? 0
        let pantryListID = product["PantryListID"] ?? 0

        let dict = ["PantryItemID": pantryListItemID,
                    "PantryListID": pantryListID,
                    "CustomerID": UserInfo.shared.customerID!]
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: dict, strURL: SyncEngine.baseURL + SyncEngine.deleteItemFromFavorite) { (response) in
            
            self.arrLatestSpecial[indexPath.item]["IsInPantry"] = false
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc func copyPantryListAction()
    {
        if UserInfo.shared.customerOnHoldStatus==true && !AppFeatures.shared.isAllowOnHoldPlacingOrder {
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
                    if self.arrLatestSpecial.count > 0 , let pantryid = self.arrLatestSpecial[0]["PantryListID"] as? NSNumber
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
                            Helper.shared.showAlertOnController(message: "Could not copy empty favourite list.", title: CommonString.alertTitle)
                        }
                        else
                        {
                            Helper.shared.showAlertOnController(message: "Could not copy empty pantry list.", title: CommonString.alertTitle)
                        }
                    }
                }
                
                
            }
        }
    }
    
    @objc func handleEnquiryPopupTap(_ button : UIButton) -> Void
    {
        if UserInfo.shared.customerOnHoldStatus==true && !AppFeatures.shared.isAllowOnHoldPlacingOrder {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                return
            })
        }
        else{
            let objForEnquiry = arrLatestSpecial[button.tag]
            if let enquiryPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:"addEnquiryPopupSroryID") as? AddNewEnquiryPopup
            {
                enquiryPopup.itemForEnquiry = objForEnquiry
                enquiryPopup.parentView = self
                UIApplication.shared.keyWindow?.rootViewController?.present(enquiryPopup, animated: false, completion: nil)
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
    //    MARK:- Scroll View -
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate
        {
          //  self.handlePaginationIfRequired(scrollView:  scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
      //  self.handlePaginationIfRequired(scrollView:  scrollView)
    }
    
//    func handlePaginationIfRequired(scrollView: UIScrollView)
//    {
//        if scrollView.contentSize.height < (scrollView.contentOffset.y + scrollView.frame.size.height + 5.0), totalResults != nil, Int(truncating: self.totalResults!) > self.arrLatestSpecial.count
//        {
//
////                pageNumber += 1
////                self.callSearchProductWebService(with: searchText)
//
//        }
//    }
    
    @objc func doneButtonClicked(_ textField: UITextField) {
        
        self.collectionView.isScrollEnabled = true
        if textField == txtFldActive{
            var product = self.arrLatestSpecial[textField.tag]
            
            let qtyDoubleValue:Double = (textField.text?.isEmpty)! ? 0.00:Double(textField.text!)!
            let qtyValue = qtyDoubleValue <= 0 ? 0.00:qtyDoubleValue
            product["Quantity"] = NSNumber(value: qtyValue)
            self.arrLatestSpecial[textField.tag] = product
            product = self.arrLatestSpecial[textField.tag]
            self.checkMinAndMaxOrderQuantity(productValue: product, index: textField.tag)
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
               
                numberOfValidDigits = 8
            } else {
                numberOfValidDigits = 5
            }
            
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
    
    func updateCartItemObjWithObj(dic : Dictionary<String,Any>)
    {
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: dic, strURL: SyncEngine.baseURL + SyncEngine.updateCartItem) { (response : Any) in
            
        }
    }
    
    @objc func uOMChanged(sender : UIButton)
    {
        if let obj = self.arrLatestSpecial[sender.tag]["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1
        {
            var index : Int = 0
            if let selectedIndex = self.arrLatestSpecial[sender.tag]["selectedIndex"] as? Int
            {
                index = selectedIndex
            }
            
            if index + 1 < obj.count
            {
                var objToChange = self.arrLatestSpecial[sender.tag]
                objToChange["selectedIndex"] = index + 1
                self.arrLatestSpecial[sender.tag] = objToChange
                self.collectionView.reloadData()
            }
            else
            {
                var objToChange = self.arrLatestSpecial[sender.tag]
                objToChange["selectedIndex"] = 0
                self.arrLatestSpecial[sender.tag] = objToChange
                self.collectionView.reloadData()
            }
        }
    }
}

extension WhatsNewVC: LightboxControllerPageDelegate ,LightboxControllerDismissalDelegate{
    
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        
    }
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
    }
}
