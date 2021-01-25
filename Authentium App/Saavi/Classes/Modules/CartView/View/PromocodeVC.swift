//
//  SaaviActionAlert.swift
//  Saavi
//
//  Created by Sukhpreet on 06/10/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class PromocodeVC: UIViewController {
    
    static let storyboardIdentifier = "promocodevc"
    static let shared = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "promocodevc") as! PromocodeVC
    
    @IBOutlet weak var cnstBthDeclineHeight: VerticalSpacingConstraints!
    typealias proceedCompletionBlock = (_ totalCart : Double , _ discount :Double) -> Void
    
    @IBOutlet weak var lblStaticPopupHeading: UILabel!
    @IBOutlet weak var btnAcceptOption: CustomButton!
    @IBOutlet weak var popupBoundingBox: UIView!
    @IBOutlet weak var lblAlertMessage : UILabel!
   
        @IBOutlet weak var etPromoCode: CustomTextField!
    
    @IBOutlet weak var lblMessage2: UILabel!
    @IBOutlet weak var lblMessage1: UILabel!
    var completionBlock :proceedCompletionBlock? = nil
    var acceptBtnTitle = ""
    var declineBtnTitle = ""
    var popupTitle = ""
    var popupMessage = ""
    var hideOkayButton = false
    var cartId :NSNumber = 0.0
    
    
    //    MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        DispatchQueue.main.async {
            self.lblStaticPopupHeading.font = UIFont.SFUI_SemiBold(baseScaleSize: 17.0)
            self.lblAlertMessage.font = UIFont.SFUI_Regular(baseScaleSize: 16.0)
            self.popupBoundingBox.layer.cornerRadius = 7.0 * Configration.scalingFactor()
            self.popupBoundingBox.layer.borderWidth = 0.7
            self.popupBoundingBox.layer.borderColor = UIColor.baseBlueColor().cgColor
            self.lblStaticPopupHeading.textColor = UIColor.black
            self.lblAlertMessage.translatesAutoresizingMaskIntoConstraints = false;
                  
           
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    MARK:- Button Actions
    
    @IBAction func cancelAction(_ sender: Any) {
        if self.presentingViewController != nil
        {
            self.dismiss(animated: false, completion: nil)
            print("Dismissed from window")
        }
        else
        {
            self.view.removeFromSuperview()
            print("Removed from on window")
        }
        
        if acceptBtnTitle == ""
        {
            self.completionBlock!(0.0,0.0)
        }
    }
    
    @IBAction func submitAction(_ sender: Any) {
        
        if btnAcceptOption.title(for: .normal) == "OK"{
            self.dismiss(animated: false, completion: nil)
            self.btnAcceptOption.setTitle("ADD", for: .normal)
            
        }else{
        
        if !etPromoCode.text!.isEmpty {
            let serviceURL = SyncEngine.baseURL + SyncEngine.applyPromo
            let requestToGetOrderDetails = [
                "CustomerID": UserInfo.shared.customerID!,
                "UserID": UserInfo.shared.userId!,
                "CartID": self.cartId,
                "Coupon": etPromoCode.text!
                
                ] as Dictionary<String,Any>
            
            SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestToGetOrderDetails, strURL: serviceURL) { (response : Any) in
                DispatchQueue.main.async {
                if let arrObj = response as? Dictionary<String,Any>
                {
                
                if arrObj["Message"] as? String == "Your promo code was applied successfully." {
                    self.lblMessage2.text = "Congratulations!!"
                    self.lblMessage2.textColor = UIColor.init(hex: "#66d26d")
                    
                    self.lblMessage1.text = "Your current cart value prior to the promocode was "
                    self.lblMessage1.text?.append("$" + String(format: "%.2f",((arrObj["CartTotal"] as? Double)! ) ))
                    self.lblMessage1.text?.append(" After the code was applied your new cart value is ")
                    self.lblMessage1.text?.append("$" + String(format: "%.2f",((arrObj["TotalAmountWithDiscount"] as? Double)! )) )
                    
                    
                    let foo = (arrObj["CartTotal"] as AnyObject).doubleValue ?? 0 // -> 4.21
                    let bar = (arrObj["TotalAmountWithDiscount"] as AnyObject).doubleValue ?? 0 // -> 42.5
                    
                    let diff = foo - bar
                    self.lblMessage1.text?.append(" and is a saving of $" + String(format: "%.2f",diff))
                    self.completionBlock!((arrObj["TotalAmountWithDiscount"] as? Double)!,diff)
                    
              //   ((arrObj["CartTotal"]  as? Double!)!) - (arrObj["TotalAmountWithDiscount"] as? Double!)!
                    
                    
//                    var diff : Double = ((arrObj["CartTotal"]  as? Double!)!)
//                    var final : Double = (arrObj["TotalAmountWithDiscount"] as? Double!)!
//                    var amount : Double =  diff - final
//                    
//                    self.lblMessage2.text?.append("a saving of" + String(amount))
//                    
                    self.btnAcceptOption.setTitle("OK", for: .normal)
               
                    
                }else{
                    self.lblMessage2.textColor = UIColor.black
                    
                    self.lblMessage1.text = arrObj["Message"] as? String
                    self.lblMessage2.text = ""
                }
                }
                else{
                    self.lblMessage2.textColor = UIColor.black
                    
                    self.lblMessage2.text = "Sorry that is not a valid code!"
                    self.lblMessage1.text = "Please check your code and try again"
                    
                }
            }
            }
        }else{
              Helper.shared.showAlertOnController( message: "Please enter promo code.", title: CommonString.alertTitle)
        }
        }
       
    }
    
    func reinitializeVariables()
    {
        declineBtnTitle = ""
        acceptBtnTitle = ""
        popupTitle = ""
        popupMessage = ""
    }
    
    
    func showCommonAlertOnWindow(cartID: NSNumber ,completion:@escaping proceedCompletionBlock)
    {
        self.cartId = cartID
        if etPromoCode != nil {
        self.etPromoCode.text = ""
        self.lblMessage1.text = ""
        self.lblMessage2.text = ""
        }
        self.reinitializeVariables()
        completionBlock = completion
        if UIApplication.shared.keyWindow?.rootViewController?.presentedViewController == nil
        {
            UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: false, completion: {})
        }
        else
        {
            UIApplication.shared.keyWindow?.addSubview(self.view)
            UIApplication.shared.keyWindow?.bringSubview(toFront: self.view)
        }
    }
    
    
}
