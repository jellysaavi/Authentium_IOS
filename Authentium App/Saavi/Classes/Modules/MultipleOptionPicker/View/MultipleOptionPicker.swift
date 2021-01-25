//
//  MultipleOptionPicker.swift
//  Saavi
//
//  Created by Sukhpreet on 29/09/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class MultipleOptionPicker: UIViewController, UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate{
    
    static let storyboardIdentifier = "multipleOptionPickerStoryboardID"
    
    typealias successCompletionBlock = (_ selectedArrayIndex : Int) -> Void
    
    @IBOutlet weak var lblStaticPopupHeading: UILabel!
    @IBOutlet weak var tblViewOptions: UITableView!
    @IBOutlet weak var btnAcceptOption: CustomButton!
    @IBOutlet weak var btnDeclineOpition: CustomButton!
    @IBOutlet weak var popupBoundingBox: UIView!
    
    @IBOutlet weak var popupView: UIView!
    var completionBlock :successCompletionBlock? = nil
    
    var displayKeyName = ""
    var arrOptions = Array<Dictionary<String,Any>>()
    var selectedIndex = -1
    var noSelectionAlertMessage : String?
    
    var acceptBtnTitle = ""
    var declineBtnTitle = ""
    var popupTitle = ""
    
    //    MARK:- View Lifecyclex
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.lblStaticPopupHeading.font = UIFont.SFUI_SemiBold(baseScaleSize: 18.0)
        
        self.lblStaticPopupHeading.text = popupTitle
        self.btnAcceptOption.setTitle(acceptBtnTitle, for: .normal)
        self.btnDeclineOpition.setTitle(declineBtnTitle, for: .normal)
        
        self.tblViewOptions.reloadData()
        
        
               
    }
    
 
   
    //    MARK:- Show Popup
    func showMultipleOptionPickerOnWindow(forDisplayKeyName : String, withDataSource : Array<Dictionary<String,Any>>, withTitle : String, withSuccessButtonTitle : String, withCancelButtonTitle : String, withAlertMessage alertMessage : String?, completion:@escaping successCompletionBlock)
    {
        completionBlock = completion
        popupTitle = withTitle
        acceptBtnTitle = withSuccessButtonTitle
        declineBtnTitle = withCancelButtonTitle
        self.arrOptions = withDataSource
        self.displayKeyName = forDisplayKeyName
        self.noSelectionAlertMessage = alertMessage
        for i in 0..<arrOptions.count {
            if arrOptions[i].keyExists(key: "AddressId") && arrOptions[i]["AddressId"] as? NSNumber == UserInfo.shared.justAdded {
                selectedIndex = i
            }
        }
        
        UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: false, completion: {
            self.tblViewOptions.reloadData()
        })
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        completionBlock!(-44)
        self.dismiss(animated: false, completion: nil)
        //        self.view.removeFromSuperview()
    }
    
    @IBAction func submitAction(_ sender: Any) {
        if selectedIndex >= 0
        {
            UserInfo.shared.justAdded = 0
            completionBlock!(selectedIndex)
            self.dismiss(animated: false, completion: nil)
        }
        else
        {
            Helper.shared.showAlertOnController(message: (noSelectionAlertMessage != nil) ? noSelectionAlertMessage! : "Please choose one option.", title: "")
        }
    }
    
    // MARK: - Popup Data Handling
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOptions.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCellIdentifier", for: indexPath) as! CategorySelectionCollectionCell
        
        cell.textLabel?.text = arrOptions[indexPath.row][displayKeyName] as? String
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 16.0)
        cell.textLabel?.numberOfLines = 3
        
        if selectedIndex == indexPath.row
        {
              let index = IndexPath(row: selectedIndex, section: 0) // use your index number or Indexpath
             self.tblViewOptions.scrollToRow(at: index,at: .bottom, animated: true) //here .middle is the scroll position can change it as per your need

            let checkmark = UIImageView(image: UIImage(named: "checkbox_checked"))
            checkmark.tintColor = UIColor.baseBlueColor()
            cell.accessoryView = checkmark
            cell.accessoryView?.tintColor = UIColor.baseBlueColor()
        }
        else
        {
            let checkmark = UIImageView(image: UIImage(named: "checkbox_unchecked"))
            checkmark.tintColor = UIColor.activeTextFieldColor()
            cell.accessoryView = checkmark
            cell.accessoryView?.tintColor = UIColor.activeTextFieldColor()
        }
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0 * VerticalSpacingConstraints.spacingConstant
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        self.tblViewOptions.reloadData()
    }
      func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                let responseDict = self.arrOptions[indexPath.row]
                                           if responseDict.keyExists(key: "AddressId")
                                           {
                    
                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: "Are you sure you want to delete this address?", withCancelButtonTitle: "No", completion:{
                        
                        if self.arrOptions.count > 0
                        {
                            let responseDict = self.arrOptions[indexPath.row]
                            if responseDict.keyExists(key: "AddressId")
                            {
                                let PantryListId = responseDict["AddressId"]
                                self.deleteItemFromFavFavoriteList(indexPath: indexPath, id: PantryListId!)
                               // self.getAllFavoriteLists()
                            }
                        }

                        
                    })
                }
            }
        }
        
        func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
            return "Delete"
        }
    
    func deleteItemFromFavFavoriteList(indexPath:IndexPath,id:Any){
         let requestDic = [
             "AddressID": id
             ] as Dictionary<String,Any>
         print(requestDic)
         SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestDic, strURL: SyncEngine.baseURL + SyncEngine.deleteDeliveryAddress) { (response: Any) in
             print(response)
             self.arrOptions.remove(at: indexPath.row)
             if self.arrOptions.count == 0{
                 //self.showNoItemsLabel()
             }
             DispatchQueue.main.async {
                 self.tblViewOptions.deleteRows(at: [indexPath], with: .automatic)
                 self.tblViewOptions.reloadData()
             }
         }
     }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

