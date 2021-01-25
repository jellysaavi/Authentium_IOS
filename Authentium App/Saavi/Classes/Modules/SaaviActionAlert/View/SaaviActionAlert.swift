//
//  SaaviActionAlert.swift
//  Saavi
//
//  Created by Sukhpreet on 06/10/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class SaaviActionAlert: UIViewController {
    
    static let storyboardIdentifier = "saaviActionAleryStoryboardIdentifier"
    static let shared = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "saaviActionAleryStoryboardIdentifier") as! SaaviActionAlert
    
    @IBOutlet weak var cnstBthDeclineHeight: VerticalSpacingConstraints!
    typealias proceedCompletionBlock = () -> Void
    
    @IBOutlet weak var lblStaticPopupHeading: UILabel!
    @IBOutlet weak var btnAcceptOption: CustomButton!
    @IBOutlet weak var btnDeclineOpition: CustomButton!
    @IBOutlet weak var popupBoundingBox: UIView!
    @IBOutlet weak var lblAlertMessage : UILabel!
    @IBOutlet weak var btnOK: CustomButton!
    
    
    var completionBlock :proceedCompletionBlock? = nil
    var acceptBtnTitle = ""
    var declineBtnTitle = ""
    var popupTitle = ""
    var popupMessage = ""
    var hideOkayButton = false
    
    //    MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        DispatchQueue.main.async {
            self.lblStaticPopupHeading.font = UIFont.SFUI_SemiBold(baseScaleSize: 18.0)
            self.lblAlertMessage.font = UIFont.SFUI_Regular(baseScaleSize: 17.0)
            self.popupBoundingBox.layer.cornerRadius = 7.0 * Configration.scalingFactor()
            self.popupBoundingBox.layer.borderWidth = 0.7
            self.popupBoundingBox.layer.borderColor = UIColor.baseBlueColor().cgColor
            self.lblStaticPopupHeading.text = self.popupTitle
            self.lblStaticPopupHeading.textColor = UIColor.black
            
            if self.hideOkayButton{
                self.btnOK.isHidden = true
                self.cnstBthDeclineHeight.constant = 0
            }
            if self.acceptBtnTitle == ""
            {
                self.btnDeclineOpition.isHidden  = true
                self.btnAcceptOption.isHidden = true
                self.btnOK.isHidden = false
                self.btnOK.setTitle(self.declineBtnTitle.uppercased(), for: .normal)
            }
            else
            {
                self.btnDeclineOpition.isHidden  = false
                self.btnAcceptOption.isHidden = false
                self.btnOK.isHidden = true
                self.btnAcceptOption.setTitle(self.acceptBtnTitle.uppercased(), for: .normal)
                self.btnDeclineOpition.setTitle(self.declineBtnTitle.uppercased(), for: .normal)
            }
            self.lblAlertMessage.attributedText = self.popupMessage.convertHtmlToAttributedStringWithCSS(font: UIFont(name: "Arial", size: 16), csscolor: "black", lineheight: 5, csstextalign: "center")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.btnOK.isHidden = false
        self.cnstBthDeclineHeight.constant = 40
        self.hideOkayButton = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    MARK:- Button Actions
    
    @IBAction func cancelAction(_ sender: Any?)
    {
        if self.presentingViewController != nil
        {
            self.dismiss(animated: false, completion: nil)
            print("Dismissed from window")
        }
        else
        {
            self.view.removeFromSuperview()
            print("Removed from on window")
        }
        
        if acceptBtnTitle == ""
        {
            self.completionBlock!()
        }
    }
    
    @IBAction func submitAction(_ sender: Any) {
        self.cancelAction(nil)
        self.completionBlock!()
       
    }
    
    func reinitializeVariables()
    {
        declineBtnTitle = ""
        acceptBtnTitle = ""
        popupTitle = ""
        popupMessage = ""
       
        
    }
   
    
    func showCommonAlertOnWindow(withTitle : String, withSuccessButtonTitle : String?, withMessage : String ,withCancelButtonTitle : String, hideOkayButton:Bool? = nil, completion:@escaping proceedCompletionBlock)
    {
        self.reinitializeVariables()
        self.hideOkayButton = hideOkayButton != nil ? hideOkayButton!:false
        completionBlock = completion
        popupTitle = withTitle == CommonString.app_name ? "":withTitle
        if withSuccessButtonTitle != nil
        {
            acceptBtnTitle = withSuccessButtonTitle!
        }
        declineBtnTitle = withCancelButtonTitle
        popupMessage = withMessage
        if UIApplication.shared.keyWindow?.rootViewController?.presentedViewController == nil
        {
            UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: false, completion: {})
        }
        else
        {
            UIApplication.shared.keyWindow?.addSubview(self.view)
            UIApplication.shared.keyWindow?.bringSubview(toFront: self.view)
        }
    }
    
    
}
