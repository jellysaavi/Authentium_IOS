//
//  ForgotPasswordPresenter.swift
//  Saavi
//
//  Created by Sukhpreet on 05/07/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class ForgotPasswordPresenter: NSObject, ForgotPasswordPresenterProtocol
{
    var interactor : ForgotPasswordInteractorProtocol?
    var view : ForgotPasswordViewProtocol?
    var wireframe : ForgotPasswordWireframe?
    
    func processForgotPasswordRequest(email : String)
    {
        interactor?.processForgotPasswordRequest(email : email)
    }
    
    func requestProcessed() {
        view?.handleRequestProcessed()
    }
    
    func backAction() {
        wireframe?.hideForgotController()
    }
}
