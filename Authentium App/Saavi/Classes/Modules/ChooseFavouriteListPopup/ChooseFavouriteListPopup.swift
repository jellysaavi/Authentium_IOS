//
//  ChooseFavouriteListPopup.swift
//  Saavi
//
//  Created by Sukhpreet on 02/09/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

typealias FavouriteCompletionBlock = (_ isFavorite : Bool) -> Void

class ChooseFavouriteListPopup: UIViewController ,UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate
{
    var arrFavoriteLists = Array<Dictionary<String,Any>>()
    @IBOutlet weak var tableViewFavoriteListing : UITableView!
    @IBOutlet weak var labelTitleOfPopup: UILabel!
    @IBOutlet weak var btnOk: CustomButton!
    @IBOutlet weak var popupView: UIView!
    var selectedIndex = -1
    var productID : NSNumber?
    var completionBlock : FavouriteCompletionBlock?
    //var customerId = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableViewFavoriteListing.tableFooterView = UIView()
        getAllFavoriteLists()
        
        labelTitleOfPopup.font = UIFont.SFUI_SemiBold(baseScaleSize: 18.0)
        popupView.layer.cornerRadius = 7.0 * Configration.scalingFactor()
        
        // Do any additional setup after loading the view.
        let tapReco : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hidePopupAction(reco:)))
        tapReco.numberOfTapsRequired  = 1
        tapReco.cancelsTouchesInView = false
        tapReco.delegate = self
        self.view.addGestureRecognizer(tapReco)
        NotificationCenter.default.addObserver(self, selector: #selector(self.getAllFavoriteLists), name: NSNotification.Name(rawValue: "FavoriteListAdded"), object: nil)
    }
    
    
    
    // MARK:- Table view data source and delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrFavoriteLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCellIdentifier", for: indexPath) as! CategorySelectionCollectionCell
        
        if self.arrFavoriteLists.count > 0
        {
            let responseDict = self.arrFavoriteLists[indexPath.row]
            
            if responseDict.keyExists(key: "PantryListName")
            {
                let categoryName = responseDict["PantryListName"]
                cell.textLabel?.text = categoryName as? String
                cell.textLabel?.textColor = UIColor.black
                cell.textLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
            }
            if selectedIndex == indexPath.row
            {
                let checkmark = UIImageView(image: UIImage(named: "checkbox_checked"))
                checkmark.tintColor = UIColor.baseBlueColor()
                cell.accessoryView = checkmark
            }
            else
            {
                let checkmark = UIImageView(image: UIImage(named: "checkbox_unchecked"))
                checkmark.tintColor = UIColor.activeTextFieldColor()
                cell.accessoryView = checkmark
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedIndex = indexPath.row
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0 * Configration.scalingFactor()
    }
    
    
    // MARK: - Service Communication
    @objc func getAllFavoriteLists()
    {
        var customID = String()
        if UserInfo.shared.isSalesRepUser == true{
            customID = UserInfo.shared.customerID!
        }
        else{
            customID = UserInfo.shared.customerID!
        }
        let serviceURL = SyncEngine.baseURL + SyncEngine.getCustomerPantryList
        self.arrFavoriteLists.removeAll()
        let requestToGetOrderDetails = [
            "CustomerID":customID,
            ] as Dictionary<String,Any>
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestToGetOrderDetails, strURL: serviceURL) { (response : Any) in
            if response is Array<Dictionary<String,Any>>
            {
                self.arrFavoriteLists =  response as! Array<Dictionary<String,Any>>
            }
            if self.arrFavoriteLists.count == 0
            {
                self.addNewFavoriteList()
                //Helper.shared.showAlertOnController( message: "No favourite list available.Please create new favourite list.", title: CommonString.alertTitle)
            }
            DispatchQueue.main.async(execute: {
                self.tableViewFavoriteListing.reloadData()
            })
            
        }
        
    }
    
    
    func addNewFavoriteList(){
        
        if UserInfo.shared.customerOnHoldStatus==true && !AppFeatures.shared.isAllowOnHoldPlacingOrder {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                return
            })
        }
        else{
            if let favorietController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addFavoriteListPopupSroryID") as? AddFavoriteListView
            {
               //    self.dismiss(animated: false, completion: nil)
                favorietController.parentController = self
                favorietController.isCreatedByRepUser = false
                DispatchQueue.main.async {
                    self.present(favorietController, animated: false, completion: nil)
                //
                //                    UIApplication.shared.keyWindow?.rootViewController?.present(favorietController, animated: false, completion: nil)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.tableViewFavoriteListing.reloadData()
    }
    
    
    @objc func hidePopupAction(reco : UITapGestureRecognizer)
    {
        if  reco.view == self.view
        {
            self.dismiss(animated: false, completion: nil)
            self.view.endEditing(true)
        }
    }
    
    func showCommonAlertOnWindow(completion:@escaping FavouriteCompletionBlock)
    {
        completionBlock = completion
        UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: false, completion: {
        })
    }
    
    
    
    
    @IBAction func submitAction(_ sender: CustomButton)
    {
        if productID != nil, selectedIndex > -1, arrFavoriteLists.count > selectedIndex , let favoriteListId = arrFavoriteLists[selectedIndex]["PantryListID"] as? NSNumber
        {
            let requestObj = [
                "PantryListID": favoriteListId,
                "ProductID": productID!,
                "Quantity": 0,
                ] as [String:Any]
            
            let serviceURL = SyncEngine.baseURL + SyncEngine.addItemToPantryList
            
            SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestObj, strURL: serviceURL) { (response : Any) in
                DispatchQueue.main.async {
                    self.dismiss(animated: false, completion: {
                        self.completionBlock!(true)
                        Helper.shared.showAlertOnController( message: "Product added successfully", title: CommonString.app_name,hideOkayButton: true)
                        Helper.shared.dismissAlert()
                    })
                }
            }
        }
        else
        {
            if arrFavoriteLists.count == 0
            {
                Helper.shared.showAlertOnController( message: "Please add a favourite list to continue.", title: CommonString.alertTitle)
            }
            else
            {
                Helper.shared.showAlertOnController( message: "Please choose favourite list.", title: CommonString.alertTitle)
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == self.view
        {
            return true
        }
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
