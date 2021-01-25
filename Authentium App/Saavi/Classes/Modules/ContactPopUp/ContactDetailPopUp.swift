//
//  ContactDetailPopUp.swift
//  Saavi
//
//  Created by Irmeen Sheikh on 02/04/18.
//  Copyright © 2018 Saavi. All rights reserved.
//

import UIKit
import MessageUI

class ContactDetailPopUp: UIViewController , UITableViewDelegate, UITableViewDataSource ,MFMailComposeViewControllerDelegate{
    
    @IBOutlet weak var tbl_ContactDetail: UITableView!
    @IBOutlet weak var view_contactDetailPopup: UIView!
    
    @IBOutlet weak var lbl_Title: customLabelGrey!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_Title.font = UIFont.SFUI_Regular(baseScaleSize: 22.0)
        self.view_contactDetailPopup.layer.cornerRadius = 5.0
        self.lbl_Title.backgroundColor = UIColor.baseBlueColor()
        self.lbl_Title.text = "Contact Details"
        self.tbl_ContactDetail.delegate = self
        self.tbl_ContactDetail.dataSource = self
        self.tbl_ContactDetail.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (UserInfo.shared.contactDetailArr?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactDetailCell") as? ContactDetailCell
        cell?.btn_email.tag = indexPath.row
        cell?.lbl_name.text = UserInfo.shared.contactDetailArr![indexPath.row]["Name"] as? String
        cell?.lbl_contactNo.text = UserInfo.shared.contactDetailArr![indexPath.row]["Phone1"] as? String
        cell?.btn_email.addTarget(self, action: #selector(emailButtonAction(sender:)), for: .touchUpInside)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Configration.scalingFactor() * 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UserInfo.shared.contactDetailArr![indexPath.row]["Phone1"] as? String != nil
        {
            Helper.shared.customerPhoneNumber = UserInfo.shared.contactDetailArr![indexPath.row]["Phone1"] as? String
            Helper.shared.placeCallFromController(controller: self, withPhone : Helper.shared.customerPhoneNumber!)
        }
        else
        {
            Helper.shared.showAlertOnController( message: "", title: CommonString.noContactInfoFound)
        }
    }
    
    @IBAction func CancelAction(_ sender: Any) {
        self.dismiss(animated: false, completion: {})
    }
    
    @objc func emailButtonAction(sender:UIButton){
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            mailComposeViewController.setToRecipients([(UserInfo.shared.contactDetailArr![sender.tag]["Email"] as? String)!])
            
            
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        //        mailComposerVC.setSubject("Sending you an in-app e-mail...")
        //        mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: "Your device could not send e-mail.  Please check e-mail configuration and try again.", withCancelButtonTitle: "OK", completion: {
        })
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: false, completion: {})
        controller.dismiss(animated: true, completion: nil)
    }
    
}

class ContactDetailCell: UITableViewCell {
    
    @IBOutlet weak var lbl_name: customLabelGrey!
    @IBOutlet weak var lbl_contactNo: customLabelGrey!
    @IBOutlet weak var btn_email: UIButton!
    
    override func awakeFromNib() {
        self.btn_email.setTitleColor(UIColor.baseBlueColor(), for: .normal)
        self.btn_email.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 15.0)
    }
}

