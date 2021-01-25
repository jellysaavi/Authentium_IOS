//
//  LoginWireframe.swift
//  Saavi
//
//  Created by Sukhpreet on 19/06/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import Foundation
import UIKit

class LoginWireFrame: LoginViewWireframeProtocol
{
    
    var presenter : LoginViewPresenterProtocol?
    var loginView : ViewController?
    
    func showTermsAndConditionsWindow(){
        
        if let termsAndConditonsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: TermAndConditionPopUpVC.termsAndConsitionsStoryboardID) as? TermAndConditionPopUpVC
        {
            termsAndConditonsController.wireframe = self
            if AppFeatures.shared.isShowTermConditionsPopup == true
            {
                termsAndConditonsController.istermsAnCondition = true
            }
            else
            {
                termsAndConditonsController.isLiquor = true
            }
            DispatchQueue.main.async {
                self.loginView?.navigationController?.present(termsAndConditonsController, animated: true, completion: nil)
            }
        }
    }
    
    func showChildList(){
        
        if let childListViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ChildListViewController.childListStoryboard) as? ChildListViewController
        {
            childListViewController.wireframe = self
            DispatchQueue.main.async {
                self.loginView?.navigationController?.pushViewController(childListViewController, animated: false)
               // self.loginView?.navigationController?.present(childListViewController, animated: true, completion: nil)
            }
        }
    }
    
    func showIntroPopupFromWireframe() {
        self.presenter?.requestIntroPopupDetails()
    }
    
    func showLiquorPopup()
    {
        self.showTermsAndConditionsWindow()
    }
    
    
    func createLoginView(isShowChild:Bool) -> UINavigationController
    {
        let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tutorialNavController") as! CustomNavigationController
        
        if let view = navController.viewControllers[0] as? ViewController
        {
            loginView = view
            let interactor = LoginInteractor()
            let presenter  = LoginViewPresenter()
            let dataManager  = LoginDataManager()
            
            view.presenter = presenter
            view.isShowChild = isShowChild
            presenter.Interactor = interactor
            presenter.view = view
            presenter.wireframe = self
            
            dataManager.interactor = interactor
            interactor.dataManager = dataManager
            
            interactor.presenter = presenter
            self.presenter = presenter
            
            return navController
        }
        return navController
    }
    
    
    func createSignUp(isShowChild:Bool) -> SignupViewController
    {
        let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        
       
        return navController
    }
    func makeRootViewController( onWindow window : UIWindow,isShowChild:Bool)
    {
        let vc  = self.createLoginView(isShowChild: isShowChild)
        window.rootViewController = vc
        
        if isShowChild{
            
            self.showChildList()
        }
    }
    
    func makeRootViewController1( onWindow window : UIWindow,isShowChild:Bool)
    {
        let vc  = self.createSignUp(isShowChild: isShowChild)
        window.rootViewController = vc
        
        
    }
    
    func showIntroPopupRequest(response: Any){
        
        if UserInfo.shared.isSalesRepUser == false{
            
            Helper.shared.nextOrderDates = ((response as! Dictionary<String,AnyObject>)["orderDates"] as! Array<String>)
            
            if ((response as! Dictionary<String,AnyObject>)["permittedDays"] as? Array<String>) != nil && ((response as! Dictionary<String,AnyObject>)["permittedDays"] as! Array<String>).count > 0
            {
                Helper.shared.allowedWeekdaysForDelivery = ((response as! Dictionary<String,AnyObject>)["permittedDays"] as! Array<String>)
            }
            else
            {
                Helper.shared.allowedWeekdaysForDelivery = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
            }
            
            if let allowedSundays = (response as? Dictionary<String, AnyObject>)?["sundayOrdering"] as? Bool, allowedSundays == true
            {
                AppFeatures.shared.isSundayOrderingEnabled = allowedSundays
                if Helper.shared.allowedWeekdaysForDelivery?.contains("sunday") == false
                {
                    Helper.shared.allowedWeekdaysForDelivery?.append("sunday")
                }
            }
            else
            {
                AppFeatures.shared.isSundayOrderingEnabled = false
            }
            
            if let SlotsByDate = (response as? Dictionary<String, AnyObject>)?["SlotsByDate"] as? Bool, SlotsByDate == true
            {
                
                    AppFeatures.shared.slotsByDate = true
                   Helper.shared.slots = ((response as! Dictionary<String,AnyObject>)["Slots"] as! Array<Dictionary<String,AnyObject>>)
                
            }else{
                AppFeatures.shared.slotsByDate = false
            }
            
            
            if let phoneNumber = (response as? Dictionary<String,Any>)?["customerPhone"] as? String
            {
                Helper.shared.customerPhoneNumber = phoneNumber
            }
            
             self.loginView?.continueAction()
        }
        
        let cutOffTime = ((response as! Dictionary<String,AnyObject>)["intro"] as? Dictionary<String,AnyObject>)?["OrderCutOff"] as? String
        UserInfo.shared.orderCutOffTime = cutOffTime ?? ""
        
        let Description = ((response as! Dictionary<String,AnyObject>)["intro"] as? Dictionary<String,AnyObject>)?["Description"] as? String
        UserInfo.shared.order_Description = Description ?? ""

    }
    
    func showDeliveryTypePopup(response: Any){
        
        DispatchQueue.main.async {
            
             if let receiveOrderPopup = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReceiveOrderPopupVC") as? ReceiveOrderPopupVC
            {
                receiveOrderPopup.backButtonTitle = "SKIP"
                receiveOrderPopup.modalPresentationStyle = .overCurrentContext
                self.loginView?.present(receiveOrderPopup, animated: false, completion: nil)
                receiveOrderPopup.completionBlock = { (buttonPressed, deliveyType) -> Void in
                    
                    if buttonPressed == .moveNext {
                      
                         UserInfo.shared.isDelivery = deliveyType == DeliveryType.pickUp ? false : true
                    }
                    self.showDatePickerPopup(response: response)
                }
            }
            
        }
    }
    
    
    func showDatePickerPopup(response: Any){
        
        if let orderDatePicker = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "datePickerStoryID") as? DatePickerView
        {
            orderDatePicker.modalPresentationStyle = .overCurrentContext
            orderDatePicker.redirectedFrom = .login
            self.loginView?.present(orderDatePicker, animated: false, completion: nil)
            orderDatePicker.completionBlock = { (buttonPressed) -> Void in
                self.loginView?.continueAction()
            }
        }
    }
    
    func showSalesRepDashboard()
    {
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            if AppFeatures.shared.isRepProductBrowsing == false || AppFeatures.shared.isAdvancedPantry == false
            {
                if let customerViewController = UIStoryboard(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "CustomerListVC") as? CustomerListVC
                {
                    DispatchQueue.main.async
                        {
                            let customerNavController = UINavigationController(rootViewController: customerViewController)
                            UIApplication.shared.keyWindow?.rootViewController = customerNavController
                            if UserInfo.shared.isSalesRepUser!{
                                UserLocationManager.shared.getCurrentLocation()
                            }
                    }
                }
            }else{
                
                if let salesRepController = UIStoryboard(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "salesRepChooseCustomerStoryboardID") as? UINavigationController
                {
                    DispatchQueue.main.async
                        {
                        UIApplication.shared.keyWindow?.rootViewController = salesRepController
                        if UserInfo.shared.isSalesRepUser!{
                            UserLocationManager.shared.getCurrentLocation()
                        }
                    }
                }
            }
            
        }else{
            
            DispatchQueue.main.async {
                
                let customerListWireframe = CustomerListWireFrame()
                customerListWireframe.makeRootViewController(onWindow: UIApplication.shared.keyWindow!)
                if UserInfo.shared.isSalesRepUser!{
                    UserLocationManager.shared.getCurrentLocation()
                }
                
            }

        }
    }
    
}
