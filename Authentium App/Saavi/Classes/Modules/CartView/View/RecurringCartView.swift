//
//  RecurringCartView.swift
//  Saavi
//
//  Created by Vikramjeet Singh on 06/08/20.
//  Copyright © 2020 Saavi. All rights reserved.
//

import UIKit
import Lightbox
import WebKit

class RecurringCartView: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate {
    
    var arrCartItems = Array<Dictionary<String,Any>>()
    @IBOutlet weak var cartTableView: UITableView!
    var isShowingOrderDetails : Bool = false
    var orderID : NSNumber?
    var isShowingSavedOrder = false
    var selectedIndexPathArray = Array<Int>()
    @IBOutlet weak var headerView: UIView!
    var isOnlyDonationBox = true
    var donationPrice: Double = 0.0
    
    /*Variables for PO Number*/
    
    @IBOutlet weak var btnAddItem: UIButton!
    
    @IBOutlet weak var btnPlaceOrder: UIButton!
    @IBOutlet weak var btnSaveOrder: UIButton!
    @IBOutlet weak var staticLblSelect: UILabel!
    
    @IBOutlet weak var viewAmount: UIView!
    @IBOutlet weak var lblTitleSubTotal: UILabel!
    @IBOutlet weak var lblSubTotal: UILabel!
   
    
    @IBOutlet weak var viewFreight: UIView!
    @IBOutlet weak var btnAddPromo: UILabel!
    
    @IBOutlet weak var viewAmountHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveOrderHeightConstraint: VerticalSpacingConstraints!
    @IBOutlet weak var placeOrderBtnHeightConstraint: VerticalSpacingConstraints!
    @IBOutlet weak var addItemsHeightConstraint: VerticalSpacingConstraints!
    @IBOutlet weak var verticalSpacingBwSaveAndPlace: NSLayoutConstraint!
    
    @IBOutlet var suspendBtn: UIButton!
    
    
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
    var deliveryAddress : NSNumber = 0
    var modelForPayment = NSMutableDictionary()

    var isSuspended = Bool()
    var isPaymentPopupEnabled = Bool()
    var isViewDidLoadCalled = false

    
    @IBOutlet var paymentNoticeBgView: UIView!
    @IBOutlet var paymentNoticeView: UIView!
    @IBOutlet var paymentNoticeCheckboxBtn: UIButton!
    @IBOutlet var okBtn: UIButton!
    
    
    @IBOutlet var paymentInfoBgView: UIView!
    @IBOutlet var paymentInfoMainView: UIView!
    @IBOutlet var paymentInfoOkBtn: UIButton!
    @IBOutlet var paymentInfoWebView: WKWebView!
    
    @IBOutlet var paymentPopupScroll: UIScrollView!
    
    @IBOutlet var paymentInfoLbl: UILabel!
    

    
    @IBOutlet weak var lblTotalOrderValue : UILabel?
    
    //    MARK:- View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        isViewDidLoadCalled = true
        
        self.createTotalCartValueLabel()

        self.cartTableView.estimatedRowHeight = 70
        self.cartTableView.rowHeight = UITableViewAutomaticDimension
        
        DispatchQueue.main.async {
            self.btnAddItem.layer.cornerRadius = 15.0
            self.btnAddItem.titleLabel?.font = UIFont.Roboto_Bold(baseScaleSize: 18.0)
            self.btnSaveOrder.layer.cornerRadius = 15.0
            self.btnSaveOrder.titleLabel?.font = UIFont.Roboto_Bold(baseScaleSize: 18.0)
            self.btnPlaceOrder.layer.cornerRadius = 15.0
            self.btnPlaceOrder.titleLabel?.font = UIFont.Roboto_Bold(baseScaleSize: 18.0)
            
            self.btnAddItem.backgroundColor = UIColor.primaryColor()
            self.btnPlaceOrder.backgroundColor = UIColor.primaryColor2()
            
            
            self.paymentNoticeView.layer.cornerRadius = 10
            self.paymentNoticeView.clipsToBounds = true
            self.okBtn.layer.cornerRadius = 15.0
            self.okBtn.titleLabel?.font = UIFont.Roboto_Bold(baseScaleSize: 18.0)
            self.okBtn.backgroundColor = UIColor.primaryColor()
            
            
            self.paymentInfoMainView.layer.cornerRadius = 10
            self.paymentInfoMainView.clipsToBounds = true
            self.paymentInfoOkBtn.layer.cornerRadius = 15.0
            self.paymentInfoOkBtn.titleLabel?.font = UIFont.Roboto_Bold(baseScaleSize: 18.0)
            self.paymentInfoOkBtn.backgroundColor = UIColor.primaryColor()

            
            if(UserDefaults.standard.value(forKey: "isPaymentPopupEnabled") == nil)
            {
                self.paymentNoticeCheckboxBtn.setImage(UIImage(named: "unCheck1"), for: .normal)
                self.isPaymentPopupEnabled = false
                UserDefaults.standard.set(false, forKey: "isPaymentPopupEnabled")
            }
            else
            {
                let isPaymentPopupEnabled = UserDefaults.standard.value(forKey: "isPaymentPopupEnabled") as! Bool
                if (isPaymentPopupEnabled == false)
                {
                    self.paymentNoticeCheckboxBtn.setImage(UIImage(named: "unCheck1"), for: .normal)
                    self.isPaymentPopupEnabled = false
                    UserDefaults.standard.set(false, forKey: "isPaymentPopupEnabled")
                }
                else
                {
                    self.paymentNoticeCheckboxBtn.setImage(UIImage(named: "check1"), for: .normal)
                    self.isPaymentPopupEnabled = true
                    UserDefaults.standard.set(true, forKey: "isPaymentPopupEnabled")
                }
            }


        }
        
        self.cartTableView.tableFooterView = UIView()
        Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
        Helper.shared.setNavigationTitle(viewController: self, title: "Recurring Order")
            
        self.lblTitleSubTotal.font = UIFont.SFUIText_Regular(baseScaleSize: 15.0)
        self.lblSubTotal.font = UIFont.SFUIText_Regular(baseScaleSize: 15.0)
        if AppFeatures.shared.saveOrderPermitted == true && isShowingSavedOrder == false{
            self.placeOrderBtnHeightConstraint.constant = 0.0//39.5 * VerticalSpacingConstraints.spacingConstant
        }else{
            self.placeOrderBtnHeightConstraint.constant = 0.0
        }
        
        for view in headerView.subviews
        {
            if view is UILabel
            {
                (view as! UILabel).font = UIFont.SFUI_Regular(baseScaleSize: 15.0)
            }
        }
        
//        suspendBtn.setImage(UIImage(named: "check1"), for: .normal)
//        isSuspended = true
        
      //  self.showPaymentPopup()
                
        paymentPopupScroll.isScrollEnabled = false
        
        if (self.view.frame.size.height < 736)
        {
            paymentPopupScroll.isScrollEnabled = true
            paymentPopupScroll.contentSize = CGSize(width: paymentPopupScroll.frame.size.width, height: 950)
            paymentInfoMainView.frame = CGRect(x:paymentInfoMainView.frame.origin.x , y: paymentInfoMainView.frame.origin.y, width: paymentInfoMainView.frame.size.width, height: paymentInfoMainView.frame.size.height + 300)

        }
        else if (self.view.frame.size.height == 736)
        {
            paymentPopupScroll.isScrollEnabled = true
            paymentPopupScroll.contentSize = CGSize(width: paymentPopupScroll.frame.size.width, height: 980)
            paymentInfoMainView.frame = CGRect(x:paymentInfoMainView.frame.origin.x , y: paymentInfoMainView.frame.origin.y, width: paymentInfoMainView.frame.size.width, height: paymentInfoMainView.frame.size.height + 300)

        }
        else if (self.view.frame.size.height == 812)
        {
            paymentPopupScroll.isScrollEnabled = true
            paymentPopupScroll.contentSize = CGSize(width: paymentPopupScroll.frame.size.width, height: 1000)
            paymentInfoMainView.frame = CGRect(x:paymentInfoMainView.frame.origin.x , y: paymentInfoMainView.frame.origin.y, width: paymentInfoMainView.frame.size.width, height: paymentInfoMainView.frame.size.height + 250)
        }
        else if (self.view.frame.size.height > 812)
        {
            paymentPopupScroll.isScrollEnabled = false
        }


    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.setDefaultNavigation()
        }
        
       // self.getCartItems()
        self.getRecurringCartItems()
    }
    
    func showPaymentPopup()
    {
        SyncEngine.sharedInstance.sendGetRequestToServer(strURL: SyncEngine.baseURL + SyncEngine.GetHelp + "PaymentNotice1") { (response: Any) in
            
            print(response)
            
            if let responseDic = response as? Dictionary<String,Any>
            {
                print(responseDic)
//                SaaviActionHelp.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage:responseDic["Description"] as! String!, withCancelButtonTitle: "OK", completion:{
//
//                })
                
                DispatchQueue.main.async
                {
                        let htmlStr = responseDic["Description"] as! String
                        self.paymentInfoWebView.loadHTMLString(htmlStr, baseURL: Bundle.main.bundleURL)
                        
                        self.navigationController?.isNavigationBarHidden = true
                        self.tabBarController?.tabBar.isHidden = true
                        self.paymentInfoBgView.isHidden = false
                }

            }
            
        }
    }
    
    @IBAction func PaymentInfoOkButton(_ sender: Any)
    {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        paymentInfoBgView.isHidden = true
    }
    
    
    @IBAction func OKButtonAction(_ sender: Any)
    {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        paymentNoticeBgView.isHidden = true
        
        if self.arrCartItems.count == 0
        {
            Helper.shared.showAlertOnController( message: "Please add products before placing order.", title: CommonString.app_name)
//            self.navigationController?.popViewController(animated: false)
            return
        }

        if (self.isSuspended == true)
        {
            self.callApiForSavingOrder()
        }
        else
        {
            self.showDeliveryTypePopup()
        }

    }
    
    @IBAction func PaymentNoticeCheckboxButton(_ sender: Any)
    {
        if isPaymentPopupEnabled == true
        {
            paymentNoticeCheckboxBtn.setImage(UIImage(named: "unCheck1"), for: .normal)
            isPaymentPopupEnabled = false
            UserDefaults.standard.set(false, forKey: "isPaymentPopupEnabled")

        }
        else
        {
            paymentNoticeCheckboxBtn.setImage(UIImage(named: "check1"), for: .normal)
            isPaymentPopupEnabled = true
            UserDefaults.standard.set(true, forKey: "isPaymentPopupEnabled")
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
                let ordValue = self.orderTotal!
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
            let priceStr = total.withCommas()
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
        
        let gst = total * 10 / 100
        let grandTotal = total - self.discount
        self.cartTotal = grandTotal
        self.lblSubTotal.text = "\(CommonString.currencyType)\(grandTotal.withCommas())"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if self.orderID != nil , self.isShowingOrderDetails == true
        {
            Helper.shared.setNavigationTitle(withTitle: "Order Detail - \(String(describing: self.orderID!))", withLeftButton: .backButton, onController: self)
        }
        self.cartTableView.reloadData()
    }
        
    
    func getRecurringCartItems() -> Void
    {
        self.donationPrice = 0.0
        self.isOnlyDonationBox = true
        DispatchQueue.main.async {
         
        }
        let serviceURL = SyncEngine.baseURL + SyncEngine.getRecurryCartItems
        let requestToGetCartItems = [
            "CustomerID": UserInfo.shared.customerID!
            ] as Dictionary<String,Any>
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestToGetCartItems, strURL: serviceURL) { (response : Any) in
            
            if  response as? Dictionary<String,Any> != nil {
            
            self.autoAuthorize = (response as? Dictionary<String,Any>)?["AuthPayment"] as? Bool
            debugPrint(response)

                let recurrProducts = (response as? Dictionary<String,Any>)?["RecurringOrder"]
                self.modelForPayment = (recurrProducts as! NSDictionary).mutableCopy() as! NSMutableDictionary
                let recurrProducts_arr : Array = ((recurrProducts as? Dictionary<String,Any>)?["RecurrProds"] as? Array<Dictionary<String,Any>>)!
                debugPrint(recurrProducts)
                self.arrCartItems.removeAll()
                self.arrCartItems += recurrProducts_arr
                DispatchQueue.main.async {
                    self.cartTableView.reloadData()
                }
                self.tempCartID = (recurrProducts as? Dictionary<String,Any>)?["ID"] as! NSNumber
                self.minCartValue = ((response as? Dictionary<String,Any>)?["MinCartValue"]! as? Double)!
                
                UserInfo.shared.deliveryAddress = (recurrProducts as? Dictionary<String,Any>)?["AddressID"] as! NSNumber
                UserInfo.shared.pickupAddress = (recurrProducts as? Dictionary<String,Any>)?["PickupID"] as! NSNumber
                UserInfo.shared.Frequency = (recurrProducts as? Dictionary<String,Any>)?["Frequency"] as? String
                
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                let StartDate = (recurrProducts as? Dictionary<String,Any>)?["StartDate"] as? String
                Helper.shared.selectedDeliveryDate = df.date(from: StartDate!)
                
                let OrderType = (recurrProducts as? Dictionary<String,Any>)?["OrderType"] as? String
                if (OrderType == "Delivery")
                {
                    UserInfo.shared.isDelivery = true
                }
                else
                {
                    UserInfo.shared.isDelivery = false
                }
                
                if(self.isViewDidLoadCalled == true)
                {
                    self.isViewDidLoadCalled = false
                    let DeliveryDate  = ((response as? Dictionary<String,Any>)?["DeliveryDate"]! as? String)!
                    let PaymentDate  = ((response as? Dictionary<String,Any>)?["PaymentDate"]! as? String)!
                    let TotalAmount  = ((response as? Dictionary<String,Any>)?["TotalAmount"]! as? NSNumber)!

                    DispatchQueue.main.async {
                        self.paymentInfoLbl.text = "Your next charge of " + String(format: "$%@",TotalAmount) + " will be made on the " + String(format: "%@",PaymentDate) + " for a " + String(format: "%@",DeliveryDate) + " delivery date."
                        self.navigationController?.isNavigationBarHidden = true
                        self.tabBarController?.tabBar.isHidden = true
                        self.paymentInfoBgView.isHidden = false
                    }
                }
                

                
//                Your next charge of $90.00 will be made on the 18/08/2020 for a 20/08/2020 delivery date.



                DispatchQueue.main.async {
                    let Suspended  = (recurrProducts as? Dictionary<String,Any>)?["IsSuspended"] as! Bool
                    if (Suspended == false)
                    {
                        self.suspendBtn.setImage(UIImage(named: "unCheck1"), for: .normal)
                        self.isSuspended = false
                        UserInfo.shared.isSuspended = false
                    }
                    else
                    {
                        self.suspendBtn.setImage(UIImage(named: "check1"), for: .normal)
                        self.isSuspended = true
                        UserInfo.shared.isSuspended = true
                    }
                }


                
                self.createAndShowOrderValue()

           
//            debugPrint(response)
//            if let items = (response as? Dictionary<String,Any>)?["CartItems"] as? Array<Dictionary<String,Any>>
//            {
//                debugPrint(items)
//                self.arrCartItems.removeAll()
//                self.arrCartItems += items
//                DispatchQueue.main.async {
//                    self.cartTableView.reloadData()
//                }
//
//                if self.arrCartItems.count > 0{
//                    self.tempCartID = (self.arrCartItems[0]["CartID"] as? NSNumber)!
//                    self.createAndShowOrderValue()
//                }else{
//                    Helper.shared.cartCount = 0
//                }
//
////                if let cartTotalValue = (response as? Dictionary<String,Any>)?["CartTotal"] as? Double
////                {
////                    self.orderTotal = cartTotalValue
////                    self.cartTotal = cartTotalValue
////
////                }
//            }
            
//            self.createAndShowOrderValue()
        }}
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
        
    }
    
    @objc func btnAddEditCommentAction(sender : UIButton){
        
        
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
            }
        }else{
            cell?.lblPrice.text = "-"
            cell?.lblPrice?.textAlignment = .center
        }
        
        
            cell?.btnShowImage.tag = indexPath.row
            cell?.btnShowImage.addTarget(self, action: #selector(self.btnShowImage), for: .touchUpInside)
            cell?.btnPencil.isHidden = true
//            cell?.btnPencil.isSelected = false
//            cell?.btnPencil.tag = indexPath.row
//            cell?.btnPencil.addTarget(self, action: #selector(self.btnAddEditCommentAction), for: .touchUpInside)
            
//            if Int(truncating: objToBeShownInRow["ProdCommentID"] as? NSNumber ?? 0) > 0 {
//
//                cell?.btnPencil.isSelected = true
//            }
            
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
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            
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
        
        if (UserInfo.shared.isSuspended == false)
        {
            Helper.shared.showAlertOnController( message: "Please suspend your existing subscription first to make updates into your recurring cart", title: CommonString.app_name,hideOkayButton: true)
            Helper.shared.dismissAlert()
            return
        }

        
        let indexPath = IndexPath(item: index, section: 0)
        
        let cell = self.cartTableView.cellForRow(at: indexPath) as! CartTableViewCell
        
        if AppFeatures.shared.IsShowQuantityPopup == true{
            
            var product = arrCartItems[index]

            if let circularPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "circularQuantityStoryboardID") as? CircularQuantityPopup{
                
                circularPopup.quantityPerUnit = 1
//                circularPopup.isEach =  Helper.shared.getSelectedUomNameQuantity(product: product).isEach
                
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
        
        let productDetail = productValue
        
        self.arrCartItems[index]["Quantity"] = quantityValue
       // self.cartTableView.reloadData()
       // self.createAndShowOrderValue()
        self.updateCartItemObjWithObj(dic: productDetail, quantityVal: Double(truncating: quantityValue))


        
//        if productDetail["Quantity"]  as? NSNumber == nil{
//            productDetail["Quantity"] = 1.0
//        }
//
//        let minQty = (productDetail["MinOQ"] as? Int ?? 0)
//        let maxQty = (productDetail["MaxOQ"] as? Int ?? 0)
//        let qtyPerUnit = Helper.shared.getPackSize(dic: productValue)
//
//        if AppFeatures.shared.isMinOrderQuantity == true && AppFeatures.shared.isMaxOrderQuantity == true {
//
//            if (Int(truncating: NSNumber(value: minQty))/qtyPerUnit) > Int(quantityValue) && NSNumber(value: minQty) != 0
//            {
//                let msgString = "This item has a minimum order quantity of \( Int(truncating: NSNumber(value: minQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: minQty))) \("units to cart ?")"
//                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
//                    productDetail["Quantity"] = minQty/qtyPerUnit
//                    self.arrCartItems[index] = productDetail
//                    self.cartTableView.reloadData()
//                    self.backOrder(dic: productDetail)
//                })
//            }
//            else if (Int(truncating: NSNumber(value: maxQty))/qtyPerUnit) < Int(quantityValue) && NSNumber(value: maxQty) != 0
//            {
//                let msgString = "This item has a maximum order quantity of \( Int(truncating: NSNumber(value: maxQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: maxQty))) \("units to cart ?")"
//
//                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
//                    productDetail["Quantity"] = maxQty/qtyPerUnit
//                    self.arrCartItems[index] = productDetail
//                    self.cartTableView.reloadData()
//                    self.backOrder(dic: productDetail)
//                })
//            }
//            else{
//                self.arrCartItems[index]["Quantity"] = Double(quantityValue)
//                self.backOrder(dic: self.arrCartItems[index])
//            }
//        }
//        else if  AppFeatures.shared.isMinOrderQuantity == true {
//            if (Int(truncating: NSNumber(value: minQty))/qtyPerUnit) > Int(quantityValue) && NSNumber(value: minQty) != 0
//            {
//                let msgString = "This item has a minimum order quantity of \( Int(truncating: NSNumber(value: minQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: minQty))) \("units to cart ?")"
//                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
//                    productDetail["Quantity"] = minQty/qtyPerUnit
//                    self.arrCartItems[index] = productDetail
//                    self.cartTableView.reloadData()
//                    self.backOrder(dic: productDetail)
//                })
//            }
//            else if  AppFeatures.shared.isMaxOrderQuantity == true {
//                if (Int(truncating: NSNumber(value: maxQty))/qtyPerUnit) < Int(quantityValue) && NSNumber(value: maxQty) != 0
//                {
//                    let msgString = "This item has a maximum order quantity of \( Int(truncating: NSNumber(value: maxQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: maxQty))) \("units to cart ?")"
//
//                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
//                        productDetail["Quantity"] = maxQty/qtyPerUnit
//                        self.arrCartItems[index] = productDetail
//                        self.cartTableView.reloadData()
//                        self.backOrder(dic: productDetail)
//                    })
//                }
//            }
//            else{
//                self.arrCartItems[index]["Quantity"] = Double(quantityValue)
//                self.backOrder(dic: self.arrCartItems[index])
//            }
//        }
//        else if  AppFeatures.shared.isMaxOrderQuantity == true {
//            if (Int(truncating: NSNumber(value: maxQty))/qtyPerUnit) <  Int(quantityValue) && NSNumber(value: maxQty) != 0
//            {
//                let msgString = "This item has a maximum order quantity of \( Int(truncating: NSNumber(value: maxQty))). \("Do you want to add") \( Int(truncating: NSNumber(value: maxQty))) \("units to cart ?")"
//                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: msgString, withCancelButtonTitle: "No", completion:{
//                    productDetail["Quantity"] = maxQty/qtyPerUnit
//                    self.arrCartItems[index] = productDetail
//                    self.cartTableView.reloadData()
//                    self.backOrder(dic: productDetail)
//                })
//            }
//            else{
//                self.arrCartItems[index]["Quantity"] = quantityValue
//                self.backOrder(dic: self.arrCartItems[index])
//            }
//        }
//        else{
//            self.arrCartItems[index]["Quantity"] = quantityValue
//            self.backOrder(dic: self.arrCartItems[index])
//        }
    }
    
    
    
    @IBAction func SuspendButtonAction(_ sender: Any)
    {
        if isSuspended == true
        {
            suspendBtn.setImage(UIImage(named: "unCheck1"), for: .normal)
            isSuspended = false
            UserInfo.shared.isSuspended = false
        }
        else
        {
            suspendBtn.setImage(UIImage(named: "check1"), for: .normal)
            isSuspended = true
            UserInfo.shared.isSuspended = true
        }

    }
    
    
    @objc func backBtnAction() -> Void
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func removeProductFromCartAction(sender : UIButton)
    {
        if (UserInfo.shared.isSuspended == false)
        {
            Helper.shared.showAlertOnController( message: "Please suspend your existing subscription first to make updates into your recurring cart", title: CommonString.app_name,hideOkayButton: true)
            Helper.shared.dismissAlert()
            return
        }
        
        if let productID = self.arrCartItems[sender.tag]["RecurrProdID"] as? NSNumber, let itemName = (self.arrCartItems[sender.tag]["ProductName"] as? String)
        {
            
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: "Delete Product", withSuccessButtonTitle: "Yes", withMessage: "Are you sure you want to remove \(itemName) from the cart?", withCancelButtonTitle: "No", completion:{
                self.callAPIToRemoveItemFromCart(productID: productID,index:sender.tag)
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
                selectedIndexPathArray.append(selectedProdId)
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
    
    
    func callAPIToRemoveItemFromCart(productID : NSNumber,index:Int)
    {
        let dicCartItem = [
            "RecurrProdID": productID,
        ]
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: dicCartItem, strURL: SyncEngine.baseURL + SyncEngine.deleteItemFromRecurringCart) { (response : Any) in
            DispatchQueue.main.async {
                
                Helper.shared.showAlertOnController( message: "Product deleted successfully.", title: CommonString.app_name,hideOkayButton: true)
                Helper.shared.dismissAlert()
                self.getRecurringCartItems()

                
//                if Helper.shared.cartCount == 1{
//                    NotificationCenter.default.post(name: Notification.Name("UpdateCart"), object: nil, userInfo: ["ProductID":productID])
//                }
//                else{
//                    DispatchQueue.main.async {
//                        Helper.shared.showAlertOnController( message: "Product deleted successfully.", title: CommonString.app_name,hideOkayButton: true)
//                        Helper.shared.dismissAlert()
//                        NotificationCenter.default.post(name: Notification.Name("UpdateCart"), object: nil, userInfo: ["ProductID": productID])
//                    }
//                }
//                if self.arrCartItems.count <= 1{
//                    DispatchQueue.main.async {
//                        Helper.shared.cartCount = 0
//                        self.navigationController?.popViewController(animated: true)
//                        Helper.shared.showAlertOnController( message: "No items found in cart. Please add items to continue.", title: CommonString.app_name,hideOkayButton: true)
//                        Helper.shared.dismissAlert()
//                    }
//                }else {
//                    self.arrCartItems.remove(at: index)
//                    self.getCartItems()
//                    self.promoApplied =  false;
//                }
            }
        }
    }
    
    @IBAction func placeOrderAction(_ sender: Any)
    {
        let isPaymentPopupEnabled = UserDefaults.standard.value(forKey: "isPaymentPopupEnabled") as! Bool
        if (isPaymentPopupEnabled == false)
        {
            paymentNoticeBgView.isHidden = false
            self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.tabBar.isHidden = true
        }
        else
        {
            if self.arrCartItems.count == 0
            {
                Helper.shared.showAlertOnController( message: "Please add products before placing order.", title: CommonString.app_name)
    //            self.navigationController?.popViewController(animated: false)
                return
            }
    
            if (self.isSuspended == true)
            {
                self.callApiForSavingOrder()
            }
            else
            {
                self.showDeliveryTypePopup()
            }

        }

        
    }
    
    @IBAction func addMoreItemsAction(_ sender: Any?)
    {
        if (UserInfo.shared.isSuspended == false)
        {
            Helper.shared.showAlertOnController( message: "Please suspend your existing subscription first to make updates into your recurring cart", title: CommonString.app_name,hideOkayButton: true)
            Helper.shared.dismissAlert()
            return
        }

        if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderVCStoryboardId") as? OrderVC
        {
//            destinationViewController.isSearchingProduct = true
//            destinationViewController.isShowingDefaultPantryList = false
            destinationViewController.isComingFromRecurringCart = true
            destinationViewController.RecurringCartId = self.tempCartID
            self.navigationController?.pushViewController(destinationViewController, animated: false)
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
    func showDatePicker(){
        
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
                self.showDatePicker()
                
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
                          self.showDatePicker()
                          
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
                            self.addressId =  addressID
                            UserInfo.shared.deliveryAddress = self.addressId
                            self.showDatePicker()
                        }
                    }
                }
            }
        }
    }
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
                        let Address1 = suggestedAddresses[selectedVal]["Address1"] as? String
                        UserInfo.shared.pickupAddressString = Address1

                           self.pickupAddress =  addressID
                         UserInfo.shared.pickupAddress = addressID
                          self.showDatePicker()
                       }
                       }
                       else{
                           if let addressID = suggestedAddresses[0]["ID"] as? NSNumber
                           {
                            let Address1 = suggestedAddresses[selectedVal]["Address1"] as? String
                            UserInfo.shared.pickupAddressString = Address1

                            self.pickupAddress =  addressID
                             
                               UserInfo.shared.pickupAddress =  addressID
                               self.showDatePicker()
                           }
                       }
                   }
               }
           }
       }
    
    @objc func processOrder() -> Void
    {
        if self.minCartValue! > 0.0 {
            
            if cartTotal! <  self.minCartValue!
            {
                           Helper.shared.showAlertOnController( message: "Sorry, the minimum order value is " + String(format: "\(CommonString.currencyType)%.2f", minCartValue!) + ". Please add further items to ensure you can place your order.", title: "Minimum Order Value")
                           return;
            }
        }
        
        
        self.isFrieghtChargesApplicable = false
        if Helper.shared.isDateSelected() == false && AppFeatures.shared.IsDatePickerEnabled == true
        {
            self.showDeliveryTypePopup()
            return
        }
        else if AppFeatures.shared.shouldShowFreightCharges == true && cartTotal != nil && cartTotal! < Helper.shared.orderValue && UserInfo.shared.isDelivery
        {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: CommonString.frieghtChargesMessage, withCancelButtonTitle: "No", completion: {
                self.isFrieghtChargesApplicable = true
                
//                self.lblcharges.text = String(format: "\(CommonString.currencyType)%.2f", Helper.shared.freightcharges)
                self.cartTotal = self.cartTotal! + Helper.shared.freightcharges
                self.lblSubTotal.text = String(format: "\(CommonString.currencyType)%.2f", self.cartTotal!)
                
                self.showBuyInPopup()

                
            })
        }
        else
        {
            showBuyInPopup()
        }
    }
    
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
    func callAPIForPlacingOrder()
    {
        Helper.shared.lastSetDateTimestamp = nil
        
        if (UserInfo.shared.isSuspended == true)
        {
            self.callApiForSavingOrder()
        }
        else
        {
            if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CheckoutVC") as? CheckoutViewController
            {
                if(UserInfo.shared.isSuspended == true)
                {
                    self.modelForPayment.setValue(1, forKey: "IsSuspended")
                }
                else
                {
                    self.modelForPayment.setValue(0, forKey: "IsSuspended")
                }
                vc.cartTotal = self.cartTotal!;
                vc.tempCartID = self.tempCartID;
                vc.modelPayment = self.modelForPayment
                vc.comingFromRecurringCart = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
        
    @IBAction func saveOrderAction(_ sender: Any)
    {
    }
    
    func callApiForSavingOrder()
    {
        if UserInfo.shared.isDelivery
        {
            self.pickupAddress = 0
            self.deliveryAddress = UserInfo.shared.deliveryAddress
        }
        else
        {
            self.pickupAddress = UserInfo.shared.pickupAddress
            self.deliveryAddress = 0

        }
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        let saveOrderRequest = [
            "ID": self.tempCartID,
            "CustomerID": UserInfo.shared.customerID!,
            "AddressID": self.deliveryAddress,
            "PickupID": self.pickupAddress,
            "Frequency": UserInfo.shared.Frequency!,
            "IsSuspended": UserInfo.shared.isSuspended,
            "OrderType": UserInfo.shared.isDelivery == true ? "Delivery" : "Pick-up",
            "StartDate": df.string(from: Helper.shared.selectedDeliveryDate ?? Date()),
            "RecurrProds": self.arrCartItems
            ] as [String : Any]
        
        let requestURL  = SyncEngine.baseURL + SyncEngine.ManageRecurringOrders
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: saveOrderRequest, strURL: requestURL) { (response : Any) in
            
            Helper.shared.showAlertOnController( message: "Order saved successfully.", title: CommonString.app_name,hideOkayButton: true)
            Helper.shared.dismissAlert()
            self.getRecurringCartItems()

//            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: "Order saved successfully.", withCancelButtonTitle: "OK", completion: {
               

                
//                DispatchQueue.main.async {
//                    self.navigationController?.popViewController(animated: true)
                    
//                    if ((self.navigationController?.tabBarController?.viewControllers) != nil)
//                    {
//                        for controller in ((self.navigationController?.tabBarController!.viewControllers![0] as? UINavigationController)?.viewControllers)!
//                        {
//                            if let control = controller as? OrderVC
//                            {
//                                control.getAllDefaultPantryItems(searchText: "")
//                            }
//                        }
//                    }
//                }
                
//            })
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
                        
                       // self.getCartItems()
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
    //        var arrPrices : Array<Dictionary<String,Any>>?
    //        if let prices = dic["DynamicUOM"] as? Array<Dictionary<String,Any>>
    //        {
    //            arrPrices = prices
    //        }
    //        else if let prices = dic["Prices"] as? Array<Dictionary<String,Any>>
    //        {
    //            arrPrices = prices
    //        }
    //        else if let prices = dic["Prices"] as? Dictionary<String,Any>
    //        {
    //            arrPrices = [prices]
    //        }
    //
    //
    //        let index = arrPrices?.index(where: { (testdic : Dictionary<String, Any>) -> Bool in
    //            testdic["UOMID"] as? NSNumber == dic["OrderUnitId"] as? NSNumber
    //        })
    //        if let obj = arrPrices?[index ?? 0]
    //        {
                let dic = [
                    "RecurrProdID": (dic["RecurrProdID"] as? NSNumber)!,
                    "RecurrID": self.tempCartID,
                    "ProductID": (dic["ProductID"] as? NSNumber)!,
                    "Quantity": quantityVal,
                    ] as [String : Any]
                
                SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: dic, strURL: SyncEngine.baseURL + SyncEngine.updateRecurringCartItem) { (response : Any) in
                    
                    Helper.shared.showAlertOnController( message: "Product Updated successfully.", title: CommonString.app_name,hideOkayButton: true)
                    Helper.shared.dismissAlert()
                    self.getRecurringCartItems()
                }
    //        }
        }
    
    
    @objc func setDefaultNavigation() -> Void
    {
        self.navigationItem.rightBarButtonItems = nil
        Helper.shared.createLatestSpecialsBarButtonItem(onController: self)
        Helper.shared.createHelpButtonItem(onController: self)
    }
    
    @objc func showHelpAction()
    {
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
}
