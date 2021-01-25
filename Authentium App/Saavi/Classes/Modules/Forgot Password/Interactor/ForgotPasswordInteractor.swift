//
//  ForgotPasswordInteractor.swift
//  Saavi
//
//  Created by Sukhpreet on 05/07/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class ForgotPasswordInteractor: NSObject, ForgotPasswordInteractorProtocol {
    
    var presenter : ForgotPasswordPresenter?
    
    func processForgotPasswordRequest(email : String)
    {
        let request = ["email":email]
        let serviceURL = SyncEngine.baseURL + SyncEngine.ForgotPassword
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: request, strURL: serviceURL) { (response : Any) in
        
                self.presenter?.requestProcessed()

    }
}
}
