//
//  CustomerListDataManager.swift
//  Saavi
//
//  Created by Sukhpreet on 19/07/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class CustomerListDataManager: NSObject, CustomerListDataManagerProtocol {
    
    var interactor : CustomerListViewInteractorOutputProtocol?
    
    func getMainFeaturesOfApplication() {
        let URLstring = SyncEngine.baseURL+SyncEngine.getMainFeaturesOfApplication
        SyncEngine.sharedInstance.sendGetRequestToServer(strURL: URLstring) { (response : Any) in
            self.interactor?.handleResponseFromMainFeatureApi(response: response)
        }
    }
    
    func getCustomerFeatures(customerID:String)
    {
        let serviceURL = SyncEngine.baseURL + SyncEngine.getCustomerFeatures
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: ["userID" : UserInfo.shared.userId!,"CustomerID" : customerID,"IsRepUser" : UserInfo.shared.isSalesRepUser!], strURL: serviceURL, completion: {(response : Any) in
            self.interactor?.processCustomerfeatureRequest(withResponse: response)
        })
    }
    
}


