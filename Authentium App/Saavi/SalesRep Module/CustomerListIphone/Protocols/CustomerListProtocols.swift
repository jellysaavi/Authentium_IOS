    //
    //  CustomerListProtocols.swift
    //  Saavi
    //
    //  Created by Sukhpreet on 19/06/17.
    //  Copyright © 2017 Saavi. All rights reserved.
    //
    
    import Foundation
    import UIKit
    
    // VIEW
    protocol CustomerListViewProtocol
    {

    }
    
    // PRESENTER
    protocol CustomerListViewPresenterProtocol
    {
        func viewDidLoad() -> Void
        
        func getCustomerFeatures(customerID:String)
        func handleNavigationAsPerResponse()
    }
    
    
    
    protocol CustomerListViewInteractorInputProtocol
    {
        
        func getCustomerFeatures(customerID:String)
    }
    
    protocol CustomerListViewInteractorOutputProtocol {
        
        func handleResponseFromMainFeatureApi(response : Any)
        func processCustomerfeatureRequest(withResponse response :Any)
        
    }
    
    protocol CustomerListViewWireframeProtocol
    {
        func createCustomerListView() -> UINavigationController
        func makeRootViewController( onWindow window : UIWindow)
        func showCustomerHomeScreen() -> Void
        
    }

    protocol CustomerListDataManagerProtocol
    {
        func getCustomerFeatures(customerID:String)
    }
    
    
    
    
