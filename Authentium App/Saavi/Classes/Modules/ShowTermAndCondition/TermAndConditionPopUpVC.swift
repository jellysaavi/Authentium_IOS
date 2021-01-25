//
//  TermAndConditionPopUpVC.swift
//  Saavi
//
//  Created by Irmeen Sheikh on 02/04/18.
//  Copyright © 2018 Saavi. All rights reserved.
//

import UIKit

class TermAndConditionPopUpVC: UIViewController {
    
    
    static let termsAndConsitionsStoryboardID = "termsAndConditionStoryboardIdentifier"

    @IBOutlet weak var img_Logo: UIImageView!
    @IBOutlet weak var lbl_welcome: customLabel!
    @IBOutlet weak var contentTextView: CustomTextView!
    @IBOutlet weak var btn_accept: CustomButton!
    @IBOutlet weak var btn_Decline: CustomButton!
    @IBOutlet weak var view_main: UIView!
    @IBOutlet weak var declineBtnWithConstant: NSLayoutConstraint!
    var istermsAnCondition :Bool = false
    var isLiquor :Bool = false
    var wireframe : LoginWireFrame?
    @IBOutlet weak var btnAcceptTrailingConstant: VerticalSpacingConstraints!
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        contentTextView.alwaysBounceHorizontal = false
        contentTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.view_main.layer.borderWidth = 0.6 * Configration.scalingFactor()
        self.view_main.layer.borderColor = UIColor.baseBlueColor().cgColor
        contentTextView.layer.borderWidth = 0;
        contentTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        lbl_welcome.font = UIFont.Roboto_Bold(baseScaleSize: 22.0)
        contentTextView.textAlignment = .justified
        if isLiquor == true
        {
            declineBtnWithConstant.constant =  0.0
            lbl_welcome.text = "WARNING!"
            contentTextView.attributedText = generateliquorPopUpStr(heading: CommonString.liquorPopUpHeading, content: CommonString.liquorpopUpString)
            btnAcceptTrailingConstant.constant = -60
        }
        else{
            lbl_welcome.text = "Welcome Message"
            contentTextView.text = CommonString.termsAndConditionString
            declineBtnWithConstant.constant = 120.0
            btnAcceptTrailingConstant.constant = 10
        }
        contentTextView.contentOffset = CGPoint(x: 0.0, y: 0.0)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func DeclineAction(_ sender: Any) {
        //show login screen
        SyncEngine.sharedInstance.accessToken = nil
        Helper.shared.lastSetDateTimestamp = nil
        Helper.shared.selectedDeliveryDate = nil      
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        let loginWireframe = LoginWireFrame()
        loginWireframe.makeRootViewController(onWindow: UIApplication.shared.keyWindow!, isShowChild: false)
    }
    
    @IBAction func AcceptAction(_ sender: Any)
    {
        if istermsAnCondition == true
        {
            if AppFeatures.shared.isLiquorControlPopup == true
            {
                lbl_welcome.text = "WARNING!"
                contentTextView.attributedText = generateliquorPopUpStr(heading: CommonString.liquorPopUpHeading, content: CommonString.liquorpopUpString)
                declineBtnWithConstant.constant = 0.0
                btnAcceptTrailingConstant.constant = -60
                isLiquor = true
                istermsAnCondition = false
                
            }else if AppFeatures.shared.isParent && UserInfo.shared.isParent{
                
                self.dismiss(animated: false, completion:{
                    
                    self.wireframe?.presenter?.showChildList()
                })
                
            }else{
                
                self.dismiss(animated: false, completion:{
                    self.wireframe?.presenter?.requestIntroPopupDetails()
                })
            }
            
        }else if AppFeatures.shared.isParent && UserInfo.shared.isParent{
            
            self.dismiss(animated: false, completion:{
                
                self.wireframe?.presenter?.showChildList()
            })
            
        }else if isLiquor == true{
            
            self.dismiss(animated: false, completion: {
                self.wireframe?.showIntroPopupFromWireframe()
            })
            
        }
        
    }
    
    func generateliquorPopUpStr(heading:String ,content:String) -> NSAttributedString{
        
        let attrStr = NSMutableAttributedString()
        let headingAttrStr = NSAttributedString(string: heading, attributes: [NSAttributedStringKey.font : UIFont.SFUI_SemiBold(baseScaleSize: 18.0), NSAttributedStringKey.foregroundColor : UIColor.activeTextFieldColor()])
        let textAttrStr = NSAttributedString(string: content, attributes: [NSAttributedStringKey.font : UIFont.SFUI_Regular(baseScaleSize: 16.0), NSAttributedStringKey.foregroundColor : UIColor.activeTextFieldColor()])
        attrStr.append(headingAttrStr)
        attrStr.append(textAttrStr)
        return attrStr
        
    }
    
}
