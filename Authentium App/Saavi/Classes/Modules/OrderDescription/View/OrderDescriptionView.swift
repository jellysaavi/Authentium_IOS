//
//  OrderDescriptionView.swift
//  Saavi
//
//  Created by Irmeen Sheikh on 18/12/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit
import Lightbox

class OrderDescriptionView: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    @IBOutlet weak var collectionVw_imageGallery: UICollectionView!
    @IBOutlet weak var imgVwCartIcon: UIImageView!
    @IBOutlet weak var collectionVw_itemDescription: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionVwImageGalleryHeight: HorizontalSpacingConstraints!
    @IBOutlet weak var lbl_productName: UILabel!
    @IBOutlet weak var lbl_supplierName: UILabel!
    @IBOutlet weak var lbl_productCode: UILabel!
    @IBOutlet weak var lblProductStatus: PaddingLabel!
    @IBOutlet weak var lblQuantityPerUnit: UILabel!
    @IBOutlet weak var lblBarcodeNum: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    
    @IBOutlet weak var cnstShareButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var lbl_price: UILabel!
    @IBOutlet weak var img_UOMDropdown: UIImageView!
    @IBOutlet weak var img_Product: UIImageView!
    @IBOutlet weak var btn_AddToCart: UIButton!
    @IBOutlet weak var btnAlternateItems: UIButton!
    @IBOutlet weak var lblTitleFeatureAndSpecifications: UILabel!
    @IBOutlet weak var lblDetailFeaturesAndSpecifications: UILabel!
    @IBOutlet weak var lbl_Description: UILabel!
    @IBOutlet weak var lbl_exGST: UILabel!
    @IBOutlet weak var lbl_Each: UILabel!
    //    @IBOutlet weak var codeLeadingConstant: HorizontalSpacingConstraints!
    @IBOutlet weak var arrowUOMDropdown: NSLayoutConstraint!
    @IBOutlet weak var img_productHeight: NSLayoutConstraint!
    @IBOutlet weak var btn_Favorite: UIButton!
    var noImageLabel : UILabel?
    @IBOutlet weak var clctn_weekCount: UICollectionView!
    @IBOutlet var lbl_SalesHistory: customLabelGrey!
    @IBOutlet weak var btnFavHeight: NSLayoutConstraint!
    @IBOutlet var weekClctnHeight: NSLayoutConstraint!
    @IBOutlet weak var salesHistoryWidthConstant: NSLayoutConstraint!
    var productID = NSNumber()
    var strPackSize = ""
    var isSalesRep:Bool = false
    var objproductDetail = Dictionary<String,Any>()
    var arr_Images = Array<Dictionary<String,String>>()
    var productImages = [String]()
    var arr_List = Array<Dictionary<String,String>>()
    var selectedImageIndex = NSInteger()
    var salesRepCustomerId : NSNumber = 0
    var uomID :NSNumber = 0
    var specialPrice :NSNumber = 0
    var qtyPerUnit : NSNumber = 0
    @IBOutlet weak var alternateItemsBtnWidthConstant: NSLayoutConstraint!
    @IBOutlet weak var btn_specialPrice: UIButton!
    @IBOutlet weak var btnItemEnquiry: UIButton!
    @IBOutlet weak var stackViewButtons: UIStackView!
    var txtFldActive = UITextField()
    var tempString = String()
    var isTxtFieldChanged : Bool = false
    
    var salesRepHeaderArr = [["name":"REP"], ["name":"CATEGORY"], ["name":"SUB CATEGORY"], ["name":"QUANTITY"]]
    var weakArr = [["Weak":"WK1"],["Weak":"WK2"],["Weak":"WK3"],["Weak":"WK4"],["Weak":"WK5"],["Weak":"WK6"],["Weak":"WK7"],["Weak":"WK8"]]
    var isMoveBack = false
    
    //MARK: - - Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        weekClctnHeight.constant = 80.0

        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardWillHideHandler),name:NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        self.collectionVw_itemDescription.layer.borderWidth = 1.0
        self.collectionVw_itemDescription.layer.borderColor = UIColor.lightGray.cgColor
        adjustFontSizeAsPerScreen()
        self.setValues()
        if isSalesRep == true{
            btnFavHeight.constant = 0.0
        }
        else{
            if AppFeatures.shared.isUserAllowedToAddItemsToPantryList == true
            {
                btnFavHeight.constant = 50.0
            }
            else{
                btnFavHeight.constant = 0.0
            }
        }

        arr_List.append(["name":"AVAILABILITY"])
        arr_List.append(["name":"CTN QTY"])
        arr_List.append(["name":"QUANTITY"])
        self.collectionVw_itemDescription.reloadData()
        self.btn_Favorite.tintColor = UIColor.baseBlueColor()
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            self.img_Product.contentMode = UIViewContentMode.scaleAspectFit
            self.img_Product.backgroundColor = UIColor(red: 246.0/255.0, green: 247.0/255.0, blue: 248.0/255.0, alpha: 1.0)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(OrderDescriptionView.setDefaultNavigation), name: NSNotification.Name(rawValue: "cartCountChanged"), object: nil)
        
        // Override all checks
        
        if !UserInfo.shared.isSalesRepUser! && AppFeatures.shared.shoudlShowProductImages == false
        {
            
            self.img_Product.backgroundColor = UIColor(red: 246.0/255.0, green: 247.0/255.0, blue: 248.0/255.0, alpha: 1.0)
            self.img_Product.image = nil
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            label.text = "No image available"
            label.textAlignment = .center
            label.font = UIFont.SFUI_SemiBold(baseScaleSize: 20.0)
            label.textColor = UIColor.gray
            label.sizeToFit()
            //            label.center = img_Product.center
            img_Product.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.centerXAnchor.constraint(equalTo: self.img_Product.centerXAnchor, constant:0).isActive = true
            label.centerYAnchor.constraint(equalTo: self.img_Product.centerYAnchor, constant:0).isActive = true
            label.widthAnchor.constraint(equalToConstant: 250.0).isActive = true
            noImageLabel = label
        }
//        if AppFeatures.shared.isItemEnquiryPopup == true{
//            self.btnItemEnquiry.isHidden = false
//        }
       
    }
    
    @objc private func keyboardWillHideHandler(notification: NSNotification){
        //do stuff using the userInfo property of the notification object
        if isTxtFieldChanged{}else{
            txtFldActive.text = tempString
        }
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        callAPIForGettingDescriptionOfProduct()
        
        self.tabBarController?.tabBar.isHidden = true
        self.setDefaultNavigation()
       // lbl_SalesHistory.adjustsFontSizeToFitWidth=true
        
        self.setBottomButtons()
        
        if UserInfo.shared.isSalesRepUser == true && AppFeatures.shared.isAdvancedPantry == false{
            
            alternateItemsBtnWidthConstant.constant = self.view.frame.width/3.0
        }
        

        if AppFeatures.shared.isShowProductHistory == true {
            weekClctnHeight.constant = 80.0
            //salesHistoryWidthConstant.constant = 70.0
        }
        else{
            weekClctnHeight.constant = 0.0
           // salesHistoryWidthConstant.constant = 0.0
        }
        
//        if UserInfo.shared.isSalesRepUser! && !AppFeatures.shared.IsEnableRepToAddSpecialPrice{
//            self.btn_specialPrice.isHidden = true
//        }else
        if !UserInfo.shared.isSalesRepUser!{
            self.btn_specialPrice.isHidden = true
        }else{
            if UserInfo.shared.isSalesRepUser! { // Implemented for hide every type user
                self.btn_specialPrice.isHidden = true
            }
            if  UIDevice.current.userInterfaceIdiom == .pad && AppFeatures.shared.isAdvancedPantry == true{
                self.btnAlternateItems.isHidden = true
            }
        }
        
         self.btnAlternateItems.isHidden = true
    }
    
    func setBottomButtons(){
        
        self.btn_specialPrice.setTitle("SPECIAL PRICE", for: .normal)
        
        self.btnAlternateItems.setTitle("ALTERNATE ITEMS", for: .normal)
        
        self.btn_AddToCart.setTitle("ADD TO CART", for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if noImageLabel != nil
        {
            noImageLabel?.center = img_Product.center
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func tapOnProductImage(gesture: UIGestureRecognizer){
        
        let originalString:String = self.arr_Images[selectedImageIndex]["ImageName"]!
        let urlString:String = originalString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        self.shoLargeImage(urlStr: urlString)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- CollectionView delegate and datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView == collectionVw_imageGallery
        {
            return productImages.count
        }
        if collectionView == collectionVw_itemDescription
        {
            return arr_List.count
        }
        else{
            return weakArr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView == collectionVw_imageGallery
        {
            let cell : ItemsCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemsCollection", for: indexPath) as! ItemsCollectionCell
            cell.img_ProductListImg.tintColor = UIColor.baseBlueColor().withAlphaComponent(0)
            cell.img_ProductListImg.backgroundColor = UIColor.white
            
            let originalString:String = self.productImages[indexPath.row]
            let urlString:String = originalString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
            cell.img_ProductListImg.contentMode = .scaleAspectFit
            DispatchQueue.main.async {
                
            
            cell.img_ProductListImg.setImageWith(URL(string: urlString), placeholderImage: #imageLiteral(resourceName: "ImagePlaceholder"))
            }
            cell.layer.borderColor = UIColor.darkGray.cgColor
            cell.layer.borderWidth = 1.0
            
            return cell
        }else if collectionView == collectionVw_itemDescription{
            
            if arr_List[indexPath.row]["name"] == "QUANTITY"{
                
                let cell : QuantityCiollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuantityCiollection", for: indexPath) as! QuantityCiollectionCell
                if isSalesRep == true && AppFeatures.shared.isAdvancedPantry == true{
                    cell.lbl_ListQty.text = salesRepHeaderArr[indexPath.row]["name"]
                }
                else{
                    cell.lbl_ListQty.text = arr_List[indexPath.row]["name"]
                }
                cell.btn_addQty.tag = indexPath.item
                cell.btn_addQty.addTarget(self, action: #selector(showQuantityPopupAction (_:)), for: UIControlEvents.touchDown)
                
                if objproductDetail.keyExists(key: "Quantity"), let number = objproductDetail["Quantity"] as? NSNumber, Float(truncating: number) != 0.0
                {
                    let quantityStr = ((Double(truncating: number))*100).rounded()/100 //"\(Int(truncating: number))"
                    cell.txtFldQty.text = quantityStr.cleanValue
                }
                else
                {
                    cell.txtFldQty.text = AppFeatures.shared.IsAllowDecimal ? 0.00.cleanValue:UserInfo.shared.isSalesRepUser! ? 0.00.cleanValue:"0"
                }
                return cell
            }
            else
            {
                let cell : ListCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCollection", for: indexPath) as! ListCollectionCell
                if isSalesRep == true && AppFeatures.shared.isAdvancedPantry == true{
                    
                    cell.lbl_list.text = salesRepHeaderArr[indexPath.row]["name"]
                    //if salesRepHeaderArr[indexPath.row]["name"] == "Rep."
                    if salesRepHeaderArr[indexPath.row]["name"] == "REP"
                    {
                        cell.lbl_ListValue.text = UserInfo.shared.name
                        cell.lbl_ListValue.textColor = UIColor.primaryColor()
                    }
                    
                    if salesRepHeaderArr[indexPath.row]["name"] == "CATEGORY" {
                        
                        cell.lbl_ListValue.textColor = UIColor.darkGreyColor()
                        if let categoryName =  self.objproductDetail["MainCategoryName"] as? String
                        {
                            cell.lbl_ListValue.text = categoryName
                            
                        }
                        else{
                            cell.lbl_ListValue.text = "-"
                        }
                        
                    }
                    if salesRepHeaderArr[indexPath.row]["name"] == "SUB CATEGORY" {
                        cell.lbl_ListValue.textColor = UIColor.darkGreyColor()
                        if let categoryName =  self.objproductDetail["CategoryName"] as? String
                        {
                            cell.lbl_ListValue.text = categoryName
                        }
                        else{
                            cell.lbl_ListValue.text = ""
                        }
                    }
                }
                else{
                    
                    cell.lbl_list.text = arr_List[indexPath.row]["name"]
                    
                    if arr_List[indexPath.row]["name"] == "AVAILABILITY"
                    {
                        if let stockQuantity =  self.objproductDetail["StockQuantity"] as? Double, Int(stockQuantity) > 2 {
                            
                            cell.lbl_ListValue.text = "IN STOCK"
                            cell.lbl_ListValue.textColor = UIColor.primaryColor()
                            self.btn_AddToCart.isUserInteractionEnabled = true
                        }else if let stockQuantity =  self.objproductDetail["StockQuantity"] as? Double, Int(stockQuantity) > 0 {
                            cell.lbl_ListValue.text = "LOW STOCK"
                            cell.lbl_ListValue.textColor = UIColor.yellowStarColor()
                            self.btn_AddToCart.isUserInteractionEnabled = true
                        }else{
                            cell.lbl_ListValue.text = "INCOMING"
                            cell.lbl_ListValue.textColor = UIColor.red
                            self.btn_AddToCart.isUserInteractionEnabled = true
                        }
                    }
                    
                    if arr_List[indexPath.row]["name"] == "CTN QTY"{
                        
                        cell.lbl_ListValue.textColor = UIColor.baseBlueColor()
                        if self.strPackSize.isEmpty{
                            cell.lbl_ListValue.text = "-"
                        }else{
                            cell.lbl_ListValue.text = self.strPackSize
                        }
                    }
                }
                return cell
            }
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekCollectionCell", for: indexPath) as! WeekCollectionCell
            
            cell.lbl_week_count.text = self.weakArr[indexPath.row]["Weak"]
            var weekSalesDic = Dictionary<String,Any>()
            if let weeklySaleDic = objproductDetail["WeeklySales"] as? Dictionary<String,Any> , objproductDetail["WeeklySales"] as? Dictionary<String,Any> != nil{
                weekSalesDic = weeklySaleDic
            }
            if indexPath.row == 0 {
                if (weekSalesDic.keyExists(key: "Week1Sales")), let weekSales = weekSalesDic["Week1Sales"] as? Double{
                    let weekSalesStr = String(format: "%.0f", weekSales)
                    cell.lbl_WeekValue.text = weekSalesStr
                }
            }
            else if indexPath.row == 1 {
                if (weekSalesDic.keyExists(key: "Week2Sales")), let weekSales = weekSalesDic["Week2Sales"] as? Double{
                    let weekSalesStr = String(format: "%.0f", weekSales)
                    cell.lbl_WeekValue.text = weekSalesStr
                }
            }
            else if indexPath.row == 2 {
                if (weekSalesDic.keyExists(key: "Week3Sales")), let weekSales = weekSalesDic["Week3Sales"] as? Double{
                    let weekSalesStr = String(format: "%.0f", weekSales)
                    cell.lbl_WeekValue.text = weekSalesStr
                }
            }
            else if indexPath.row == 3 {
                if (weekSalesDic.keyExists(key: "Week4Sales")), let weekSales = weekSalesDic["Week4Sales"] as? Double{
                    let weekSalesStr = String(format: "%.0f", weekSales)
                    cell.lbl_WeekValue.text = weekSalesStr
                }
            }
            else if indexPath.row == 4 {
                if (weekSalesDic.keyExists(key: "Week5Sales")), let weekSales = weekSalesDic["Week5Sales"] as? Double{
                    let weekSalesStr = String(format: "%.0f", weekSales)
                    cell.lbl_WeekValue.text = weekSalesStr
                }
            }
            else if indexPath.row == 5 {
                if (weekSalesDic.keyExists(key: "Week6Sales")), let weekSales = weekSalesDic["Week6Sales"] as? Double{
                    let weekSalesStr = String(format: "%.0f", weekSales)
                    cell.lbl_WeekValue.text = weekSalesStr
                }
            }
            else if indexPath.row == 6 {
                if (weekSalesDic.keyExists(key: "Week7Sales")), let weekSales = weekSalesDic["Week7Sales"] as? Double{
                    let weekSalesStr = String(format: "%.0f", weekSales)
                    cell.lbl_WeekValue.text = weekSalesStr
                }
            }
            else if indexPath.row == 7 {
                if (weekSalesDic.keyExists(key: "Week8Sales")), let weekSales = weekSalesDic["Week8Sales"] as? Double{
                    let weekSalesStr = String(format: "%.0f", weekSales)
                    cell.lbl_WeekValue.text = weekSalesStr
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if collectionView == collectionVw_itemDescription
        {
            return CGSize(width: collectionView.bounds.size.width / CGFloat(arr_List.count) , height: collectionView.bounds.size.height)
        }
        else if collectionView == collectionVw_imageGallery
        {
            return CGSize(width: collectionView.bounds.size.height * 1.50, height: collectionView.bounds.size.height)
        }
        else{
            return CGSize(width: 50, height: 80)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if collectionView == self.collectionVw_imageGallery
        {
            let originalString:String = self.productImages[indexPath.row]
            let urlString:String = originalString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
            self.shoLargeImage(urlStr: urlString)
        }
    }
    
    func shoLargeImage(urlStr:String){
        let images = [LightboxImage.init(imageURL: URL.init(string:urlStr)!)]
        let controller = LightboxController(images: images)
        controller.pageDelegate = self
        controller.dismissalDelegate = self
        controller.modalPresentationStyle = .fullScreen
                  
       // controller.dynamicBackground = true
        self.present(controller, animated: true, completion: nil)
    }
    //MARK:- Button Action
    
    @IBAction func Favorite_action(_ sender: Any) {
        
        if UserInfo.shared.isGuest == true
        {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.guestUser, withCancelButtonTitle: "OK", completion: {
                Helper.shared.logoutAsGuest()
                return
            })
        }
        else if UserInfo.shared.customerOnHoldStatus == true && !AppFeatures.shared.isAllowOnHoldPlacingOrder
        {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                return
            })
        }
        else{
            addProductToFavoriteList()
        }
    }
    
    @IBAction func UOM_action(_ sender: Any)
    {
        uOMChanged()
    }
    
    @IBAction func addToCart_action(_ sender: Any){
      
        let stockQuantity = self.objproductDetail["StockQuantity"] as? Double ?? 0.0
        
        if stockQuantity != 0.0 {
            
            if self.objproductDetail["IsAvailable"] as? Int == 1
            {
                var product = self.objproductDetail
                if UserInfo.shared.isGuest == true
                {
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.guestUser, withCancelButtonTitle: "OK", completion: {
                        Helper.shared.logoutAsGuest()
                        return
                    })
                }
                else if UserInfo.shared.isSalesRepUser == false || AppFeatures.shared.isAdvancedPantry == false {
                    if UserInfo.shared.customerOnHoldStatus == true && AppFeatures.shared.isBrowsingEnabledForHoldCust == true && !AppFeatures.shared.isAllowOnHoldPlacingOrder{
                        SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: { })
                    }
                    else{
                        var quantity = Double(exactly:(product["Quantity"] as? NSNumber) ?? 0.0) ?? 0.0
                        
                        var qtyPerUnit = 0.0
                        var arrPrices : Array<Dictionary<String,Any>>?
                        if let prices = product["DynamicUOM"] as? Array<Dictionary<String,Any>>
                        {
                            arrPrices = prices
                        }else if let prices = product["Prices"] as? Array<Dictionary<String,Any>>{
                            arrPrices = prices
                        }
                        else if let prices = product["Prices"] as? Dictionary<String,Any>
                        {
                            arrPrices = [prices]
                        }
                        let objToFetch = arrPrices![0]
                        if let packSize = objToFetch["QuantityPerUnit"] as? Int {
                            qtyPerUnit = Double(packSize)
                        }
                        
                        if quantity > 0.0{
                            quantity = quantity + qtyPerUnit
                        }
                        product["Quantity"] = quantity
                        self.objproductDetail["Quantity"] = product["Quantity"]
                        self.checkMinAndMaxOrderQuantity(productValue: self.objproductDetail, index: (sender as AnyObject).tag, quantity:(product["Quantity"] as? NSNumber) ?? 0.0)
                    }
                }
                else{
                    var quantity = Double(exactly:(product["Quantity"] as? NSNumber) ?? 0.0) ?? 0.0
                    
                    var qtyPerUnit = 0.0
                    var arrPrices : Array<Dictionary<String,Any>>?
                    if let prices = product["DynamicUOM"] as? Array<Dictionary<String,Any>>
                    {
                        arrPrices = prices
                    }else if let prices = product["Prices"] as? Array<Dictionary<String,Any>>{
                        arrPrices = prices
                    }
                    else if let prices = product["Prices"] as? Dictionary<String,Any>
                    {
                        arrPrices = [prices]
                    }
                    let objToFetch = arrPrices![0]
                    if let packSize = objToFetch["QuantityPerUnit"] as? Int {
                        qtyPerUnit = Double(packSize)
                    }
                    
                    if quantity > 0.0{
                        quantity = quantity + qtyPerUnit
                    }
                    product["Quantity"] = quantity
                    self.objproductDetail["Quantity"] = product["Quantity"]
                    self.addProductToCartWithDate(productDetail: product, actualIndex: (sender as AnyObject).tag)
                }
            }
            else{
                Helper.shared.showAlertOnController( message: "Product is not available", title: CommonString.alertTitle)
            }
        }else {
            Helper.shared.showAlertOnController( message: "No stock available", title: CommonString.alertTitle)
        }

    }
    @IBAction func specialPriceAction(_ sender: Any) {
        
        if (UserInfo.shared.isSalesRepUser! && UIDevice.current.userInterfaceIdiom == .phone) {
            
            // let custId:Int = Int(UserInfo.shared.customerID ?? "0")!
            
            let specialPriceVCObj = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SpecailPriceAlertID") as! SpecailPriceAlert
            DispatchQueue.main.async {
                specialPriceVCObj.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                specialPriceVCObj.senderView = self
                //specialPriceVCObj.customerID =  NSNumber(value:custId)
                
                specialPriceVCObj.productID = self.productID
                specialPriceVCObj.price = self.specialPrice
                specialPriceVCObj.UOMId = self.uomID
                specialPriceVCObj.qtyPerUnit = self.qtyPerUnit
                if self.objproductDetail.keyExists(key: "IsInCart") ,let isInCart = self.objproductDetail["IsInCart"] as? Bool{
                    specialPriceVCObj.isInCart = isInCart
                }
                self.present(specialPriceVCObj, animated: false, completion: nil)
            }
            
        }else{
            
            //let custId:Int = Int(UserInfo.shared.customerID == nil ? "0":UserInfo.shared.customerID!)!
            
            let specialPriceVCObj = UIStoryboard.init(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "SpecailPriceAlertID") as! SpecailPriceAlert
            DispatchQueue.main.async {
                specialPriceVCObj.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                specialPriceVCObj.senderView = self
                //specialPriceVCObj.customerID = NSNumber(value:custId)
                specialPriceVCObj.productID = self.productID
                specialPriceVCObj.price = self.specialPrice
                specialPriceVCObj.UOMId = self.uomID
                specialPriceVCObj.qtyPerUnit = self.qtyPerUnit
                if self.objproductDetail.keyExists(key: "IsInCart") ,let isInCart = self.objproductDetail["IsInCart"] as? Bool{
                    specialPriceVCObj.isInCart = isInCart
                }
                self.present(specialPriceVCObj, animated: false, completion: nil)
            }
        }
        
    }
    @IBAction func alternateItems_action(_ sender: Any)
    {
        if isSalesRep == true && AppFeatures.shared.isAdvancedPantry == true{
            //            if self.objproductDetail["IsAvailable"] as? Int == 1
            //            {
            let obj = self.objproductDetail
            self.addProductToCartWithDate(productDetail: obj, actualIndex: (sender as AnyObject).tag)
            //            }
            //            else{
            //                Helper.shared.showAlertOnController( message: "Product is not available", title: CommonString.alertTitle)
            //            }
        }
    }
    
    //MARK:- Call webservice
    func callAPIForGettingDescriptionOfProduct()
    {
        var request = [
            "productID": productID
            ] as [String:Any]
        
        request["isRepUser"] = UserInfo.shared.isSalesRepUser
        if AppFeatures.shared.isAdvancedPantry == false{
            request["CustomerID"] = UserInfo.shared.customerID!
        }
        else{
            request["CustomerID"] = NSNumber(value: Int(UserInfo.shared.customerID ?? "0")!)
        }
        request["UserID"] = UserInfo.shared.userId ?? ""
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: request, strURL: SyncEngine.baseURL + SyncEngine.getProductDetailByID) { (response : Any) in
            if let items = (response as? Dictionary<String,Any>)?["product"] as? Dictionary<String,Any>
            {
                self.objproductDetail = items
                
                DispatchQueue.main.async
                    {
                        self.setValues()
                        self.collectionVw_itemDescription.reloadData()
                        self.collectionVw_imageGallery.reloadData()
                }
            }
        }
    }
    
    func setValues(){
        
        print("checkkk1")
        // Product Name
        self.img_Product.tintColor = UIColor.baseBlueColor().withAlphaComponent(0.5)
        
//        if self.objproductDetail["IsStatusIN"] as? Bool == true{
//            self.lbl_productName.textColor = UIColor.blue
//        }else if let isCountrywideReward =  objproductDetail["IsCountrywideRewards"] as? Bool, isCountrywideReward == true {
//            self.lbl_productName.textColor = UIColor.primaryColor()
//        } else {
//            self.lbl_productName.textColor = UIColor.baseBlueColor()
//        }
        
        if AppFeatures.shared.isHighlightRewardItem
        {
            if let isCountrywideReward =  objproductDetail["IsCountrywideRewards"] as? Bool, isCountrywideReward == true
            {
                self.lbl_productName.textColor = UIColor.init(hex: "#b0cf00")
            }
            else
            {
                self.lbl_productName.textColor = UIColor.baseBlueColor()
            }
        }
        else
        {
            self.lbl_productName.textColor = UIColor.baseBlueColor()
        }
        if let isBuyIn =  objproductDetail["BuyIn"] as? Bool, isBuyIn == true
        {
            self.lbl_productName.textColor = UIColor.init(hex: "#2a99f3")
        }


        
        let desc1 = (self.objproductDetail["ProductName"] as? String) ?? ""
        let desc2 = self.objproductDetail["Description2"] as? String ?? ""
        let desc3 = self.objproductDetail["Description3"] as? String ?? ""
        var desc = String()
        if !desc1.isEmpty{
            desc += "\(desc1)"
        }
        if !desc2.isEmpty{
            desc += "\n\(desc2)"
        }
        if !desc3.isEmpty{
            desc += "\n\(desc3)"
        }
        self.lbl_productName.text = desc//((productDescDic)["ProductName"] as? String)
        // Supplier Name
        
        let barcode = (self.objproductDetail["Barcode"] as? String) ?? ""
       // self.lblBarcodeNum.text = barcode
        if AppFeatures.shared.isShowSupplier == false
        {
            self.lbl_supplierName.text = ""
            //            self.codeLeadingConstant.constant = 0.0
        }
        else
        {
            if let supplierName =  self.objproductDetail["Supplier"] as? String, supplierName != ""
            {
                self.lbl_supplierName.text = supplierName
            }
            else
            {
                self.lbl_supplierName.text = "N/A"
            }
        }
        
        // Product Code
        if let productCode = self.objproductDetail["ProductCode"] as? String
        {
            let code_str = String(format: "CODE : %@", productCode.uppercased())
            self.lbl_productCode.text = code_str
        }
        else
        {
            self.lbl_productCode.text = ""
        }
        
        DispatchQueue.main.async {
            self.lblProductStatus.layer.cornerRadius = 8.0
        }
        if let new = self.objproductDetail["IsNew"] as? Bool, new == true {
            self.lblProductStatus.text = "NEW"
            self.lblProductStatus.backgroundColor = UIColor.primaryColor()
        }else if let new = objproductDetail["IsOnSale"] as? Bool, new == true {
            self.lblProductStatus.text = "SALE"
            self.lblProductStatus.backgroundColor = UIColor.primaryColor2()
        }else if let new = objproductDetail["IsBackSoon"] as? Bool, new == true {
            self.lblProductStatus.text = "INCOMING"
            self.lblProductStatus.backgroundColor = UIColor.primaryColor3()
        }else{
            self.lblProductStatus.text = ""
        }
        
        
        if let isPantryItem =  objproductDetail["IsInPantry"] as? Bool, isPantryItem == true
        {
            btn_Favorite.isSelected = true
            btn_Favorite.setImage(#imageLiteral(resourceName: "selectedFavorite"), for: .normal)
        }
        else{
            btn_Favorite.isSelected = false
            btn_Favorite.setImage(#imageLiteral(resourceName: "unselected_Favorite"), for: .normal)
        }
        
        if let descriptionString = self.objproductDetail["Description"] as? String, descriptionString != ""
        {
            self.lblTitleFeatureAndSpecifications.attributedText = self.generateDescriptionStrleft(withInputStr:"Item Description" , string: descriptionString)
            self.lblTitleFeatureAndSpecifications.textAlignment = .left
        }
        else
        {
//            self.lblTitleFeatureAndSpecifications.attributedText = self.generateDescriptionStrleft(withInputStr:"Item Description" , string: "No description available.")
        }
        
        let feature1 = self.objproductDetail["Feature1"] as? String ?? ""
        let feature2 = self.objproductDetail["Feature2"] as? String ?? ""
        let feature3 = self.objproductDetail["Feature3"] as? String ?? ""
        let productFeature = self.objproductDetail["ProductFeature"] as? String ?? ""
print("checkkk2")
        
        var features = ""
        if !feature1.isEmpty{
            features = "\(feature1.replacingOccurrences(of: "\n", with: "<Br>"))"
        }
        if !feature2.isEmpty{
            if !features.isEmpty
            {
                features += "<BR>\(feature2.replacingOccurrences(of: "\n", with: "<Br>"))"
            }else {
                features += "<BR>\(feature2.replacingOccurrences(of: "\n", with: "<Br>"))"
            }
        }
        if !feature3.isEmpty{
            if !features.isEmpty
            {
                features += "<BR>\(feature3.replacingOccurrences(of: "\n", with: "<Br>"))"
            }else {
                features += "\(feature3.replacingOccurrences(of: "\n", with: "<Br>"))"
            }
        }
        if !productFeature.isEmpty{
            if !features.isEmpty
            {
                features += "<BR>\(productFeature.replacingOccurrences(of: "\n", with: "<Br>"))"
            }else {
                features += "\(productFeature.replacingOccurrences(of: "\n", with: "<Br>"))"
            }
        }

        if !features.isEmpty
        {
            DispatchQueue.main.async {
              self.lbl_Description.attributedText = self.generateDescriptionStr(withInputStr:"Item Inclusions" , string: features.replacingOccurrences(of: "\n", with: "<Br>"))
            }
        }else{
//            self.lbl_Description.attributedText = self.generateDescriptionStr(withInputStr:"Item Inclusions" , string: "No Inclusions available")
        }
        
        if self.objproductDetail["ProductImages"] as? Array<Dictionary<String,Any>> != nil
        {
            self.arr_Images = self.objproductDetail["ProductImages"] as! Array<Dictionary<String,String>>
            
            if self.arr_Images.count > 0
            {
                if !UserInfo.shared.isSalesRepUser! && !AppFeatures.shared.shoudlShowProductImages{
                    collectionVwImageGalleryHeight.constant = 0.0
                }else{
                    
                    self.img_Product.isUserInteractionEnabled = true
                    
                    let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tapOnProductImage(gesture:)))
                    self.img_Product.addGestureRecognizer(tapgesture)
                    self.img_Product.contentMode = .scaleAspectFit
                    let originalString:String = self.arr_Images[0]["ImageName"]!
                    let urlString:String = originalString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
                    
                    self.img_Product.setImageWith(URL(string: urlString), placeholderImage: #imageLiteral(resourceName: "ImagePlaceholder"))
                    
                    collectionVwImageGalleryHeight.constant = 60.0 *  VerticalSpacingConstraints.spacingConstant
                }
            }else{
                collectionVwImageGalleryHeight.constant = 0.0
            }
        }
        print("checkkk3")
        DispatchQueue.main.async {
            self.collectionVw_imageGallery.reloadData()
        }
        var arrPrices : Array<Dictionary<String,Any>>?
        if let prices = objproductDetail["DynamicUOM"] as? Array<Dictionary<String,Any>>
        {
            arrPrices = prices
        }
        else if let prices = objproductDetail["Prices"] as? Array<Dictionary<String,Any>>
        {
            arrPrices = prices
        }
        else if let prices = objproductDetail["Prices"] as? Dictionary<String,Any>
        {
            //            prices["UOMDesc"] = objproductDetail["UOMDesc"] as? String
            //            prices["UOMID"] = objproductDetail["UOMID"] as? NSNumber
            arrPrices = [prices]
        }
        
        if (arrPrices != nil), arrPrices!.count > 0
        {
            let testIndex = arrPrices?.index(where: { (testdic : Dictionary<String, Any>) -> Bool in
                testdic["UOMID"] as? NSNumber == objproductDetail["UOMID"] as? NSNumber
            })
            
            if (testIndex != nil)
            {
                objproductDetail["selectedIndex"] = testIndex
            }
            
            
            var selectedIndex = 0
            if let index = objproductDetail["selectedIndex"] as? Int
            {
                selectedIndex = index
            }
            
            let objToFetch = arrPrices![selectedIndex]
            if let price = objToFetch["Price"] as? Double
            {
                if (UserInfo.shared.isSalesRepUser == false && AppFeatures.shared.shouldShowProductPrice) || UserInfo.shared.isSalesRepUser == true
                {
                    let price_final = Double(round(100*price)/100)
                    let priceStr = String(format: "\(CommonString.currencyType)%.2f", price_final)
                    self.lbl_price.text = price <= 0 ? CommonString.marketprice:priceStr
                    uomID = (objToFetch["UOMID"] as? NSNumber)!
                    specialPrice = (objToFetch["Price"] as? NSNumber)!
                    qtyPerUnit = (objToFetch["QuantityPerUnit"] as? NSNumber) ?? 1
                    
                }
                else
                {
                    self.lbl_price.text = ""
                }
                if UserInfo.shared.isSalesRepUser == true{
                    if objToFetch["IsSpecial"] as? Bool == true && objToFetch["IsPromotional"] as? Bool == true{
                        lbl_price.textColor = UIColor.red
                    }
                    else if objToFetch["IsSpecial"] as? Bool == true{
                        lbl_price.textColor = UIColor.red
                    }
                    else if objToFetch["IsPromotional"] as? Bool == true{
                        lbl_price.textColor = UIColor.promotionalProductYellowColor()
                    }
                    else{
                        lbl_price.textColor = UIColor.priceInfoLightGreyColor()
                    }
                }
                else{
                    lbl_price.textColor = UIColor.baseBlueColor()
                }
//                if let packSize = objToFetch["QuantityPerUnit"] as? Int, AppFeatures.shared.isShowPackSize == true{
//                    self.lblQuantityPerUnit.isHidden = false
//                    self.strPackSize = "\(packSize)"
//                    self.lblQuantityPerUnit.text = "[CTN QTY: \(packSize)]"
//                }else{
//                    self.lblQuantityPerUnit.isHidden = true
//                }
            }
        
            self.lblQuantityPerUnit.text = ""
            self.lblQuantityPerUnit.isHidden = false

            var brandSupplierStr = String()
            brandSupplierStr = ""
            if AppFeatures.shared.shouldShowBrandNameInProductList
            {
                let brandName : String = (objproductDetail["Brand"] as? String)!
                brandSupplierStr = "BRAND: " + brandName
                self.lblQuantityPerUnit.text = brandSupplierStr
            }
            if AppFeatures.shared.isShowSupplier
            {
                let SupplierName : String = (objproductDetail["Supplier"] as? String)!
                brandSupplierStr = brandSupplierStr + "    SUPPLIER: " + SupplierName
                self.lblQuantityPerUnit.text = brandSupplierStr
            }

            
            if let strUOM = objToFetch["UOMDesc"] as? String
            {
                self.lbl_Each.text = strUOM
                
            }
            else
            {
                self.lbl_Each.text = objproductDetail["UOMDesc"] as? String
            }
            print("checkkk4")
            self.lbl_Each.textColor = UIColor.gray
            if objproductDetail.keyExists(key: "LastOrderUOMID"), let lastUom = objproductDetail["LastOrderUOMID"] as? Int, lastUom == objToFetch["UOMID"] as? Int, lastUom > 0{
                self.lbl_Each.textColor = UIColor.gray
            }
        }
        else
        {
            self.lbl_price.text = ""
            self.lbl_Each.text = objproductDetail["UOMDesc"] as? String
            if objproductDetail["UOMID"] as? NSNumber != nil{
                uomID = objproductDetail["UOMID"] as! NSNumber
            }
            if objproductDetail["Price"] as? NSNumber != nil{
                specialPrice = (objproductDetail["Price"] as! NSNumber)
            }
            if objproductDetail["QuantityPerUnit"] as? NSNumber != nil{
                qtyPerUnit = (objproductDetail["QuantityPerUnit"] as? NSNumber) ?? 1
            }
        }
        
        if let obj = self.objproductDetail["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1
        {
            arrowUOMDropdown.constant = 10.0
            img_UOMDropdown.isHidden=false
        }
        else
        {
            arrowUOMDropdown.constant = 0.0
            img_UOMDropdown.isHidden=true
        }
        
        if self.objproductDetail.keyExists(key: "IsInCart") ,let isInCart = self.objproductDetail["IsInCart"] as? Bool{
            self.imgVwCartIcon.image = isInCart ? #imageLiteral(resourceName: "LS_green-cart"):#imageLiteral(resourceName: "LS_add_to_cart")
        }
        
        if AppFeatures.shared.isShareButtons{
            self.cnstShareButtonWidth.constant = 40.0
        }
        
//        self.clctn_weekCount.backgroundColor = UIColor.red
        self.clctn_weekCount.reloadData()
        self.getProductImages()
    }
    
    func getProductImages(){
        print("checkkk5")
        self.productImages.removeAll()
        for image in arr_Images{
            DispatchQueue.main.async{
            if self.arr_Images.count > 0{
                print("checkkk6")
                var imgUrl = image["ImageName"] ?? ""
                imgUrl = imgUrl.replacingOccurrences(of: " ", with: "")
                
                let url: NSURL = NSURL(string: imgUrl)!
                do {
//                    let imgData = try NSData(contentsOf: url as URL, options: NSData.ReadingOptions())
                    self.productImages.append(imgUrl)
                   
                } catch {
                    return
                }
            }
                 //self.collectionVw_imageGallery.reloadData()
            }
        }
    }
    
    func adjustFontSizeAsPerScreen() -> Void
    {
        self.lbl_productName.font = UIFont.SFUI_Bold(baseScaleSize: 14) //..SFUI_Regular(baseScaleSize: 18.0)
        
        self.lbl_price.font = UIFont.SFUI_SemiBold(baseScaleSize: 16.0)
        self.lbl_supplierName.font = UIFont.SFUI_Regular(baseScaleSize: 14.0)
        self.lbl_productCode.font = UIFont.SFUI_Regular(baseScaleSize: 14.0)
        self.lblProductStatus.font = UIFont.SFUI_Regular(baseScaleSize: 14.0)
        self.lblQuantityPerUnit.font = UIFont.SFUI_Regular(baseScaleSize: 14.0)
        self.lblBarcodeNum.font = UIFont.SFUI_Regular(baseScaleSize: 14.0)
        self.lbl_Description.font = UIFont.SFUI_Regular(baseScaleSize: 14.0)
        self.lbl_exGST.font = UIFont.SFUI_Regular(baseScaleSize: 12.0)
        self.btn_AddToCart.titleLabel?.font = UIFont.SFUI_SemiBold(baseScaleSize: 12.0)
        self.btn_specialPrice.titleLabel?.font = UIFont.SFUI_SemiBold(baseScaleSize: 12.0)
        self.btnAlternateItems.titleLabel?.font = UIFont.SFUI_SemiBold(baseScaleSize: 12.0)
        self.btn_Favorite.imageView?.tintColor = UIColor.yellowStarColor()
        self.lblTitleFeatureAndSpecifications.font = UIFont.SFUI_Regular(baseScaleSize: 14.0)
        self.lblDetailFeaturesAndSpecifications.font = UIFont.SFUI_Regular(baseScaleSize: 12.0)
        self.lbl_Each.font = UIFont.SFUI_Regular(baseScaleSize: 14.0)
        
        self.btn_specialPrice.backgroundColor = UIColor.baseBlueColor()
        
        self.btnAlternateItems.backgroundColor = UIColor.primaryColor()
        
        self.btn_AddToCart.backgroundColor = UIColor.primaryColor2()
    }
    
    @objc func backBtnAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnItemEnquiryAction(_ sender: UIButton) {
        
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
            let objForEnquiry =  self.objproductDetail
            if let enquiryPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:"addEnquiryPopupSroryID") as? AddNewEnquiryPopup
            {
                enquiryPopup.itemForEnquiry = objForEnquiry
                enquiryPopup.parentView = self
                UIApplication.shared.keyWindow?.rootViewController?.present(enquiryPopup, animated: false, completion: nil)
            }
        }
    }
    func generateDescriptionStrleft(withInputStr header:String, string : String) -> NSAttributedString
    {
        let attrStr = NSMutableAttributedString()
        let headingAttrStr = NSAttributedString(string: "\(header)\n\n", attributes: [NSAttributedStringKey.font : UIFont.SFUI_SemiBold(baseScaleSize: 18.0), NSAttributedStringKey.foregroundColor : UIColor.activeTextFieldColor()])
        let textAttrStr = string.convertHtmlToAttributedStringWithCSS(font: UIFont(name: "Arial", size: 16), csscolor: "black", lineheight: 5, csstextalign: "left")
        
        attrStr.append(headingAttrStr)
        attrStr.append(textAttrStr!)
        return attrStr
    }

    func generateDescriptionStr(withInputStr header:String, string : String) -> NSAttributedString
    {
        let attrStr = NSMutableAttributedString()
        let headingAttrStr = NSAttributedString(string: "\(header)\n\n", attributes: [NSAttributedStringKey.font : UIFont.SFUI_SemiBold(baseScaleSize: 18.0), NSAttributedStringKey.foregroundColor : UIColor.activeTextFieldColor()])
        let textAttrStr = string.convertHtmlToAttributedStringWithCSS(font: UIFont(name: "Arial", size: 16), csscolor: "black", lineheight: 5, csstextalign: "center")
        
        attrStr.append(headingAttrStr)
        attrStr.append(textAttrStr!)
        return attrStr
    }
    
    func addProductToFavoriteList(){
        
        if AppFeatures.shared.isFavoriteList{
            if let chooseFavorite = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "choosefavouriteListPopupStoryboardIdentifier") as? ChooseFavouriteListPopup{
                chooseFavorite.productID = productID
                chooseFavorite.productID = productID
                chooseFavorite.showCommonAlertOnWindow(completion: { (isFav : Bool) in
                    self.objproductDetail["IsInPantry"] = isFav
                    self.setValues()
                })
            }
        }else{
            self.addItemToDefaultPantry(productID: productID)
        }
    }
    
    func addItemToDefaultPantry(productID : NSNumber?){
        
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
                    
                    self.objproductDetail["IsInPantry"] = true
                    self.setValues()
                    debugPrint("addItemToPantryList API call Alert 1")

                    Helper.shared.showAlertOnController(message: "Product added successfully.", title: CommonString.app_name,hideOkayButton: true)
                    Helper.shared.dismissAlert()
                }
            }
        }
    }
    
    func addProductToCartWithDate ( productDetail : Dictionary<String, Any>, actualIndex : Int = -1)
    {
        if UserInfo.shared.isGuest == true
        {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.guestUser, withCancelButtonTitle: "OK", completion: {
                Helper.shared.logoutAsGuest()
                return
            })
        }
        else if UserInfo.shared.customerOnHoldStatus == true && UserInfo.shared.isSalesRepUser == false && !AppFeatures.shared.isAllowOnHoldPlacingOrder{
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                return
            })
        }
        else{
            
            if AppFeatures.shared.IsDatePickerEnabled == true {
                
                if true
                {
                    self.showBuyInPopup(productDetail: productDetail, actualIndex: actualIndex)
                }else{
                    
                    self.showDeliveryTypePopup {
                        self.showBuyInPopup(productDetail: productDetail, actualIndex: actualIndex)
                    }
                }
            }else{
                self.showBuyInPopup(productDetail: productDetail, actualIndex: actualIndex)
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
        }else{
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
        self.objproductDetail["Quantity"] = qtyValue
        if !AppFeatures.shared.isBackOrder{
            self.objproductDetail["Quantity"] = qtyValue
            self.checkOrderMultiplies(productDetail: self.objproductDetail, actualIndex: actualIndex)
        }else if sohValue > qtyValue{
            self.objproductDetail["Quantity"] = qtyValue
            self.checkOrderMultiplies(productDetail: self.objproductDetail, actualIndex: actualIndex)
        }else{
            if let buyInPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:SaaviActionAlert.storyboardIdentifier) as? SaaviActionAlert
            {
                if sohValue <= 0{
                    
                    buyInPopup.showCommonAlertOnWindow(withTitle: "Important", withSuccessButtonTitle: "", withMessage: "Sorry, this product is out of stock at this moment.", withCancelButtonTitle: "Ok") {
                        self.objproductDetail["Quantity"] = 0.0
                        self.collectionVw_itemDescription.reloadData()
                        self.setValues()
                    }
                }else if sohValue < qtyPerUnit || (sohValue < qtyValue && qtyPerUnit != 1) {
                    
                    buyInPopup.showCommonAlertOnWindow(withTitle: "Important", withSuccessButtonTitle: "", withMessage: "Sorry, there are only \(sohValue) units available. Only this quantity will be added to the cart", withCancelButtonTitle: "Ok") {
                        
                        
                        if let obj = productDetail["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1{
                            
                            for index in 0..<arrPrices!.count
                            {
                                let objToFetch = arrPrices![index]
                                if let packSize = objToFetch["QuantityPerUnit"] as? Int {
                                    
                                    if packSize == 1{
                                        self.objproductDetail["Quantity"] = sohValue
                                        self.objproductDetail["UnitName"] = objToFetch["UOMDesc"] as? String
                                        self.objproductDetail["OrderUnitName"] = objToFetch["UOMDesc"] as? String
                                        self.objproductDetail["UOMID"] = objToFetch["UOMID"] as? NSNumber
                                        self.objproductDetail["OrderUnitId"] = objToFetch["UOMID"] as? NSNumber
                                        self.objproductDetail["Price"] = objToFetch["Price"]
                                        self.objproductDetail["IsSpecial"] = objToFetch["IsSpecial"]
                                        self.objproductDetail["IsPromotional"] = objToFetch["IsPromotional"]
                                        self.objproductDetail["QuantityPerUnit"] = objToFetch["QuantityPerUnit"]
                                        self.objproductDetail["selectedIndex"] = index
                                        self.collectionVw_itemDescription.reloadData()
                                        self.checkOrderMultiplies(productDetail: self.objproductDetail, actualIndex: actualIndex)
                                        break
                                    }
                                }
                            }
                        }
                    }
                    
                }else {
                    buyInPopup.showCommonAlertOnWindow(withTitle: "Important", withSuccessButtonTitle: "",  withMessage: "Your order quantity is greater than the stock on hand quantity of \(sohValue). Only the available quantity will be added to the cart.",   withCancelButtonTitle: "Ok") {
                        
                        self.objproductDetail["Quantity"] = Int(sohValue/qtyPerUnit)
                        self.collectionVw_itemDescription.reloadData()
//                        self.checkOrderMultiplies(productDetail: self.objproductDetail, actualIndex: actualIndex)
                        self.addProductToCart(productDetail: productDetail, actualIndex: actualIndex, quantityVal :  Int(sohValue/qtyPerUnit))

                        self.setValues()
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
//                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: "This item can only be ordered in multiples of \(quantityPerUnit). We are adding \(unitToBedded.cleanValue) to the cart.", withCancelButtonTitle: "OK", completion: {

                    self.addProductToCart(productDetail: productDict, actualIndex: actualIndex)
//                })
            }
        }else{
            self.addProductToCart(productDetail: productDetail, actualIndex: actualIndex)
        }
    }
    
    //MARK: - - Share Button Action
    @IBAction func btnShareAction(_ sender: UIButton) {
        
        let text = "\(self.objproductDetail["ShareURL"] ?? "")"
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    //MARK: - - Add To Cart Button
    func addProductToCart(productDetail : Dictionary<String, Any>, actualIndex : Int = -1, quantityVal: Int = 0){

        var quantity : Int = 0
        if quantityVal == 0 {
            quantity = Int(truncating: (productDetail.keyExists(key: "Quantity") && productDetail["Quantity"] as? NSNumber != nil && Float(truncating: productDetail["Quantity"] as! NSNumber) != 0) ? (productDetail["Quantity"] as! NSNumber) : 1)
        }else{
            quantity = quantityVal
        }

        let objToFetch =  Helper.shared.getSelectedUOM(productDetail: productDetail)
        let customerId : String = UserInfo.shared.customerID ?? "0"
        let requestDic = [
            "CartID": 0,
            "CustomerID": customerId,
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
                "UnitId": objToFetch["UOMID"],
                "IsSpecialPrice":  objToFetch["IsSpecial"]
            ]
            ] as [String : Any]
        
        let serviceURL = SyncEngine.baseURL + SyncEngine.addItemsToCart
        
        var uomDesc:String = ""
        
        switch objToFetch["UOMDesc"] as? String {
        case "EA","ea","Ea","EACH","each","Each":
            
            //                if AppFeatures.shared.isOrderMultiples{
            //
            //                }
            
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
            Helper.shared.dismissAlert()

            if let isAlreadyInCart = self.objproductDetail["IsInCart"] as? Bool, isAlreadyInCart == false
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

                
//                Helper.shared.showAlertOnController(message: startStr + " added to cart successfully", title: productDetail["ProductName"] as! String,hideOkayButton: true
                    Helper.shared.showAlertOnController(message:"Added to cart successfully", title: "",hideOkayButton: true

                )
                Helper.shared.dismissAddedToCartAlert()
                self.popToBarScanViewController()
                }
            }
            else
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

//                    Helper.shared.showAlertOnController(message: startStr + " updated in cart successfully", title: productDetail["ProductName"] as! String,hideOkayButton: true
                    Helper.shared.showAlertOnController(message:"Updated in cart successfully", title: "",hideOkayButton: true

                    )
                    Helper.shared.dismissAddedToCartAlert()
                    self.popToBarScanViewController()
                }
            }
            NotificationCenter.default.post(name: Notification.Name("addToCart"), object: nil, userInfo: ["ProductID": self.productID ,"Quantity": ((requestDic["CartItem"] as! Dictionary<String,Any>)["Quantity"] as! NSNumber)])
            
            if actualIndex > -1
            {
                self.objproductDetail["IsInCart"] = true
                self.objproductDetail["Quantity"] = quantity
                DispatchQueue.main.async {
                    self.setValues()
                    self.collectionVw_itemDescription.reloadData()
                    self.collectionVw_imageGallery.reloadData()
                }
            }
            
            self.callAPIToUpdateCartNumber()
        }
    }
    
    private func popToBarScanViewController(){
        DispatchQueue.main.async {
            if self.isMoveBack{
                
                for controller in self.navigationController!.viewControllers as Array {
                    if controller is BarCodeScanViewController{
                        self.navigationController!.popToViewController(controller, animated: true)
                        break
                    }
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
    
    @objc func showQuantityPopupAction(_ sender : UIButton?)
    {
        let stockQuantity = self.objproductDetail["StockQuantity"] as? Double ?? 0.0
        
        if stockQuantity != 0.0 {
            
            let cell = self.collectionVw_itemDescription.cellForItem(at: IndexPath.init(row: (sender?.tag)!, section: 0)) as? QuantityCiollectionCell
            
            if AppFeatures.shared.IsDatePickerEnabled == true{
                if true{
                    if AppFeatures.shared.IsShowQuantityPopup == true{
                        self.renderQuantityPopUp(cell: cell, sender: sender)
                    }else{
                        if cell != nil {
                            self.txtFldActive = (cell?.txtFldQty)!
                            self.txtFldActive.becomeFirstResponder()
                            self.txtFldActive.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonClicked))
                        }
                    }
                }else{
                    self.showDeliveryTypePopup {
                        self.showQuantityPopupAction(sender)
                    }
                }
            }else  if AppFeatures.shared.IsShowQuantityPopup{
                self.renderQuantityPopUp(cell: cell, sender: sender)
            }else{
                if cell != nil {
                    self.txtFldActive = (cell?.txtFldQty)!
                    self.txtFldActive.becomeFirstResponder()
                    self.txtFldActive.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonClicked))
                }
            }
        }else {
            Helper.shared.showAlertOnController( message: "No stock available", title: CommonString.alertTitle)
        }

    }
    
    @objc func doneButtonClicked(_ sender: Any) {
        let stockQuantity = self.objproductDetail["StockQuantity"] as? Double ?? 0.0
        
        if stockQuantity != 0.0 {
            
            self.scrollView.isScrollEnabled = true
            var product = objproductDetail
            let qtyDoubleValue:Double = (self.txtFldActive.text?.isEmpty)! ? 1.00:Double(txtFldActive.text!)!
            let qtyValue = qtyDoubleValue < 0 ? 1.00:qtyDoubleValue
            product["Quantity"] = NSNumber(value: qtyValue)
            objproductDetail = product
            //self.addProductToCartWithDate(productDetail: objproductDetail)
            self.checkMinAndMaxOrderQuantity(productValue: product, index: 0, quantity: NSNumber(value:qtyValue))
            self.collectionVw_itemDescription.reloadData()
        }else {
            Helper.shared.showAlertOnController( message: "No stock available", title: CommonString.alertTitle)
        }

    }
    
    func renderQuantityPopUp(cell:QuantityCiollectionCell?, sender:UIButton?){
        if cell != nil{
            if let index = self.collectionVw_itemDescription.indexPath(for: cell!){
                var product = objproductDetail

                if let circularPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "circularQuantityStoryboardID") as? CircularQuantityPopup{
                    
                    circularPopup.quantityPerUnit = Helper.shared.getSelectedUomNameQuantity(product: product).quantity
                    circularPopup.isEach =  Helper.shared.getSelectedUomNameQuantity(product: product).isEach
                    
                    if product.keyExists(key: "Quantity"){
                        
                        circularPopup.circularSlider.currentValue = Float(truncating: (( product["Quantity"]) as? NSNumber)!)
                        circularPopup.currentQuantity = String(format: "%.2f", Double(truncating: (( product["Quantity"]) as? NSNumber)!))  //"\(Int(truncating: (( product["Quantity"]) as? NSNumber)!))"
                        circularPopup.showCommonAlertOnWindow{
                            product["Quantity"] = NSNumber(value: Double(circularPopup.txtFldQuantity.text!)!)
                            //self.objproductDetail = product
                            self.collectionVw_itemDescription.reloadData()
                            if UserInfo.shared.isGuest == true
                            {
                                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.guestUser, withCancelButtonTitle: "OK", completion: {
                                    Helper.shared.logoutAsGuest()
                                    return
                                })
                            }
                            else if UserInfo.shared.isSalesRepUser == false || AppFeatures.shared.isAdvancedPantry == false{
                                if UserInfo.shared.customerOnHoldStatus == true && AppFeatures.shared.isBrowsingEnabledForHoldCust == true && !AppFeatures.shared.isAllowOnHoldPlacingOrder{
                                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: { })
                                }else{
                                    self.checkMinAndMaxOrderQuantity(productValue: product, index: (sender as AnyObject).tag, quantity: NSNumber(value: Double(circularPopup.txtFldQuantity.text!)!))
                                }
                                self.collectionVw_itemDescription.reloadData()
                            }else{
                                self.objproductDetail["Quantity"] = Double(circularPopup.txtFldQuantity.text!)!
                                self.addProductToCartWithDate(productDetail: product, actualIndex: (sender as AnyObject).tag)
                            }
                        }
                    }else{
                        circularPopup.circularSlider.currentValue = 1.0
                        circularPopup.showCommonAlertOnWindow{
                            product["Quantity"] = NSNumber(value: Double(circularPopup.txtFldQuantity.text!)!)
                            self.objproductDetail = product
                            self.collectionVw_itemDescription.reloadData()
                        }
                    }
                    
                    if let bool = product["IsInCart"] as? Bool, bool == true{
                        circularPopup.btnAddToCart.setTitle("UPDATE CART", for: .normal)
                    }
                }
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
        else if UserInfo.shared.customerOnHoldStatus == true && !AppFeatures.shared.isAllowOnHoldPlacingOrder
        {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                return
            })
            
        }else{
            
            var product = productValue
            if product["Quantity"]  as? NSNumber == nil{
                product["Quantity"] = 1.0
            }
            
            let minQty = (product["MinOQ"] as? Int ?? 0)
            let maxQty = (product["MaxOQ"] as? Int ?? 0)
            let qtyPerUnit = Int(Helper.shared.getPackSize(dic: productValue))
            
            if AppFeatures.shared.isMinOrderQuantity == true && AppFeatures.shared.isMaxOrderQuantity == true {
                if (Int(truncating: NSNumber(value: minQty))/qtyPerUnit) > Int(truncating: (product["Quantity"] as? NSNumber)!) && NSNumber(value: minQty) != 0
                {
                    let msgString = "This item has a minimum order quantity of \( Int(truncating: NSNumber(value: minQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: minQty))) \("units to cart ?")"
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                        self.objproductDetail["Quantity"] = minQty/qtyPerUnit
                        self.collectionVw_itemDescription.reloadData()
                        self.addProductToCartWithDate(productDetail: self.objproductDetail, actualIndex: index)
                    })
                }
                else if (Int(truncating: NSNumber(value: maxQty))/qtyPerUnit) < Int(truncating: (product["Quantity"] as? NSNumber)!) && NSNumber(value: maxQty) != 0
                {
                    let msgString = "This item has a maximum order quantity of \( Int(truncating: NSNumber(value: maxQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: maxQty))) \("units to cart ?")"
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                        self.objproductDetail["Quantity"] = maxQty/qtyPerUnit
                        self.collectionVw_itemDescription.reloadData()
                        self.addProductToCartWithDate(productDetail: self.objproductDetail, actualIndex: index)
                    })
                }
                else{
                    self.objproductDetail["Quantity"] = quantity
                    self.addProductToCartWithDate(productDetail: self.objproductDetail, actualIndex: index)
                }
            }
            else if  AppFeatures.shared.isMinOrderQuantity == true {
                if (Int(truncating: NSNumber(value: minQty))/qtyPerUnit) > Int(truncating: (product["Quantity"] as? NSNumber)!) && NSNumber(value: minQty) != 0
                {
                    let msgString = "This item has a minimum order quantity of \( Int(truncating: NSNumber(value: minQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: minQty))) \("units to cart ?")"
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                        self.objproductDetail["Quantity"] = minQty/qtyPerUnit
                        self.collectionVw_itemDescription.reloadData()
                        self.addProductToCartWithDate(productDetail: self.objproductDetail, actualIndex: index)
                    })
                }
                else if  AppFeatures.shared.isMaxOrderQuantity == true {
                    if (Int(truncating: NSNumber(value: maxQty))/qtyPerUnit) < Int(truncating: (product["Quantity"] as? NSNumber)!) && NSNumber(value: maxQty) != 0
                        
                    {
                        let msgString = "This item has a maximum order quantity of \( Int(truncating: NSNumber(value: maxQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: maxQty))) \("units to cart ?")"
                        SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                            self.objproductDetail["Quantity"] = maxQty/qtyPerUnit
                            self.collectionVw_itemDescription.reloadData()
                            self.addProductToCartWithDate(productDetail: self.objproductDetail, actualIndex: index)
                        })
                    }
                }
                else{
                    self.objproductDetail["Quantity"] = quantity
                    self.addProductToCartWithDate(productDetail: self.objproductDetail, actualIndex: index)
                }
            }
            else if  AppFeatures.shared.isMaxOrderQuantity == true {
                if (Int(truncating: NSNumber(value: maxQty))/qtyPerUnit) < Int(truncating: (product["Quantity"] as? NSNumber)!) && NSNumber(value: maxQty) != 0
                {
                    let msgString = "This item has a maximum order quantity of \( Int(truncating: NSNumber(value: maxQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: maxQty))) \("units to cart ?")"
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                        self.objproductDetail["Quantity"] = maxQty/qtyPerUnit
                        self.collectionVw_itemDescription.reloadData()
                        self.addProductToCartWithDate(productDetail: self.objproductDetail, actualIndex: index)
                    })
                }
                else{
                    self.objproductDetail["Quantity"] = quantity
                    self.addProductToCartWithDate(productDetail: self.objproductDetail, actualIndex: index)
                }
            }
            else{
                self.objproductDetail["Quantity"] = quantity
                self.addProductToCartWithDate(productDetail: self.objproductDetail, actualIndex: index)
            }
        }
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
        if true
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
    
    func uOMChanged()
    {
        if let obj = self.objproductDetail["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1
        {
            var index : Int = 0
            if let selectedIndex = self.objproductDetail["selectedIndex"] as? Int
            {
                index = selectedIndex
            }
            
            if index + 1 < obj.count
            {
                var objToChange = self.objproductDetail
                var newObj = obj[index+1]
                objToChange["UnitName"] = newObj["UOMDesc"] as? String
                objToChange["OrderUnitName"] = newObj["UOMDesc"] as? String
                objToChange["UOMID"] = newObj["UOMID"] as? NSNumber
                objToChange["OrderUnitId"] = newObj["UOMID"] as? NSNumber
                objToChange["Price"] = newObj["Price"]
                objToChange["IsSpecial"] = newObj["IsSpecial"]
                objToChange["IsPromotional"] = newObj["IsPromotional"]
                objToChange["QuantityPerUnit"] = newObj["QuantityPerUnit"]
                objToChange["selectedIndex"] = index + 1
                self.objproductDetail = objToChange
                setValues()
            }
            else
            {
                var objToChange = self.objproductDetail
                objToChange["selectedIndex"] = 0
                var newObj = obj[0]
                objToChange["selectedIndex"] = 0
                objToChange["UnitName"] = newObj["UOMDesc"] as? String
                objToChange["OrderUnitName"] = newObj["UOMDesc"] as? String
                objToChange["UOMID"] = newObj["UOMID"] as? NSNumber
                objToChange["OrderUnitId"] = newObj["UOMID"] as? NSNumber
                objToChange["Price"] = newObj["Price"]
                objToChange["IsSpecial"] = newObj["IsSpecial"]
                objToChange["IsPromotional"] = newObj["IsPromotional"]
                objToChange["QuantityPerUnit"] = newObj["QuantityPerUnit"]
                self.objproductDetail = objToChange
                setValues()
            }
        }
    }
    @objc func setDefaultNavigation() -> Void
    {
        if UserInfo.shared.isSalesRepUser == true{
            self.navigationItem.rightBarButtonItems = nil
            Helper.shared.createCartIcon(onController: self)
            Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
            if UserInfo.shared.isSalesRepUser! {
                Helper.shared.setNavigationTitle(viewController: self, title: UserInfo.shared.navigationTitle )
            }else {
                Helper.shared.setNavigationTitle(viewController: self, title: "Product Detail")
            }
        }
        else{
            self.navigationItem.rightBarButtonItems = nil
            Helper.shared.createCartIcon(onController: self)
            Helper.shared.createLatestSpecialsBarButtonItem(onController: self)
            Helper.shared.setNavigationTitle(viewController: self, title: "")
            if UserInfo.shared.isSalesRepUser! {
                Helper.shared.setNavigationTitle(withTitle: UserInfo.shared.navigationTitle, withLeftButton: .backButton, onController: self)
            }else {
                Helper.shared.setNavigationTitle(withTitle: "Product Detail", withLeftButton: .backButton, onController: self)
            }
        }
    }
    //    func backAction(_ button : UIButton)
    //    {
    //        self.navigationController?.popViewController(animated: false)
    //    }
    
    @objc func showCartScreen() -> Void
    {
        if UserInfo.shared.isSalesRepUser == true && AppFeatures.shared.isAdvancedPantry == true{
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                
                if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cartVCStoryboardID") as? CartView
                {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else{
                
                if let vc = UIStoryboard.init(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "MyCartVC") as? MyCartVC
                {
                    
                    //vc.customerId = NSNumber(value: Int(UserInfo.shared.customerID ?? "0")!) //self.salesRepCustomerId
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        else{
            
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

class ListCollectionCell : UICollectionViewCell
{
    @IBOutlet weak var lbl_list: UILabel!
    @IBOutlet weak var lbl_ListValue: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.lbl_list.font = UIFont.SFUI_SemiBold(baseScaleSize: 13.0)
        self.lbl_ListValue.font = UIFont.SFUI_Regular(baseScaleSize: 15.0)
    }
}


class QuantityCiollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var lbl_ListQty: UILabel!
    @IBOutlet weak var lbl_QtyValue: UILabel!
    @IBOutlet weak var btn_Qty: UIButton!
    @IBOutlet weak var btn_addQty: UIButton!
    @IBOutlet weak var txtFldQty: UITextField!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.txtFldQty.keyboardType = UserInfo.shared.isSalesRepUser! ? .decimalPad:AppFeatures.shared.IsAllowDecimal ? .decimalPad:.numberPad
        self.lbl_ListQty.font = UIFont.SFUI_SemiBold(baseScaleSize: 13.0)
        self.txtFldQty.font = UIFont.SFUI_Regular(baseScaleSize: 13.0)
        self.btn_Qty.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 13.0)
        self.btn_Qty.backgroundColor = UIColor.baseBlueColor()
        self.txtFldQty.layer.borderWidth = 1.0
        self.txtFldQty.layer.borderColor = UIColor.baseBlueColor().cgColor
    }
}

class ItemsCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var img_ProductListImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
class WeekCollectionCell: UICollectionViewCell {
    
    @IBOutlet var lbl_week_count: UILabel!
    @IBOutlet weak var lbl_WeekCount: customLabelGrey!
    @IBOutlet weak var lbl_WeekValue: customLabelGrey!
    override func awakeFromNib()
    {
        self.lbl_week_count.font = UIFont.SFUI_SemiBold(baseScaleSize: 11.0)
        self.lbl_week_count.textColor = UIColor.priceInfoLightGreyColor()
        self.lbl_WeekValue.font = UIFont.SFUI_Regular(baseScaleSize: 12.0)
    }
}


//MARK: - - TextField Delegates
extension OrderDescriptionView:UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        self.scrollView.isScrollEnabled = false
        if AppFeatures.shared.IsShowQuantityPopup{
            return false
        }else{
            tempString = textField.text ?? ""
            textField.text = ""
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == self.txtFldActive{
            self.scrollView.isScrollEnabled = true
            self.txtFldActive.text = ((textField.text?.isEmpty)!) ? (AppFeatures.shared.IsAllowDecimal ? 0.00.cleanValue: UserInfo.shared.isSalesRepUser! ? 0.00.cleanValue:"0"):textField.text
            self.collectionVw_itemDescription.reloadData()
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        isTxtFieldChanged = true
        if !AppFeatures.shared.IsAllowDecimal{
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
    
}

extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}

extension OrderDescriptionView: LightboxControllerPageDelegate ,LightboxControllerDismissalDelegate{
    
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        
    }
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
    }
}
