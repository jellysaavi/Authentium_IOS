//
//  CustomerListWireframe.swift
//  Saavi
//
//  Created by Sukhpreet on 19/06/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import Foundation
import UIKit

class CustomerListWireFrame: CustomerListViewWireframeProtocol
{
    var presenter : CustomerListViewPresenterProtocol?
    var customerListView : CustomerListIphoneViewController?
    
    func createCustomerListView() -> UINavigationController
    {
        let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomerListNav") as! CustomNavigationController
        
        if let view = navController.viewControllers[0] as? CustomerListIphoneViewController
        {
            customerListView = view
            let interactor = CustomerListInteractor()
            let presenter  = CustomerListViewPresenter()
            let dataManager  = CustomerListDataManager()
            
            view.presenter = presenter
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
    
    func makeRootViewController( onWindow window : UIWindow)
    {
        let vc  = self.createCustomerListView()
        window.rootViewController = vc
     
    }
    
    func showCustomerHomeScreen() -> Void
    {
        DispatchQueue.main.async {
            
            if let testVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "menuHierarchyHandlerStoryID") as? MenuHierarchyHandler
            {
                let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomerListNav") as! CustomNavigationController
                navController.pushViewController(testVC, animated: false)
            }
        }
        
    }
}

