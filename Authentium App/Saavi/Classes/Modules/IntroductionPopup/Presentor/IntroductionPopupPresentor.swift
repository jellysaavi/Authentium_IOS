//
//  IntroductionPopupPresentor.swift
//  Saavi
//
//  Created by Sukhpreet on 20/07/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class IntroductionPopupPresentor: NSObject, IntroductionPopupPresentorProtocol {

    var view : IntroductionPopupViewProtocol?
    var parentView : ViewController?
    var parentChildView : ViewController?
    var strDescription : String?
    var strCutOffTime : String?
    var interactor : IntroductionPopupInteractorProtocol?
    var wireframe : IntroductionPopupWireframeProtocol?

    func viewDidLoad() {
     view?.configureDisplaySettings()
    }
    
    func viewDidAppear() {
        view?.loadValuesFromObj(withDesc: UserInfo.shared.order_Description, withCutOffTime: UserInfo.shared.orderCutOffTime)
        view?.handleSelectorFromParent(parentView: parentView!)
    }
}
