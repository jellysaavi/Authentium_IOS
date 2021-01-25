//
//  SpecailPriceAlert.swift
//  Saavi
//
//  Created by Priya on 12/03/18.
//  Copyright © 2018 Saavi. All rights reserved.
//

import UIKit

class SpecailPriceAlert: UIViewController, UITextFieldDelegate,UIGestureRecognizerDelegate{
    
    var senderView : OrderDescriptionView?
    var priceInfoSenderView : PriceInfoVC?
    var parentController : UIViewController?
    //var customerID:NSNumber = 0
    var isAlways :Bool = false
    var productID : NSNumber = 0
    var price : NSNumber?
    var UOMId : NSNumber = 0
    var qtyPerUnit : NSNumber = 0
    var specialPrice : NSNumber?
    var isInCart : Bool = false
    
    @IBOutlet weak var imageVwSpecialPrice: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tapReco : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hidePopupAction(reco:)))
        tapReco.numberOfTapsRequired  = 1
        tapReco.cancelsTouchesInView = true
        tapReco.delegate = self
        self.view.addGestureRecognizer(tapReco)
        //  self.price = self.specialPrice
        self.imageVwSpecialPrice.image = #imageLiteral(resourceName: "specialPrice").withRenderingMode(.alwaysTemplate)
        self.imageVwSpecialPrice.tintColor = UIColor.baseBlueColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func hidePopupAction(reco : UITapGestureRecognizer)
    {
        if reco.view == self.view{
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func alwaysApplyAction(_ sender: Any) {
        isAlways = true
        if self.senderView != nil{
            showPopUp()
        }
        else{
            callAPIForSpecialPrice()
        }
        
    }
    
    @IBAction func thisOrderOnlyAction(_ sender: Any) {
        isAlways = false
        if self.senderView != nil{
            showPopUp()
        }
        else{
            callAPIForSpecialPrice()
        }
    }
    
    //MARK:- Call webservice
    func callAPIForSpecialPrice()
    {
        var customId = String()
        if UserInfo.shared.isSalesRepUser == true && AppFeatures.shared.isAdvancedPantry == false{
            customId = UserInfo.shared.customerID!
        }
        else{
            customId = String(describing: UserInfo.shared.customerID!)
        }
        let request = [
            "ProductID": productID,
            "CustomerID": customId,
            "RepUserID": UserInfo.shared.userId!,
            "UOMID": UOMId,
            "Price": self.specialPrice ?? 0,
            "AlwaysApply": isAlways,
            "QuantityPerUnit":qtyPerUnit,
            "IsInCart": isInCart ,
            "CartID" : Helper.shared.salesRepTempCartId
            ] as [String : Any]
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: request, strURL: SyncEngine.baseURL + SyncEngine.AddSpecialPrice) { (response : Any) in
            //            if let items = (response as? Dictionary<String,Any>)?["product"] as? Dictionary<String,Any>
            //            {
            DispatchQueue.main.async
                {
                    
                    self.dismiss(animated: false, completion: {
                        if self.senderView != nil && self.senderView is OrderDescriptionView{
                            DispatchQueue.main.async
                                {
                                    NotificationCenter.default.post(name: Notification.Name("UpdateSpecialPrice"), object: nil, userInfo: nil)
                                    self.senderView?.callAPIForGettingDescriptionOfProduct()
                                    self.senderView?.collectionVw_itemDescription.reloadData()
                                    self.senderView?.setValues()
                                    
                            }
                        }
                        else{
                            DispatchQueue.main.async {
                                self.priceInfoSenderView?.dismissSuperView()
                            }
                        }
                    })
            }
        }
        // }
    }
    
    //MARK:- textfield delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let aSet = NSCharacterSet(charactersIn:"0123456789.").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        
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
            return newText.count<=7
        }
        return string == numberFiltered
    }
    
    func showPopUp()
    {
        let alertController = UIAlertController(title:CommonString.app_name, message: CommonString.enterPriceString, preferredStyle: .alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Price"
            textField.keyboardType = .decimalPad
            textField.delegate = self
            
        }
        
        let saveAction = UIAlertAction(title: "OK", style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            let txtFieldPrice =  Double(firstTextField.text!)
            if  firstTextField.text != "", Double(truncating: self.price!) <  txtFieldPrice!
            {
                Helper.shared.showAlertOnController( message: "Customer normal price is \(String(format: "\(CommonString.currencyType)%.2f", Double(truncating: self.price!))).Applied price must not be higher than the customer price.", title: CommonString.app_name)
            }else if (firstTextField.text?.isEmpty)!{
                
                Helper.shared.showAlertOnController( message: "Please enter price.", title: CommonString.app_name)
                
            }
            else
            {
                self.specialPrice = Double(firstTextField.text!)! as NSNumber
                self.callAPIForSpecialPrice()
            }
        })
        
        let cancelAction = UIAlertAction(title: "CANCEL", style: .default, handler: { (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
}
