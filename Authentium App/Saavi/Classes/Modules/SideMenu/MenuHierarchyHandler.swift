//
//  MenuHierarchyHandler.swift
//  Saavi
//
//  Created by Sukhpreet on 27/06/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

protocol SideMenuDelegate {
    func showMeSideMenu() -> Void
    func hideSideMenuFromMe() -> Void
}

class MenuHierarchyHandler: WDViewController,SideMenuDelegate {

    var index:Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setupParameters() {
        sideMenuType = .LeftMenuBelowMainView
        resizeMainContentView = true
        sizeMenuWidth = UIScreen.main.bounds.size.width * 0.90
        scaleFactor = 128.0/UIScreen.main.bounds.size.height
    }
    
    override func getSideMenuViewController() -> UIViewController? {
        let navigation:UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileNavController") as! UINavigationController
//        self.mainContentDelegate = navigation as! WDSideMenuDelegate
        return navigation
    }

    override func getMainViewController() -> UIViewController? {
        
        let sideMenuViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "saaviTabBarStoryID") as! SaaviTabBarController
        sideMenuViewController.menuController = self
        
        sideMenuViewController.index = index
        var controllers = ["orderVCStoryboardIdentifier"]
        
//        if !AppFeatures.shared.hasAccessToDefaultPantry
//        {
//             controllers = ["productsVCStoryboardIdentifier"]
//        }
    
//        if AppFeatures.shared.isShowBarcode
//        {
//            controllers.insert("barcodeScanVCStoryboardIdentifier", at: 1)
//        }
        
        if AppFeatures.shared.isShowNotifications == true
        {
            controllers.append("notificationsVCStoryboardIdentifier")
        }

       controllers.append("whatIsNewStoryboardIdentifier") // what is new
        
        if AppFeatures.shared.showOrderHistory
        {
            controllers.append("historyVCStoryboardIdentifier")
        }
        
        controllers.append("favoriteVCStoryboardIdentifier")
        
        if AppFeatures.shared.isShowAccount{
            
            controllers.append("profileNavController")
            if let index = controllers.index(of: "profileNavController")
            {
                sideMenuViewController.index = self.index == nil ? self.index:index
            }
        }
        
        if AppFeatures.shared.shouldShowInvoices
        {
            controllers.append("invoiceVCStoryboardIdentifier")
        }
        
        if !AppFeatures.shared.canSearchProduct
        {
            if let index = controllers.index(of: "productsVCStoryboardIdentifier")
            {
                controllers.remove(at: index)
            }
        }
        if AppFeatures.shared.isSpecialProductRequest == true
        {
            controllers.append("specialProductRequestVCStoryID")
        }
        
        
        self.getViewControllersForTabBar(controllers: controllers, tabbar: sideMenuViewController)
        sideMenuViewController.tabBar.bringSubview(toFront: sideMenuViewController.customCollectionTabBarController)
        return sideMenuViewController
    }

   @objc func showMeSideMenu() {
        self.showSideMenu()
    }
    
    func hideSideMenuFromMe() {
        self.hideSideMenu()
    }
    
    func performLogout() -> Void {
        self.navigationController?.popViewController(animated: true)
        if let appName = Bundle.main.bundleIdentifier
        {
        UserDefaults.standard.removePersistentDomain(forName: appName)
            UserDefaults.standard.synchronize()
        }
    }
    
    
    func getViewControllersForTabBar(controllers : [String], tabbar : SaaviTabBarController){
        
        for str in controllers
        {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: str) as! UINavigationController
            if tabbar.viewControllers != nil
            {
            tabbar.viewControllers?.append(vc)
            }
            else
            {
                tabbar.viewControllers = [vc] as Array<UIViewController>
            }
        }
    }
}
