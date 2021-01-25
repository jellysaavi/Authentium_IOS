//
//  CartView.swift
//  Saavi
//
//  Created by Sukhpreet on 25/09/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit
import Lightbox

class CartView: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate {
    
    var arrCartItems = Array<Dictionary<String,Any>>()
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var staticLabelAddComment: UILabel!
    @IBOutlet weak var textViewAddComment: UITextView!
    @IBOutlet weak var btnClearComment: UIButton!
    var isShowingOrderDetails : Bool = false
    @IBOutlet weak var cnstViewCommentBoxHeight: NSLayoutConstraint!
    var orderID : NSNumber?
    var isShowingSavedOrder = false
    var selectedIndexPathArray = Array<Int>()
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var viewCommentBox: UIView!
    var isOnlyDonationBox = true
    var donationPrice: Double = 0.0
    
    /*Variables for PO Number*/
    @IBOutlet weak var poPopupView: UIView!
    @IBOutlet weak var poPopupBoudingView: UIView!
    @IBOutlet weak var lblstaticHeadingPONumber: UILabel!
    @IBOutlet weak var txtFldPONumber: CustomTextField!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnAddPONumber: UIButton!
    
    @IBOutlet weak var btnAddItem: UIButton!
    
    @IBOutlet weak var btnPlaceOrder: UIButton!
    @IBOutlet weak var btnSaveOrder: UIButton!
    @IBOutlet weak var staticLblSelect: UILabel!
    
    @IBOutlet weak var viewAmount: UIView!
    @IBOutlet weak var lblTitleSubTotal: UILabel!
    @IBOutlet weak var lblSubTotal: UILabel!
   
    @IBOutlet weak var viewPromo: UIView!
    
    @IBOutlet weak var viewFreight: UIView!
    @IBOutlet weak var btnAddPromo: UILabel!
    
    @IBOutlet weak var lblPromo: UILabel!
    @IBOutlet weak var lblDicount: UILabel!
    @IBOutlet weak var viewAmountHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveOrderHeightConstraint: VerticalSpacingConstraints!
    @IBOutlet weak var placeOrderBtnHeightConstraint: VerticalSpacingConstraints!
    @IBOutlet weak var addItemsHeightConstraint: VerticalSpacingConstraints!
    @IBOutlet weak var verticalSpacingBwSaveAndPlace: NSLayoutConstraint!
    
    
    @IBOutlet weak var lblFreight: UILabel!
    @IBOutlet weak var lblcharges: UILabel!
    
    var commentID : NSNumber?
    var orderCommentID : NSNumber?
    var commentString : String?
    var poNumber: String?
    var addressId : NSNumber = 0
    var tempCartID : NSNumber = 0
    var isFrieghtChargesApplicable = false
    var txtFldActive = UITextField()
    var selectedIndex : Int = 0
    var autoAuthorize : Bool?
    var suggestionloaded = false
    var promoApplied =  false;
    var minCartValue : Double?
    var cartTotal : Double?
    var discount : Double = 0.0
    var orderTotal : Double?
    var pickupAddress : NSNumber = 0
    var isRecurringOrder = Bool()
    var RecurrCartID : NSNumber = 0

    
    
    @IBOutlet weak var lblTotalOrderValue : UILabel?
    
    //    MARK:- View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isRecurringOrder = false
        
        if self.isShowingOrderDetails && self.orderID != nil
        {
            //            self.getOrderDetails()
            NotificationCenter.default.addObserver(self, selector: #selector(CartView.setDefaultNavigation), name: NSNotification.Name(rawValue: "cartCountChanged"), object: nil)
        }else{
            self.createTotalCartValueLabel()
            //            self.getCartItems()
            self.textViewAddComment.contentInset = UIEdgeInsets(top: 1, left: 5, bottom: 1, right: 5)
            self.txtFldPONumber.delegate = self
        }
        self.cartTableView.estimatedRowHeight = 70
        self.cartTableView.rowHeight = UITableViewAutomaticDimension
        self.viewPromo.isHidden = true
        self.viewPromo.isHidden = true
        self.lblFreight.isHidden = true
        self.lblFreight.isHidden = true
        self.lblPromo.isHidden = true
        self.lblDicount.isHidden = true
        
        DispatchQueue.main.async {
            self.btnAddItem.layer.cornerRadius = 15.0
            self.btnAddItem.titleLabel?.font = UIFont.Roboto_Bold(baseScaleSize: 18.0)
            self.btnSaveOrder.layer.cornerRadius = 15.0
            self.btnSaveOrder.titleLabel?.font = UIFont.Roboto_Bold(baseScaleSize: 18.0)
            self.btnPlaceOrder.layer.cornerRadius = 15.0
            self.btnPlaceOrder.titleLabel?.font = UIFont.Roboto_Bold(baseScaleSize: 18.0)
            
            self.btnAddItem.backgroundColor = UIColor.primaryColor()
            self.btnPlaceOrder.backgroundColor = UIColor.primaryColor2()
            self.btnSaveOrder.backgroundColor = UIColor.primaryColor()

        }
       // self.viewPromo.isHidden = true
        self.staticLabelAddComment.font = UIFont.Roboto_Italic(baseScaleSize: 15.0)
        self.lblstaticHeadingPONumber.font = UIFont.SFUIText_Semibold(baseScaleSize: 15.0)
        self.poPopupBoudingView.layer.cornerRadius = 0.7 * Configration.scalingFactor()
        
        self.viewCommentBox.layer.borderWidth = 1.0
        self.viewCommentBox.layer.borderColor = UIColor.init(red: 229.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1.0).cgColor
        self.viewCommentBox.layer.cornerRadius = 5.0 * Configration.scalingFactor()
        self.txtFldPONumber.applyBorder()
        self.textViewAddComment.font = UIFont.Roboto_Italic(baseScaleSize: 15.0)
        self.textViewAddComment.text = "Add Delivery Comment"
        self.textViewAddComment.textColor = AppConfig.darkGreyColor()
        self.txtFldPONumber.font = UIFont.SFUIText_Regular(baseScaleSize: 15.0)
        
        self.cartTableView.tableFooterView = UIView()
        self.poPopupBoudingView.layer.cornerRadius = 5.0 * Configration.scalingFactor()
        Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
        Helper.shared.setNavigationTitle(viewController: self, title: "My Cart")
        if self.isShowingOrderDetails
        {
            self.btnSaveOrder.setTitle("RE-ORDER", for: .normal)
            self.btnSaveOrder.addTarget(self, action: #selector(reorderItemsInCart), for: .touchUpInside)
            self.viewAmount.isHidden = true
            self.viewAmountHeightConstraint.constant = 0.0
            self.saveOrderHeightConstraint.constant = 0.0
            self.addItemsHeightConstraint.constant = 0.0
            Helper.shared.setNavigationTitle(withTitle: "Order Detail", withLeftButton: .backButton, onController: self)
            staticLabelAddComment.isHidden = true
            textViewAddComment.isHidden = true
            btnClearComment.setImage(nil, for: .normal)
            self.viewCommentBox.isHidden = true
            self.cnstViewCommentBoxHeight.constant = 0.0
            staticLblSelect.text = "SELECT"
            staticLblSelect.textColor = UIColor(red: 123.0/255.0, green: 129.0/255.0, blue: 129.0/255.0, alpha: 1.0)
            
            for view in self.viewAmount.subviews{
                if let lbl = view as? UILabel{
                    lbl.text = ""
                }
            }
        }else{
            
            self.lblTitleSubTotal.font = UIFont.SFUIText_Regular(baseScaleSize: 15.0)
            self.lblSubTotal.font = UIFont.SFUIText_Regular(baseScaleSize: 15.0)
            self.btnPlaceOrder.setTitle("PLACE ORDER", for: .normal)
            if AppFeatures.shared.saveOrderPermitted == true && isShowingSavedOrder == false{
                self.placeOrderBtnHeightConstraint.constant = 0.0//39.5 * VerticalSpacingConstraints.spacingConstant
            }else{
                self.placeOrderBtnHeightConstraint.constant = 0.0
            }
            self.cnstViewCommentBoxHeight.constant = 30.0 * VerticalSpacingConstraints.spacingConstant
        }
        
        for view in headerView.subviews
        {
            if view is UILabel
            {
                (view as! UILabel).font = UIFont.SFUI_Regular(baseScaleSize: 15.0)
            }
        }
        self.textViewAddComment.centerVertically()
        self.btnAddPONumber.titleLabel?.font =  UIFont.SFUI_Regular(baseScaleSize: 16.0)
        self.btnSkip.titleLabel?.font =  UIFont.SFUI_Regular(baseScaleSize: 16.0)
        self.btnSkip.setTitleColor(UIColor.white, for: .normal)
        self.btnAddPONumber.setTitleColor(UIColor.white, for: .normal)
        self.btnSkip.backgroundColor = UIColor.primaryColor()
        self.btnAddPONumber.backgroundColor = UIColor.primaryColor2()
    }
    
    
    func getSuggestiveProducts() {
        let dicCartItem = [
            "CustomerID": UserInfo.shared.customerID!,
            "UserID" :UserInfo.shared.userId!,
            "CartID" : self.tempCartID
            ] as [String : Any]
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: dicCartItem, strURL: SyncEngine.baseURL + SyncEngine.getSuggestions) { (response : Any) in
            
            self.suggestionloaded = true
            
            if let arrObj = response as? Dictionary<String,Any>
            {
               // var arraySuggestiveProduts :Array<Dictionary<String,Any>>
                let  arrayLatestSpecial =  arrObj["Specials"] as? Array<Dictionary<String,Any>>
                    
                   let arraySuggestiveProduts =  arrObj["SuggestiveItems"] as? Array<Dictionary<String,Any>>
                
                if arrayLatestSpecial!.count > 0 || arraySuggestiveProduts!.count > 0 {
                    DispatchQueue.main.async {
                        if let multipleObj = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: MultipleOptionPickerproducts.storyboardIdentifier) as? MultipleOptionPickerproducts
                        {
                            multipleObj.showMultipleOptionPickerOnWindow(forDisplayKeyName: "ProductName", withDataSource: arrayLatestSpecial!, withTitle: "We noticed you ordered these previously. Would you like to add?", withSuccessButtonTitle: "OK", withCancelButtonTitle: "CANCEL", withAlertMessage: "Please choose shipping address.",withDataSource2:  arraySuggestiveProduts!) { (selectedVal : Int) in
                                
                                self.getCartItems()
                                
                            }
                        }
                    }
                }
                    
                
               
                
                
                }
            
            else
            {
                
            }
        }
            
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.textViewAddComment.text.isEmpty || self.textViewAddComment.text == "Add Delivery Comment"{
            self.textViewAddComment.font = UIFont.Roboto_Italic(baseScaleSize: 15.0)
            self.textViewAddComment.text = "Add Delivery Comment"
        }else{
            self.textViewAddComment.font = UIFont.SFUIText_Regular(baseScaleSize: 15.0)
        }
        self.textViewAddComment.centerVertically()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if(AppFeatures.shared.isShowStandingOrder == false)
        {
           btnAddItem.setTitle("BACK", for: .normal)
        }
        
        DispatchQueue.main.async {
            self.setDefaultNavigation()
        }
        
        if self.isShowingOrderDetails && self.orderID != nil
        {
            self.getOrderDetails()
        }
        else
        {
            self.getCartItems()
        }
    }
    
    func createTotalCartValueLabel()
    {
        if AppFeatures.shared.shouldShowProductPrice
        {
            self.lblTotalOrderValue?.font = UIFont.SFUI_SemiBold(baseScaleSize: 16.0)
            self.lblTotalOrderValue?.textColor = UIColor.baseBlueColor()
        }
    }
    
    func createAndShowOrderValue()
    {
        DispatchQueue.main.async {
            if self.orderTotal != nil
            {
                let ordValue_temp = self.orderTotal!
                
                let ordValue = Double(round(100*ordValue_temp)/100)

                
                let string = String(format: "Order Value : \(CommonString.currencyType)%@",ordValue.withCommas())
                let attrStr = NSMutableAttributedString(string: string)
                attrStr.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.baseBlueColor(), NSAttributedStringKey.font : UIFont.SFUI_Bold(baseScaleSize: 14.0)], range: NSRange(location: 0, length: string.count))
                
                attrStr.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.activeTextFieldColor(), NSAttributedStringKey.font : UIFont.SFUI_Regular(baseScaleSize: 14.0)], range: (string as NSString).range(of: "Order Value :"))
                self.lblTotalOrderValue?.attributedText = attrStr
                self.showOrderDetailWithGST(total: self.orderTotal!)
            }
            else
            {
                self.manuallyCreateCartValue()
            }
            
        }
    }
    
    func manuallyCreateCartValue()
    {
        if self.arrCartItems.count > 0
        {
            var total : Double = 0.0
            for i in 0...self.arrCartItems.count - 1
            {
                if let expectedPrice = self.arrCartItems[i]["Price"] as? Double
                {
                    if let quantitty = self.arrCartItems[i]["Quantity"] as? Double
                    {
                        total = total + (expectedPrice*quantitty)
                    }
                }
            }
            let price_final = Double(round(100*total)/100)
            
            let priceStr = price_final.withCommas()
            DispatchQueue.main.async {
                let string = "Order Value : \(CommonString.currencyType)\(priceStr)"
                let attrStr = NSMutableAttributedString(string: string)
                attrStr.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.baseBlueColor(), NSAttributedStringKey.font : UIFont.SFUI_Regular(baseScaleSize: 14.0)], range: NSRange(location: 0, length: string.count))
                attrStr.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.activeTextFieldColor()], range: (string as NSString).range(of: "Order Value :"))
                self.lblTotalOrderValue?.attributedText = attrStr
            }
            self.showOrderDetailWithGST(total: total)
        }
        else
        {
            let string = "Order Value : \(CommonString.currencyType)0.0"
            let attrStr = NSMutableAttributedString(string: string)
            attrStr.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.baseBlueColor(), NSAttributedStringKey.font : UIFont.SFUI_Regular(baseScaleSize: 14.0)], range: NSRange(location: 0, length: string.count))
            attrStr.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.activeTextFieldColor()], range: (string as NSString).range(of: "Order Value :"))
            self.lblTotalOrderValue?.attributedText = attrStr
            self.showOrderDetailWithGST(total: 0.0)
        }
    }
    
    func showOrderDetailWithGST(total:Double){
        
//        let gst = total * 10 / 100
        let grandTotal = total - self.discount
        
        let price_final = Double(round(100*grandTotal)/100)

        
        self.lblSubTotal.text = "\(CommonString.currencyType)\(price_final.withCommas())"
    }
    
    @objc func reorderItemsInCart()
    {
        if UserInfo.shared.customerOnHoldStatus==true && !AppFeatures.shared.isAllowOnHoldPlacingOrder{
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                return
            })
        }
        else{
            if selectedIndexPathArray.count > 0
            {
                let requestURL = SyncEngine.baseURL + SyncEngine.reorderItems
                let requestDic = [
                    "UserID": UserInfo.shared.userId!,
                    "IsPlacedByRep" : UserInfo.shared.isSalesRepUser!,
                    "CustomerID": UserInfo.shared.customerID!,
                    "OrderID": orderID!,
                    "AppendToSavedOrder": false,
                    "Products" : self.selectedIndexPathArray
                    ] as [String : Any]
                
                SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestDic, strURL: requestURL) { (response :  Any) in
                    self.showCartScreen()
                    Helper.shared.showAlertOnController( message: "\(self.selectedIndexPathArray.count) items added to cart", title: CommonString.app_name, hideOkayButton: true)
                    Helper.shared.dismissAddedToCartAlert()
                    
                    self.selectedIndexPathArray.removeAll()
                    Helper.shared.callAPIToUpdateCartNumber()
                    DispatchQueue.main.async {
                        self.cartTableView.reloadData()
                    }
                }
            }
            else
            {
                Helper.shared.showAlertOnController( message: "Please select items to reorder.", title: CommonString.app_name)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (self.commentString != nil)
        {
            self.textViewAddComment.text = self.commentString
            self.btnClearComment.isHidden = false
        }
        
        if self.orderID != nil , self.isShowingOrderDetails == true
        {
            Helper.shared.setNavigationTitle(withTitle: "Order Detail - \(String(describing: self.orderID!))", withLeftButton: .backButton, onController: self)
        }
        self.cartTableView.reloadData()
    }
    
    //    MARK :- Server Communication
    
    func getCartItems() -> Void
    {
        self.donationPrice = 0.0
        self.isOnlyDonationBox = true
        DispatchQueue.main.async {
         
        self.viewPromo.isHidden = true
        self.lblFreight.isHidden = true
        self.lblcharges.isHidden = true
        }
        let serviceURL = SyncEngine.baseURL + SyncEngine.getCartItems
        let requestToGetCartItems = [
            "UserID": UserInfo.shared.userId!,
            "CustomerID": UserInfo.shared.customerID!,
            "IsPlacedByRep": UserInfo.shared.isSalesRepUser!,
            "IsSavedOrder" : isShowingSavedOrder,
            "CartID" : (orderID == nil) ? 0 : orderID!
            ] as Dictionary<String,Any>
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestToGetCartItems, strURL: serviceURL) { (response : Any) in
            
            if  response as? Dictionary<String,Any> != nil {
            
            self.autoAuthorize = (response as? Dictionary<String,Any>)?["AuthPayment"] as? Bool
            
            if (AppFeatures.shared.isShowStandingOrder == true)
            {
                if(((response as? Dictionary<String, Any>)?.keyExists(key: "RecurrCartID")) != nil)
                {
                    self.RecurrCartID = ((response as? Dictionary<String,Any>)?["RecurrCartID"]! as? NSNumber)!
                }
            }
                
            self.minCartValue = ((response as? Dictionary<String,Any>)?["MinCartValue"]! as? Double)!
            

           // debugPrint(response)
            if let items = (response as? Dictionary<String,Any>)?["CartItems"] as? Array<Dictionary<String,Any>>
            {
                self.arrCartItems.removeAll()
                self.arrCartItems += items
                DispatchQueue.main.async {
                    self.cartTableView.reloadData()
                }
                
                if self.arrCartItems.count > 0{
                    self.tempCartID = (self.arrCartItems[0]["CartID"] as? NSNumber)!
                    self.createAndShowOrderValue()
                }else{
                    Helper.shared.cartCount = 0
                }
                
                if let cartTotalValue = (response as? Dictionary<String,Any>)?["CartTotal"] as? Double
                {
                    self.orderTotal = cartTotalValue
                    self.cartTotal = cartTotalValue
                    
                }
            }
            
            
            if (response as? Dictionary<String,Any>)?["IsCouponApplied"] as? Bool != nil {
                          
                           let isCouponApplied = (response as? Dictionary<String,Any>)?["IsCouponApplied"] as? Bool
                          
                           if isCouponApplied == true {
                               DispatchQueue.main.async {
                                 
                               self.viewPromo.isHidden = false
                               self.lblPromo.isHidden = false
                               self.lblDicount.isHidden = false
                               let string = String(format: "\(CommonString.currencyType)%.2f", ((response as? Dictionary<String,Any>)?["CouponAmount"] as? Double)!)
                               self.lblDicount.text = "(" + String(string) + ")"
                                   
                                   
                                   self.discount = ((response as? Dictionary<String,Any>)?["CouponAmount"] as? Double)!
                                  
                                   let cartTotalValue = (response as? Dictionary<String,Any>)?["CartTotal"] as? Double
                                   self.cartTotal = cartTotalValue! - self.discount;
                                                                
                               
                           }
                           }else{
                            self.discount  = 0.0
                }
                       }
            
            if self.suggestionloaded == false {
                
               // if AppFeatures.shared.IsSuggestiveSell
                //{
                    self.getSuggestiveProducts()
                //}
            }
            self.createAndShowOrderValue()
        }}
    }
    
    func getOrderDetails()
    {
        let serviceURL = SyncEngine.baseURL + SyncEngine.getOrderItems
        let requestToGetOrderDetails = [
            "CustomerID": UserInfo.shared.customerID!,
            "OrderID": self.orderID!,
            "UserID": UserInfo.shared.userId!,
            "IsOrderHistory": true
            ] as Dictionary<String,Any>
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestToGetOrderDetails, strURL: serviceURL) { (response : Any) in
            if let items = response as? Array<Dictionary<String,Any>>
            {
                self.arrCartItems.removeAll()
                self.arrCartItems += items
                DispatchQueue.main.async {
                    self.cartTableView.reloadData()
                }
                if self.arrCartItems.count > 0
                {
                    self.tempCartID = (self.arrCartItems[0]["CartID"] as? NSNumber)!
                }
                self.calculateOrderValue()
            }
        }
    }
    
    //    MARK: - Table View Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrCartItems.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @objc func btnShowImage(sender : UIButton){
        
        let objToBeShownInRow = self.arrCartItems[sender.tag]
        
        if let images = objToBeShownInRow["ProductImages"] as? Array<Dictionary<String,Any>>, images.count > 0
        {
            let originalString:String = (images[0]["ImageName"]! as! String)
            let urlString:String = originalString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
            
            let images = [LightboxImage.init(imageURL:URL(string: urlString)!)]
            let controller = LightboxController(images: images)
            controller.modalPresentationStyle = .fullScreen
            controller.pageDelegate = self
            controller.dismissalDelegate = self
            
            //controller.dynamicBackground = true
            
            present(controller, animated: true, completion: nil)
        }
    }
    
    @objc func btnAddEditCommentAction(sender : UIButton){
        
        if let commentListingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addCommentsStoryboardID") as? ChooseCommentView
        {
            commentListingVC.senderView = self
            let objToBeShownInRow = self.arrCartItems[sender.tag]
            
            let productId = (objToBeShownInRow["ProductID"] as! NSNumber)
            print(productId)
            commentListingVC.productId = productId
            commentListingVC.productDict = objToBeShownInRow
            self.commentID = objToBeShownInRow["ProdCommentID"] as? NSNumber ?? 0
            UIApplication.shared.keyWindow?.rootViewController?.present(commentListingVC, animated: false, completion: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: CartTableViewCell.cartCellReuseIdentifier) as? CartTableViewCell
        
        let objToBeShownInRow = self.arrCartItems[indexPath.row]
        
        if objToBeShownInRow["IsDonationBox"] as? Bool == false {
            self.isOnlyDonationBox = false;
        }else{
            self.donationPrice = donationPrice + (objToBeShownInRow["Price"] as? Double)!
            
        }
        
        cell?.lblPrice.adjustsFontSizeToFitWidth = true
        cell?.lblDescription.text = (objToBeShownInRow["ProductName"] as? String)
        DispatchQueue.main.async {
            cell?.lblProductStatus.layer.cornerRadius = 8
        }
        if let new = objToBeShownInRow["ProductIsNew"] as? Bool, new == true {
            cell?.lblProductStatus.text = "NEW"
            cell?.lblProductStatus.backgroundColor = UIColor.primaryColor()
        }else if let new = objToBeShownInRow["ProductIsOnSale"] as? Bool, new == true {
            cell?.lblProductStatus.text = "SALE"
            cell?.lblProductStatus.backgroundColor = UIColor.primaryColor2()
        }else if let new = objToBeShownInRow["ProductIsBackSoon"] as? Bool, new == true {
            cell?.lblProductStatus.text = "INCOMING"
            cell?.lblProductStatus.backgroundColor = UIColor.primaryColor3()
        }else{
            cell?.lblProductStatus.text = ""
        }
        
        cell?.txtQuantity.tag = indexPath.row
        cell?.txtQuantity.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonClicked))
        
        if objToBeShownInRow["IsStatusIN"] as? Bool == true{
            cell?.lblDescription.textColor = UIColor.blue
        }
        
        if AppFeatures.shared.shouldShowProductPrice
        {
            if let expectedPrice = objToBeShownInRow["Price"] as? Double
            {
                let price_final = Double(round(100*expectedPrice)/100)

                let priceStr = String(format: "\(CommonString.currencyType)%.2f", price_final)
                cell?.lblPrice.text = expectedPrice <= 0 ? CommonString.marketprice:priceStr
                cell?.lblPrice?.textAlignment = .center
                cell?.lblGst?.textAlignment = .center
            }
            
            var arrPrices : Array<Dictionary<String,Any>>?
            if let prices = objToBeShownInRow["DynamicUOM"] as? Array<Dictionary<String,Any>>
            {
                arrPrices = prices
            }
            else if let prices = objToBeShownInRow["Prices"] as? Array<Dictionary<String,Any>>
            {
                arrPrices = prices
            }
            else if let prices = objToBeShownInRow["Prices"] as? Dictionary<String,Any>
            {
                arrPrices = [prices]
            }
            
            
            let index = arrPrices?.index(where: { (testdic : Dictionary<String, Any>) -> Bool in
                testdic["UOMID"] as? NSNumber == objToBeShownInRow["OrderUnitId"] as? NSNumber
            })
            if let obj = arrPrices?[index ?? 0]
            {
                if UserInfo.shared.isSalesRepUser == true{
                    
                    if obj["IsSpecial"] as? Bool == true && obj["IsPromotional"] as? Bool == true{
                        cell?.lblPrice.textColor = UIColor.red
                        
                    }
                    else if obj["IsSpecial"] as? Bool == true{
                        cell?.lblPrice.textColor = UIColor.red
                    }
                    else if obj["IsPromotional"] as? Bool == true{
                        cell?.lblPrice.textColor = UIColor.promotionalProductYellowColor()
                    }
                    else{
                        cell?.lblPrice.textColor = UIColor.baseBlueColor()
                    }
                }
                
                cell?.lblUnitOfMeasurement.setTitleColor(UIColor.gray,for: .normal)
                if objToBeShownInRow.keyExists(key:"LastOrderUOMID"), let lastUom = objToBeShownInRow["LastOrderUOMID"] as? Int, lastUom == obj["UOMID"] as? Int, lastUom > 0{
                    cell?.lblUnitOfMeasurement.setTitleColor(UIColor.gray,for: .normal)
                }
                
                if let expectedPrice = obj["Price"] as? Double
                {
                    let price_final = Double(round(100*expectedPrice)/100)

                    let priceStr = String(format: "\(CommonString.currencyType)%.2f", price_final)
                    cell?.lblPrice.text = expectedPrice <= 0 ? CommonString.marketprice:priceStr.trimmingCharacters(in: .whitespacesAndNewlines)
                    cell?.lblPrice?.textAlignment = .center
                    cell?.lblGst?.textAlignment = .center
                }
                
                let quantitty = (objToBeShownInRow["Quantity"] as? Double)!
                let expectedPrice = (obj["Price"] as? Double)!
                let totalPriceWithQuantity = quantitty * expectedPrice
                
                let price_final = Double(round(100*totalPriceWithQuantity)/100)

                
                let priceStrTotal = String(format: "\(CommonString.currencyType)%.2f", price_final)
                cell?.LblTotalPricePerQuantity.text = totalPriceWithQuantity <= 0 ? CommonString.marketprice:priceStrTotal.trimmingCharacters(in: .whitespacesAndNewlines)

            }
            
            

            
        }else{
            cell?.lblPrice.text = "-"
            cell?.lblPrice?.textAlignment = .center
        }
        
        
        if self.isShowingOrderDetails == false
        {
            
            cell?.btnShowImage.tag = indexPath.row
            cell?.btnShowImage.addTarget(self, action: #selector(self.btnShowImage), for: .touchUpInside)
            cell?.btnPencil.isHidden = false
            cell?.btnPencil.isSelected = false
            cell?.btnPencil.tag = indexPath.row
            cell?.btnPencil.addTarget(self, action: #selector(self.btnAddEditCommentAction), for: .touchUpInside)
            
            if Int(truncating: objToBeShownInRow["ProdCommentID"] as? NSNumber ?? 0) > 0 {
                
                cell?.btnPencil.isSelected = true
            }
            
            if let obj = self.arrCartItems[indexPath.row]["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1
            {
                cell?.lblUnitOfMeasurement.setImage(#imageLiteral(resourceName: "sort_down"), for: .normal)
                cell?.lblUnitOfMeasurement.semanticContentAttribute = .forceRightToLeft
                cell?.lblUnitOfMeasurement.imageView?.contentMode = .scaleAspectFit
                cell?.lblUnitOfMeasurement.addTarget(self, action: #selector(uOMChanged), for: .touchUpInside)
                cell?.lblUnitOfMeasurement.tag = indexPath.row
                
            }
            else
            {
                cell?.lblUnitOfMeasurement.setImage(nil, for: .normal)
            }
            cell?.btnCross.addTarget(self, action: #selector(self.removeProductFromCartAction(sender:)), for: UIControlEvents.touchUpInside)
        }
        else
        {
            cell?.btnPencil.isHidden = true
            cell?.btnCross.tag = indexPath.row
            cell?.btnCross.addTarget(self, action: #selector(self.reorderProductsSelectionChanged(sender:)), for: UIControlEvents.touchUpInside)
            cell?.txtQuantity.isUserInteractionEnabled = false
            cell?.txtQuantity.borderStyle = .none
            
            
            if let selectedProdId = self.arrCartItems[indexPath.row]["ProductID"] as? Int
            {
                if selectedIndexPathArray.contains(selectedProdId)
                {
                    cell?.btnCross.setImage(#imageLiteral(resourceName: "checkbox_checked"), for: .normal)
                    cell?.btnCross.tintColor = UIColor.baseBlueColor()
                }
                else
                {
                    cell?.btnCross.setImage(#imageLiteral(resourceName: "checkbox_unchecked"), for: .normal)
                    cell?.btnCross.tintColor = UIColor.activeTextFieldColor()
                }
            }
            cell?.lblUnitOfMeasurement.setImage(nil, for: .normal)
            cell?.lblUnitOfMeasurement.titleLabel?.textAlignment = .center
        }
        
        cell?.lblUnitOfMeasurement.setTitle(objToBeShownInRow["OrderUnitName"] as? String, for: .normal)
        
        
        if let quantitty = objToBeShownInRow["Quantity"] as? Double{
            cell?.txtQuantity.text = quantitty.cleanValue
        }
        
        cell?.btnCross.tag = indexPath.row
        cell?.txtQuantity.tag = indexPath.row
        //CART
        cell?.txtQuantity.delegate = self
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
    
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.showCommentsScreenAction()
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == txtFldPONumber{
            
            return true
        }else{
            
            if AppFeatures.shared.IsShowQuantityPopup == true{
                self.selectedIndex = textField.tag
                self.updateQuantity(index: textField.tag)
                return false
                
            }else {
                
                self.txtFldActive = textField
                self.txtFldActive.text = ""
                return true
            }
            
        }
        
    }
    
    @objc func doneButtonClicked(_ textField: UITextField) {
        
        if textField == self.txtFldActive{
            var product = self.arrCartItems[textField.tag]
            
            let qtyDoubleValue:Double = (textField.text?.isEmpty)! ? 1.00:Double(textField.text!)!
            let qtyValue = qtyDoubleValue <= 0 ? 1.00:qtyDoubleValue
            product["Quantity"] = NSNumber(value: qtyValue)
            self.arrCartItems[textField.tag] = product
            product = self.arrCartItems[textField.tag]
            //self.backOrder(dic: product)
            self.checkMinAndMaxOrderQuantity(productValue: product, index: textField.tag, quantityValue: NSNumber(value: Double(qtyValue) ?? 0.0))
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == self.txtFldActive{
            
            self.txtFldActive.text = ((textField.text?.isEmpty)!) ? (AppFeatures.shared.IsAllowDecimal ? 0.00.cleanValue: UserInfo.shared.isSalesRepUser! ? 0.00.cleanValue:"0"):textField.text
            self.cartTableView.reloadData()
        }
    }
    
    func checkOrderMultiplies(productDetail : Dictionary<String, Any>){
        
        var productDict = productDetail
        
        var unitToBedded = Double(exactly:productDetail["Quantity"] as? NSNumber ?? 0.0) ?? 0.0
        
        let objToFetch = Helper.shared.getSelectedUOM(productDetail: productDetail)
        let arrayUomEach = ["EA","EACH"]
        let uomName = objToFetch["UOMDesc"] as? String
        let quantityPerUnit = objToFetch["QuantityPerUnit"] as? Int ?? 0
        
        unitToBedded = Helper.shared.calculateQuantityMultiplier(units: unitToBedded,quantityPerUnit:quantityPerUnit)
        
        self.arrCartItems[self.selectedIndex]["Quantity"] = unitToBedded
        
        productDict["Quantity"] = unitToBedded
        if AppFeatures.shared.isOrderMultiples && arrayUomEach.contains((uomName?.uppercased())!.trimmingCharacters(in: .whitespacesAndNewlines)) {
            
            DispatchQueue.main.async {
                //                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: "This item can only be ordered in multiples of \(quantityPerUnit). We are adding \(unitToBedded.cleanValue) to the cart.", withCancelButtonTitle: "OK", completion: {
                
                self.updateCartItemObjWithObj(dic: productDetail, quantityVal: unitToBedded)
                //                })
            }
        }else{
            self.updateCartItemObjWithObj(dic: productDetail, quantityVal: unitToBedded )
        }
    }
    
    func updateQuantity(index:Int){
        
        let indexPath = IndexPath(item: index, section: 0)
        
        let cell = self.cartTableView.cellForRow(at: indexPath) as! CartTableViewCell
        
        if AppFeatures.shared.IsShowQuantityPopup == true{
            
            var product = arrCartItems[index]

            if let circularPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "circularQuantityStoryboardID") as? CircularQuantityPopup{
                
                circularPopup.quantityPerUnit = Helper.shared.getSelectedUomNameQuantity(product: product).quantity
                circularPopup.isEach =  Helper.shared.getSelectedUomNameQuantity(product: product).isEach
                
                if product.keyExists(key: "Quantity"){
                    
                    circularPopup.circularSlider.currentValue = Float(truncating: (( product["Quantity"]) as? NSNumber)!)
                    circularPopup.currentQuantity = "\(Double(truncating: (( product["Quantity"]) as? NSNumber)!))"
                    
                }else{
                    circularPopup.circularSlider.currentValue = 1.0
                }
                circularPopup.showCommonAlertOnWindow{
                    self.checkMinAndMaxOrderQuantity(productValue: self.arrCartItems[index], index: index, quantityValue: NSNumber(value: Double(circularPopup.txtFldQuantity.text!)!))
                    self.cartTableView.reloadData()
                }
                circularPopup.btnAddToCart.setTitle("UPDATE CART", for: .normal)
            }
            
        }else{
            
            //            self.txtFldActive = cell.txtQuantity
            //            self.txtFldActive.becomeFirstResponder()
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.text == "", string == " "{
            
            return false
        }
        else if string == "\n"{
            
            textField.resignFirstResponder()
            textField.endEditing(true)
            
        }/*else if textField == txtFldPONumber{
             
             let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
             
             if textField == txtFldPONumber{
             
             return newText.count<=30
             }
         }*/else if textField == self.txtFldActive{
            
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
    
    func checkMinAndMaxOrderQuantity(productValue : Dictionary<String, Any>, index : Int ,quantityValue: NSNumber){
        
        var productDetail = productValue
        
        if productDetail["Quantity"]  as? NSNumber == nil{
            productDetail["Quantity"] = 1.0
        }
        
        let minQty = (productDetail["MinOQ"] as? Int ?? 0)
        let maxQty = (productDetail["MaxOQ"] as? Int ?? 0)
        let qtyPerUnit = Helper.shared.getPackSize(dic: productValue)
        
        if AppFeatures.shared.isMinOrderQuantity == true && AppFeatures.shared.isMaxOrderQuantity == true {
            
            if (Int(truncating: NSNumber(value: minQty))/qtyPerUnit) > Int(quantityValue) && NSNumber(value: minQty) != 0
            {
                let msgString = "This item has a minimum order quantity of \( Int(truncating: NSNumber(value: minQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: minQty))) \("units to cart ?")"
                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                    productDetail["Quantity"] = minQty/qtyPerUnit
                    self.arrCartItems[index] = productDetail
                    self.cartTableView.reloadData()
                    self.backOrder(dic: productDetail)
                })
            }
            else if (Int(truncating: NSNumber(value: maxQty))/qtyPerUnit) < Int(quantityValue) && NSNumber(value: maxQty) != 0
            {
                let msgString = "This item has a maximum order quantity of \( Int(truncating: NSNumber(value: maxQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: maxQty))) \("units to cart ?")"
                
                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                    productDetail["Quantity"] = maxQty/qtyPerUnit
                    self.arrCartItems[index] = productDetail
                    self.cartTableView.reloadData()
                    self.backOrder(dic: productDetail)
                })
            }
            else{
                self.arrCartItems[index]["Quantity"] = Double(quantityValue)
                self.backOrder(dic: self.arrCartItems[index])
            }
        }
        else if  AppFeatures.shared.isMinOrderQuantity == true {
            if (Int(truncating: NSNumber(value: minQty))/qtyPerUnit) > Int(quantityValue) && NSNumber(value: minQty) != 0
            {
                let msgString = "This item has a minimum order quantity of \( Int(truncating: NSNumber(value: minQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: minQty))) \("units to cart ?")"
                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                    productDetail["Quantity"] = minQty/qtyPerUnit
                    self.arrCartItems[index] = productDetail
                    self.cartTableView.reloadData()
                    self.backOrder(dic: productDetail)
                })
            }
            else if  AppFeatures.shared.isMaxOrderQuantity == true {
                if (Int(truncating: NSNumber(value: maxQty))/qtyPerUnit) < Int(quantityValue) && NSNumber(value: maxQty) != 0
                {
                    let msgString = "This item has a maximum order quantity of \( Int(truncating: NSNumber(value: maxQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: maxQty))) \("units to cart ?")"
                    
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                        productDetail["Quantity"] = maxQty/qtyPerUnit
                        self.arrCartItems[index] = productDetail
                        self.cartTableView.reloadData()
                        self.backOrder(dic: productDetail)
                    })
                }
            }
            else{
                self.arrCartItems[index]["Quantity"] = Double(quantityValue)
                self.backOrder(dic: self.arrCartItems[index])
            }
        }
        else if  AppFeatures.shared.isMaxOrderQuantity == true {
            if (Int(truncating: NSNumber(value: maxQty))/qtyPerUnit) <  Int(quantityValue) && NSNumber(value: maxQty) != 0
            {
                let msgString = "This item has a maximum order quantity of \( Int(truncating: NSNumber(value: maxQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: maxQty))) \("units to cart ?")"
                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
                    productDetail["Quantity"] = maxQty/qtyPerUnit
                    self.arrCartItems[index] = productDetail
                    self.cartTableView.reloadData()
                    self.backOrder(dic: productDetail)
                })
            }
            else{
                self.arrCartItems[index]["Quantity"] = quantityValue
                self.backOrder(dic: self.arrCartItems[index])
            }
        }
        else{
            self.arrCartItems[index]["Quantity"] = quantityValue
            self.backOrder(dic: self.arrCartItems[index])
        }
    }
    
    
    //    MARK:- User Actions
    func showCommentsScreenAction()
    {
        if let commentListingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addCommentsStoryboardID") as? ChooseCommentView
        {
            commentListingVC.senderView = self
            self.commentID = self.orderCommentID
            UIApplication.shared.keyWindow?.rootViewController?.present(commentListingVC, animated: false, completion: nil)
        }
    }
    
    @objc func backBtnAction() -> Void
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func removeProductFromCartAction(sender : UIButton)
    {
        if let itemID = self.arrCartItems[sender.tag]["CartItemID"] as? NSNumber,let productID = self.arrCartItems[sender.tag]["ProductID"] as? NSNumber, let itemName = (self.arrCartItems[sender.tag]["ProductName"] as? String)
        {
            
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: "Delete Product", withSuccessButtonTitle: "Yes", withMessage: "Are you sure you want to remove \(itemName) from the cart?", withCancelButtonTitle: "No", completion:{
                self.callAPIToRemoveItemFromCart(cartItemID: itemID, productID: productID,index:sender.tag)
            })
        }
    }
    
    @objc func reorderProductsSelectionChanged(sender : UIButton)
    {
        if let selectedProdId = self.arrCartItems[sender.tag]["ProductID"] as? Int{
            
            if selectedIndexPathArray.contains(selectedProdId){
                if let index = selectedIndexPathArray.index(of: selectedProdId)
                {
                    selectedIndexPathArray.remove(at: index)
                }
            }else{
                
                let sohValue = self.arrCartItems[sender.tag]["StockQuantity"] as? Double ?? 0.0
                var qtyValue = self.arrCartItems[sender.tag]["Quantity"] as? NSNumber
                qtyValue = qtyValue == 0.0 ? 1.0:qtyValue
                
                if let buyInPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:SaaviActionAlert.storyboardIdentifier) as? SaaviActionAlert
                {
                    if sohValue <= 0
                    {
                        buyInPopup.showCommonAlertOnWindow(withTitle: "Important", withSuccessButtonTitle: "", withMessage: "Sorry, this product is out of stock at this moment.", withCancelButtonTitle: "Ok") {
                        }
                   }
                    else if sohValue >= qtyValue as! Double
                    {
                        selectedIndexPathArray.append(selectedProdId)
                    }
                    else if sohValue < qtyValue as! Double
                    {
                        buyInPopup.showCommonAlertOnWindow(withTitle: "Important", withSuccessButtonTitle: "", withMessage: "Your order quantity is greater than  the stock on hand quantity of \(sohValue). Only the available quantity will be added to the cart.", withCancelButtonTitle: "Ok") {
                        }
                    }
                }
                else
                {
                    
                }
                
            }
            self.cartTableView.reloadData()
        }
    }
    
    func calculateOrderValue(){
        
        var total = 0.0
        for product in self.arrCartItems{
            var price = product["Price"] as? Double ?? 0.0
            let quantity = product["Quantity"] as? Double ?? 0.0
            price = price * quantity
            total += price
        }
        //self.cartTotal = total
        self.createAndShowOrderValue()
    }
    
    
    func callAPIToRemoveItemFromCart(cartItemID : NSNumber , productID : NSNumber,index:Int)
    {
        let dicCartItem = [
            "CartItemID": cartItemID,
        ]
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: dicCartItem, strURL: SyncEngine.baseURL + SyncEngine.deleteItemFromCart) { (response : Any) in
            DispatchQueue.main.async {
                
                if Helper.shared.cartCount == 1{
                    NotificationCenter.default.post(name: Notification.Name("UpdateCart"), object: nil, userInfo: ["ProductID":productID])
                }
                else{
                    DispatchQueue.main.async {
                        Helper.shared.showAlertOnController( message: "Product deleted successfully.", title: CommonString.app_name,hideOkayButton: true)
                        Helper.shared.dismissAlert()
                        NotificationCenter.default.post(name: Notification.Name("UpdateCart"), object: nil, userInfo: ["ProductID": productID])
                    }
                }
                if self.arrCartItems.count <= 1{
                    DispatchQueue.main.async {
                        Helper.shared.cartCount = 0
                        self.navigationController?.popViewController(animated: true)
                        Helper.shared.showAlertOnController( message: "No items found in cart. Please add items to continue.", title: CommonString.app_name,hideOkayButton: true)
                        Helper.shared.dismissAlert()
                    }
                }else {
                    self.arrCartItems.remove(at: index)
                    self.getCartItems()
                    self.promoApplied =  false;
                    self.viewPromo.isHidden = true
                    self.viewPromo.isHidden = true
                    self.lblFreight.isHidden = true
                    self.lblFreight.isHidden = true
                }
            }
        }
    }
    
    func showPONumberPopup()
    {
        self.poPopupView.isHidden = false
        self.txtFldPONumber.text = ""
        self.navigationController?.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func hidePoPopupNumber()
    {
        self.poPopupView.isHidden = true
        self.txtFldPONumber.text = ""
        self.view.endEditing(true)
        self.navigationController?.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
        
        if AppFeatures.shared.isMultipleAddresses == true
        {
//            self.getUserAddresses()
            showBuyInPopup()
        }
        else
        {
            showBuyInPopup()
        }
    }
    
    
    @IBAction func handlePONumber(_ sender: Any)
    {
        if (txtFldPONumber.text?.count)! > 0
        {
            self.poNumber = self.txtFldPONumber.text
            self.hidePoPopupNumber()
        }
        else
        {
            Helper.shared.showAlertOnController( message: "Please enter PO number to continue.", title: CommonString.alertTitle)
        }
    }
    
    @IBAction func skipPONumberEntry(_ sender: Any)
    {
        self.hidePoPopupNumber()
    }
    
    @IBAction func placeOrderAction(_ sender: Any)
    {
        if (AppFeatures.shared.isShowStandingOrder == true)
        {
            if (Int(truncating: self.RecurrCartID) > 0)
            {
                UserDefaults.standard.set("no", forKey: "RecurringOrder")

                Helper.shared.lastSetDateTimestamp = nil
                Helper.shared.selectedDeliveryDate = nil
                
                if !self.isOnlyDonationBox {
                  
                
                    if UserInfo.shared.customerOnHoldStatus && !AppFeatures.shared.isAllowOnHoldPlacingOrder{
                        SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                            return
                        })
                        return
                    }
                    
                    if self.arrCartItems.count == 0
                    {
                        Helper.shared.showAlertOnController( message: "Please add products before placing order.", title: CommonString.app_name)
                        self.navigationController?.popViewController(animated: false)
                        return
                    }
                    self.perform(#selector(self.processOrder), with: nil, afterDelay: 0.2)
                }else{
                    if self.arrCartItems.count == 0
                              {
                                  Helper.shared.showAlertOnController( message: "Please add products before placing order.", title: CommonString.app_name)
                                  self.navigationController?.popViewController(animated: false)
                                  return
                              }
                    self.callAPIForPlacingOrder()
                }

            }
            else
            {
                self.showRecurringPopup()
            }
        }
        else
        {
            UserDefaults.standard.set("no", forKey: "RecurringOrder")

            Helper.shared.lastSetDateTimestamp = nil
            Helper.shared.selectedDeliveryDate = nil
            
            if !self.isOnlyDonationBox {
              
            
                if UserInfo.shared.customerOnHoldStatus && !AppFeatures.shared.isAllowOnHoldPlacingOrder{
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                        return
                    })
                    return
                }
                
                if self.arrCartItems.count == 0
                {
                    Helper.shared.showAlertOnController( message: "Please add products before placing order.", title: CommonString.app_name)
                    self.navigationController?.popViewController(animated: false)
                    return
                }
                self.perform(#selector(self.processOrder), with: nil, afterDelay: 0.2)
            }else{
                if self.arrCartItems.count == 0
                          {
                              Helper.shared.showAlertOnController( message: "Please add products before placing order.", title: CommonString.app_name)
                              self.navigationController?.popViewController(animated: false)
                              return
                          }
                self.callAPIForPlacingOrder()
            }

        }
        
        
        
        
    
    }
    
    func placeOrder()
    {
        if !self.isOnlyDonationBox {
          
        
            if UserInfo.shared.customerOnHoldStatus && !AppFeatures.shared.isAllowOnHoldPlacingOrder{
                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                    return
                })
                return
            }
            
            if self.arrCartItems.count == 0
            {
                Helper.shared.showAlertOnController( message: "Please add products before placing order.", title: CommonString.app_name)
                self.navigationController?.popViewController(animated: false)
                return
            }
            self.perform(#selector(self.processOrder), with: nil, afterDelay: 0.2)
        }else{
            self.callAPIForPlacingOrder()
        }
    }

    
    @objc func processOrder() -> Void
    {
        let checkCartValue = self.orderTotal! - donationPrice
        if self.minCartValue! > 0.0 {
            
            if donationPrice  > 0.0 {
            if checkCartValue <  self.minCartValue! {
                Helper.shared.showAlertOnController( message: "Sorry, the minimum order value is " + String(format: "\(CommonString.currencyType)%.2f", minCartValue!) + " and the minimum order value calculation excludes the value of the special item(s). Please add further items to ensure you can place your order.", title: "Minimum Order Value")
                return;
            }
            }
            else{
                if orderTotal! <  self.minCartValue! {
                               Helper.shared.showAlertOnController( message: "Sorry, the minimum order value is " + String(format: "\(CommonString.currencyType)%.2f", minCartValue!) + ". Please add further items to ensure you can place your order.", title: "Minimum Order Value")
                               return;
                           }
            }
        }
        
        
        self.isFrieghtChargesApplicable = false
        if Helper.shared.isDateSelected() == false && AppFeatures.shared.IsDatePickerEnabled == true
        {
            self.showDeliveryTypePopup()
            return
        }
        else if AppFeatures.shared.shouldShowFreightCharges == true && orderTotal != nil && orderTotal! < Helper.shared.orderValue && UserInfo.shared.isDelivery && lblFreight.isHidden
        {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: CommonString.frieghtChargesMessage, withCancelButtonTitle: "No", completion: {
                self.isFrieghtChargesApplicable = true
                if AppFeatures.shared.showPOPopupWhileOrdering == true
                {
                    self.showPONumberPopup()
                }
               
                else
                {
                    self.showBuyInPopup()
                }
                
                self.viewPromo.isHidden = false
                self.lblFreight.isHidden = false
                self.lblcharges.isHidden = false
                self.lblcharges.text = String(format: "\(CommonString.currencyType)%.2f", Helper.shared.freightcharges)
                self.cartTotal = self.cartTotal! + Helper.shared.freightcharges
                
                let price_final = Double(round(100*self.cartTotal!)/100)

                
                self.lblSubTotal.text = String(format: "\(CommonString.currencyType)%.2f", price_final)
                
            })
        }
        else if AppFeatures.shared.showPOPopupWhileOrdering == true
        {
            self.showPONumberPopup()
        }
        else
        {
            showBuyInPopup()
        }
    }
    
    func showDatePicker(){
        
        DispatchQueue.main.async {
            if let orderDatePicker = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "datePickerStoryID") as? DatePickerView
            {
                orderDatePicker.modalPresentationStyle = .overCurrentContext
                orderDatePicker.completionBlock = {(buttonPressed) -> Void in
                    if buttonPressed! != .backORFinishLator{
                        self.processOrder()
                    }
                }
                self.present(orderDatePicker, animated: false, completion: nil)
            }
        }

    }
    func showRecurringPopup()
    {
        DispatchQueue.main.async {
        let RecurringPopupVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecurringOrderPopupVC") as? RecurringOrderPopupVC
        RecurringPopupVC?.modalPresentationStyle = .overCurrentContext
        self.present(RecurringPopupVC!, animated: false, completion: nil)
        RecurringPopupVC?.completionBlock1 = { (buttonPressed) -> Void in
            
            if buttonPressed == .YesPlease
            {
                UserDefaults.standard.set("yes", forKey: "RecurringOrder")

                if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecurringCartView") as? RecurringCartView
                {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else
            {
                UserDefaults.standard.set("no", forKey: "RecurringOrder")

                Helper.shared.lastSetDateTimestamp = nil
                Helper.shared.selectedDeliveryDate = nil
                
                if !self.isOnlyDonationBox {
                  
                
                    if UserInfo.shared.customerOnHoldStatus && !AppFeatures.shared.isAllowOnHoldPlacingOrder{
                        SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                            return
                        })
                        return
                    }
                    
                    if self.arrCartItems.count == 0
                    {
                        Helper.shared.showAlertOnController( message: "Please add products before placing order.", title: CommonString.app_name)
                        self.navigationController?.popViewController(animated: false)
                        return
                    }
                    self.perform(#selector(self.processOrder), with: nil, afterDelay: 0.2)
                }else{
                    if self.arrCartItems.count == 0
                              {
                                  Helper.shared.showAlertOnController( message: "Please add products before placing order.", title: CommonString.app_name)
                                  self.navigationController?.popViewController(animated: false)
                                  return
                              }
                    self.callAPIForPlacingOrder()
                }

                self.dismiss(animated: false, completion: nil)
            }
          }
        }
    }

    
    func showDeliveryTypePopup(){
        DispatchQueue.main.async {
            if let receiveOrderPopup = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReceiveOrderPopupVC") as? ReceiveOrderPopupVC
            {
                receiveOrderPopup.modalPresentationStyle = .overCurrentContext
                self.present(receiveOrderPopup, animated: false, completion: nil)
                receiveOrderPopup.completionBlock = { (buttonPressed, deliveyType) -> Void in

                    if buttonPressed == .moveNext {

                        if deliveyType == DeliveryType.pickUp {
                            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: "Are you sure you want to pickup?", withCancelButtonTitle: "No") {

                                UserInfo.shared.isDelivery = deliveyType == DeliveryType.pickUp ? false : true
                                  if AppFeatures.shared.isMultipleAddresses == true
                                               {
                                                   self.getUserAddresses()
                                  }else{
                                    self.showDatePicker()
                                }
                            }
                        }else{

                        UserInfo.shared.isDelivery = deliveyType == DeliveryType.pickUp ? false : true
                         if AppFeatures.shared.isMultipleAddresses == true
                                       {
                                           self.getUserAddresses()
                        }else{
                            self.showDatePicker()
                            }

                        }

                    }
                }
            }

        }
    }
    
    @IBAction func addMoreItemsAction(_ sender: Any?)
    {
        if (AppFeatures.shared.isShowStandingOrder == true)
        {
            UserDefaults.standard.set("yes", forKey: "RecurringOrder")
            if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecurringCartView") as? RecurringCartView
            {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else
        {
                    var isAlreadyPresent : Bool = false
                    var index = 0
                    for defaultPantryController in (self.navigationController?.viewControllers)!
                    {
                        if defaultPantryController is OrderVC, (defaultPantryController as! OrderVC).isShowingDefaultPantryList == true
                        {
                            isAlreadyPresent = true
                        }
                    }
            
                    if isAlreadyPresent == false {
            
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "productsVCStoryboardIdentifier") as! UINavigationController
                        if AppFeatures.shared.showPantryList && AppFeatures.shared.canSearchProduct
                        {
                            for indexx in 0..<(self.navigationController?.tabBarController?.viewControllers?.count)!{
            
                                let controller = self.navigationController?.tabBarController?.viewControllers![indexx]
                                if controller?.restorationIdentifier == vc.restorationIdentifier{
                                    index = indexx
                                    break
                                }
                            }
                        }
                        self.navigationController?.tabBarController?.selectedIndex = index
                        (self.navigationController?.tabBarController?.viewControllers?[index] as? UINavigationController)?.popToRootViewController(animated: true)
                        (self.navigationController?.tabBarController as? SaaviTabBarController)?.customCollectionTabBarController.reloadData()
                    }else{
                        self.navigationController?.popViewController(animated: true)
                    }
        }
    }
    
    //MARK: - - Show Buiy In products
    func showBuyInPopup(){
        
        var buyInPruducts = ""
        
        for product in self.arrCartItems{
            
            if product["BuyIn"] as? Bool == true{
                
                let productName = (product["ProductName"] as? String) ?? ""
                buyInPruducts.append("\(productName)\n")
                
            }
            
        }
        
        if buyInPruducts.isEmpty{
            
            self.callAPIForPlacingOrder()
        }else {
            
            if let buyInPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BuyInProductListPopupViewController") as? BuyInProductListPopupViewController
            {
                
                buyInPopup.showAlertOnWindow(products: buyInPruducts){
                    self.callAPIForPlacingOrder()
                }
            }
        }
    }
    
    func callAPIForPlacingOrder(){
                
        Helper.shared.lastSetDateTimestamp = nil
//        Helper.shared.selectedDeliveryDate = nil
        let df = DateFormatter()
        //df.dateFormat = "dd/MM/yyyy"
//        let date = df.string(from: Helper.shared.selectedDeliveryDate ?? Date())
//        let deliveryDay:String = (Helper.shared.customerAppendDic_List["dayOfDelivery"] as? String) ?? ""
//        let dayStr = (Helper.shared.selectedDeliveryDate == nil) ? "Today":(deliveryDay.isEmpty ? "Today":deliveryDay)
        DispatchQueue.main.async {
            
            if let orderPlacePopup = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrderPlacePopupVC") as? OrderPlacePopupVC
            {
                //"Are you sure you want to place this order for \(dayStr),\(date)?"
                orderPlacePopup.modalPresentationStyle = .overCurrentContext
                self.present(orderPlacePopup, animated: false, completion: nil)
                orderPlacePopup.completionBlock = { (value) -> Void in
                    
                    if value == .yes {
                        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        var saveOrderRequest = [
                            "CustomerID": UserInfo.shared.customerID!,
                            "TempCartID": self.tempCartID,
                            "UserID": UserInfo.shared.userId!,
                            "CartID": self.tempCartID,
                            "CommentID":  self.orderCommentID == nil ? 0 : self.orderCommentID!,
                            "AddressID": self.addressId,
                            "PickupID":self.pickupAddress,
                            "PONumber": (self.poNumber == nil) ? "" : self.poNumber!,
                            "OrderStatus": 1,
                            "Comment": self.commentString == nil ? "" : self.commentString!,
                            "OrderDate": df.string(from: Helper.shared.selectedDeliveryDate ?? Date()),
                            "CutOffTime": "",
                            "ExtDoc": "",
                            "PackagingSequence": "",
                            "IsAutoOrdered": false,
                            "DeviceToken": "",
                            "DeviceType": "iPhone",
                            "DeviceVersion": "",
                            "DeliveryType":UserInfo.shared.isDelivery == true ? "Delivery" : "Pick-up",
                            "DeviceModel": "",
                            "AppVersion": "",
                            "SaveOrder": false,
                            "HasFreightCharges" : self.isFrieghtChargesApplicable,
                            "HasNonDeliveryDayCharges" : Helper.shared.isOrderingOnNonDeliveryDay,
                            "IsOrderPlpacedByRep":UserInfo.shared.isSalesRepUser!,
                            "IsContactless":Helper.shared.IsContactless,
                            "IsLeave":Helper.shared.IsLeave,
                            "IsDelivery":UserInfo.shared.isDelivery] as [String : Any]
                        
                        if UserInfo.shared.isSalesRepUser!{
                            saveOrderRequest["Latitude"] = UserLocationManager.shared.lattitude
                            saveOrderRequest["Longitude"] = UserLocationManager.shared.longitude
                        }
                        
                        let requestURL  = SyncEngine.baseURL + SyncEngine.placeOrder
                        
                        if AppFeatures.shared.isStripePayment && !UserInfo.shared.isSalesRepUser! {
                            
                            if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CheckoutVC") as? CheckoutViewController
                            {
                                vc.cartTotal = self.cartTotal!;
                                vc.tempCartID = self.tempCartID;
                                vc.saveOrderRequest = saveOrderRequest;
                                vc.autoAuthorize = self.autoAuthorize;
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                        else{
                        
                        debugPrint("orderDetail==",saveOrderRequest)
                        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: saveOrderRequest, strURL: requestURL) { (response : Any) in
                            DispatchQueue.main.async {
                                
//                                Helper.shared.showAlertOnController( message: "Your order has been placed successfully.\(((((response as? Dictionary<String,Any>)?["OrderID"]) as? NSNumber) != nil) ? " Your order number is \((((response as? Dictionary<String,Any>)?["OrderID"]) as! NSNumber))" : "")", title: CommonString.app_name,hideOkayButton: true)
//
//
//                                Helper.shared.dismissAlert()
                                
                                if let orderSubmittedPopup = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrderSubmittedPopupVC") as? OrderSubmittedPopupVC
                                {
                                    //"Are you sure you want to place this order for \(dayStr),\(date)?"
                                    orderSubmittedPopup.modalPresentationStyle = .overCurrentContext
                                    self.present(orderSubmittedPopup, animated: false, completion: nil)
                                    orderSubmittedPopup.completionBlock = { 
                                        Helper.shared.lastSetDateTimestamp = nil
                                        Helper.shared.selectedDeliveryDate = nil
                                        Helper.shared.cartCount = 0
                                        NotificationCenter.default.post(name: Notification.Name("placeOrder"), object: nil, userInfo: nil)
                                        self.addMoreItemsAction(nil)
                                        
                                    }
                                }
                                
                            }
                            }}
                    }
                }
            }
//            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: "Are you sure you want to place this order for \(dayStr),\(date)?", withCancelButtonTitle: "No")
//            {
//
//
//            }
        }
    }
    
    
    
    @IBAction func saveOrderAction(_ sender: Any)
    {
        if self.isShowingOrderDetails
        {
            
        }
        else
        {
            self.callApiForSavingOrder()
        }
    }
    
    func callApiForSavingOrder()
    {
        let saveOrderRequest = [
            "TempCartID": self.tempCartID,
            "UserID": UserInfo.shared.userId!,
            "CustomerID": UserInfo.shared.customerID!,
            "SaveOrder": true
            ] as [String : Any]
        
        let requestURL  = SyncEngine.baseURL + SyncEngine.placeOrder
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: saveOrderRequest, strURL: requestURL) { (response : Any) in
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: "Order saved successfully.", withCancelButtonTitle: "OK", completion: {
                DispatchQueue.main.async {
                    Helper.shared.cartCount = 0
                    self.navigationController?.popViewController(animated: true)
                    
                    if ((self.navigationController?.tabBarController?.viewControllers) != nil)
                    {
                        for controller in ((self.navigationController?.tabBarController!.viewControllers![0] as? UINavigationController)?.viewControllers)!
                        {
                            if let control = controller as? OrderVC
                            {
                                control.getAllDefaultPantryItems(searchText: "")
                            }
                        }
                    }
                }
                
            })
        }
    }
    
    func getUserAddresses()
    {
        Helper.shared.lastSetDateTimestamp = nil
        Helper.shared.selectedDeliveryDate = nil
        
        if UserInfo.shared.isDelivery {
        
            let dicCartItem = [
                      "CustomerID": UserInfo.shared.customerID
                  ]
                  
                  SyncEngine.sharedInstance.sendGetRequestToServer(strURL: SyncEngine.baseURL + SyncEngine.getUserAddresses) { (response : Any) in
         
            if let arrObj = response as? Array<Dictionary<String,Any>>, arrObj.count > 0
            {
                
                 self.showAddressChoosePopup(suggestedAddresses: arrObj)
                
            }
            else
            {
                Helper.shared.showAlertOnController( message: "No delivery address found.", title: CommonString.app_name,hideOkayButton: true)
                Helper.shared.dismissAlert()
               // self.showDatePicker()
                
            }
        }
        }else {
            let serviceURL = SyncEngine.baseURL + SyncEngine.getPickupAddress
                  SyncEngine.sharedInstance.sendGetRequestToServer(strURL: serviceURL) { (response : Any) in
                    
                    let arrObj1 = response as? Dictionary<String,Any>
                    if  arrObj1 != nil
                    {
                        if let arrObj = arrObj1!["Pickups"] as? Array<Dictionary<String,Any>> ,arrObj.count > 0
                      {
                          
                          self.showPickupAddressChoosePopup(suggestedAddresses: arrObj)
                          
                      }
                      else
                      {
                        Helper.shared.showAlertOnController( message: "No pickup address found.", title: CommonString.app_name,hideOkayButton: true)
                        Helper.shared.dismissAlert()

//                          self.showDatePicker()
                          
                      }
                    }
        }
        }}
    
    func showPickupAddressChoosePopup(suggestedAddresses : Array<Dictionary<String,Any>>)
       {
           
           
           let title = "Select your preferred Pick-Up location"
           let cancelButton = "CANCEL"
           let AddressNameKey = "PickupAddress"
           DispatchQueue.main.async {
               if let multipleObj = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: MultipleOptionPicker.storyboardIdentifier) as? MultipleOptionPicker
               {
                   multipleObj.showMultipleOptionPickerOnWindow(forDisplayKeyName: AddressNameKey, withDataSource: suggestedAddresses, withTitle: title, withSuccessButtonTitle: "OK", withCancelButtonTitle: cancelButton, withAlertMessage: "Sorry you must select one pickup address") { (selectedVal : Int) in
                      
                       if selectedVal >= 0  {
                       // Handle Response here.
                       if let addressID = suggestedAddresses[selectedVal]["ID"] as? NSNumber
                       {
                           self.pickupAddress =  addressID
                         UserInfo.shared.pickupAddress = addressID
                          self.showDatePicker()
                       }
                       }
                       else{
                           if let addressID = suggestedAddresses[0]["ID"] as? NSNumber
                           {
                             // self.pickupAddress =  addressID
                               //UserInfo.shared.pickupAddress =  addressID
                               //self.showDatePicker()
                           }
                       }
                   }
               }
           }
       }
    
    func showAddressChoosePopup(suggestedAddresses : Array<Dictionary<String,Any>>)
    {
        
        
        let title = UserInfo.shared.isDelivery ? "Your Delivery Address" : "Select your preferred Pick-Up location"
        let cancelButton = "CANCEL" //UserInfo.shared.isDelivery ? "ADD" : "CANCEL"
        let AddressNameKey = UserInfo.shared.isDelivery ? "Address1" : "PickupAddress"
        DispatchQueue.main.async {
            if let multipleObj = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: MultipleOptionPicker.storyboardIdentifier) as? MultipleOptionPicker
            {
                multipleObj.showMultipleOptionPickerOnWindow(forDisplayKeyName: AddressNameKey, withDataSource: suggestedAddresses, withTitle: title, withSuccessButtonTitle: "OK", withCancelButtonTitle: cancelButton, withAlertMessage: "Please choose shipping address.") { (selectedVal : Int) in
                   
                    if selectedVal >= 0  {
                    // Handle Response here.
                    if let addressID = suggestedAddresses[selectedVal]["AddressId"] as? NSNumber
                    {
                        self.addressId =  addressID
                        UserInfo.shared.deliveryAddress = self.addressId
                        self.showDatePicker()
                    }
                    }
                   else{
                        if let addressID = suggestedAddresses[0]["AddressId"] as? NSNumber
                        {
                          ///  self.addressId =  addressID
                            //UserInfo.shared.deliveryAddress = self.addressId
                            //self.showDatePicker()
                        }
                    }
                }
            }
        }
    }
    
    @objc func uOMChanged(sender : UIButton)
    {
        if let obj = self.arrCartItems[sender.tag]["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1
        {
            let index = obj.index(where: { (testdic : Dictionary<String, Any>) -> Bool in
                testdic["UOMDesc"] as? String == sender.titleLabel?.text
            })
            
            if index! + 1 < obj.count
            {
                var newObj = obj[index!+1]
                var objToChange = arrCartItems[sender.tag]
                objToChange["UnitName"] = newObj["UOMDesc"] as? String
                objToChange["OrderUnitName"] = newObj["UOMDesc"] as? String
                objToChange["UOMID"] = newObj["UOMID"] as? NSNumber
                objToChange["OrderUnitId"] = newObj["UOMID"] as? NSNumber
                objToChange["Price"] = newObj["Price"] as? Double
                self.arrCartItems[sender.tag] = objToChange
                self.checkMinAndMaxOrderQuantity(productValue: objToChange, index: sender.tag, quantityValue:  objToChange["Quantity"] as? NSNumber ?? 0)
            }
            else
            {
                var newObj = obj[0]
                var objToChange = arrCartItems[sender.tag]
                objToChange["UnitName"] = newObj["UOMDesc"] as? String
                objToChange["OrderUnitName"] = newObj["UOMDesc"] as? String
                objToChange["UOMID"] = newObj["UOMID"] as? NSNumber
                objToChange["OrderUnitId"] = newObj["UOMID"] as? NSNumber
                objToChange["Price"] = newObj["Price"] as? Double
                self.arrCartItems[sender.tag] = objToChange
                self.checkMinAndMaxOrderQuantity(productValue: objToChange, index: sender.tag, quantityValue:objToChange["Quantity"] as? NSNumber ?? 0)
            }
        }
    }
    
    
    func backOrder(dic : Dictionary<String,Any>){
        
        let sohValue = dic["StockQuantity"] as? Double ?? 0.0
        var qtyValue = Double(truncating:(dic["Quantity"] as? NSNumber) ?? 0.0)
        qtyValue = qtyValue == 0.0 ? 1.0:qtyValue
        var qtyPerUnit = 1.0
        
        var arrPrices : Array<Dictionary<String,Any>>?
        if let prices = dic["DynamicUOM"] as? Array<Dictionary<String,Any>>
        {
            arrPrices = prices
        }
        else if let prices = dic["Prices"] as? Array<Dictionary<String,Any>>
        {
            arrPrices = prices
        }
        else if let prices = dic["Prices"] as? Dictionary<String,Any>
        {
            arrPrices = [prices]
        }
        
        if let obj = dic["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1// Implement new(only check)
        {
            
            if (arrPrices != nil), arrPrices!.count > 0
            {
                let testIndex = arrPrices?.index(where: { (testdic : Dictionary<String, Any>) -> Bool in
                    testdic["UOMID"] as? NSNumber == dic["UOMID"] as? NSNumber
                })
                
                let objToFetch = arrPrices![testIndex ?? 0]
                if let packSize = objToFetch["QuantityPerUnit"] as? Int {
                    qtyPerUnit = Double(packSize)
                    qtyValue = qtyValue * Double(packSize)
                }
            }
        }
        
        var product = dic
        if !AppFeatures.shared.isBackOrder{
            product["Quantity"] = Int(qtyValue/qtyPerUnit)
            self.checkOrderMultiplies(productDetail :product)
        }else if sohValue > qtyValue{
            product["Quantity"] = Int(qtyValue/qtyPerUnit)
            self.checkOrderMultiplies(productDetail : product)
        }else {
            
            if let buyInPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:SaaviActionAlert.storyboardIdentifier) as? SaaviActionAlert
            {
                if sohValue <= 0{
                    
                    buyInPopup.showCommonAlertOnWindow(withTitle: "Important", withSuccessButtonTitle: "", withMessage: "Sorry, this product is out of stock at this moment.", withCancelButtonTitle: "Ok") {
                        
                        self.getCartItems()
                    }
                }else if sohValue < qtyPerUnit || (sohValue < qtyValue && qtyPerUnit != 1) {
                    
                    buyInPopup.showCommonAlertOnWindow(withTitle: "Important", withSuccessButtonTitle: "", withMessage: "Sorry, there are only \(sohValue) units available. Only this quantity will be added to the cart", withCancelButtonTitle: "Ok") {
                        if let obj = dic["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1{
                            
                            for index in 0..<arrPrices!.count
                            {
                                let objToFetch = arrPrices![index]
                                if let packSize = objToFetch["QuantityPerUnit"] as? Int {
                                    
                                    if packSize == 1{
                                        
                                        product["UnitName"] = objToFetch["UOMDesc"] as? String
                                        product["OrderUnitName"] = objToFetch["UOMDesc"] as? String
                                        product["UOMID"] = objToFetch["UOMID"] as? NSNumber
                                        product["OrderUnitId"] = objToFetch["UOMID"] as? NSNumber
                                        product["Price"] = objToFetch["Price"] as? Double
                                        product["Quantity"] = sohValue
                                        self.self.checkOrderMultiplies(productDetail : product)
                                        self.cartTableView.reloadData()
                                        break
                                    }
                                }
                            }
                        }
                    }
                }else {
                    buyInPopup.showCommonAlertOnWindow(withTitle: "Important", withSuccessButtonTitle: "", withMessage: "Your order quantity is greater than  the stock on hand quantity of \(sohValue). Only the available quantity will be added to the cart.", withCancelButtonTitle: "Ok") {
                        
                        product["Quantity"] = Int(sohValue/qtyPerUnit)
                        self.checkOrderMultiplies(productDetail : product)
                    }
                }
            }
        }
    }
    
    
    func updateCartItemObjWithObj(dic : Dictionary<String,Any>, quantityVal: Double = 0.0 )
    {
        var arrPrices : Array<Dictionary<String,Any>>?
        if let prices = dic["DynamicUOM"] as? Array<Dictionary<String,Any>>
        {
            arrPrices = prices
        }
        else if let prices = dic["Prices"] as? Array<Dictionary<String,Any>>
        {
            arrPrices = prices
        }
        else if let prices = dic["Prices"] as? Dictionary<String,Any>
        {
            arrPrices = [prices]
        }
        
        
        let index = arrPrices?.index(where: { (testdic : Dictionary<String, Any>) -> Bool in
            testdic["UOMID"] as? NSNumber == dic["OrderUnitId"] as? NSNumber
        })
        if let obj = arrPrices?[index ?? 0]
        {
            let dic = [
                "CartItemID": (dic["CartItemID"] as? NSNumber)!,
                "CartID": (dic["CartID"] as? NSNumber)!,
                "ProductID": (dic["ProductID"] as? NSNumber)!,
                "Quantity": quantityVal,
                "Price": (obj["Price"] as? Double)!,
                "UnitId": (obj["UOMID"] as? NSNumber)!,
                "CommentID": self.commentID == nil ? (dic["ProdCommentID"] as? NSNumber ?? 0): self.commentID!
                ] as [String : Any]
            
            SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: dic, strURL: SyncEngine.baseURL + SyncEngine.updateCartItem) { (response : Any) in
                
                self.commentID = nil
                Helper.shared.showAlertOnController( message: "Product Updated successfully.", title: CommonString.app_name,hideOkayButton: true)
                Helper.shared.dismissAlert()
                NotificationCenter.default.post(name: Notification.Name("addToCart"), object: nil, userInfo: ["ProductID":dic["ProductID"] as? NSNumber! , "Quantity":dic["Quantity"] as? NSNumber ])
                self.getCartItems()
            }
        }
    }
    
    @IBAction func clearTVTextAction(_ sender: Any) {
        commentID = nil
        orderCommentID = nil
        commentString = nil
        textViewAddComment.text = ""
        self.cnstViewCommentBoxHeight.constant = 30.0 * VerticalSpacingConstraints.spacingConstant
        self.btnClearComment.isHidden = true
    }
    
    @objc func showCartScreen() -> Void
    {
        DispatchQueue.main.async {
            if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cartVCStoryboardID") as? CartView
            {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @objc func setDefaultNavigation() -> Void
    {
        self.navigationItem.rightBarButtonItems = nil
        if self.isShowingOrderDetails
        {
            Helper.shared.createCartIcon(onController: self)
        }
        Helper.shared.createLatestSpecialsBarButtonItem(onController: self)
        Helper.shared.createHelpButtonItem(onController: self)
    }
    
    @objc func showLatestSpecialsAction(){
        
        if let walkthrough = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: WhatsNewVC.storyboardID) as? WhatsNewVC{
            walkthrough.isFromTab = false
            self.navigationController?.pushViewController(walkthrough, animated: true)
        }
    }
    
    @IBAction func btnPromocodeAction(_ sender: Any) {
        if self.arrCartItems.count == 0{
                           DispatchQueue.main.async {
                               self.navigationController?.popViewController(animated: true)
                               Helper.shared.showAlertOnController( message: "No items found in cart. Please add items to continue.", title: CommonString.app_name,hideOkayButton: true)
                               Helper.shared.dismissAlert()
                           }
                       
        }else{
        PromocodeVC.shared.showCommonAlertOnWindow(cartID: self.tempCartID ,completion: { (totalCart : Double ,  discount :Double) in
            self.promoApplied =  true;
            if discount > 0 {
                self.cartTotal = totalCart
                
                let price_final = Double(round(100*totalCart)/100)

                self.viewPromo.isHidden = false
                let string = "(" + String(format: "\(CommonString.currencyType)%.2f", discount) + ")"
                let total = String(format: "\(CommonString.currencyType)%.2f", price_final)
                
                self.lblDicount.text = String(string)
                self.lblSubTotal.text = String(total)
                self.lblPromo.isHidden  = false
                self.lblDicount.isHidden = false
                self.isFrieghtChargesApplicable = false
                self.lblcharges.isHidden = true
                self.lblFreight.isHidden = true
            }
           
        })
        }
    }
    @objc func showHelpAction(){
        
        SyncEngine.sharedInstance.sendGetRequestToServer(strURL: SyncEngine.baseURL + SyncEngine.GetHelp + "cartpage") { (response: Any) in
            
            print(response)
            
            if let responseDic = response as? Dictionary<String,Any>
            {
                print(responseDic)
                SaaviActionHelp.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage:responseDic["Description"] as! String!, withCancelButtonTitle: "OK", completion:{
                    
                })
                
                
                
            }
            
        }
    }
    
//    @objc func showSearchBar() -> Void
//    {
//        if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderVCStoryboardId") as? OrderVC
//        {
//            destinationViewController.isSearchingProduct = true
//            destinationViewController.isShowingDefaultPantryList = false
//            self.navigationController?.pushViewController(destinationViewController, animated: false)
//        }
//    }
}

class PaddingLabel: UILabel {
    
    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 5.0
    @IBInspectable var rightInset: CGFloat = 5.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += topInset + bottomInset
            contentSize.width += leftInset + rightInset
            return contentSize
        }
    }
}

extension CartView: LightboxControllerPageDelegate ,LightboxControllerDismissalDelegate{
    
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        
    }
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
    }
}


