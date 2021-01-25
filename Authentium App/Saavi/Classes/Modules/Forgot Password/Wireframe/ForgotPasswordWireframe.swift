//
//  ForgotPasswordWireframe.swift
//  Saavi
//
//  Created by Sukhpreet on 05/07/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class ForgotPasswordWireframe: ForgotPasswordWireframeProtocol
{
    var presentedViewController : UIViewController?
    
    func createForgotPasswordModule() -> ForgotPassword {
        
        let interactor = ForgotPasswordInteractor()
        let presenter = ForgotPasswordPresenter()
        
        let forgotPasswordVC = Configration.mainStoryboard().instantiateViewController(withIdentifier: "ForgotPasswordVCStoryId") as! ForgotPassword
        forgotPasswordVC.presenter = presenter
        presenter.interactor = interactor
        interactor.presenter = presenter
        presenter.view = forgotPasswordVC
        presenter.wireframe = self
        presentedViewController = forgotPasswordVC
        return forgotPasswordVC
    }
    
    func pushForgotFromVC(baseController : UIViewController)
    {
        let forgotVC = self.createForgotPasswordModule()
        baseController.navigationController?.pushViewController(forgotVC, animated: false)
    }
    
    func hideForgotController()
    {
        presentedViewController?.navigationController?.popViewController(animated: false)
    }
    
}
