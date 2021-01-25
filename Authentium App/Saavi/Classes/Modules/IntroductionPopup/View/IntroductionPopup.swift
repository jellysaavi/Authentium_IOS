//
//  IntroductionPopup.swift
//  Saavi
//
//  Created by Sukhpreet on 29/06/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class IntroductionPopup: UIViewController {
    
    @IBOutlet weak var lblImportantNote: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblCutOffTime: UILabel!
    @IBOutlet weak var lblstaticCutOffTime: UILabel!
    @IBOutlet weak var img_Star: UIImageView!
    @IBOutlet weak var img_MessageLblBackground: UIImageView!
    
    var presenter : IntroductionPopupPresentorProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        presenter?.viewDidLoad()
        img_Star.tintColor=UIColor.baseBlueColor()
        img_MessageLblBackground.backgroundColor = UIColor.baseBlueColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presenter?.viewDidAppear()
    }
}

extension IntroductionPopup : IntroductionPopupViewProtocol
{
    func configureDisplaySettings()
    {
        lblImportantNote.font = UIFont.SFUIText_Regular(baseScaleSize: 20.0)
        lblMessage.font = UIFont.SFUIText_Semibold(baseScaleSize: 17.0)
        btnContinue.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
        btnContinue.setTitleColor(UIColor.baseBlueColor(), for: .normal)
        lblCutOffTime.font = UIFont.SFUI_Bold(baseScaleSize: 19.0)
        lblstaticCutOffTime.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
    }
    
    func loadValuesFromObj(withDesc desc : String, withCutOffTime cutOff : String)
    {
        lblMessage.text = desc
        lblCutOffTime.text = cutOff
    }
    
    func handleSelectorFromParent(parentView : ViewController)
    {
        btnContinue.addTarget(parentView, action: #selector(parentView.continueToHomeAction), for: UIControlEvents.touchUpInside)
    }
}

