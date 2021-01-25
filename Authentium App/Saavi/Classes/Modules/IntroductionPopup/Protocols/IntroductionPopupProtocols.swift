//
//  IntroductionPopupProtocols.swift
//  Saavi
//
//  Created by Sukhpreet on 20/07/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

protocol IntroductionPopupInteractorProtocol
{
    
}

protocol IntroductionPopupPresentorProtocol
{
    func viewDidLoad()
    func viewDidAppear()
}


protocol IntroductionPopupWireframeProtocol
{
    func createIntroPopupViewController(onController controller : ViewController)
}


protocol IntroductionPopupViewProtocol
{
    func configureDisplaySettings()
    func loadValuesFromObj(withDesc desc : String, withCutOffTime cutOff : String)
    func handleSelectorFromParent(parentView : ViewController)
}


protocol IntroductionPopupDataManagerProtocol
{
    
}
