//
//  ReceiveOrderPopupVC.swift
//  Saavi
//
//  Created by goMad Infotech on 15/07/19.
//  Copyright © 2019 Saavi. All rights reserved.
//

import UIKit

enum DeliveryStatus {
    case skip
    case moveNext
}

enum DeliveryType {
    case none
    case pickUp
    case delivery
}

typealias ReceiveOrderCompleted = (_ value : DeliveryStatus, _ deliveryType : DeliveryType) -> Void

class ReceiveOrderPopupVC: UIViewController {
    
    //MARK: - - Outlets/Variables
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblPickUp: UILabel!
    @IBOutlet weak var lblPickUpDetail: UILabel!
    @IBOutlet weak var lblDelivery: UILabel!
    @IBOutlet weak var btnPickUp: UIButton!
    @IBOutlet weak var btnDelivery: UIButton!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    
    @IBOutlet weak var btnContactLess: UIButton!
    @IBOutlet weak var btnDeliveryATDoor: UIButton!
    
    @IBOutlet weak var lblPermission: UIButton!
    
    @IBOutlet weak var lblContactless: UIButton!
    
    // Handle completion if needed.
    var completionBlock : ReceiveOrderCompleted? = nil
    var deliveryType : DeliveryType = .none
    var backButtonTitle = "BACK"
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
            self.makeUIChanges()
            self.btnSkip.setTitle(self.backButtonTitle, for: .normal)
            self.btnSkip.backgroundColor = UIColor.primaryColor()
            self.btnContinue.backgroundColor = UIColor.primaryColor2()
              btnDeliveryATDoor.isSelected.toggle()
             btnContactLess.isSelected.toggle()
        
       
    }
    
    //MARK: - Implement UI changes
    private func makeUIChanges() -> Void {
        //Set corner radius
        self.viewAlert.layer.cornerRadius = 10
        self.viewAlert.clipsToBounds = true
        
        self.lblDescription.font = UIFont.SFUI_Regular(baseScaleSize: 20.0)
        self.lblPickUp.font = UIFont.SFUI_SemiBold(baseScaleSize: 18.0)
        self.lblDelivery.font = UIFont.SFUI_SemiBold(baseScaleSize: 18.0)
        self.lblPickUpDetail.font = UIFont.SFUI_Regular(baseScaleSize: 13.0)
        
        self.btnSkip.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
        self.btnContinue.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
        
       deliveryType = DeliveryType.delivery
        
        if !UserInfo.shared.isDelivery{
            self.btnDelivery.isSelected = false
            self.btnPickUp.isSelected = true
            
            deliveryType = DeliveryType.pickUp
            btnContactLess.isHidden = true
            btnDeliveryATDoor.isHidden = true
            lblContactless.isHidden = true
            lblPermission.isHidden = true
        }else{
            self.btnPickUp.isSelected = false
            btnDelivery.isSelected = true;
                  
            deliveryType = DeliveryType.delivery
            btnContactLess.isHidden = false
            btnDeliveryATDoor.isHidden = false
            lblContactless.isHidden = false
            lblPermission.isHidden = false
        }
        
        
    }
    
    //MARK: - Buttons Actions
    
    /// This function is used to choose Received Order option from Pickup or Delivery.
    ///
    /// - Parameter sender: sender pass the button type that is selected.
    @IBAction func btnReceiveOrderTypeAction(_ sender: UIButton) {
        if sender == btnPickUp {
            self.btnDelivery.isSelected = false
            deliveryType = DeliveryType.pickUp
            btnContactLess.isHidden = true
            btnDeliveryATDoor.isHidden = true
            lblContactless.isHidden = true
            lblPermission.isHidden = true
        }else{
            self.btnPickUp.isSelected = false
            deliveryType = DeliveryType.delivery
            btnContactLess.isHidden = false
            btnDeliveryATDoor.isHidden = false
            lblContactless.isHidden = false
            lblPermission.isHidden = false
        }
        sender.isSelected = true
    }
    
    /// Skip button click action
    @IBAction func btnSkipAction(_ sender: Any) {
        self.dismiss(animated: false, completion: {
            if self.completionBlock != nil{
                
                self.completionBlock!(DeliveryStatus.skip, DeliveryType.none)
            }
        })
    }
    
    @IBAction func btnDeliveryAction(_ sender: Any) {
        btnContactLess.isSelected.toggle()
    }
    
    @IBAction func btnDeliveryPermissionAction(_ sender: Any) {
        btnDeliveryATDoor.isSelected.toggle()
    }
    
    @IBAction func btnContactlessTextAction(_ sender: Any) {
        btnContactLess.isSelected.toggle()
    }
    @IBAction func btnPermissiontextaction(_ sender: Any) {
        btnDeliveryATDoor.isSelected.toggle()
    }
    @IBAction func btnContactLessAction(_ sender: Any) {
        btnContactLess.isSelected.toggle()
    }
    /// Continue button click action
    @IBAction func btnContinueAction(_ sender: Any) {
        if deliveryType == DeliveryType.none{
            
            Helper.shared.showAlertOnController( message: "Please choose delivery type.", title: CommonString.alertTitle)
        }
        else if deliveryType == DeliveryType.delivery{
               Helper.shared.IsContactless = btnContactLess.isSelected
               Helper.shared.IsLeave = btnDeliveryATDoor.isSelected
            
            if !btnDeliveryATDoor.isSelected {
                Helper.shared.showAlertOnController( message: "Sorry, but we can’t do deliveries without having your permission to leave.", title: "Permission To Leave")
            }else{
                self.dismiss(animated: false, completion: {
                    if self.completionBlock != nil{
                        self.completionBlock!(DeliveryStatus.moveNext, DeliveryType.delivery)
                    }
                })
            }
            
            
            
        }
        else {
            self.dismiss(animated: false, completion: {
                if self.completionBlock != nil{
                    self.completionBlock!(DeliveryStatus.moveNext, DeliveryType.pickUp)
                }
            })
        }
    }
}
