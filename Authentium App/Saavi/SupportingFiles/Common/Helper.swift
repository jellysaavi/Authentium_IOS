//
//  Helper.swift
//  Saavi
//
//  Created by Sukhpreet on 30/06/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit
import Foundation

class Helper: NSObject {
    
    static let shared = Helper()
    var allowedWeekdaysForDelivery : Array<String>?
    var nextOrderDates : Array<String>?
    var selectedDeliveryDate : Date?
    var lastSetDateTimestamp : Date?
    var customerPhoneNumber : String?
    var stripePublicKey : String?
    var stripeAccountId : String?
    @objc dynamic var cartCount = 0
    @objc dynamic var cartOrderValue : Double = 0
    var salesRepTempCartId : NSNumber = 0
    var customerAppendDic_List = Dictionary<String,Any>()
    var isOrderingOnNonDeliveryDay = false
    var orderValue : Double = 0
    var freightcharges : Double = 0
      
    var IsLeave : Bool = false
    var IsContactless : Bool = false
    var slots = Array<Dictionary<String,Any>>()
    
    //    MARK:- Alert Controller
    
    override init() {
        super.init()
        self.addObserver(self, forKeyPath: "cartCount", options: .prior, context: nil)
    }
    
    func isDateSelected() -> Bool
    {
        if selectedDeliveryDate != nil, lastSetDateTimestamp != nil, Date().timeIntervalSince(lastSetDateTimestamp!) < 1200
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func showAlertOnController(message : String, title : String,hideOkayButton:Bool? = nil)
    {
        let isHiddenOkayButton = hideOkayButton != nil ? hideOkayButton:false
        DispatchQueue.main.async {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: title, withSuccessButtonTitle: nil, withMessage: message, withCancelButtonTitle: "OK",hideOkayButton:isHiddenOkayButton , completion: {
            })
        }
    }
    
    func dismissAlert(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            let transition = CATransition().fadeTransition()
            SaaviActionAlert.shared.view.layer.add(transition, forKey: kCATransition)
            SaaviActionAlert.shared.dismiss(animated: false, completion: nil)
        })
    }
    func dismissAddedToCartAlert(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
            let transition = CATransition().fadeTransition()
//            if UIApplication.shared.keyWindow?.rootViewController?.presentedViewController == nil
//            {
                SaaviActionAlert.shared.view.layer.add(transition, forKey: kCATransition)
                SaaviActionAlert.shared.dismiss(animated: false, completion: nil)
//            }
//            else
//            {
                SaaviActionAlert.shared.view.removeFromSuperview()
//
//            }
        })
    }


    
    // MARK:- Label Delegtates
    
    func createLabelWithMessage(message : String) -> UILabel
    {
        let label = UILabel()
        label.font = UIFont.SFUI_SemiBold(baseScaleSize: 16.0)
        label.text = message
        label.textColor = UIColor.darkGray
        label.sizeToFit()
        return label
    }
    
    //MARK: - - Calculate Margin percentage
    func calculateMarginPercentage(price:Double,companyPrice:Double)->String{
        
        let margin = ((price - companyPrice) / price)
        let marginPercentage = margin * 100;
        var str = String.init(format:"%.2f",marginPercentage)
        str = (price + companyPrice) == 0 ? 0.00.cleanValue:str
        return "\(str)%"
    }
    
    // MARK: Set textField's left padding
    func setLeftPaddingPoints(amount:CGFloat , textField:UITextField){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: textField.frame.size.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    //MARK set textfield border
    func setTextFieldBorder(textField:UITextField){
        textField.layer.masksToBounds = false
        textField.layer.shadowRadius = 2.0
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOffset = CGSize(width:1.0,height: 1.0)
        textField.layer.shadowOpacity = 0.3
    }
    //
    
    
    //    MARK:- Navigation Title
   
    func setNavigationTitle( viewController : UIViewController, title : String)
    {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width:30, height: 30))
        titleLabel.text = title
        titleLabel.textColor = UIColor.baseBlueColor()
        titleLabel.font = UIFont.SFUI_Bold(baseScaleSize: 16.0)
        titleLabel.sizeToFit()
        viewController.navigationItem.titleView = titleLabel
    }
   
    func setNavigationTitle(withTitle title : String ,withLeftButton buttonType : SaaviLeftBarButtonType, onController controller : UIViewController)
    {
        var leftBarItem : UIButton!
        if buttonType == .backButton
        {
            leftBarItem = UIButton(type: .custom)
            leftBarItem.setImage(#imageLiteral(resourceName: "back-screen"), for: .normal)
            leftBarItem.frame = CGRect(x: 0, y: 0, width: 40, height: 50)
            leftBarItem.imageView?.contentMode = .scaleAspectFit
            leftBarItem.addTarget(controller, action: Selector(("backBtnAction")), for: .touchUpInside)
            if UserInfo.shared.isSalesRepUser == true{
                leftBarItem.tintColor = UIColor.baseBlueColor()
            }
            else
            {
                leftBarItem.tintColor = UIColor.baseBlueColor()
            }
            // leftBarItem.tintColor = UIColor.darkGray
            leftBarItem.sizeToFit()
            var frame = leftBarItem.frame
            var size = frame.size
            size = CGSize(width: size.width + 20.0, height: size.height)
            frame.size = size
            leftBarItem.frame = frame
        }else{
            
            leftBarItem = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            leftBarItem.setImage(#imageLiteral(resourceName: "icon_profile"), for: .normal)
            leftBarItem.imageView?.tintColor = UIColor.baseBlueColor()
            leftBarItem.addTarget((controller.navigationController?.tabBarController as? SaaviTabBarController)?.menuController, action: #selector((controller.navigationController?.tabBarController as? SaaviTabBarController)?.menuController?.showMeSideMenu), for: .touchUpInside)
            leftBarItem.sizeToFit()
        }
        
        var rightBarButtonsWidth = CGFloat(0.0)
        
        if controller.navigationItem.rightBarButtonItems != nil
        {
            for btn : UIBarButtonItem in controller.navigationItem.rightBarButtonItems!
            {
                if btn.image != nil
                {
                    rightBarButtonsWidth += (btn.image?.size.width)! + 20.0
                }
                else if btn.customView != nil
                {
                    rightBarButtonsWidth += (btn.customView?.bounds.width)! + 20.0
                }
            }
        }
        
        
        let titleLabel = UILabel(frame: CGRect(x: leftBarItem.frame.maxX + 10.0, y: 0, width:30, height: 30))
        titleLabel.text = title
        titleLabel.font = UIFont.SFUI_Bold(baseScaleSize: 16.0)
        titleLabel.clipsToBounds = true
        titleLabel.textColor = UIColor.baseBlueColor()
        titleLabel.sizeToFit()
        let leftWidth = controller.view.frame.size.width - rightBarButtonsWidth - leftBarItem.frame.size.width - 40.0
        if titleLabel.bounds.size.width > leftWidth
        {
            controller.navigationItem.titleView = titleLabel
            controller.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: leftBarItem)]
        }
        else
        {
            controller.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: leftBarItem), UIBarButtonItem(customView: titleLabel)]
        }
    }
    func setNavigationTitleWithNilBackButton(withTitle title : String ,withLeftButton buttonType : SaaviLeftBarButtonType, onController controller : UIViewController)
    {
        var leftBarItem : UIButton!
        if buttonType == .backButton
        {
            leftBarItem = UIButton(type: .custom)
            leftBarItem.setImage(#imageLiteral(resourceName: "back-screen"), for: .normal)
            leftBarItem.frame = CGRect(x: 0, y: 0, width: 40, height: 50)
            leftBarItem.imageView?.contentMode = .scaleAspectFit
//            leftBarItem.addTarget(controller, action: Selector(("backBtnAction")), for: .touchUpInside)
            leftBarItem.isHidden = true
            if UserInfo.shared.isSalesRepUser == true{
                leftBarItem.tintColor = UIColor.baseBlueColor()
            }
            else
            {
                leftBarItem.tintColor = UIColor.baseBlueColor()
            }
            // leftBarItem.tintColor = UIColor.darkGray
            leftBarItem.sizeToFit()
            var frame = leftBarItem.frame
            var size = frame.size
            size = CGSize(width: size.width + 20.0, height: size.height)
            frame.size = size
            leftBarItem.frame = frame
        }else{
            
            leftBarItem = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            leftBarItem.setImage(#imageLiteral(resourceName: "icon_profile"), for: .normal)
            leftBarItem.imageView?.tintColor = UIColor.baseBlueColor()
            leftBarItem.addTarget((controller.navigationController?.tabBarController as? SaaviTabBarController)?.menuController, action: #selector((controller.navigationController?.tabBarController as? SaaviTabBarController)?.menuController?.showMeSideMenu), for: .touchUpInside)
            leftBarItem.sizeToFit()
        }
        
        var rightBarButtonsWidth = CGFloat(0.0)
        
        if controller.navigationItem.rightBarButtonItems != nil
        {
            for btn : UIBarButtonItem in controller.navigationItem.rightBarButtonItems!
            {
                if btn.image != nil
                {
                    rightBarButtonsWidth += (btn.image?.size.width)! + 20.0
                }
                else if btn.customView != nil
                {
                    rightBarButtonsWidth += (btn.customView?.bounds.width)! + 20.0
                }
            }
        }
        
        
        let titleLabel = UILabel(frame: CGRect(x: leftBarItem.frame.maxX + 10.0, y: 0, width:30, height: 30))
        titleLabel.text = title
        titleLabel.font = UIFont.SFUI_Bold(baseScaleSize: 16.0)
        titleLabel.clipsToBounds = true
        titleLabel.textColor = UIColor.baseBlueColor()
        titleLabel.sizeToFit()
        let leftWidth = controller.view.frame.size.width - rightBarButtonsWidth - leftBarItem.frame.size.width - 40.0
        if titleLabel.bounds.size.width > leftWidth
        {
            controller.navigationItem.titleView = titleLabel
            controller.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: leftBarItem)]
        }
        else
        {
            controller.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: leftBarItem), UIBarButtonItem(customView: titleLabel)]
        }
    }

    
    func setNavigationTitle(withTitle title : [String] ,withLeftButtons buttonsOfType :[SaaviLeftBarButtonType], onController controller : UIViewController)
    {
        var leftBarItem1 : UIButton!
        var leftBarItem2 : UIButton!
        let buttonFirst = buttonsOfType[0]
        let buttonSecond = buttonsOfType[1]
        
        if buttonFirst == .backButton || buttonFirst == .profileButton
        {
            leftBarItem1 = UIButton(type: .custom)
            leftBarItem1.setImage(#imageLiteral(resourceName: "back-screen"), for: .normal)
            leftBarItem1.frame = CGRect(x: 0, y: 0, width: 40, height: 50)
            leftBarItem1.imageView?.contentMode = .scaleAspectFit
            leftBarItem1.addTarget(controller, action: Selector(("backBtnAction")), for: .touchUpInside)
            if UserInfo.shared.isSalesRepUser == true{
                leftBarItem1.tintColor = UIColor.baseBlueColor()
            }
            else
            {
                leftBarItem1.tintColor = UIColor.darkGray
            }
            // leftBarItem.tintColor = UIColor.darkGray
            leftBarItem1.sizeToFit()
            var frame = leftBarItem1.frame
            var size = frame.size
            size = CGSize(width: size.width + 20.0, height: size.height)
            frame.size = size
            leftBarItem1.frame = frame
        }
        if buttonSecond == .profileButton || buttonSecond == .backButton
        {
            leftBarItem2 = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            leftBarItem2.setImage(#imageLiteral(resourceName: "icon_profile"), for: .normal)
            leftBarItem2.imageView?.tintColor = UIColor.baseBlueColor()
            leftBarItem2.addTarget((controller.navigationController?.tabBarController as? SaaviTabBarController)?.menuController, action: #selector((controller.navigationController?.tabBarController as? SaaviTabBarController)?.menuController?.showMeSideMenu), for: .touchUpInside)
            leftBarItem2.sizeToFit()
        }
        
        var rightBarButtonsWidth = CGFloat(0.0)
        
        if controller.navigationItem.rightBarButtonItems != nil
        {
            for btn : UIBarButtonItem in controller.navigationItem.rightBarButtonItems!
            {
                if btn.image != nil
                {
                    rightBarButtonsWidth += (btn.image?.size.width)! + 20.0
                }
                else if btn.customView != nil
                {
                    rightBarButtonsWidth += (btn.customView?.bounds.width)! + 20.0
                }
            }
        }
        
        
        let titleLabel = UILabel(frame: CGRect(x: leftBarItem2.frame.maxX + 10.0, y: 0, width:30, height: 30))
        titleLabel.text = title[1]
        titleLabel.font = UIFont.SFUI_Bold(baseScaleSize: 16.0)
        titleLabel.clipsToBounds = true
        titleLabel.textColor = UIColor.baseBlueColor()
        titleLabel.sizeToFit()
        //let leftWidth = controller.view.frame.size.width - rightBarButtonsWidth - leftBarItem2.frame.size.width - 40.0
        //        if titleLabel.bounds.size.width > leftWidth
        //        {
        //controller.navigationItem.titleView = titleLabel
        controller.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: leftBarItem1),UIBarButtonItem(customView: leftBarItem2),UIBarButtonItem(customView: titleLabel)]
        //        }
        //        else
        //        {
        //            controller.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: leftBarItem2), UIBarButtonItem(customView: titleLabel)]
        //        }
    }
    
    func getPackSize(dic:Dictionary<String,Any>)->Int{
        
        var arrPrices : Array<Dictionary<String,Any>>?
        if let prices = dic["DynamicUOM"] as? Array<Dictionary<String,Any>>{
            arrPrices = prices
        }else if let prices = dic["Prices"] as? Array<Dictionary<String,Any>>{
            arrPrices = prices
        }else if let prices = dic["Prices"] as? Dictionary<String,Any>{
            arrPrices = [prices]
        }
        if (arrPrices != nil), arrPrices!.count > 0{
            
            var index : Int = 0
            if let selectedIndex = dic["selectedIndex"] as? Int
            {
                index = selectedIndex
            }else if index + 1 < arrPrices!.count{
                
                let testIndex = arrPrices?.index(where: { (testdic : Dictionary<String, Any>) -> Bool in
                    testdic["UOMID"] as? NSNumber == dic["UOMID"] as? NSNumber
                })
                if (testIndex != nil)
                {
                    index = testIndex!
                }
                let testIndex1 = arrPrices?.index(where: { (testdic : Dictionary<String, Any>) -> Bool in
                    testdic["UOMID"] as? NSNumber == dic["OrderUnitId"] as? NSNumber
                })
                if (testIndex1 != nil)
                {
                    index = testIndex1!
                }
            }
            
            let objToFetch = arrPrices![index]
            if let packSize = objToFetch["QuantityPerUnit"] as? Int {
                return packSize
            }
        }
        return 0
    }
    
    //MARK:- Navigation Buttons
    
    func createLatestSpecialsBarButtonItem(onController controller:UIViewController, isForceAdd : Bool = false) -> Void
    {
        if AppFeatures.shared.canShowLatestSpecials == true{
            
            let latestSpecialBarBtnItem  = UIBarButtonItem(image: #imageLiteral(resourceName: "iconLatestSpecial"), style: .plain, target: controller, action: Selector(("showLatestSpecialsAction")))
            latestSpecialBarBtnItem.tintColor = UIColor.baseBlueColor()
            if controller.navigationItem.rightBarButtonItems != nil{
                controller.navigationItem.rightBarButtonItems?.append(latestSpecialBarBtnItem)
            }else{
                controller.navigationItem.rightBarButtonItems = [latestSpecialBarBtnItem]
            }
        }
    }
    
    func createHelpButtonItem(onController controller:UIViewController, isForceAdd : Bool = false) -> Void
    {
        
            let latestSpecialBarBtnItem  = UIBarButtonItem(image: #imageLiteral(resourceName: "help"), style: .plain, target: controller, action: Selector(("showHelpAction")))
            latestSpecialBarBtnItem.tintColor = UIColor.baseBlueColor()
            if controller.navigationItem.rightBarButtonItems != nil{
                controller.navigationItem.rightBarButtonItems?.append(latestSpecialBarBtnItem)
            }else{
                controller.navigationItem.rightBarButtonItems = [latestSpecialBarBtnItem]
            }
        
    }
    func createEmailButtonItem(onController controller:UIViewController, isForceAdd : Bool = false) -> Void
    {
        
        let latestSpecialBarBtnItem  = UIBarButtonItem(image: #imageLiteral(resourceName: "Email"), style: .plain, target: controller, action: #selector(PantryListVC.showEmailScreen))
        latestSpecialBarBtnItem.tintColor = UIColor.baseBlueColor()
        if controller.navigationItem.rightBarButtonItems != nil{
            controller.navigationItem.rightBarButtonItems?.append(latestSpecialBarBtnItem)
        }else{
            controller.navigationItem.rightBarButtonItems = [latestSpecialBarBtnItem]
        }
        
    }
    func createNotesButtonItem(onController controller:UIViewController, isForceAdd : Bool = false) -> Void
    {
        
        let latestSpecialBarBtnItem  = UIBarButtonItem(image: #imageLiteral(resourceName: "notes"), style: .plain, target: controller, action: #selector(PantryListVC.showNotesScreen))
        latestSpecialBarBtnItem.tintColor = UIColor.baseBlueColor()
        if controller.navigationItem.rightBarButtonItems != nil{
            controller.navigationItem.rightBarButtonItems?.append(latestSpecialBarBtnItem)
        }else{
            controller.navigationItem.rightBarButtonItems = [latestSpecialBarBtnItem]
        }
        
    }
    
    func createCartIcon(onController controller:UIViewController, isForceAdd : Bool = false) -> Void
    {
        let cartBtn = UIButton(type: .custom)
        cartBtn.setImage(#imageLiteral(resourceName: "LS_add_to_cart"), for: .normal)
        cartBtn.imageView?.tintColor = UIColor.baseBlueColor()
        cartBtn.sizeToFit()
        cartBtn.isUserInteractionEnabled = false
        /* Because only btn was clickable and was causing break*/
        //        cartBtn.addTarget(controller, action: Selector(("showCartScreen")), for: .touchUpInside)
        
        let numberLabel = UILabel()
        if Helper.shared.cartCount > 0
        {
            numberLabel.text = "\(Helper.shared.cartCount)"
        }
        else
        {
            numberLabel.text = ""
        }
        numberLabel.backgroundColor = UIColor.primaryColor()
        numberLabel.textColor = UIColor.white
        numberLabel.clipsToBounds = true
        numberLabel.textAlignment = NSTextAlignment.center
        numberLabel.font = UIFont.SFUI_SemiBold(baseScaleSize: 13.0)
        numberLabel.sizeToFit()
        numberLabel.frame = CGRect(x: numberLabel.frame.minX, y: numberLabel.frame.minY-10, width: (numberLabel.frame.width > 0.0) ? (numberLabel.frame.width + 10.0) : 0.0, height: (numberLabel.frame.width > 0.0) ? (numberLabel.frame.width + 10.0) : 0.0)
        numberLabel.layer.cornerRadius = numberLabel.frame.size.width/2.0
        numberLabel.isUserInteractionEnabled = false
        
        let cartIcon = UIView(frame: CGRect(x: 0, y: 0, width: 55, height: 44))
        cartIcon.addSubview(cartBtn)
        cartBtn.center = cartIcon.center
        cartIcon.addSubview(numberLabel)
        numberLabel.center = CGPoint(x: cartBtn.frame.maxX, y: cartBtn.frame.minY)
        cartIcon.sizeToFit()
        
        /*In order to make whole thing clickable*/
        let tapGesture = UITapGestureRecognizer(target: controller, action: Selector(("showCartScreen")))
        tapGesture.numberOfTapsRequired = 1
        cartIcon.addGestureRecognizer(tapGesture)
        
        let cartBtnItem = UIBarButtonItem(customView: cartIcon)
        if controller.navigationItem.rightBarButtonItems != nil
        {
            controller.navigationItem.rightBarButtonItems?.append(cartBtnItem)
        }
        else
        {
            controller.navigationItem.rightBarButtonItems = [cartBtnItem]
        }
    }
    
    func createSearchIcon(onController controller:UIViewController, isForceAdd : Bool = false) -> Void
    {
        let searchBarBtnItem  = UIBarButtonItem(image: #imageLiteral(resourceName: "search"), style: .plain, target: controller, action: Selector(("showSearchBar")))
        searchBarBtnItem.tintColor = UIColor.baseBlueColor()
        
        if AppFeatures.shared.canSearchProduct
        {
            if controller.navigationItem.rightBarButtonItems != nil
            {
                controller.navigationItem.rightBarButtonItems?.append(searchBarBtnItem)
            }
            else
            {
                controller.navigationItem.rightBarButtonItems = [searchBarBtnItem]
            }
        }
    }
    
    func createCopyPantryItem(onController controller:UIViewController, isForceAdd : Bool = false)
    {
        let copyPantryBtnItem = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_icon_copy") , style: .plain, target: controller, action: Selector(("copyPantryListAction")))
        copyPantryBtnItem.tintColor = UIColor.baseBlueColor()
        if controller.navigationItem.rightBarButtonItems != nil{
            controller.navigationItem.rightBarButtonItems?.append(copyPantryBtnItem)
        }else{
            controller.navigationItem.rightBarButtonItems = [copyPantryBtnItem]
        }
    }
    
    func deleteOrderFromServer()
    {
        SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: "Delete saved order ?", withSuccessButtonTitle: "Yes", withMessage: "Are you sure you want to delete saved order. This cannot be undone.", withCancelButtonTitle: "No")
        {
            
        }
    }
    
    //MARK: Right View mode of textfield
    func setRightViewMode(textField:UITextField,imageSelected:String,amount:CGFloat){
        let rightView = UIView()
        let rightImageView = UIImageView()
        rightImageView.frame = CGRect(x:0, y:textField.frame.size.height/2 - 5, width:15, height: 10)
        if imageSelected != ""{
            rightImageView.image = UIImage(named:imageSelected)
            rightImageView.contentMode = .scaleAspectFit
        }
        rightView.addSubview(rightImageView)
        rightView.frame = CGRect(x:0, y:0, width:amount, height: textField.frame.size.height)
        textField.rightViewMode = .always
        textField.rightView = rightView
    }
    
    
    //    MARK:- Calling
    func placeCallFromController(controller : UIViewController, withPhone phoneNumber : String)
    {
        if Helper.shared.customerPhoneNumber != nil, Helper.shared.customerPhoneNumber!.count > 0
        {
            if let phoneCallURL:URL = URL(string: "tel:\(String(describing: phoneNumber.replacingOccurrences(of: " ", with: "")))")
            {
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL)) {
                    let alertController = UIAlertController(title: CommonString.app_name, message: "Are you sure you want to call \n\(String(describing: Helper.shared.customerPhoneNumber!))?", preferredStyle: .alert)
                    let yesPressed = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                        application.open(phoneCallURL, options: [:], completionHandler: nil)
                    })
                    let noPressed = UIAlertAction(title: "No", style: .default, handler: { (action) in
                        
                    })
                    alertController.addAction(yesPressed)
                    alertController.addAction(noPressed)
                    if controller is DatePickerView == false{
                        application.open(phoneCallURL, options: [:], completionHandler: nil)
                        //                    controller.navigationController?.present(alertController, animated: true, completion: nil)
                    }else{
                        application.open(phoneCallURL, options: [:], completionHandler: nil)
                    }
                }
                else
                {
                    Helper.shared.showAlertOnController(message: "You cannot make call from this device.", title: "Not supported")
                }
            }
        }
        else
        {
            Helper.shared.showAlertOnController(message: "", title: "No contact information found.")
        }
    }
    
    func processCustomerfeatureRequest(withResponse response: Any) {
        if response is Dictionary<String,Any> && (response as! Dictionary<String,Any>).keyExists(key: "customerFeatures"), let dic = (response as! Dictionary<String,Any>)["customerFeatures"] as? Dictionary<String,Any>
        {
            
            let array = (response as? NSDictionary)?.value(forKeyPath: "customerDetails") as? NSArray
            let dict = array?.object(at: 0) as? NSDictionary
            
            if let runnumber = dict?.value(forKeyPath:"RunNo") as? String{
                
                AppFeatures.shared.defaultRunNumber = runnumber
            }
            
            if let saveOrderAllowed = dic["IsPONumber"] as? Bool
            {
                AppFeatures.shared.showPOPopupWhileOrdering = saveOrderAllowed
            }
            
            if let showPDFInvoice = dic["IsInvoicePdf"] as? Bool
            {
                AppFeatures.shared.shouldShowPDFInvoice = showPDFInvoice
            }
            
            if let showNoticeboardPdf = dic["IsPDF"] as? Bool
            {
                AppFeatures.shared.showNoticeboardPdf = showNoticeboardPdf
            }
            
            if let saveOrderAllowed = dic["IsSaveOrder"] as? Bool
            {
                AppFeatures.shared.saveOrderPermitted = saveOrderAllowed
            }
            
            if let showOrderDate = dic["IsOrderDate"] as? Bool
            {
                AppFeatures.shared.showOrderDateInHistory = showOrderDate
            }
            
            
            if let dynamicUOM = dic["IsDynamicUOM"] as? Bool
            {
                AppFeatures.shared.allowDyanamicUOM = dynamicUOM
            }
            
            if let showInvoice = dic["IsInvoice"] as? Bool
            {
                AppFeatures.shared.shouldShowInvoices = showInvoice
            }
            
            if let showFrieghtCharges = dic["IsFreightChargeApplicable"] as? Bool
            {
                AppFeatures.shared.shouldShowFreightCharges = showFrieghtCharges
            }
            
            if let isShowProductLongDetail =  dic["IsShowProductLongDetail"] as? Bool
            {
                AppFeatures.shared.shouldShowLongDetail = isShowProductLongDetail
            }
            
            if let isAllowUserToAddPantry = dic["IsAllowUserToAddPantry"] as? Bool
            {
                AppFeatures.shared.isUserAllowedToAddPantryList = isAllowUserToAddPantry
            }
            
            
            if let isShowPrice = dic["IsShowPrice"] as? Bool
            {
                AppFeatures.shared.shouldShowProductPrice = isShowPrice
            }
            
            if let isUserAllowedToAddItemsToPantry = dic["IsAddItemToPantry"] as? Bool
            {
                AppFeatures.shared.isUserAllowedToAddItemsToPantryList = isUserAllowedToAddItemsToPantry
            }
            
            if let showBrand = dic["IsShowBrand"] as? Bool
            {
                AppFeatures.shared.shouldShowBrandNameInProductList = showBrand
            }
            
            if let shouldShowPantry = dic["IsPantryList"] as? Bool
            {
                AppFeatures.shared.hasAccessToDefaultPantry = shouldShowPantry
            }
            
            if let shouldHighlightStock = dic["IsHighlightStock"] as? Bool
            {
                AppFeatures.shared.shouldHighlightStock = shouldHighlightStock
            }
            if let isStripePayment = dic["IsStripePayment"] as? Bool
            {
                AppFeatures.shared.isStripePayment = isStripePayment
            }
            
            if let canSearchProduct = dic["IsSearchProduct"] as? Bool
            {
                AppFeatures.shared.canSearchProduct = canSearchProduct
            }
            
            if let canSortPantry = dic["IsPantrySorting"] as? Bool
            {
                AppFeatures.shared.canSortPantry = canSortPantry
            }
            
            if let canSortPantry = dic["IsPantrySorting"] as? Bool
            {
                AppFeatures.shared.canSortPantry = canSortPantry
            }
            
            if let canShowOrderHistory = dic["IsOrderHistory"] as? Bool
            {
                AppFeatures.shared.showOrderHistory = canShowOrderHistory
            }
            
            if let isLatestSpecials = dic["IsLatestSpecials"] as? Bool
            {
                AppFeatures.shared.canShowLatestSpecials = isLatestSpecials
            }
            if let isShowSupplier = dic["IsShowSupplier"] as? Bool
            {
                AppFeatures.shared.isShowSupplier = isShowSupplier
            }
            if let isCopyPantryEnabled = dic["IsCopyPantryEnabled"] as? Bool
            {
                AppFeatures.shared.copyPantryEnabled = isCopyPantryEnabled
            }
            
            if let addItemToDefault = dic["IsAddItemToDefaultPantry"] as? Bool
            {
                AppFeatures.shared.isUserAllowedToAddItemsToDefaultPantry = addItemToDefault
            }
            
            if let isNoticeBoard = dic["IsNoticeBoard"] as? Bool
            {
                AppFeatures.shared.isNoticeBoard = isNoticeBoard
            }
            if let isTargetMarketing = dic["IsTargetMarketing"] as? Bool
            {
                AppFeatures.shared.isTargetMarketing = isTargetMarketing
            }
            if let isNonDeliveryDayOrdering = dic["IsNonDeliveryDayOrdering"] as? Bool
            {
                AppFeatures.shared.isNonDeliveryDayOrdering = isNonDeliveryDayOrdering
            }
            if let isSpecialProductRequest = dic["IsSpecialProductRequest"] as? Bool
            {
                AppFeatures.shared.isSpecialProductRequest = isSpecialProductRequest
            }
            if let isMOQ = dic["IsMOQ"] as? Bool
            {
                AppFeatures.shared.isMinOrderQuantity = isMOQ
            }
            if let isMaxOQ = dic["IsMaxOQ"] as? Bool
            {
                AppFeatures.shared.isMaxOrderQuantity = isMaxOQ
            }
            if let isBrowsingEnabledForHoldCust = dic["IsBrowsingEnabledForHoldCust"] as? Bool
            {
                AppFeatures.shared.isBrowsingEnabledForHoldCust = isBrowsingEnabledForHoldCust
            }
            if let isCheckDelivery = dic["IsCheckDelivery"] as? Bool
            {
                AppFeatures.shared.isCheckDelivery = isCheckDelivery
            }
            
            if let showStock = dic["IsShowStock"] as? Bool
            {
                AppFeatures.shared.shouldShowStock = showStock
            }
            
            if let isDecimalAllowed = dic["IsAllowDecimal"] as? Bool{
                
                AppFeatures.shared.IsAllowDecimal = isDecimalAllowed
            }
            
        }
        
        if response is Dictionary<String,Any> && (response as! Dictionary<String,Any>).keyExists(key: "customerDetails"), let custDetailArr = (response as! Dictionary<String,Any>)["customerDetails"] as? Array<Dictionary<String,Any>>
        {
            if let termsAndConditionString = custDetailArr[0]["TermconditionMessage"] as? String
            {
                CommonString.termsAndConditionString = termsAndConditionString
            }
            if let debtorOnHold = custDetailArr[0]["DebtorOnHold"] as? Bool{
                UserInfo.shared.customerOnHoldStatus  = debtorOnHold
                UserInfo.shared.customerRepOnHoldStatus  = debtorOnHold
            }
            
            if let postCode = custDetailArr[0]["PostCode"] as? String
            {
                UserInfo.shared.postcode = postCode
            }
        }
        
        if response is Dictionary<String,Any> && (response as! Dictionary<String,Any>).keyExists(key: "ContactDetails"), let contactDetailArr = (response as! Dictionary<String,Any>)["ContactDetails"] as? Array<Dictionary<String,Any>>
        {
            UserInfo.shared.contactDetailArr = contactDetailArr
        }
        
        if response is Dictionary<String,Any> && (response as! Dictionary<String,Any>).keyExists(key: "DeliveryCharges"), let deliveryChargesArr = (response as! Dictionary<String,Any>)["DeliveryCharges"] as? Array<Dictionary<String,Any>>
        {
            if deliveryChargesArr.count>0{
                if deliveryChargesArr[0].keyExists(key: "NonDeliveryDaysMessage"),let nonDeliveryPopUpString = deliveryChargesArr[0]["NonDeliveryDaysMessage"] as? String
                {
                    CommonString.nonDeliveryPopUpString = nonDeliveryPopUpString
                }
                if deliveryChargesArr[0].keyExists(key: "FrightMessage"), let isFrieghtChargesMessage = deliveryChargesArr[0]["FrightMessage"] as? String
                {
                    CommonString.frieghtChargesMessage = isFrieghtChargesMessage
                }
                
                if deliveryChargesArr[0].keyExists(key: "DeliveryFee"), let isFrieghtChargesMessage = deliveryChargesArr[0]["DeliveryFee"] as? Double
                               {
                                self.freightcharges = isFrieghtChargesMessage
                               }
                if deliveryChargesArr[0].keyExists(key: "OrderValue"), let orderValue = deliveryChargesArr[0]["OrderValue"] as? Double
                {
                    self.orderValue = orderValue
                }
            }
            
        }
        if response is Dictionary<String,Any> && (response as! Dictionary<String,Any>).keyExists(key: "PDFDetails"), let pdfDetailsDic = (response as! Dictionary<String,Any>)["PDFDetails"] as? Dictionary<String,Any>
        {
            if pdfDetailsDic.keyExists(key: "PdfFile") , let noticeboardPDF = pdfDetailsDic["PdfFile"] as? String
            {
                CommonString.noticeboardPDF = noticeboardPDF
            }
            if pdfDetailsDic.keyExists(key: "GroupDetails"), let targetMarketingPDFArr = pdfDetailsDic["GroupDetails"] as? Array<Dictionary<String,Any>>{
                CommonString.tarketMarketingPDF = (targetMarketingPDFArr[0]["PdfFile"] as? String)!
            }
        }
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name("cartCountChanged"), object: nil)
        }
    }
    
    func calculateQuantityMultiplier(units:Double,quantityPerUnit:Int) ->Double{
        
        if quantityPerUnit == 0
        {
          //  quantityPerUnit = 1
        }
        
        var unitToBedded = units
        let units:Int = Int(ceil(unitToBedded))
        if units <= quantityPerUnit{
            unitToBedded = Double(quantityPerUnit)
        }else if units > quantityPerUnit {
            
            if units % quantityPerUnit == 0{
                unitToBedded = Double(units)
            }else {
                let value:Double = Double(Double(units) / Double(quantityPerUnit))
                unitToBedded = ceil(value) * Double(quantityPerUnit)
                debugPrint(unitToBedded)
            }
        }
        return unitToBedded
    }
    
    func getSelectedUOM(productDetail : Dictionary<String, Any>)->Dictionary<String,Any>{
        
        var arrPrices : Array<Dictionary<String,Any>>?
        if let prices = productDetail["DynamicUOM"] as? Array<Dictionary<String,Any>>
        {
            arrPrices = prices
        }
        else if var prices = productDetail["Prices"] as? Dictionary<String,Any>
        {
            if productDetail["UOMDesc"] as? String != nil {
                prices["UOMDesc"] = productDetail["UOMDesc"] as? String
            }
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
        }
        return arrPrices![selectedIndex]
    }
    
    //
    func getSelectedUomNameQuantity(product:Dictionary<String, Any>) -> (isEach:Bool,quantity:Int) {
        
        let objToFetch = Helper.shared.getSelectedUOM(productDetail:product)
        var isEachValue = false
        let uomName = objToFetch["UOMDesc"] as? String
        let arrayUomEach = ["EA","EACH"]
        
        if arrayUomEach.contains((uomName?.uppercased())!.trimmingCharacters(in: .whitespacesAndNewlines)){
            isEachValue = true
        }
        let quantityPerUnit = objToFetch["QuantityPerUnit"] as? Int ?? 0
        return (isEachValue,quantityPerUnit)
    }
    
    func callAPIToUpdateCartNumber()
    {
        let request = [
            "CartID": 0,
            "IsSavedOrder": false,
            "UserID": UserInfo.shared.userId!,
            "CustomerID": UserInfo.shared.customerID!,
            "isRepUser": UserInfo.shared.isSalesRepUser!
            ] as [String : Any]
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: request, strURL: SyncEngine.baseURL + SyncEngine.getCartCount, withIndicator: false) { (response : Any) in
            if let obj = response as? Dictionary<String,Any>, let cartCount = obj["Count"] as? NSNumber
            {
                self.cartCount = 0
                DispatchQueue.main.async {
                    self.cartCount = Int(truncating: cartCount)
                }
            }
        }
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x:0, y:0, width:width, height:CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
    func logout(){
        
        SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.logOutTitle, withSuccessButtonTitle: "Yes", withMessage: CommonString.logOutString, withCancelButtonTitle: "No") {
            self.logOutUser()
        }
    }
    func logoutAsGuest(){
        let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        UIApplication.shared.keyWindow!.rootViewController = navController
        
    }
    func logOutUser()  {
        SyncEngine.sharedInstance.accessToken = nil
        var username = ""
        var pass = ""
        
        if let emailAddress = UserDefaults.standard.value(forKey: "savedEmailAddress") as? String, let password = UserDefaults.standard.value(forKey: "savedPassword") as? String
        {
            username = emailAddress
            pass = password
        }
        
        var devicetoken = String()
        if UserDefaults.standard.value(forKey: "DeviceToken") == nil
        {
            devicetoken = ""
        }
        else
        {
            devicetoken = UserDefaults.standard.value(forKey: "DeviceToken") as! String
        }

        
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        
        UserDefaults.standard.set(devicetoken, forKey: "DeviceToken")

        
        if username != "" && pass != ""
        {
            UserDefaults.standard.set(username, forKey: "savedEmailAddress")
            UserDefaults.standard.set(pass, forKey: "savedPassword")
        }
        
        Helper.shared.lastSetDateTimestamp = nil
        Helper.shared.selectedDeliveryDate = nil
        Helper.shared.cartCount = 0
        AppFeatures.shared.isTargetMarketing = false
        AppFeatures.shared.showNoticeboardPdf = false
        UserDefaults.standard.synchronize()
        let loginWireframe = LoginWireFrame()
        loginWireframe.makeRootViewController(onWindow: UIApplication.shared.keyWindow!, isShowChild: false)
    }
    
}


class  UserInfo : NSObject
{
    static let shared = UserInfo()
    var name : String?
    var customerID : String?
    var userId : String?
    var salesRepCustID: String?
    var isSalesRepUser : Bool?
    var contactDetailArr : Array<Dictionary<String,Any>>?
    var customerOnHoldStatus :  Bool = false
    var isGuest : Bool = false
    var customerRepOnHoldStatus :  Bool = false
    var isParent : Bool = false
    var parentId : String?
    var orderCutOffTime:String = ""
    var order_Description:String = ""
    var isDelivery:Bool = false
    var navigationTitle: String = ""
    var postcode: String = "0"
    var pickupAddress: NSNumber = 0
    var justAdded:NSNumber = 0
    var deliveryAddress: NSNumber = 0
    var Frequency : String?
    var isSuspended : Bool?
    var deliveryAddressString : String?
    var pickupAddressString : String?
    
}
class  RegisterInfo : NSObject
{
    static let shared = RegisterInfo()
    var user_type : String?
    var email : String?
    var password : String?
    var first_name : String?
    var last_name: String?
    var mobile_number: String?
    var country: String?
    var city: String?
}




