//
//  AddFavoriteListView.swift
//  Saavi
//
//  Created by Sukhpreet on 01/09/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class AddFavoriteListView: UIViewController ,UIGestureRecognizerDelegate, UITextFieldDelegate{
    @IBOutlet weak var textFieldFavoriteListName: CustomTextField!
    @IBOutlet weak var labelTitleOfPopup: UILabel!
    @IBOutlet weak var btnOk: CustomButton!
    @IBOutlet weak var popupView: UIView!
    
    var parentController : UIViewController?
    var isCopyingExistingPantry : Bool = false
    var pantryListToBeCopiedId : NSNumber?
    var titleOfPopup : String?
    var isCreatedByRepUser : Bool = false
    // var customerID = String()
    
    // MARK:- View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textFieldFavoriteListName.applyBorder()
        labelTitleOfPopup.font = UIFont.SFUI_SemiBold(baseScaleSize: 18.0)
        popupView.layer.cornerRadius = 7.0 * Configration.scalingFactor()
        
        let tapReco : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hidePopupAction(reco:)))
        tapReco.numberOfTapsRequired  = 1
        tapReco.cancelsTouchesInView = true
        tapReco.delegate = self
        self.view.addGestureRecognizer(tapReco)
        
        self.textFieldFavoriteListName.delegate = self
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.isCopyingExistingPantry
        {
            self.textFieldFavoriteListName.attributedPlaceholder = nil
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if titleOfPopup != nil
        {
            self.labelTitleOfPopup.text = self.titleOfPopup
        }
        if self.parentController is FavoriteListView
        {
            //customerID = UserInfo.shared.customerID!
        }
        else if self.parentController is OrderVC
        {
            //customerID = UserInfo.shared.customerID!
        }
        else if self.parentController is PantryListVC
        {
            //customerID = UserInfo.shared.customerID! //String(describing: (self.parentController as! PantryListVC).customerID)
            let attributes = [
                NSAttributedStringKey.font : UIFont.Roboto_Italic(baseScaleSize: 14)
            ]
            self.textFieldFavoriteListName.attributedPlaceholder = NSAttributedString(string: "Add Pantry List", attributes:attributes)
            
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    MARK:- Gesture Recoganizer Delegates
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == self.popupView
        {
            return false
        }
        return true
    }
    
    //    MARK:- Text Field Delegates
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.text == "", string == " "
        {
            return false
        }
        else if (textField.text! as NSString).replacingCharacters(in: range, with: string).contains("  ")
        {
            return false
        }
        else
        {
            let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            return newText.count<=50
        }
    }
    
    //    MARK:- Hide Popup
    @objc func hidePopupAction(reco : UITapGestureRecognizer)
    {
        if  reco.view == self.view
        {
            if self.textFieldFavoriteListName.isEditing
            {
                self.textFieldFavoriteListName.endEditing(true)
            }
            else
            {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    @IBAction func submitAction(_ sender: CustomButton){
        
        self.view.endEditing(true)
        if (self.textFieldFavoriteListName.text?.count)! > 0{
            
            let request = [
                "PantryListID": (pantryListToBeCopiedId == nil) ? 0 : pantryListToBeCopiedId!,
                "CustomerID": UserInfo.shared.customerID!,
                "PantryListName": self.textFieldFavoriteListName.text!,
                "IsCreatedByRepUser": isCreatedByRepUser,
                "IsCopy":isCopyingExistingPantry
                ] as [String : Any]
            
            let serviceURL = SyncEngine.baseURL + SyncEngine.addUpdatePantryList
            
            SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: request, strURL: serviceURL) { (response : Any) in
                if self.parentController is FavoriteListView
                {
                    (self.parentController as! FavoriteListView).getAllFavoriteLists()
                }
                else if self.parentController is OrderVC
                {
                    for controller in (self.parentController?.navigationController?.viewControllers)!
                    {
                        if controller is FavoriteListView
                        {
                            (controller as! FavoriteListView).getAllFavoriteLists()
                        }
                    }
                }
                else if self.parentController is PantryListVC
                {
                    DispatchQueue.main.async
                        {
                            (self.parentController as! PantryListVC).getRepCustomerPantryLists()
                    }
                }
                DispatchQueue.main.async {
                    DispatchQueue.main.async
                        {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FavoriteListAdded"), object: nil)
                            var listName : String = "Pantry"
                            if UserInfo.shared.isSalesRepUser == true{
                                if self.isCopyingExistingPantry
                                {
                                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: "\(listName) list copied successfully.", withCancelButtonTitle: "OK" , completion: {
                                        self.dismiss(animated: false, completion:nil)
                                    })
                                    
                                }
                                else{
                                    
                                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: "\(listName) list created successfully.", withCancelButtonTitle: "OK", completion: {
                                        self.dismiss(animated: false, completion:nil)
                                    })
                                }
                            }
                            else{
                                if AppFeatures.shared.isNonFoodVersion || self.parentController is FavoriteListView
                                    
                                {
                                    listName = "Favourite"
                                }
                                
                                if self.isCopyingExistingPantry
                                {
//                                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: "\(listName) list copied successfully.", withCancelButtonTitle: "OK", completion: {
//                                        self.dismiss(animated: false, completion:nil)
//                                    })
                                    DispatchQueue.main.async{
                                        Helper.shared.showAlertOnController(message:"Favourite list copied successfully", title: "",hideOkayButton: true
                                        )
                                        Helper.shared.dismissAddedToCartAlert()
                                    }
                                }
                                else
                                {
//                                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: "\(listName) list created successfully.", withCancelButtonTitle: "OK", completion: {
//                                    self.dismiss(animated: false, completion:nil)
//                                    })
                                    
                                    DispatchQueue.main.async{
                                            Helper.shared.showAlertOnController(message:"Favourite list created successfully", title: "",hideOkayButton: true
                                            )
                                            Helper.shared.dismissAddedToCartAlert()
                                    }
                                }
                            }
                            self.dismiss(animated: false, completion:nil)
                    }
                  
                }
            }
        }
        else
        {
            if self.parentController is PantryListVC{
                Helper.shared.showAlertOnController( message: "Please enter Pantry list name", title: CommonString.alertTitle)
            }
            else if self.parentController is FavoriteListView{
                Helper.shared.showAlertOnController( message: "Please enter new name for  favourite list.", title: CommonString.alertTitle)
            }
            else{
                
                if AppFeatures.shared.isNonFoodVersion
                {
                    Helper.shared.showAlertOnController( message: "Please enter new name for copied favourite list.", title: CommonString.alertTitle)
                }
                else{
                    Helper.shared.showAlertOnController( message: "Please enter new name for copied Pantry list.", title: CommonString.alertTitle)
                }
                
            }
        }
    }
}

