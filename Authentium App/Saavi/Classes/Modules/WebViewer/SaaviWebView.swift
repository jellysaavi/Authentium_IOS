//
//  SaaviWebView.swift
//  Saavi
//
//  Created by Sukhpreet on 22/11/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit
import WebKit

class SaaviWebView: UIViewController,WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var saaviWebView: WKWebView!
    var urlAddress = ""
    var isTargetMarketing : Bool = false
    var isNoticeboard : Bool = false
    var parentLoginController : ViewController?
    var senderView : InvoicesView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saaviWebView.backgroundColor = UIColor.white
        saaviWebView.uiDelegate = self
        saaviWebView.navigationDelegate = self
        self.navigationController?.navigationItem.hidesBackButton = true
        if AppFeatures.shared.isTargetMarketing == true || AppFeatures.shared.showNoticeboardPdf == true{
            if self.senderView == nil{
                self.setdefaultNavigation()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if urlAddress != ""
        {
                     //let pageRequest = NSURLRequest(url: URL(string: urlAddress.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!)
            //let htmlFilePath = Bundle.main.url(forResource: "TermsOfUse", withExtension: "html")
           // saaviWebView.loadFileURL(htmlFilePath, allowingReadAccessTo: htmlFilePath)
           // let request = NSURLRequest(url: htmlFilePath!)
           // self.saaviWebView.load(request)
            
                   let url = URL(string: urlAddress)!
//                   saaviWebView.loadFileURL(url, allowingReadAccessTo: url)
            
                   let request = URLRequest(url: url)
            
                   saaviWebView.load(request)
            
            
                       
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setdefaultNavigation(){
        
        let nextBtn = UIButton(type: .custom)
        let image = UIImage(named: "next-screen")
        nextBtn.setImage(image, for: .normal)
        nextBtn.tintColor = UIColor.baseBlueColor()
        nextBtn.frame = CGRect(x: 0, y: 0, width: 34, height: 44)
        nextBtn.imageView?.contentMode = .scaleAspectFit
        nextBtn.addTarget(self, action: #selector(self.nextBtnAction), for: .touchUpInside)
        let barBtn = UIBarButtonItem(customView: nextBtn)
        self.navigationItem.rightBarButtonItems = [barBtn]
    }
    
    @objc func nextBtnAction(){
        
        if isTargetMarketing == true && AppFeatures.shared.isNoticeBoard == true{
            urlAddress = CommonString.noticeboardPDF.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
            if urlAddress != ""
            {
                Loader.shared.showLoader()
                let pageRequest = URLRequest(url: URL(string: urlAddress)!)
                self.saaviWebView.load(pageRequest)
                isTargetMarketing = false
            }
        }
        else
        {
            self.dismiss(animated: false, completion: {
                self.parentLoginController?.showCustomerHomeScreen()
            })
        }
        
    }
    
    @objc func backBtnAction()
    {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}
