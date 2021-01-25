//
//  ProfileVC.swift
//  Saavi
//
//  Created by Sukhpreet on 27/06/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var lblNoMessage: UILabel!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblCall: UILabel!
    @IBOutlet weak var background_status: UIImageView!
    @IBOutlet weak var backgroundMessages: UIImageView!
    @IBOutlet weak var lblMessageheading: UILabel!
    @IBOutlet weak var lblStaticWelcom: UILabel!
    @IBOutlet weak var lblStaticMobileOrdering: UILabel!
    @IBOutlet weak var tblVwAccountStatus: UITableView!
    @IBOutlet weak var tblViewMessages: UITableView!
    var arrMessages : [Dictionary<String,Any>] = [Dictionary<String,Any>]()
    var width_profileMessage : CGFloat = 0.0
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet var lblCustomerRepName: [UILabel]!
    var fromCustomerList:Bool = false
    // Constraints
    @IBOutlet weak var logoutTop: NSLayoutConstraint!
    @IBOutlet weak var logoTop: NSLayoutConstraint!
    @IBOutlet weak var welcomeTop: NSLayoutConstraint!
    @IBOutlet weak var nameTop: NSLayoutConstraint!
    @IBOutlet weak var saaviMobileOrdeingTop: NSLayoutConstraint!
    @IBOutlet weak var statusBorderTop: NSLayoutConstraint!
    @IBOutlet weak var messageTop: NSLayoutConstraint!
    var accountStatusDict = NSMutableDictionary()
    var phoneNumber : String?
    
    func manageConstraints(){
        
        let constantMultiplier = Configration.scalingFactor()
        logoutTop.constant = 25.0 * constantMultiplier
        logoTop.constant = 35.0 * constantMultiplier
        welcomeTop.constant = logoTop.constant
        nameTop.constant = 0.0 * constantMultiplier
        saaviMobileOrdeingTop.constant = 3.0 * constantMultiplier
        statusBorderTop.constant = 30.0 * constantMultiplier
        //messageTop.constant = 25.0 * constantMultiplier
    }
    
    //    MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserInfo.shared.isSalesRepUser == true && AppFeatures.shared.isAdvancedPantry == false{
            btnLogout.setTitle(" Select Customer", for: .normal)
            btnLogout.setImage(#imageLiteral(resourceName: "back-screen"), for: .normal)
            btnLogout.tintColor = UIColor.baseBlueColor()
        }else{
            btnLogout.setTitle("Logout", for: .normal)
            btnLogout.setImage(nil, for: .normal)
            btnLogout.titleLabel?.font =  UIFont(name: "Helvetica-Bold", size: 17)

        }
        btnLogout.setTitleColor(UIColor.baseBlueColor(), for: .normal)
        // Do any additional setup after loading the view.
        if self.navigationController?.navigationController is CustomNavigationController{
            let controller = self.navigationController?.navigationController as! CustomNavigationController
            controller.interactivePopGestureRecognizer?.isEnabled = false
        }
        DispatchQueue.global(qos: .background).async {
            
            self.fetchUserProfile()
        }
        
        let callActionTap = UITapGestureRecognizer(target: self, action: #selector(self.callAction))
        self.lblCall.addGestureRecognizer(callActionTap)
        self.lblCall.isUserInteractionEnabled = true
        self.lblUserName.textColor=UIColor.baseBlueColor()
        self.lblCustomerRepName[1].textColor=UIColor.baseBlueColor()
        self.lblStaticMobileOrdering.textColor = UIColor.baseBlueColor()
        
        let footerVw = UIView()
        footerVw.backgroundColor = UIColor.white
        self.tblViewMessages.tableFooterView = footerVw
        
        var status = ""
        if UserInfo.shared.customerOnHoldStatus == false && !AppFeatures.shared.isAllowOnHoldPlacingOrder
        {
            status = "Current"
        }
        else
        {
            status = "On Hold"
        }
        var mutableStr = NSMutableAttributedString(string: "Status : \(status)")
        if UserInfo.shared.customerOnHoldStatus == false && !AppFeatures.shared.isAllowOnHoldPlacingOrder
        {
            mutableStr.addAttributes([NSAttributedStringKey.font : UIFont.SFUI_Regular(baseScaleSize: 15.0), NSAttributedStringKey.foregroundColor : UIColor.baseBlueColor()], range: NSRange(location: 0, length: mutableStr.length))
        }
        else
        {
            mutableStr.addAttributes([NSAttributedStringKey.font : UIFont.SFUI_Regular(baseScaleSize: 15.0), NSAttributedStringKey.foregroundColor : UIColor.red], range: NSRange(location: 0, length: mutableStr.length))
        }
        
        mutableStr.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.black], range: (mutableStr.string as NSString).range(of: "Status :"))
        self.lblStatus.attributedText = mutableStr
        
        mutableStr = NSMutableAttributedString(string: "Enquiries : Tap to call")
        mutableStr.addAttributes([NSAttributedStringKey.font : UIFont.SFUI_Regular(baseScaleSize: 15.0), NSAttributedStringKey.foregroundColor : UIColor.baseBlueColor()], range: NSRange(location: 0, length: mutableStr.length))
        mutableStr.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.black], range: (mutableStr.string as NSString).range(of: "Enquiries :"))
        self.lblCall.attributedText = mutableStr
        
        self.lblCall.adjustsFontSizeToFitWidth = true
        self.lblStatus.adjustsFontSizeToFitWidth = true
        self.tblVwAccountStatus.layer.borderColor = UIColor.lightGreyColor().cgColor
        self.tblVwAccountStatus.layer.borderWidth = 1.0
        self.tblVwAccountStatus.layer.cornerRadius = 2.0
        self.tblVwAccountStatus.clipsToBounds = true
        self.setDefaultNavigation()
    }
    
    private func setDefaultNavigation(){
        
        if UserInfo.shared.isSalesRepUser!
        {
            Helper.shared.setNavigationTitle(viewController: self, title: "Account")
        }
        
        let saveBtn = UIButton(type: .custom)
        saveBtn.setTitle("Logout", for: .normal)
        saveBtn.setTitleColor(UIColor.baseBlueColor(), for: .normal)
        saveBtn.titleLabel?.font =  UIFont(name: "Helvetica-Bold", size: 17)

        //saveBtn.tintColor = AppConfig.redColor()
        saveBtn.frame = CGRect(x: 0, y: 0, width: 34, height: 44)
        saveBtn.imageView?.contentMode = .scaleAspectFit
        saveBtn.addTarget(self, action: #selector(self.logoutButtonAction(_:)), for: .touchUpInside)
        let barBtn = UIBarButtonItem(customView: saveBtn)
        
        if self.navigationItem.leftBarButtonItems != nil {
            self.navigationItem.leftBarButtonItems?.append(barBtn)
        }else{
            self.navigationItem.leftBarButtonItem = barBtn
        }
    }
    
    @objc func backBtnAction() -> Void
    {
        if fromCustomerList == true{
            self.navigationController?.popViewController(animated: true)
        }else if (UserInfo.shared.isSalesRepUser! && UIDevice.current.userInterfaceIdiom == .phone){
            self.navigationController?.navigationController?.popViewController(animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    @objc func logoutButtonAction(_ sender:UIButton){
        if UserInfo.shared.isSalesRepUser == true
        {
            if UIDevice.current.userInterfaceIdiom == .phone{
                Helper.shared.logout()
            }else{
                AppFeatures.shared.isTargetMarketing = false
                AppFeatures.shared.showNoticeboardPdf = false
                self.navigationController?.navigationController?.popViewController(animated: true)
            }
        }
        else
        {
            Helper.shared.logout()
        }
    }
    
    @objc func callAction()
    {
        if AppFeatures.shared.isShowContactDetails == true && (UserInfo.shared.contactDetailArr!.count)>0{
            let contactDetailPopUpObj = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContactDetailPopUp") as! ContactDetailPopUp
            DispatchQueue.main.async {
                contactDetailPopUpObj.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                UIApplication.shared.keyWindow?.rootViewController?.present(contactDetailPopUpObj, animated: false, completion: nil)
            }
        }
        else{
            
            if Helper.shared.customerPhoneNumber != nil
            {
                Helper.shared.placeCallFromController(controller: self, withPhone : Helper.shared.customerPhoneNumber!)
            }
            else
            {
                Helper.shared.showAlertOnController(message: "", title: "No contact information found.")
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.handleDesignsAsPerDevice()
        
        width_profileMessage = (self.view.frame.size.width * 0.9 * 315/375) - 37
        
    }
    
    func handleDesignsAsPerDevice()
    {
        self.manageConstraints()
        background_status.layer.borderColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0).cgColor
        background_status.layer.borderWidth = 1.0
        background_status.layer.cornerRadius = 5.0
        
        let fontSize:CGFloat = (UIDevice.current.userInterfaceIdiom == .phone) ? 15.0:21.0
        
        backgroundMessages.layer.cornerRadius = 5.0
        tblViewMessages.backgroundColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1.0)
        btnLogout.titleLabel?.font = UIFont.SFUI_SemiBold(baseScaleSize: fontSize)
        headingLabel.font = UIFont.SFUIText_Semibold(baseScaleSize: fontSize)
        
        
        
        lblStaticWelcom.font = UIFont.SFUI_Regular(baseScaleSize: fontSize)
        lblUserName.font = UIFont.SFUI_Regular(baseScaleSize: fontSize)
        lblCustomerRepName[0].font = UIFont.SFUI_Regular(baseScaleSize: fontSize)
        lblCustomerRepName[1].font = UIFont.SFUI_Regular(baseScaleSize: fontSize)
        
        lblStaticMobileOrdering.font = UIFont.SFUI_Regular(baseScaleSize: 15.0)
        lblMessageheading.font = UIFont.SFUIText_Semibold(baseScaleSize: fontSize)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - - Status Button Action
    @IBAction func btnStatusAction(_ sender: UIButton) {
        if CommonString.app_name == "Opack"{
            let contactDetailPopUpObj = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CurrentDetailsPopupVC") as! CurrentDetailsPopupVC
            DispatchQueue.main.async {
                contactDetailPopUpObj.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                contactDetailPopUpObj.dict = self.accountStatusDict as? [String:Any]
                UIApplication.shared.keyWindow?.rootViewController?.present(contactDetailPopUpObj, animated: false, completion: nil)
            }
        }
    }
    
    @IBAction func logoutAction(_ sender: Any)
    {
        
    }
    
    // MARK: - Table View Handling
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tblVwAccountStatus{
            return 6
        }
        return (arrMessages.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileMessageCellReuseID") as! ProfileMessageCell
        if tableView == self.tblVwAccountStatus{
            
            switch indexPath.row {
            case 0:
                let price = self.accountStatusDict.value(forKey: "CurrentBalance") as? Double ?? 0.0
                cell.lblDesc.text = String(format: "\(CommonString.currencyType)%@", price.withCommas())
                cell.lblMessageText.text = "Current Balance:"
                break
            case 1:
                let price = self.accountStatusDict.value(forKey: "Bal30Days") as? Double ?? 0.0
                cell.lblDesc.text = String(format: "\(CommonString.currencyType)%@", price.withCommas())
                cell.lblMessageText.text = "30+ Days:"
                break
            case 2:
                let price = self.accountStatusDict.value(forKey: "Bal60Days") as? Double ?? 0.0
                cell.lblDesc.text = String(format: "\(CommonString.currencyType)%@", price.withCommas())
                cell.lblMessageText.text = "60+ Days:"
                break
            case 3:
                let price = self.accountStatusDict.value(forKey: "Bal90Days") as? Double ?? 0.0
                cell.lblDesc.text = String(format: "\(CommonString.currencyType)%@", price.withCommas())
                cell.lblMessageText.text = "90+ Days:"
                break
            case 4:
                let price = self.accountStatusDict.value(forKey: "Bal120PlusDays") as? Double ?? 0.0
                cell.lblDesc.text = String(format: "\(CommonString.currencyType)%@", price.withCommas())
                cell.lblMessageText.text = "120+ Days:"
                break
            case 5:
                let price = self.accountStatusDict.value(forKey: "TotalBalance") as? Double ?? 0.0
                cell.lblDesc.text = String(format: "\(CommonString.currencyType)%@", price.withCommas())
                cell.lblMessageText.text = "Total Outstanding:"
                break
            default:
                break
            }
        }else{
            self.configureCell(cell: cell , forIndexPath: indexPath)
        }
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == self.tblViewMessages, (arrMessages[indexPath.row]["isRead"] as? Bool) == false
        {
            let str = arrMessages[indexPath.row]["Message"] as! String
            return str.heightOfText(withConstrainedWidth: width_profileMessage, font: UIFont.SFUI_Bold(baseScaleSize: 16.5)) + 20.0
        }else if  tableView == self.tblVwAccountStatus{
            return 40
        }
        else
        {
            return 80
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tblViewMessages{
            if let messageDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessageDetailVC") as? MessageDetailVC
            {
                messageDetail.message = (arrMessages[indexPath.row]["Message"] as? String)!
                self.navigationController?.pushViewController(messageDetail, animated: false)
            }
        }
    }
    
    
    func configureCell( cell : ProfileMessageCell , forIndexPath indexPath : IndexPath) -> Void
    {
        cell.lblMessageText.font = UIFont.SFUIText_Semibold(baseScaleSize: 16.5)
        if (arrMessages[indexPath.row]["isRead"] as? Bool) == true
        {
            cell.lblMessageText.font = UIFont.SFUI_Regular(baseScaleSize: 16.5)
            cell.lblMessageText.textColor = UIColor(red: 53.0/255.0, green: 54.0/255.0, blue: 54.0/255.0, alpha: 1.0)
        }
        else
        {
            cell.lblMessageText.font = UIFont.SFUIText_Semibold(baseScaleSize: 16.5)
            cell.lblMessageText.textColor = UIColor.baseBlueColor()
        }
        cell.lblMessageText.text = arrMessages[indexPath.row]["Message"] as? String
    }
    
    // MARK: - Profile
    
    func fetchUserProfile() -> Void
    {
        let serviceURL = SyncEngine.baseURL + SyncEngine.GetUserProfile
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: ["userID" : UserInfo.shared.userId! ,"CustomerID" : UserInfo.shared.customerID!,"IsRepUser" : UserInfo.shared.isSalesRepUser!], strURL: serviceURL, completion: {(response : Any) in
            
            if response is Array<Any> && (response as! Array<Any>).count > 0, let dic = (response as! Array<Any>)[0] as? Dictionary<String,Any>
            {
                DispatchQueue.main.async {
                    
                    if UserInfo.shared.isSalesRepUser!
                    {
                        
                        if UIDevice.current.userInterfaceIdiom == .phone{
                            
                            if let repName = dic["Salesrep"] as? String
                            {
                                self.lblUserName.text = repName.capitalized
                            }
                            if let customerName = ((dic["Firstname"] as? String)?.capitalized)
                            {
                                self.lblCustomerRepName[0].text = "Customer"
                                self.lblCustomerRepName[1].text = "\(customerName)"
                            }
                            self.btnLogout.setTitle("Logout", for: .normal)
                            self.btnLogout.titleLabel?.font =  UIFont(name: "Helvetica-Bold", size: 17)

                            
                        }else{
                            
                            if let repName = dic["Salesrep"] as? String
                            {
                                self.lblUserName.text = repName.capitalized
                            }
                            if let customerName = ((dic["Firstname"] as? String)?.capitalized)
                            {
                                self.btnLogout.setTitle(" \(customerName)", for: .normal)
                            }
                            else
                            {
                                self.btnLogout.setTitle("Select Customer", for: .normal)
                            }
                        }
                    }
                    else
                    {
                        self.lblUserName.text = (dic["Firstname"] as? String)?.capitalized
                    }
                    
                    self.lblStaticMobileOrdering.text = (dic["BusinessName"] as? String)?.capitalized
                    Helper.shared.customerPhoneNumber = dic["Phone"] as? String
                    
                    if let balance = dic["CurrentBalance"] as? Double
                    {
                        self.accountStatusDict.setValue(balance,forKey:"CurrentBalance")
                    }
                    if let balance = dic["Bal120PlusDays"] as? Double
                    {
                        self.accountStatusDict.setValue(balance,forKey:"Bal120PlusDays")
                    }
                    if let balance = dic["Bal30Days"] as? Double
                    {
                        self.accountStatusDict.setValue(balance,forKey:"Bal30Days")
                    }
                    if let balance = dic["Bal60Days"] as? Double
                    {
                        self.accountStatusDict.setValue(balance,forKey:"Bal60Days")
                    }
                    if let balance = dic["Bal90Days"] as? Double
                    {
                        self.accountStatusDict.setValue(balance,forKey:"Bal90Days")
                    }
                    if let balance = dic["TotalBalance"] as? Double
                    {
                        self.accountStatusDict.setValue(balance,forKey:"TotalBalance")
                    }
                    if let balance = dic["DaysOverdue"] as? Double
                    {
                        self.accountStatusDict.setValue(balance,forKey:"DaysOverdue")
                    }
                    if let balance = dic["Terms"] as? String
                    {
                        self.accountStatusDict.setValue(balance,forKey:"Terms")
                    }
                    
                    self.tblVwAccountStatus.reloadData()
                    
                    if let messages = dic["Messages"] as? Array<Dictionary<String,Any>>
                    {
                        self.arrMessages = messages
                    }
                    if self.arrMessages.count == 0
                    {
                        self.lblNoMessage.isHidden = false
                    }
                    else
                    {
                        self.tblViewMessages.reloadData()
                    }
                }
            }
        })
    }
}


