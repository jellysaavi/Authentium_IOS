//
//  LoginViewPresenter.swift
//  Saavi
//
//  Created by Sukhpreet on 19/06/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import Foundation

class LoginViewPresenter : NSObject ,  LoginViewPresenterProtocol
{
    var Interactor : LoginViewInteractorInputProtocol?
    var view : LoginViewProtocol?
    var wireframe : LoginViewWireframeProtocol?
    
    func showIntroPopupRequest(response: Any) {
        wireframe?.showIntroPopupRequest(response: response)
    }
    
    func viewDidLoad()
    {
        //self.Interactor?.getMainFeaturesOfApplication()
    }
    
    func viewDidAppear(_animated: Bool) {
        
    }
    
    func handleForgotPasswordAction(text: String) {        
    }
    
    func processLoginRequest(username : String, password : String, clientToken : String)
    {
        Interactor?.processLoginRequestwith(username: username, withPassword: password, withClientToken: clientToken)
    }
    
    func showLiquorPopup()
    {
        wireframe?.showLiquorPopup()
    }
    
    func showTermsAndConditionsWindow()
    {
        wireframe?.showTermsAndConditionsWindow()
    }
    
    func showSalesRepDashboard()
    {
        wireframe?.showSalesRepDashboard()
    }
    
    func requestIntroPopupDetails()
    {
        self.Interactor?.getIntroPopupDetails()
    }
    
    func showChildList()
    {
        self.wireframe?.showChildList()
    }
    
    
    func getMainFeaturesOfApplication()
    {
        
    }

    func handleNavigationAsPerResponse()
    {
        Helper.shared.callAPIToUpdateCartNumber()
        
        if UserInfo.shared.isSalesRepUser == true
        {
            self.requestIntroPopupDetails()
            self.wireframe?.showSalesRepDashboard()
        }
        else
        {
            if UserInfo.shared.customerOnHoldStatus == true && !AppFeatures.shared.isAllowOnHoldPlacingOrder{
                
                if AppFeatures.shared.isBrowsingEnabledForHoldCust == false{
                    DispatchQueue.main.async {
                    
                    
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: "Your account is on hold. You can not browse on this application.", withCancelButtonTitle: "OK", completion: { })
                    }
                }
                else{
                    
                    if AppFeatures.shared.isShowTermConditionsPopup
                    {
                        self.showTermsAndConditionsWindow()
                    }
                    else if AppFeatures.shared.isLiquorControlPopup
                    {
                        self.showLiquorPopup()
                        
                    }else if AppFeatures.shared.isParent && UserInfo.shared.isParent{
                        
                        self.showChildList()
                    }else{
                        
                        self.requestIntroPopupDetails()
                    }
                }
            }
            else{
                
                if AppFeatures.shared.isShowTermConditionsPopup
                {
                    self.showTermsAndConditionsWindow()
                }
                else if AppFeatures.shared.isLiquorControlPopup
                {
                    self.showLiquorPopup()
                    
                }else if AppFeatures.shared.isParent && UserInfo.shared.isParent{
                    
                    self.showChildList()
                    
                }else{
                    self.requestIntroPopupDetails()
                }
            }
        }
    }
}
