//
//  IntroductionPopupWireframe.swift
//  Saavi
//
//  Created by Sukhpreet on 20/07/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class IntroductionPopupWireframe: NSObject, IntroductionPopupWireframeProtocol {

    func createIntroPopupViewController(onController controller : ViewController)
    {
        let view = UIStoryboard(name : "Main" , bundle : nil).instantiateViewController(withIdentifier: "IntroPopupStoryId") as! IntroductionPopup

        let presenter = IntroductionPopupPresentor()
        let interactor = IntroductionPopupInteractor()
        view.presenter = presenter
        presenter.interactor = interactor
        presenter.wireframe = self
        presenter.view = view
        interactor.presenter = presenter
        presenter.parentView = controller
        controller.view .addSubview(view.view)
    }
}
