//
//  NotificationsListView.swift
//  Saavi
//
//  Created by Vikramjeet Singh on 16/08/20.
//  Copyright © 2020 Saavi. All rights reserved.
//

import UIKit



class NotificationsListView: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var notificationsListTable: UITableView!
    var NotificationItems = Array<Dictionary<String,Any>>()
    var menuController : MenuHierarchyHandler?

    override func viewDidLoad() {
        
        self.notificationsListTable.isHidden = true

        if self.navigationController?.tabBarController is SaaviTabBarController
        {
            let tabBar = self.navigationController?.tabBarController as! SaaviTabBarController
            self.menuController = tabBar.menuController
        }
        Helper.shared.setNavigationTitle( viewController : self, title : "Notification")
        
//        notificationsListTable.register(UITableViewCell.self, forCellReuseIdentifier: "NotificationObjectCell")
        setDefaultNavigation()

        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.GetNotificationsList()
        self.callAPIToUpdateCartNumber()
    }
    
    @objc func setDefaultNavigation() -> Void
    {
        self.navigationItem.rightBarButtonItems = nil
        Helper.shared.createCartIcon(onController: self)
        Helper.shared.createLatestSpecialsBarButtonItem(onController: self)
        //Helper.shared.createSearchIcon(onController: self)
    }
    
    func callAPIToUpdateCartNumber()
    {
        let request = [
            "CartID": 0,
            "IsSavedOrder": false,
            "UserID": UserInfo.shared.userId!,
            "CustomerID": UserInfo.shared.customerID!,
            "isRepUser": UserInfo.shared.isSalesRepUser as Any
            ] as [String : Any]
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: request, strURL: SyncEngine.baseURL + SyncEngine.getCartCount, withIndicator: false) { (response : Any) in
            if let obj = response as? Dictionary<String,Any>, let cartCount = obj["Count"] as? NSNumber
            {
                DispatchQueue.main.async {
                    Helper.shared.cartCount = Int(truncating: cartCount)
                    self.setDefaultNavigation()
                }
            }
        }
    }

    
     func GetNotificationsList(){
        
//        let appendparmsInUrl = "?customerId=" + UserInfo.shared.customerID! + "&isRead=" + "false"
        let appendparmsInUrl = "?customerId=" + UserInfo.shared.customerID!

        SyncEngine.sharedInstance.sendGetRequestToServer(strURL: SyncEngine.baseURL + SyncEngine.GetNotificationsList + appendparmsInUrl) { (response: Any) in
            
            let notif_arr : Array = ((response as? Dictionary<String,Any>)?["Notifications"] as? Array<Dictionary<String,Any>>)!
            
//            let notif_arr = response.Notifications as! NSArray
            self.NotificationItems.removeAll()
            self.NotificationItems = notif_arr
            DispatchQueue.main.async {
                self.notificationsListTable.reloadData()
            }
            DispatchQueue.main.async {
                 let TotalUnread = (response as? Dictionary<String,Any>)?["TotalUnread"] as! NSNumber
                 if self.navigationController?.tabBarController is SaaviTabBarController
                {
                    let tabBar = self.navigationController?.tabBarController as! SaaviTabBarController
                    tabBar.TotalUnread_count_str = String(format: "%@",TotalUnread)
                    tabBar.customCollectionTabBarController.reloadData()
                }
            }

    }
}

    
    
        // MARK:- Table view data source and delegate methods
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
        {
            if (self.NotificationItems.count > 0)
            {
                self.notificationsListTable.isHidden = false
            }
            return NotificationItems.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationObjectCell", for: indexPath) as! NotificationObjectCell
            
            if self.NotificationItems.count > 0
            {
                cell.readUnreadNotifView.isHidden = true
                
                let responseDict = self.NotificationItems[indexPath.row]

                if responseDict.keyExists(key: "Message")
                {
                    let Message = responseDict["Message"]
                    cell.messageDescLbl?.text = Message as? String
                }
                if responseDict.keyExists(key: "CreatedDate")
                {
                    let CreatedDate = responseDict["CreatedDate"] as! String
                    
                    let df_new = DateFormatter()
                    df_new.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                    let msgDate : Date = df_new.date(from: CreatedDate)!

                    
                    let df = DateFormatter()
                    df.dateFormat = "dd/MM/yyyy"
                    cell.dateLbl?.text = df.string(from: msgDate)
                    
                }
                if responseDict.keyExists(key: "IsRead")
                {
                    let IsRead = responseDict["IsRead"] as! Bool
                    if(IsRead == true)
                    {
                        cell.readStatusLbl.text = "Read"
                        cell.readUnreadNotifView.isHidden = true
                    }
                    else
                    {
                        cell.readStatusLbl.text = "Unread"
                        cell.readUnreadNotifView.isHidden = false
                    }
                        
                }


            }
            
            
            cell.roundLbl.layer.cornerRadius = cell.roundLbl.frame.size.height/2
            cell.roundLbl.clipsToBounds = true
            
            cell.roundLbl.backgroundColor = UIColor.primaryColor()
            cell.readStatusLbl.textColor = UIColor.primaryColor()

            cell.dateLbl.textColor = UIColor.primaryColor()

            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
        {
             if self.NotificationItems.count > 0
             {
                let responseDict = self.NotificationItems[indexPath.row]
                self.UpdateUnreadMessageStatus(messageDict: responseDict)
             }

        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 90.0 * Configration.scalingFactor()
        }
    
    
    func UpdateUnreadMessageStatus(messageDict : Dictionary<String,Any>)
    {
        let notif_id = messageDict["ID"] as! NSNumber
        let notif_id_str = String(format: "%@",notif_id)


            let saveOrderRequest = [
                "NotificationID": notif_id_str,
                "isRead": true
                ] as [String : Any]
            
            let requestURL  = SyncEngine.baseURL + SyncEngine.UpdateUnreadNotificationStatus
            
            SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: saveOrderRequest, strURL: requestURL) { (response : Any) in
                
                self.GetNotificationsList()
        

            }
        }
    
        @objc func showCartScreen() -> Void
        {
            if UserInfo.shared.isGuest == true
            {
                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.guestUser, withCancelButtonTitle: "OK", completion: {
                    Helper.shared.logoutAsGuest()
                    return
                })
            }
            else if UserInfo.shared.customerOnHoldStatus == true && !AppFeatures.shared.isAllowOnHoldPlacingOrder{
                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                    return
                })
            }
            else{
                if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cartVCStoryboardID") as? CartView
                {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        @objc func showLatestSpecialsAction(){
            
            if let walkthrough = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: WhatsNewVC.storyboardID) as? WhatsNewVC{
                walkthrough.isFromTab = false
                self.navigationController?.pushViewController(walkthrough, animated: true)
            }
        }



        


}
class NotificationObjectCell: UITableViewCell
{
    
    @IBOutlet var dateLbl: UILabel!
    @IBOutlet var messageDescLbl: UILabel!
    @IBOutlet var roundLbl: UILabel!
    @IBOutlet var readStatusLbl: UILabel!
    @IBOutlet var readUnreadNotifView: UIView!
    
}
