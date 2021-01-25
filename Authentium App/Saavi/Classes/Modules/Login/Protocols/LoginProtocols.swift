    //
    //  LoginProtocols.swift
    //  Saavi
    //
    //  Created by Sukhpreet on 19/06/17.
    //  Copyright © 2017 Saavi. All rights reserved.
    //
    
    import Foundation
    import UIKit
    
    // VIEW
    protocol LoginViewProtocol
    {

    }
    
    // PRESENTER
    protocol LoginViewPresenterProtocol
    {
        func viewDidLoad() -> Void
        func handleForgotPasswordAction( text : String)
        func processLoginRequest(username : String, password : String, clientToken : String)
        func showIntroPopupRequest(response: Any)
        func showSalesRepDashboard()
        func showTermsAndConditionsWindow()
        func showLiquorPopup()
        func getMainFeaturesOfApplication()
        func handleNavigationAsPerResponse()
        func requestIntroPopupDetails()
        func showChildList()
    }
    
    protocol LoginViewInteractorInputProtocol
    {
        func processLoginRequestwith(username name:String, withPassword password:String, withClientToken clientToken:String)
        func getMainFeaturesOfApplication()
        func getCustomerFeatures()
        func getIntroPopupDetails()
    }
    
    protocol LoginViewInteractorOutputProtocol {
        func handleResponseFromAPI(response : Any)
        func handleResponseFromMainFeatureApi(response : Any)
        func processCustomerfeatureRequest(withResponse response :Any)
        func processIntroPopupDetails(withResponse response : Any)
    }
    
    protocol LoginViewWireframeProtocol
    {
        func createLoginView(isShowChild:Bool) -> UINavigationController
        func makeRootViewController( onWindow window : UIWindow,isShowChild:Bool)
        func showIntroPopupRequest(response: Any)
        func showSalesRepDashboard() -> Void
        func showTermsAndConditionsWindow()
        func showLiquorPopup()
        func showIntroPopupFromWireframe()
        func showChildList()
    }

    protocol LoginDataManagerProtocol
    {
        func postLoginRequest(withUsername username : String , withPassword password : String, withClientToken clientToken : String)
        func getMainFeaturesOfApplication()
        func getCustomerFeatures()
        func getIntroPopupDetails()
    }
    
    
    
    
