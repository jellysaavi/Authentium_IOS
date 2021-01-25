//
//  LoginDataManager.swift
//  Saavi
//
//  Created by Sukhpreet on 19/07/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class LoginDataManager: NSObject, LoginDataManagerProtocol {
    
    var interactor : LoginViewInteractorOutputProtocol?
    
    func postLoginRequest(withUsername username: String, withPassword password: String, withClientToken clientToken: String) {
        
        var devicetoken = String()
        if UserDefaults.standard.value(forKey: "DeviceToken") == nil
        {
            devicetoken = ""
        }
        else
        {
            devicetoken = UserDefaults.standard.value(forKey: "DeviceToken") as! String
        }

        SyncEngine.sharedInstance.authenticateUserWith(email: username, password: password, client_id: clientToken, completion: { (response : Any) in
            
            if (response as? Dictionary<String,AnyObject>) != nil
            {
                if username != "guest" {
                UserDefaults.standard.set(false, forKey: "sessionExpire")
                UserDefaults.standard.set(username, forKey: "savedEmailAddress")
                UserDefaults.standard.set(password, forKey: "savedPassword")
                UserDefaults.standard.set(true, forKey: "autoLogin")
                UserDefaults.standard.synchronize()
                }
                

                
              //  self.interactor?.handleResponseFromAPI(response: response)
            }
        })
    }
    
    func getMainFeaturesOfApplication() {
        let URLstring = SyncEngine.baseURL+SyncEngine.getMainFeaturesOfApplication
        SyncEngine.sharedInstance.sendGetRequestToServer(strURL: URLstring) { (response : Any) in
            self.interactor?.handleResponseFromMainFeatureApi(response: response)
        }
    }
    
    func getCustomerFeatures()
    {
        let serviceURL = SyncEngine.baseURL + SyncEngine.getCustomerFeatures
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: ["userID" : UserInfo.shared.userId!,"CustomerID" : UserInfo.shared.customerID!,"IsRepUser" : UserInfo.shared.isSalesRepUser!], strURL: serviceURL, completion: {(response : Any) in
            self.interactor?.processCustomerfeatureRequest(withResponse: response)
        })
    }
    
    func getIntroPopupDetails() {
        let serviceURL = SyncEngine.baseURL + SyncEngine.GetIntroPopupDetails
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: ["customerID" : UserInfo.shared.customerID!], strURL: serviceURL, completion: { (response : Any) in
            if (response as? Dictionary<String,AnyObject> != nil) && (response as! Dictionary<String,AnyObject>).keyExists(key: "intro")
            {
                self.interactor?.processIntroPopupDetails(withResponse: response)
            }
        })
    }
}


