//
//  ForgotPasswordProtocol.swift
//  Saavi
//
//  Created by Sukhpreet on 05/07/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import Foundation

protocol ForgotPasswordViewProtocol
{
    func showErrorAlert()
    func handleRequestProcessed()
}

protocol ForgotPasswordPresenterProtocol
{
    func processForgotPasswordRequest(email : String)
    
    func requestProcessed()
    
    func backAction()
}

protocol ForgotPasswordInteractorProtocol
{
    func processForgotPasswordRequest(email : String)
}

protocol ForgotPasswordWireframeProtocol
{
    func createForgotPasswordModule() -> ForgotPassword
    func hideForgotController()
}
