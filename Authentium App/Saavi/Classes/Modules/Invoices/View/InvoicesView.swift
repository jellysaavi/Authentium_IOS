//
//  InvoicesView.swift
//  Saavi
//
//  Created by Sukhpreet SIngh on 29/09/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit
import SafariServices

class InvoicesView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var arrInvoices = Array<Dictionary<String,Any>>()
    var menuController : MenuHierarchyHandler?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var lblNoInvoice: UILabel!
    // MARK:- View Lifecycle Handling
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // for removing extra seperator lines
        self.tableView.tableFooterView = UIView()
        
        if self.navigationController?.tabBarController is SaaviTabBarController
        {
            let tabBar = self.navigationController?.tabBarController as! SaaviTabBarController
            self.menuController = tabBar.menuController
        }
        
        Helper.shared.setNavigationTitle( viewController : self, title : "Invoices")
        //        if (UserInfo.shared.isSalesRepUser! && UIDevice.current.userInterfaceIdiom == .phone){
        //
        //            Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
        //        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(InvoicesView.setDefaultNavigation), name: NSNotification.Name(rawValue: "cartCountChanged"), object: nil)
        self.tableView.register(UINib.init(nibName: "InvoiceCell", bundle: nil), forCellReuseIdentifier: "InvoiceCell")
        
    }
    
    @objc func backBtnAction()
    {
        
        self.navigationController?.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func setDefaultNavigation() -> Void
    {
        self.navigationItem.rightBarButtonItems = nil
        Helper.shared.createCartIcon(onController: self)
        Helper.shared.createLatestSpecialsBarButtonItem(onController: self)
        Helper.shared.createSearchIcon(onController: self)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        callInvoicesWebService()
        self.tableView.reloadData()
        setDefaultNavigation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Table view data source and delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrInvoices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InvoiceCell", for: indexPath) as! InvoiceCell
        
        if self.arrInvoices.count > 0
        {
            let responseDict = self.arrInvoices[indexPath.row]
            
            if responseDict.keyExists(key: "OrderDate")
            {
                let orderDate = responseDict["OrderDate"]
                cell.lblDate?.text = orderDate as? String
            }
            if responseDict.keyExists(key: "InvoiceNumber")
            {
                let categoryName = responseDict["InvoiceNumber"]
                cell.lblName?.text = categoryName as? String
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let pdfViewer = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "saaviWebViewStoryboardID") as? SaaviWebView
        {
            let navController = UINavigationController(rootViewController: pdfViewer)
            if let htmlFilePath = self.arrInvoices[indexPath.row]["PdfPath"] as? String
            {
                var screenTitle = "Invoice"
                if let screenName = self.arrInvoices[indexPath.row]["InvoiceNumber"] as? String
                {
                    screenTitle.append("- \(screenName)")
                }
                pdfViewer.urlAddress = htmlFilePath
                pdfViewer.senderView = self
                Helper.shared.setNavigationTitle(withTitle: screenTitle , withLeftButton: .backButton, onController: pdfViewer)
                self.present(navController, animated: true, completion: nil)
                //pdfViewer.saaviWebView.scalesPageToFit = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0 * Configration.scalingFactor()
    }
    
    // MARK: - Service Communication
    func callInvoicesWebService()
    {
        let requestParameters = [
            
            "IsPdfListing": true,
            "CustomerID": UserInfo.shared.customerID!,
            "UserID": UserInfo.shared.userId!
            ]  as [String : Any]
        
        let serviceURL = SyncEngine.baseURL + SyncEngine.getUserInvoices
        self.arrInvoices.removeAll()
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestParameters , strURL: serviceURL) { (response : Any) in
            if response is Array<Dictionary<String,Any>>
            {
                self.arrInvoices =  response as! Array<Dictionary<String,Any>>
            }
            DispatchQueue.main.async {
                if self.arrInvoices.count == 0
                {
                    self.lblNoInvoice.isHidden = false
                }
                else
                {
                    self.lblNoInvoice.isHidden = true
                    
                    self.tableView.reloadData()
                }
            }
            
        }
    }
    
    
    // MARK: - Button Actions
    @IBAction func toggleProfileAction(_ sender: Any) {
        menuController?.showMeSideMenu()
    }
    
    @objc func showLatestSpecialsAction()
    {
        
        if let walkthrough = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: WhatsNewVC.storyboardID) as? WhatsNewVC{
            walkthrough.isFromTab = false
            self.navigationController?.pushViewController(walkthrough, animated: true)
        }
    }
    
    @objc func showSearchBar() -> Void
    {
        if let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderVCStoryboardId") as? OrderVC
        {
            destinationViewController.isSearchingProduct = true
            destinationViewController.isShowingDefaultPantryList = false
            self.navigationController?.pushViewController(destinationViewController, animated: false)
        }
    }
    
    @objc func showCartScreen() -> Void
    {
        DispatchQueue.main.async {
            if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cartVCStoryboardID") as? CartView
            {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}
