//
//  SaaviActionAlert.swift
//  Saavi
//
//  Created by Sukhpreet on 06/10/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class SaaviActionHelp: UIViewController, UIScrollViewDelegate
{
    
    static let storyboardIdentifier = "saaviActionAleryStoryboardIdentifierHelp"
    static let shared = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "saaviActionAleryStoryboardIdentifierHelp") as! SaaviActionHelp
    
    @IBOutlet weak var cnstBthDeclineHeight: VerticalSpacingConstraints!
    typealias proceedCompletionBlock = () -> Void
    
    @IBOutlet weak var lblStaticPopupHeading: UILabel!
    
    @IBOutlet weak var popupBoundingBox: UIView!
    @IBOutlet weak var lblAlertMessage : UILabel!
    @IBOutlet weak var btnOK: CustomButton!
    @IBOutlet var scrollView: UIScrollView!
    
    
    var completionBlock :proceedCompletionBlock? = nil
    var acceptBtnTitle = ""
    var declineBtnTitle = ""
    var popupTitle = ""
    var popupMessage = ""
    var hideOkayButton = false
    
    //    MARK: - View lifecycle
    
    override func viewDidLoad() {
        
        scrollView.isDirectionalLockEnabled = true
        scrollView.contentSize = CGSize(width: -50, height: self.scrollView.contentSize.height)

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
            self.btnOK.setTitle("OK", for: .normal)
            
            
            
            
            self.lblAlertMessage.attributedText = self.popupMessage.convertHtmlToAttributedStringWithCSS(font: UIFont(name: "Arial", size: 16), csscolor: "black", lineheight: 5, csstextalign: "center")
            self.lblAlertMessage.sizeToFit()
        }
    }
    func scrollViewDidScroll(scrolView: UIScrollView) {
        if scrolView.contentOffset.x>0 {
            scrolView.contentOffset.x = 0
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.btnOK.isHidden = false
        self.btnOK.setTitle("OK", for: .normal)
        
        
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
         DispatchQueue.main.async {
            if #available(iOS 13.0, *) {
                let keyWindow = UIApplication.shared.connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .map({$0 as? UIWindowScene})
                    .compactMap({$0})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first
                if keyWindow!.rootViewController?.presentedViewController == nil
                {
                    keyWindow?.rootViewController?.present(self, animated: false, completion: {})
                }
                else
                {
                    keyWindow!.addSubview(self.view)
                    keyWindow!.bringSubview(toFront: self.view)
                }
            } else {
                // Fallback on earlier versions
            }
        

        }
    }
    
    
}
