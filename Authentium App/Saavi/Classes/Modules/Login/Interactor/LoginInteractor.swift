//
//  File.swift
//  Saavi
//
//  Created by Sukhpreet on 28/06/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import Foundation

class LoginInteractor: NSObject, LoginViewInteractorInputProtocol
{
    var presenter : LoginViewPresenterProtocol?
    var dataManager : LoginDataManagerProtocol?
    
    func processLoginRequestwith(username name: String, withPassword password: String, withClientToken clientToken: String)
    {
        dataManager?.postLoginRequest(withUsername: name, withPassword: password, withClientToken: clientToken)
    }
    
    func getMainFeaturesOfApplication() {
        self.dataManager?.getMainFeaturesOfApplication()
    }
    
    func getCustomerFeatures() {
        self.dataManager?.getCustomerFeatures()
    }
    
    func processCustomerfeatureRequest(withResponse response: Any) {
        Helper.shared.processCustomerfeatureRequest(withResponse: response)
        self.presenter?.handleNavigationAsPerResponse()
    }
    
    func getIntroPopupDetails()
    {
        self.dataManager?.getIntroPopupDetails()
    }
    
}

extension LoginInteractor : LoginViewInteractorOutputProtocol
{
    func handleResponseFromAPI(response : Any)
    {
//        SyncEngine.sharedInstance.accessToken = (response as! Dictionary<String,AnyObject>)["access_token"] as? String
//
//        if ((response as! Dictionary<String,AnyObject>)["isParent"] as? String) != nil{
//
//            UserInfo.shared.isParent = ((response as! Dictionary<String,AnyObject>)["isParent"] as? String) == "True" ? true:false
//        }
//
//        if ((response as! Dictionary<String,AnyObject>)["userID"] as? String) != nil{
//
//            UserInfo.shared.userId = ((response as! Dictionary<String,AnyObject>)["userID"] as? String)
//        }
//
//        if ((response as! Dictionary<String,AnyObject>)["customerID"] as? String) != nil{
//
//            UserInfo.shared.customerID = ((response as! Dictionary<String,AnyObject>)["customerID"] as? String)
//            UserInfo.shared.salesRepCustID = UserInfo.shared.customerID
//            UserInfo.shared.parentId = UserInfo.shared.customerID
//        }
//
//        if ((response as! Dictionary<String,AnyObject>)["Name"] as? String) != nil
//        {
//            UserInfo.shared.name = ((response as! Dictionary<String,AnyObject>)["Name"] as? String)
//        }
//
//
//        if let role = (response as? Dictionary<String,Any>)?["role"] as? String, role.lowercased() == "salesrep"
//        {
//            UserInfo.shared.isSalesRepUser = true
//            UserDefaults.standard.set(true, forKey: "isSalesrep")
//        }
//        else
//        {
//            UserInfo.shared.isSalesRepUser = false
//            UserDefaults.standard.set(false, forKey: "isSalesrep")
//        }
//        self.getCustomerFeatures()
//        UserDefaults.standard.synchronize()

    }
    
    func handleResponseFromMainFeatureApi(response: Any) {
        if let responseDic = response as? Dictionary<String,Any>
        {
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
    
        }
    }
    
    func processIntroPopupDetails(withResponse response: Any) {
        presenter?.showIntroPopupRequest(response: response)
    }
}
