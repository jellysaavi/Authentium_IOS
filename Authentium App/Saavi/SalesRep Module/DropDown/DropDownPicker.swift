//
//  DropDownPicker.swift
//  Saavi
//
//  Created by Dhanotia on 19/02/18.
//  Copyright © 2018 Saavi. All rights reserved.
//

import UIKit

class DropDownPicker: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tblVwDropDown: UITableView!
    var senderView : PantryListVC?
    var frame = CGRect()
    var dropDownArr = Array<Dictionary<String,Any>>()
    var dropDownValue = Array<Any>()
    var parentView : UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblVwDropDown.tableFooterView = UIView()
        self.tblVwDropDown.frame = frame
        self.tblVwDropDown.layer.borderWidth = 1.0
        self.tblVwDropDown.layer.borderColor = UIColor.darkGreyColor().cgColor
        let tapReco : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hidePopupAction(reco:)))
        tapReco.numberOfTapsRequired  = 1
        tapReco.cancelsTouchesInView = false
        tapReco.delegate = self
        self.view.addGestureRecognizer(tapReco)
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if dropDownArr.count > 0
        {
            return dropDownArr.count
        }
        else
        {
            return dropDownValue.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownCellId", for: indexPath) as! DropDownCell
        cell.textLabel?.numberOfLines = 0
        if dropDownArr.count > 0
        {
            cell.textLabel?.text = (dropDownArr[indexPath.row]["PantryListName"] as?String)?.capitalized
        }
        else{
            cell.textLabel?.text = dropDownValue[indexPath.item] as? String
        }
        cell.textLabel?.textColor = UIColor.darkGreyColor()
        cell.textLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 13.0)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: false, completion:{
            if self.parentView != nil
            {
                if self.dropDownArr.count > 0
                {
                    self.senderView?.pantryListId = (self.dropDownArr[indexPath.row]["PantryListID"] as? NSNumber)!
                    self.senderView?.pantryListIndex = indexPath.row
                    DispatchQueue.main.async {
                        let cell = self.senderView?.clctn_SerachItems.cellForItem(at: IndexPath(item: 0, section:0)) as? SearchCell
                        cell?.txtFld_Search.text = self.dropDownArr[indexPath.row]["PantryListName"] as? String
                        self.senderView?.lbl_PantryListName.text = (self.dropDownArr[indexPath.row]["PantryListName"] as? String)?.capitalized
                        self.senderView?.pantryListIndex = indexPath.row
                        self.senderView?.filterID = 0 // So thst it changes everytime.
                        if let searchBar = self.senderView?.navigationItem.titleView as? UISearchBar
                        {
                            self.senderView?.searchBarCancelButtonClicked(searchBar)
                        }
                        else
                        {
                            self.senderView?.getAllDefaultPantryItems(searchText: "")
                        }
                        let tempBtn = UIButton(type: .custom)
                        tempBtn.tag = 0
                        self.senderView?.selectFilter(sender: tempBtn)
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        let customerCell = self.senderView?.clctn_CustomerDetail.cellForItem(at: IndexPath(item: 4, section:0)) as? CustomerDetailCell
                        customerCell?.txtFld_CustomerName.text = self.dropDownValue[indexPath.item] as? String
                        Helper.shared.customerAppendDic_List["RunNo"] = customerCell?.txtFld_CustomerName.text
                    }
                }
            }
        })
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
        }
    }
    @objc func hidePopupAction(reco : UITapGestureRecognizer)
    {
        if  reco.view == self.view
        {
            self.dismiss(animated: false, completion: nil)
            self.view.endEditing(true)
        }
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: self.tblVwDropDown))!
        {
            return false
        }
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
class DropDownCell: UITableViewCell {
    
}

