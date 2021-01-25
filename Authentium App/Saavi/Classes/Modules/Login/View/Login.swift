//
//  ViewController.swift
//  Saavi
//
//  Created by Sukhpreet Singh on 15/06/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, LoginViewProtocol {
    
    @IBOutlet weak var loginTxtFld: CustomTextField!
    @IBOutlet weak var passwordTxtFld: CustomTextField!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var btnLogin: CustomButton!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var sideicon_email: UIImageView!
    @IBOutlet weak var sideicon_password: UIImageView!
    @IBOutlet weak var lblDevelopedBy: UILabel!
    @IBOutlet weak var lblVersionInfo: customLabel!
    @IBOutlet weak var vwChild: UIView!
    @IBOutlet weak var btnTermsPolicy: UIButton!
    @IBOutlet weak var btnPrivacyPolicy: UIButton!
    var datesInfoDic :  Dictionary<String,Any>?
    
    
    @IBAction func btnGuestAction(_ sender: Any) {
        UserInfo.shared.isGuest  = true
        presenter?.processLoginRequest(username: "guest", password: "", clientToken: "")
    }
    @IBOutlet weak var btnGuestLogin: UIButton!
    //Presenter Object
    
    var presenter : LoginViewPresenterProtocol?
    var present : LoginViewPresenter?
    var isShowChild: Bool = false
    //    MARK:- View Lifecycle -
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: "isComeFirstTime")

        self.vwChild.isHidden = !self.isShowChild
        presenter?.viewDidLoad()
        btnForgotPassword.titleLabel?.font = UIFont.Roboto_Medium(baseScaleSize: 15.0)
        btnRegister.titleLabel?.font = UIFont.Roboto_Light(baseScaleSize: 17.0)
              // btnTermsPolicy.titleLabel?.font = UIFont.Roboto_Light(baseScaleSize: 15.0)
             //  btnPrivacyPolicy.titleLabel?.font = UIFont.Roboto_Light(baseScaleSize: 15.0)
        lblDevelopedBy.font = UIFont.Roboto_Light(baseScaleSize: 15.0)
        sideicon_email.tintColor = UIColor.lightGray
        sideicon_password.tintColor = UIColor.lightGray
       
        
        if let emailAddress = UserDefaults.standard.value(forKey: "savedEmailAddress") as? String, let password = UserDefaults.standard.value(forKey: "savedPassword") as? String
        {
            self.loginTxtFld.text = emailAddress
            self.passwordTxtFld.text = password
            
            if UserDefaults.standard.bool(forKey: "autoLogin") == true && self.isShowChild == false
            {
                if AppFeatures.shared.shouldShowWalkthrough == true
                {
                    self.loginAction(nil)
                }
                else
                {
                    self.perform(#selector(self.loginAction(_:)), with: nil, afterDelay: 2.3)
                }
            }
            
        }
        else
        {
            self.loginTxtFld.text = ""
            self.passwordTxtFld.text = ""
        }
        
        var versionStr = ""
        
        versionStr.append(SyncEngine.baseURLType)
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionStr.append("v\(version)")
        }
        
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            versionStr.append("(\(build))")
        }
        self.lblVersionInfo.text = versionStr
        self.lblVersionInfo.textColor = UIColor.black
        self.lblVersionInfo.font = UIFont.Roboto_Light(baseScaleSize: 10.0)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        for view in self.view.subviews
        {
            if view is CustomTextField
            {
                (view as! CustomTextField).Underline()
            }
        }
        
        if self.navigationController is CustomNavigationController
        {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    
    
    @IBAction func forgotPasswordAction(_ sender: Any)
    {
//        let forgotWireframe = ForgotPasswordWireframe()
//        forgotWireframe.pushForgotFromVC(baseController: self)
        
        
        //        if let dateTimeCorrectionPopup = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DateConfirmationPopupVC") as? DateConfirmationPopupVC
        //        {
        //            self.present(dateTimeCorrectionPopup, animated: false, completion: nil)
        //            dateTimeCorrectionPopup.completionBlock = { (value) -> Void in
        //                if value! == .dateCorrect {
        //
        //                }
        //
        //            }
        //        }
        //
        
    }
    
    @IBAction func registerAction(_ sender: Any)
    {
        DispatchQueue.main.async {
            if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterTypeViewController") as? RegisterTypeViewController
            {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }

    }
    
    @IBAction func termsAndConditionAction(_ sender: Any)
    {
        if let termsAncConditions = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "saaviWebViewStoryboardID") as? SaaviWebView
        {
            let navController = UINavigationController(rootViewController: termsAncConditions)
          if let htmlFilePath = Bundle.main.url(forResource: "TermsOfUse", withExtension: "html")?.absoluteString
           {
              termsAncConditions.urlAddress = htmlFilePath
              termsAncConditions.senderView = nil
             self.present(navController, animated: true, completion: nil)
               Helper.shared.setNavigationTitle(withTitle: "Terms & Conditions", withLeftButton: .backButton, onController: termsAncConditions)
             // termsAncConditions.saaviWebView.scalesPageToFit = false
            }
        }
    }
    
    @IBAction func privacyPolicyAction(_ sender: UIButton?)
    {
        if let privacyPolicy = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "saaviWebViewStoryboardID") as? SaaviWebView
       {
            let navController = UINavigationController(rootViewController: privacyPolicy)
           if let htmlFilePath = Bundle.main.url(forResource: "PrivacyPolicy", withExtension: "html")?.absoluteString
            {
              privacyPolicy.urlAddress = htmlFilePath
              Helper.shared.setNavigationTitle(withTitle: "Privacy Policy", withLeftButton: .backButton, onController: privacyPolicy)
               self.present(navController, animated: true, completion: nil)
               // privacyPolicy.saaviWebView.scalesPageToFit = false
           }
       }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func continueAction()
    {
        
        //(sender as! UIButton).superview?.superview?.removeFromSuperview()
        if false
        {
            DispatchQueue.main.async {
            
            
            if let pdfViewer = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "saaviWebViewStoryboardID") as? SaaviWebView
            {
                if(AppFeatures.shared.isTargetMarketing && !CommonString.tarketMarketingPDF.isEmpty){
                    let navController = UINavigationController(rootViewController: pdfViewer)
                    pdfViewer.urlAddress = CommonString.tarketMarketingPDF
                    pdfViewer.isTargetMarketing = AppFeatures.shared.isTargetMarketing
                    pdfViewer.parentLoginController = self
                    Helper.shared.setNavigationTitle(viewController: pdfViewer, title: "Noticeboard")
                    self.present(navController, animated: true, completion: nil)
                }
                else if AppFeatures.shared.isNoticeBoard == true && !CommonString.noticeboardPDF.isEmpty{
                    if let pdfViewer = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "saaviWebViewStoryboardID") as? SaaviWebView
                    {
                        let navController = UINavigationController(rootViewController: pdfViewer)
                        pdfViewer.urlAddress = CommonString.noticeboardPDF
                        pdfViewer.isNoticeboard = AppFeatures.shared.isNoticeBoard
                        pdfViewer.parentLoginController = self
                        Helper.shared.setNavigationTitle(viewController: pdfViewer, title: "Noticeboard")
                        self.present(navController, animated: true, completion: nil)
                    }
                }
            }
            else{
                
                             DispatchQueue.main.async
                            {
                                let view = UIStoryboard(name : "Main" , bundle : nil).instantiateViewController(withIdentifier: "IntroPopupStoryId") as! IntroductionPopup

                                let presenter = IntroductionPopupPresentor()
                                let interactor = IntroductionPopupInteractor()
                                view.presenter = presenter
                                presenter.interactor = interactor
                    //            presenter.wireframe = self
                                presenter.view = view
                                interactor.presenter = presenter
                                presenter.parentView = self
                                self.view .addSubview(view.view)
                            }
                }
            }
        }
        else if false
        {
            DispatchQueue.main.async {
            if let pdfViewer = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "saaviWebViewStoryboardID") as? SaaviWebView
            {
                let navController = UINavigationController(rootViewController: pdfViewer)
                pdfViewer.urlAddress = CommonString.noticeboardPDF
                pdfViewer.isNoticeboard = true
                pdfViewer.parentLoginController = self
                Helper.shared.setNavigationTitle(viewController: pdfViewer, title: "Noticeboard")
                self.present(navController, animated: true, completion: nil)
            }
            }
        }
        else
        {
             DispatchQueue.main.async
            {
                let view = UIStoryboard(name : "Main" , bundle : nil).instantiateViewController(withIdentifier: "IntroPopupStoryId") as! IntroductionPopup

                let presenter = IntroductionPopupPresentor()
                let interactor = IntroductionPopupInteractor()
                view.presenter = presenter
                presenter.interactor = interactor
    //            presenter.wireframe = self
                presenter.view = view
                interactor.presenter = presenter
                presenter.parentView = self
                self.view .addSubview(view.view)
            }
        }
    }
    @objc func continueToHomeAction()
    {
        DispatchQueue.main.async {
            if let testVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "menuHierarchyHandlerStoryID") as? MenuHierarchyHandler
            {
                self.navigationController?.pushViewController(testVC, animated: false)
            }
        }
        
    }

    
    func showCustomerHomeScreen() -> Void
    {
        DispatchQueue.main.async {
            if let testVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "menuHierarchyHandlerStoryID") as? MenuHierarchyHandler
            {
                self.navigationController?.pushViewController(testVC, animated: false)
            }
        }
        
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //    MARK: - Text Field Delegates
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if textField == loginTxtFld
        {
            sideicon_email.tintColor = UIColor.baseBlueColor()
        }
        else if textField == passwordTxtFld
        {
            sideicon_password.tintColor = UIColor.baseBlueColor()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        textField.textColor = AppConfig.darkGreyColor()
        if textField == loginTxtFld
        {
            sideicon_email.tintColor = UIColor.lightGray
            
        }
        else if textField == passwordTxtFld
        {
            sideicon_password.tintColor = UIColor.lightGray
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text == "", string == " "
        {
            return false
        }
        else if string == "\n"
        {
            textField.resignFirstResponder()
            textField.endEditing(true)
        }
        else{
            let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            return newText.count<=50
        }
        
        return true
    }
    
    @IBAction func loginAction(_ sender: Any?)
    {
         UserInfo.shared.isGuest  = false
        self.view.endEditing(true)
        
        if loginTxtFld.text?.isValidEmailAddressFormat() == false
        {
            loginTxtFld.becomeFirstResponder()
            loginTxtFld.textColor = UIColor.errorTextFieldColor()
            sideicon_email.tintColor = UIColor.errorTextFieldColor()
            Helper.shared.showAlertOnController( message: "Please enter a valid email address.", title: CommonString.alertTitle)
        }
        else if (passwordTxtFld.text?.count)! < 4
        {
            passwordTxtFld.becomeFirstResponder()
            passwordTxtFld.textColor = UIColor.errorTextFieldColor()
            sideicon_password.tintColor = UIColor.errorTextFieldColor()
            Helper.shared.showAlertOnController( message: "Please enter a valid password.", title: CommonString.alertTitle)
        }
        else
        {
//            presenter?.processLoginRequest(username: loginTxtFld.text!, password: passwordTxtFld.text!, clientToken:"DAX4qwRQvKKdPjIgURfHwUV60uMrNhOGDH93AmG7")
            self.postLoginRequest(withUsername: loginTxtFld.text!, withPassword: passwordTxtFld.text!, withClientToken: "DAX4qwRQvKKdPjIgURfHwUV60uMrNhOGDH93AmG7")
        }
    }
    
    
    func postLoginRequest(withUsername username: String, withPassword password: String, withClientToken clientToken: String) {
        
        var devicetoken = String()
        if UserDefaults.standard.value(forKey: "DeviceToken") == nil
        {
            devicetoken = ""
        }
        else
        {
            devicetoken = UserDefaults.standard.value(forKey: "DeviceToken") as! String
        }

        SyncEngine.sharedInstance.authenticateUserWith(email: username, password: password, client_id: clientToken, completion: { (response : Any) in
            
            if (response as? Dictionary<String,AnyObject>) != nil
            {
                if username != "guest" {
                UserDefaults.standard.set(false, forKey: "sessionExpire")
                UserDefaults.standard.set(username, forKey: "savedEmailAddress")
                UserDefaults.standard.set(password, forKey: "savedPassword")
                UserDefaults.standard.set(false, forKey: "autoLogin")
                UserDefaults.standard.synchronize()
                }
                
                
                
//                DispatchQueue.main.async {
//                    if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterTypeViewController") as? RegisterTypeViewController
//                    {
//                        self.navigationController?.pushViewController(vc, animated: true)
//                    }
//                }
                Helper.shared.showAlertOnController( message: "Login Successful", title: CommonString.app_name)
                
            }
        })
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    //    override func viewDidLayoutSubviews() {
    //
    //    }
}

