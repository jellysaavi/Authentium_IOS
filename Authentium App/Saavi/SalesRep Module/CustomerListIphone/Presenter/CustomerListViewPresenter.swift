//
//  CustomerListViewPresenter.swift
//  Saavi
//
//  Created by Sukhpreet on 19/06/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import Foundation

class CustomerListViewPresenter : NSObject ,  CustomerListViewPresenterProtocol
{
    var Interactor : CustomerListViewInteractorInputProtocol?
    var view : CustomerListViewProtocol?
    var wireframe : CustomerListViewWireframeProtocol?
    
    
    func getCustomerFeatures(customerID:String) {
        self.Interactor?.getCustomerFeatures(customerID:customerID)
    }
    
    func viewDidLoad()
    {
        
    }
    
    func viewDidAppear(_animated: Bool) {
        
    }

    func handleNavigationAsPerResponse()
    {
        self.wireframe?.showCustomerHomeScreen()
    }
}
