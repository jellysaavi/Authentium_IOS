
//
//  SalesRepAlert.swift
//  Saavi
//
//  Created by Dhanotia on 26/02/18.
//  Copyright © 2018 Saavi. All rights reserved.
//

import UIKit

class SalesRepAlert: UIViewController {
    
    static let storyboardIdentifier = "SalesRepAlertStoryboardIdentifier"
    static let shared = UIStoryboard(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "SalesRepAlertStoryboardIdentifier") as! SalesRepAlert
    
    typealias proceedCompletionBlock = () -> Void
    @IBOutlet weak var default_ImgView: UIImageView!
    @IBOutlet weak var lblStaticPopupHeading: UILabel!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var okBtn: CustomButton!
    var completionBlock :proceedCompletionBlock? = nil
    var okBtnTitle = ""
    var popupMessage :NSAttributedString!
    var popupTitle = ""
    var senderView : PantryListVC?
    var default_ImgName = ""
    
    //    MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.lblStaticPopupHeading.font = UIFont.Roboto_Medium(baseScaleSize: 21.0)
        self.lblContent.font = UIFont.Roboto_Regular(baseScaleSize: 21.0)
        self.popUpView.layer.cornerRadius = 7.0 * Configration.scalingFactor()
        self.popUpView.layer.borderWidth = 0.7
        self.lblStaticPopupHeading.text = popupTitle
        self.lblStaticPopupHeading.textColor = UIColor.black
        
        lblContent.attributedText = popupMessage
        default_ImgView.image = UIImage(named: default_ImgName)?.withRenderingMode(.alwaysTemplate)
        default_ImgView.tintColor = UIColor.baseBlueColor()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func okBtnAction(_ sender: Any) {
        if self.presentingViewController != nil
        {
            self.dismiss(animated: false, completion: {
                self.senderView?.index = -1
                self.senderView?.clctn_Features.reloadData()
            })
            print("Dismissed from window")
        }
        else
        {
            self.completionBlock!()
            self.view.removeFromSuperview()
            print("Removed from on window")
        }
    }
    func reinitializeVariables()
    {
        popupMessage = "".convertHtmlToAttributedStringWithCSS(font: UIFont(name: "Arial", size: 16), csscolor: "black", lineheight: 5, csstextalign: "center")
        popupTitle = ""
        okBtnTitle = ""
        default_ImgName = ""
    }
    
    func showCommonAlertOnWindow(withImage : String ,withTitle : String, withSuccessButtonTitle : String?, withMessage : String ,withCancelButtonTitle : String, completion:@escaping proceedCompletionBlock)
    {
        self.reinitializeVariables()
        completionBlock = completion
        popupMessage = withMessage.convertHtmlToAttributedStringWithCSS(font: UIFont(name: "Arial", size: 16), csscolor: "black", lineheight: 5, csstextalign: "center")
        popupTitle = withTitle
        okBtnTitle = withCancelButtonTitle
        default_ImgName = withImage
        
        if UIApplication.shared.keyWindow?.rootViewController?.modalPresentationStyle == nil
        {
            UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: false, completion: {})
            print("Presented on window")
        }
        else
        {
            UIApplication.shared.keyWindow?.addSubview(self.view)
            UIApplication.shared.keyWindow?.bringSubview(toFront: self.view)
            print("Added on window")
        }
    }
    
    
    
}
