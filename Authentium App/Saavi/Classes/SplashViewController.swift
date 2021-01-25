//
//  SplashViewController.swift
//  Saavi
//
//  Created by goMad Infotech on 11/12/18.
//  Copyright © 2018 Saavi. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    //MARK: - - Outlets
    
    //MARK: - - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigateNext()

        //self.getMainFeatures()
    }
    
    //MARK: - - Get Main Features API
    fileprivate func getMainFeatures(){
        
        let URLstring = SyncEngine.baseURL+SyncEngine.getMainFeaturesOfApplication
        SyncEngine.sharedInstance.sendGetRequestToServer(strURL: URLstring) { (response : Any) in
            self.handleResponseFromMainFeatureApi(response: response)
        }
    }
    
    //MARK: - - Navigate to Home
    fileprivate func navigateNext(){
        
        DispatchQueue.main.async {
            
            let app = UIApplication.shared.delegate as? AppDelegate
            let window = app?.window
//            if AppFeatures.shared.shouldShowWalkthrough == true, let walkthrough = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Walkthrough.storyboardID) as? Walkthrough
            if let walkthrough = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Walkthrough.storyboardID) as? Walkthrough
            {
                
                let obj = UINavigationController(rootViewController: walkthrough)
                obj.isNavigationBarHidden = true
//                let splash = SplashScreen()
//                splash.parentView = walkthrough.view
//                splash.createSplashScreen()
                window?.rootViewController = obj
            }
//            else{
//
//                let loginWireframe = LoginWireFrame()
//                loginWireframe.makeRootViewController(onWindow: window!, isShowChild: false)
//                if AppFeatures.shared.shouldShowWalkthrough == false
//                {
////                    let splash =  SplashScreen()
////                    splash.parentView = ((window?.rootViewController as? UINavigationController)?.viewControllers.last as? ViewController)?.view
////                    splash.createSplashScreen()
//                }
//            }
            window?.makeKeyAndVisible()
        }
    }
    
    //MARK: - - Handle response of Main Features API.
    func handleResponseFromMainFeatureApi(response: Any) {
        
        if let responseDic = response as? Dictionary<String,Any>{
            
            AppFeatures.shared.isFavoriteList = ((responseDic["FavoriteList"] as? Bool) != nil && (responseDic["FavoriteList"] as! Bool) == true) ? true : false
            AppFeatures.shared.isShareButtons = ((responseDic["ShareButtons"] as? Bool) != nil && (responseDic["ShareButtons"] as! Bool) == true) ? true : false
            AppFeatures.shared.isShowAccount = ((responseDic["ShowAccount"] as? Bool) != nil && (responseDic["ShowAccount"] as! Bool) == true) ? true : false
            
            AppFeatures.shared.isOrderMultiples = ((responseDic["OrderMultiples"] as? Bool) != nil && (responseDic["OrderMultiples"] as! Bool) == true) ? true : false
            
            AppFeatures.shared.isShowPackSize = ((responseDic["ShowPackSize"] as? Bool) != nil && (responseDic["ShowPackSize"] as! Bool) == true) ? true : false
            
            AppFeatures.shared.isShowCategory = ((responseDic["ShowCategory"] as? Bool) != nil && (responseDic["ShowCategory"] as! Bool) == true) ? true : false
            
            AppFeatures.shared.isAllowOnHoldPlacingOrder = ((responseDic["AllowOnHoldPostingOrder"] as? Bool) != nil && (responseDic["AllowOnHoldPostingOrder"] as! Bool) == true) ? true : false
            
            AppFeatures.shared.isShowBarcode = ((responseDic["EnableBarcodeScanning"] as? Bool) != nil && (responseDic["EnableBarcodeScanning"] as! Bool) == true) ? true : false
            AppFeatures.shared.isShowOrderMargin = ((responseDic["ShowSalesRepMargins"] as? Bool) != nil && (responseDic["ShowSalesRepMargins"] as! Bool) == true) ? true : false
            AppFeatures.shared.isSlaesRepLocationEnabled = ((responseDic["CaptureSalesRepLocation"] as? Bool) != nil && (responseDic["CaptureSalesRepLocation"] as! Bool) == true) ? true : false
            
            AppFeatures.shared.isBackOrder = ((responseDic["IsHandleBackOrders"] as? Bool) != nil && (responseDic["IsHandleBackOrders"] as! Bool) == true) ? true : false
            AppFeatures.shared.IsEnableRepToAddSpecialPrice = ((responseDic["IsEnableRepToAddSpecialPrice"] as? Bool) != nil && (responseDic["IsEnableRepToAddSpecialPrice"] as! Bool) == true) ? true : false
            AppFeatures.shared.IsDatePickerEnabled = ((responseDic["IsDatePickerEnabled"] as? Bool) != nil && (responseDic["IsDatePickerEnabled"] as! Bool) == true) ? true : false
            AppFeatures.shared.IsShowQuantityPopup = ((responseDic["IsShowQuantityPopup"] as? Bool) != nil && (responseDic["IsShowQuantityPopup"] as! Bool) == true) ? true : false
            
            AppFeatures.shared.IsSuggestiveSell = ((responseDic["IsSuggestiveSell"] as? Bool) != nil && (responseDic["IsSuggestiveSell"] as! Bool) == true) ? true : false

            AppFeatures.shared.Currency = (responseDic["Currency"] as? String ?? "$")
            AppFeatures.shared.IsShowSubCategory = ((responseDic["IsShowSubCategory"] as? Bool) != nil && (responseDic["IsShowSubCategory"] as! Bool) == true) ? true : false
            AppFeatures.shared.shouldShowWalkthrough = ((responseDic["ShowWalkthrough"] as? Bool) != nil && (responseDic["ShowWalkthrough"] as! Bool) == true) ? true : false
            AppFeatures.shared.isNonFoodVersion = ((responseDic["IsNonFoodVersion"] as? Bool) != nil && (responseDic["IsNonFoodVersion"] as! Bool) == true) ? true : false
            AppFeatures.shared.isAdvancedPantry = ((responseDic["IsAdvancedPantry"] as? Bool) != nil && (responseDic["IsAdvancedPantry"] as! Bool) == true) ? true : false
            AppFeatures.shared.isAddSpecialPriceFromPantry = ((responseDic["IsAddSpecialPriceFromPantry"] as? Bool) != nil && (responseDic["IsAddSpecialPriceFromPantry"] as! Bool) == true) ? true : false
            AppFeatures.shared.isRepProductBrowsing = ((responseDic["IsRepProductBrowsing"] as? Bool) != nil && (responseDic["IsRepProductBrowsing"] as! Bool) == true) ? true : false
            AppFeatures.shared.isHighlightRewardItem = ((responseDic["IsHighlightRewardItem"] as? Bool) != nil && (responseDic["IsHighlightRewardItem"] as! Bool) == true) ? true : false
            AppFeatures.shared.isShowOrderStatus = ((responseDic["IsShowOrderStatus"] as? Bool) != nil && (responseDic["IsShowOrderStatus"] as! Bool) == true) ? true : false
            AppFeatures.shared.isShowTermConditionsPopup = ((responseDic["IsShowTermConditionsPopup"] as? Bool) != nil && (responseDic["IsShowTermConditionsPopup"] as! Bool) == true) ? true : false
            AppFeatures.shared.isShowProductClasses = ((responseDic["IsShowProductClasses"] as? Bool) != nil && (responseDic["IsShowProductClasses"] as! Bool) == true) ? true : false
            AppFeatures.shared.isShowOnlyStockItems = ((responseDic["IsShowOnlyStockItems"] as? Bool) != nil && (responseDic["IsShowOnlyStockItems"] as! Bool) == true) ? true : false
            AppFeatures.shared.isMultipleAddresses = ((responseDic["IsMultipleAddresses"] as? Bool) != nil && (responseDic["IsMultipleAddresses"] as! Bool) == true) ? true : false
            AppFeatures.shared.isShowContactDetails = ((responseDic["IsShowContactDetails"] as? Bool) != nil && (responseDic["IsShowContactDetails"] as! Bool) == true) ? true : false
            AppFeatures.shared.isLiquorControlPopup = ((responseDic["IsLiquorControlPopup"] as? Bool) != nil && (responseDic["IsLiquorControlPopup"] as! Bool) == true) ? true : false
            AppFeatures.shared.isItemEnquiryPopup = ((responseDic["IsItemEnquiryPopup"] as? Bool) != nil && (responseDic["IsItemEnquiryPopup"] as! Bool) == true) ? true : false
            AppFeatures.shared.isShowProductCost = ((responseDic["IsShowProductCost"] as? Bool) != nil && (responseDic["IsShowProductCost"] as! Bool) == true) ? true : false
            AppFeatures.shared.isShowProductHistory = ((responseDic["IsShowProductHistory"] as? Bool) != nil && (responseDic["IsShowProductHistory"] as! Bool) == true) ? true : false
            AppFeatures.shared.isPDFSpecialProducts = ((responseDic["IsPDFSpecialProducts"] as? Bool) != nil && (responseDic["IsPDFSpecialProducts"] as! Bool) == true) ? true : false
            AppFeatures.shared.shoudlShowProductImages = ((responseDic["IsPictureViewEnabled"] as? Bool) != nil && (responseDic["IsPictureViewEnabled"] as! Bool) == true) ? true : false
            AppFeatures.shared.isShowFutureDate = ((responseDic["IsShowFutureDate"] as? Bool) != nil && (responseDic["IsShowFutureDate"] as! Bool) == true) ? true : false
            AppFeatures.shared.isShowNotifications = ((responseDic["IsNotifications"] as? Bool) != nil && (responseDic["IsNotifications"] as! Bool) == true) ? true : false
            AppFeatures.shared.isShowStandingOrder = ((responseDic["IsStandingOrder"] as? Bool) != nil && (responseDic["IsStandingOrder"] as! Bool) == true) ? true : false
           
            AppFeatures.shared.shoudlSmallShowProductImages = ((responseDic["IsThumbnail"] as? Bool) != nil && (responseDic["IsThumbnail"] as! Bool) == true) ? true : false
            
            AppFeatures.shared.isParent = ((responseDic["IsParentChild"] as? Bool) != nil && (responseDic["IsParentChild"] as! Bool) == true) ? true : false 
            self.navigateNext()
            
        }
    }
}
