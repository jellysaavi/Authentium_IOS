//
//  DatePickerView.swift
//  Saavi
//
//  Created by Sukhpreet on 12/07/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit
import KDCalendar
import iOSDropDown
enum DateRidirectedFrom{
    case login
    case others
}

enum DateButtonPressed {
    case backORFinishLator
    case moveNext
}

typealias deliveryDateSelectionCompleted = (_ status: DateButtonPressed?) -> Void

class DatePickerView: UIViewController,CalendarViewDataSource,CalendarViewDelegate  {
    func calendar(_ calendar: CalendarView, didScrollToMonth date: Date) {
        
    }
    
    func calendar(_ calendar: CalendarView, didSelectDate date: Date, withEvents events: [CalendarEvent]) {
        
    }
    
    func calendar(_ calendar: CalendarView, canSelectDate date: Date) -> Bool {
        if (AppFeatures.shared.slotsByDate) {
            
            let date1 = Date()
            
            if date.dayAfter != date1.dayAfter {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM"
            
                for slot in pickupslots {
                    let slotdate = slot["DeliveryDate"] as? String
                    
                    if slotdate == dateFormatter.string(from: date) {
                        return true
                    }
                    
                }
            
            }
             
         return false
        }else{
            return true
        }
        
    }
    
    func calendar(_ calendar: CalendarView, didDeselectDate date: Date) {
        
    }
    
    func calendar(_ calendar: CalendarView, didLongPressDate date: Date, withEvents events: [CalendarEvent]?) {
        
    }
    
    func endDate() -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = 3
        let today = Date()
        let threeMonthsAgo = self.calendarView.calendar.date(byAdding: dateComponents, to: today)!
        return threeMonthsAgo
    }
    
    func headerString(_ date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        let nameOfMonth = dateFormatter.string(from: date)
        return nameOfMonth
    }
    
    @IBOutlet weak var calendarparentview: UIView!
    func startDate() -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = 0
        let today = Date()
        let threeMonthsAgo = self.calendarView.calendar.date(byAdding: dateComponents, to: today)!
        return threeMonthsAgo
    }
    
    
  
    
    
    
    static let maxMonthsAllowedForDelivery = 3
    
    @IBOutlet weak var lblStaticText: UILabel!
    @IBOutlet weak var btnFirstPreferredDate: UIButton!
    @IBOutlet weak var btnLastPreferredDate: UIButton!
    @IBOutlet weak var lblOrderCutOffTime: UILabel!
    @IBOutlet weak var imgVwTick: UIImageView!
    @IBOutlet weak var lblStaticText_orChoose: UILabel!
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblMonth: UILabel!
    
    @IBOutlet weak var ddDeliveryType: DropDown!
    @IBOutlet var recurringOrderTimeSelection: DropDown!
    @IBOutlet var suspendBgView: UIView!
    @IBOutlet var suspendBtn: UIButton!
    var isSuspended = Bool()

    
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    
    @IBOutlet weak var btnIncreaseDay: UIButton!
    @IBOutlet weak var btnDecreaseDay: UIButton!
    
    @IBOutlet weak var btnIncreaseMonth: UIButton!
    @IBOutlet weak var btnDecreaseMonth: UIButton!
    
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var confirmationView: UIView!
    
    @IBOutlet weak var calendarView: CalendarView!
    
    @IBOutlet weak var confirmationPopupDate: UILabel!
    @IBOutlet weak var confirmationPopupLabel: UILabel!
    @IBOutlet weak var btnYesConfirmation: UIButton!
    @IBOutlet weak var btnNoConfirmationPopup: UIButton!
    
    // Handle completion if needed.
    var completionBlock :deliveryDateSelectionCompleted? = nil
    
    var redirectedFrom:DateRidirectedFrom = .others
    
    var isShowingNonDeliveryAlert = false
    var arrMonths = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var arrDates = [Dictionary<String,Any>]()
    @IBOutlet weak var pickerBackgroundView: UIImageView!
    
    var selectedMonthIndex : Int = 0
    var selectedDateIndex : Int = 0
    var allowedDeliveryDays = [Int]()
    var minimumDate = Date().addingTimeInterval(24*60*60)
    var pickupslots : Array<Dictionary<String,Any>> = Array<Dictionary<String,Any>>()
    var currentYear: String = "0"
    var minimumMonthIndex = 1
    var senderView : PantryListVC?
    var switchedtoDelivery = false
    
    //MARK: - View Lifecycle -
    
    @IBAction func dropDownAction(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        ddDeliveryType.translatesAutoresizingMaskIntoConstraints = false;
        recurringOrderTimeSelection.translatesAutoresizingMaskIntoConstraints = false;

        
        // The list of array to display. Can be changed dynamically
       ddDeliveryType.optionArray = ["Delivery", "Pickup"]
        ddDeliveryType.optionIds = [0,1]
        ddDeliveryType.checkMarkEnabled = false
        ddDeliveryType.selectedRowColor = UIColor.gray
        ddDeliveryType.isSearchEnable = false
        
        
        if UserDefaults.standard.value(forKey: "RecurringOrder") as! String == "no"
        {
            recurringOrderTimeSelection.isHidden = true
            suspendBgView.isHidden = true
        }

        
        recurringOrderTimeSelection.optionArray = ["Weekly", "Fornightly", "Monthly"]
         recurringOrderTimeSelection.optionIds = [0,1,2]
         recurringOrderTimeSelection.checkMarkEnabled = false
         recurringOrderTimeSelection.selectedRowColor = UIColor.gray
         recurringOrderTimeSelection.isSearchEnable = false

        
        
//
//        ddDeliveryType.isSelected = true
        if UserInfo.shared.isDelivery {
           ddDeliveryType.placeholder = "Delivery"
            ddDeliveryType.selectedIndex = 0
        }
        else{
            ddDeliveryType.placeholder = "Pickup"
            ddDeliveryType.selectedIndex = 1
        }
//
        ddDeliveryType.didSelect{(selectedText , index ,id) in
            if index == 0 {
                UserInfo.shared.isDelivery = true
                self.getUserAddresses()
                self.switchedtoDelivery = true
            }
            else { UserInfo.shared.isDelivery = false
                self.switchedtoDelivery = false
                self.getPickupAddresses()
            }
        }
        
        if UserDefaults.standard.value(forKey: "RecurringOrder") as! String == "yes"
        {
            if (UserInfo.shared.Frequency == "Monthly")
            {
                recurringOrderTimeSelection.placeholder = "Monthly"
                recurringOrderTimeSelection.selectedIndex = 2
                UserInfo.shared.Frequency = "Monthly"
            }
            else if (UserInfo.shared.Frequency == "Weekly")
            {
                recurringOrderTimeSelection.placeholder = "Weekly"
                recurringOrderTimeSelection.selectedIndex = 0
                UserInfo.shared.Frequency = "Weekly"
            }
            else
            {
                recurringOrderTimeSelection.placeholder = "Fornightly"
                recurringOrderTimeSelection.selectedIndex = 1
                UserInfo.shared.Frequency = "Fornightly"
            }
            
            if UserInfo.shared.isSuspended == false
            {
                suspendBtn.setImage(UIImage(named: "unCheck1"), for: .normal)
                isSuspended = false
                UserInfo.shared.isSuspended = false
            }
            else
            {
                suspendBtn.setImage(UIImage(named: "check1"), for: .normal)
                isSuspended = true
                UserInfo.shared.isSuspended = true
            }
            


        }

        
        recurringOrderTimeSelection.didSelect{(selectedText , index ,id) in
            if index == 0 {
                print("Weekly")
                UserInfo.shared.Frequency = "Weekly"
            }
            else if index == 1 {
                print("Fornightly")
                UserInfo.shared.Frequency = "Fornightly"
            }
            else{
                print("Monthly")
                UserInfo.shared.Frequency = "Monthly"
            }
        }


        
//
            let myStyle = CalendarView.Style()
        // set your values
        calendarView.style = myStyle
        calendarView.style.cellSelectedBorderColor = UIColor.init(hex: "#b3eabd")
        calendarView.style.cellSelectedColor = UIColor.init(hex: "#e4e4e4")
        calendarView.style.availableColor = UIColor.init(hex: "#b3eabd")
        
        calendarView.style.cellSelectedBorderColor = UIColor.init(hex: "#b3eabd")
        calendarView.style.cellColorOutOfRange      = UIColor(red:0/255, green:30/255, blue:68/255, alpha:0.35)
        calendarView.style.cellColorToday = UIColor.init(hex: "#e4e4e4")
        calendarView.multipleSelectionEnable = false
        
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:MM:SS"
        
        
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.marksWeekends = false
        
        
        
        
         if UserInfo.shared.isDelivery {
            self.getDeliveryDates()
          }
         else{
            self.getPickUpDates()
                 
        }
        calendarView.direction = .horizontal
       
        print(AppFeatures.shared.slotsByDate)
        print(Helper.shared.slots)
        
        makeUIChanges()
        print(UserInfo.shared.isDelivery)
        self.lblOrderCutOffTime.text = CommonString.datepickerText
//        if(!(UserInfo.shared.isDelivery == true)){
//
//            let time = self.convertAndReturnPassedStringToTimeFormat(strPreviousTime: UserInfo.shared.orderCutOffTime);
//
//            let cutOffTime = self.generateDescriptionStr(withInputStr: "*Order cut-off time: ", string: time)
//
//
//
//
//
//        }else{
//            let cutOffTime = self.generateDescriptionStr(withInputStr: "*Order cut-off time: ", string: "\(UserInfo.shared.orderCutOffTime)")
//         // self.lblOrderCutOffTime.text = CommonString.datepickerText
//        }
//
//
        

        
    }
    
    @IBAction func SuspendButtonAction(_ sender: Any) {
        if isSuspended == true
        {
            suspendBtn.setImage(UIImage(named: "unCheck1"), for: .normal)
            isSuspended = false
            UserInfo.shared.isSuspended = false
        }
        else
        {
            suspendBtn.setImage(UIImage(named: "check1"), for: .normal)
            isSuspended = true
            UserInfo.shared.isSuspended = true
        }

    }
    
    
    func convertAndReturnPassedStringToTimeFormat( strPreviousTime:String) -> String {
        let dateFormatter = self.returnDateFormatter()
        let date = dateFormatter.date(from: strPreviousTime)
        return self.getNewTimeAfterAddingHours(minutesToAdd: 90, oldDate: date!)
    }
    
    func getNewTimeAfterAddingHours(minutesToAdd:NSInteger, oldDate:Date) -> String {
        let calendar = Calendar.current
        let newDate = calendar.date(byAdding: .minute, value: minutesToAdd, to: oldDate)
        return self.returnDateFormatter().string(from: newDate!)
    }
    
    func returnDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        return dateFormatter
    }
    
    
    func generateDescriptionStr(withInputStr header:String, string : String) -> NSAttributedString
    {
        let attrStr = NSMutableAttributedString()
        let headingAttrStr = NSAttributedString(string: "\(header)", attributes: [NSAttributedStringKey.font : UIFont.SFUI_Regular(baseScaleSize: 17.0), NSAttributedStringKey.foregroundColor : UIColor.baseBlueColor()])
        let textAttrStr = NSAttributedString(string: string, attributes: [NSAttributedStringKey.font : UIFont.SFUI_Regular(baseScaleSize: 17.0), NSAttributedStringKey.foregroundColor : UIColor.red])
        attrStr.append(headingAttrStr)
        attrStr.append(textAttrStr)
        return attrStr
    }
    
    func getUserAddresses()
    {
        Helper.shared.lastSetDateTimestamp = nil
        Helper.shared.selectedDeliveryDate = nil
        
        
            let dicCartItem = [
                      "CustomerID": UserInfo.shared.customerID
                  ]
                  
                  SyncEngine.sharedInstance.sendGetRequestToServer(strURL: SyncEngine.baseURL + SyncEngine.getUserAddresses) { (response : Any) in
         
            if let arrObj = response as? Array<Dictionary<String,Any>>, arrObj.count > 0
            {
                
                
                
                    self.showAddressChoosePopup(suggestedAddresses: arrObj)
                
            }
            else
            {
               
                
            }
        }
        }
    
    func showAddressChoosePopup(suggestedAddresses : Array<Dictionary<String,Any>>)
    {
        
        
        let title = UserInfo.shared.isDelivery ? "Your Delivery Address" : "Select your preferred Pick-Up location"
        let cancelButton = "CANCEL" //UserInfo.shared.isDelivery ? "ADD" : "CANCEL"
        let AddressNameKey = UserInfo.shared.isDelivery ? "Address1" : "PickupAddress"
        DispatchQueue.main.async {
            if let multipleObj = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: MultipleOptionPicker.storyboardIdentifier) as? MultipleOptionPicker
            {
                multipleObj.showMultipleOptionPickerOnWindow(forDisplayKeyName: AddressNameKey, withDataSource: suggestedAddresses, withTitle: title, withSuccessButtonTitle: "OK", withCancelButtonTitle: cancelButton, withAlertMessage: "Please choose shipping address.") { (selectedVal : Int) in
                   
                    if selectedVal >= 0  {
                    // Handle Response here.
                    if let addressID = suggestedAddresses[selectedVal]["AddressId"] as? NSNumber
                    {
                        
                        UserInfo.shared.deliveryAddress = addressID
                           self.getDeliveryDates()
                     }
                    }
//                    else if selectedVal == -44 {
//                        DispatchQueue.main.async {
//                            AddAddressVC.shared.showCommonAlertOnWindow(cartID: 0.0 ,completion: { (totalCart : Double ,  discount :Double) in
//
//                                            self.getUserAddresses()
//                                            AddAddressVC.shared.dismiss(animated: false, completion: nil)
//
//
//                                       })
//                                       }
//                    }
                    else{
                        if let addressID = suggestedAddresses[0]["AddressId"] as? NSNumber
                        {
                            UserInfo.shared.deliveryAddress = addressID
                            self.getDeliveryDates()
                         }
                    }
                }
            }
        }
    }
    
    
    
    
    func getPickupAddresses(){
        let serviceURL = SyncEngine.baseURL + SyncEngine.getPickupAddress
              SyncEngine.sharedInstance.sendGetRequestToServer(strURL: serviceURL) { (response : Any) in
                
                let arrObj1 = response as? Dictionary<String,Any>
                if  arrObj1 != nil
                {
                    if let arrObj = arrObj1!["Pickups"] as? Array<Dictionary<String,Any>> ,arrObj.count > 0
                  {
                      
                      
                          self.showPickupAddressChoosePopup(suggestedAddresses: arrObj)
                      
                  }
                  
                }
    }
    }
    
    func showPickupAddressChoosePopup(suggestedAddresses : Array<Dictionary<String,Any>>)
    {
        
        
        let title = "Select your preferred Pick-Up location"
        let cancelButton = "CANCEL"
        let AddressNameKey = "PickupAddress"
        DispatchQueue.main.async {
            if let multipleObj = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: MultipleOptionPicker.storyboardIdentifier) as? MultipleOptionPicker
            {
                multipleObj.showMultipleOptionPickerOnWindow(forDisplayKeyName: AddressNameKey, withDataSource: suggestedAddresses, withTitle: title, withSuccessButtonTitle: "OK", withCancelButtonTitle: cancelButton, withAlertMessage: "Sorry you must select one pickup address") { (selectedVal : Int) in
                   
                    if selectedVal >= 0  {
                    // Handle Response here.
                    if let addressID = suggestedAddresses[selectedVal]["ID"] as? NSNumber
                    {
                      UserInfo.shared.pickupAddress =  addressID
                        self.getPickUpDates()
                                                 }
                    }
                    else if selectedVal == -44 {
                        
                    }
                }
            }
        }
    }
    func getDeliveryDates() {
         let dicCartItem = [
            "PickupID": 0,
                   "AddressID": UserInfo.shared.deliveryAddress,
                   "IsDelivery": true
               ]
               
               SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: dicCartItem, strURL: SyncEngine.baseURL + SyncEngine.getPickupDates) { (response : Any) in
                   
                    let arrObj = response as? Dictionary<String,Any>
                    
                    let SlotsByDate = arrObj!["SlotsByDate"] as? Bool!
                   DispatchQueue.main.async {

                   
                   if (SlotsByDate!!){
                       
                       
                       
                       let dateFormatter = DateFormatter()
                       dateFormatter.dateFormat = "EEE, dd MMM"
                       self.calendarView.clearAvailable()
                                   
                       self.pickupslots = arrObj!["Slots"] as! Array<Dictionary<String,Any>>
                       let todatdate = Date();
                                  
                       if self.pickupslots.count > 0 {
                           let dateFormatter1 = DateFormatter()
                           dateFormatter1.dateFormat = "EEE, dd MMM yyyy"
                           
                           
                           for slot in self.pickupslots {
                               let slotdate = (slot["DeliveryDate"] as? String)! + " 2020"
                               let firstDate = dateFormatter1.date(from: slotdate)
                                
                               if firstDate?.dayAfter != todatdate.dayAfter
                               {
                               
                                   self.calendarView.availableDate(firstDate!)
                               }

                             }
                           
                           
                           
                       let slotdate = self.pickupslots[0]["DeliveryDate"] as? String
                       
                           let firstDate = dateFormatter.date(from: slotdate!)
                           self.calendarView.setDisplayDate(firstDate!, animated: true)
                           self.calendarView.selectDate(firstDate!)
                           self.calendarView.deselectDate(firstDate!)

                       }else{
                           let today = Date.tomorrow
                           self.calendarView.setDisplayDate(today, animated: true)
                           self.calendarView.selectDate(today)
                       }
                       
                   }else
                       {
                   let today = Date.tomorrow
                   self.calendarView.setDisplayDate(today, animated: true)
                   self.calendarView.selectDate(today)
                       }
                   }
               }
        
    }
    
    
    func getPickUpDates(){
        
        
        let dicCartItem = [
            "PickupID": UserInfo.shared.pickupAddress,
            "AddressID": 0,
            "IsDelivery": false
        ]
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: dicCartItem, strURL: SyncEngine.baseURL + SyncEngine.getPickupDates) { (response : Any) in
            
             let arrObj = response as? Dictionary<String,Any>
             
             let SlotsByDate = arrObj!["SlotsByDate"] as? Bool!
            DispatchQueue.main.async {

            
            if (SlotsByDate!!){
                
                
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEE, dd MMM"
                self.calendarView.clearAvailable()
                            
                self.pickupslots = arrObj!["Slots"] as! Array<Dictionary<String,Any>>
                let todatdate = Date();
                           
                if self.pickupslots.count > 0 {
                    let dateFormatter1 = DateFormatter()
                    dateFormatter1.dateFormat = "EEE, dd MMM yyyy"
                    
                    
                    for slot in self.pickupslots {
                        let slotdate = (slot["DeliveryDate"] as? String)! + " 2020"
                        let firstDate = dateFormatter1.date(from: slotdate)
                         
                        if firstDate?.dayAfter != todatdate.dayAfter
                        {
                        
                            self.calendarView.availableDate(firstDate!)
                        }

                      }
                    
                    
                    
                let slotdate = self.pickupslots[0]["DeliveryDate"] as? String
                
                    let firstDate = dateFormatter.date(from: slotdate!)
                    self.calendarView.setDisplayDate(firstDate!, animated: true)
                    self.calendarView.selectDate(firstDate!)
                    self.calendarView.deselectDate(firstDate!)

                }else{
                    let today = Date.tomorrow
                    self.calendarView.setDisplayDate(today, animated: true)
                    self.calendarView.selectDate(today)
                }
                
            }else
                {
            let today = Date.tomorrow
            self.calendarView.setDisplayDate(today, animated: true)
            self.calendarView.selectDate(today)
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        let btnCallTitle = self.redirectedFrom == .login ? "FINISH LATER":"BACK"
        self.btnCall.setTitle(btnCallTitle, for: .normal)
            
        //self.refreshSuggestedDates()
       // self.getAllPossibleDaysForDelivery()
      //  self.generateAllowedDatesDictionary()
        //self.setDate()
    }
    
    @IBAction func dismisOnTap(_ sender: UITapGestureRecognizer) {
       
        if self.redirectedFrom != .login{
            self.view.endEditing(true)
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func refreshSuggestedDates()
    {
        
        if Helper.shared.nextOrderDates != nil && (Helper.shared.nextOrderDates?.count)! > 0
        {
            self.btnFirstPreferredDate.isHidden = false
            self.btnFirstPreferredDate.setTitle(" \(Helper.shared.nextOrderDates![0])", for: .normal)
            
            let df = DateFormatter()
            df.dateFormat = "yyyy"
            let year = df.string(from: Date())
            
            let strDate = Helper.shared.nextOrderDates![0] + " \(year)"
            df.dateFormat = "EEE, dd MMM yyyy"
            if let date = df.date(from: strDate)
            {
                minimumDate = date
            }
        }
        
        if Helper.shared.nextOrderDates != nil && (Helper.shared.nextOrderDates?.count)! > 1
        {
            self.btnLastPreferredDate.isHidden = false

            self.btnLastPreferredDate.setTitle(" \(Helper.shared.nextOrderDates![1])", for: .normal)
        }
       
        self.btnFirstPreferredDate.isHidden = true
        self.btnLastPreferredDate.isHidden = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //    MARK:- Button Actions -
    
    
    @IBAction func continueBtnAction(_ sender: Any)
    {
        print(self.calendarView.selectedDates)
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let currentSelectedDay = (dateFormatter.string(from: Helper.shared.selectedDeliveryDate!)).lowercased()
        if ((UserInfo.shared.isSalesRepUser == true && AppFeatures.shared.isAdvancedPantry == false) || UserInfo.shared.isSalesRepUser == false)  && !self.isShowingNonDeliveryAlert && AppFeatures.shared.isNonDeliveryDayOrdering == true && (Helper.shared.allowedWeekdaysForDelivery != nil) && !((Helper.shared.allowedWeekdaysForDelivery?.contains(currentSelectedDay))! || (Helper.shared.allowedWeekdaysForDelivery?.contains(currentSelectedDay.capitalized))!)
        {
            self.confirmationPopupDate.text = "Confirm"
            self.confirmationPopupLabel.text = CommonString.nonDeliveryPopUpString
            isShowingNonDeliveryAlert = true
        }
        else
        {
            if self.isShowingNonDeliveryAlert
            {
                Helper.shared.isOrderingOnNonDeliveryDay = true
            }
            Helper.shared.lastSetDateTimestamp = Date()
            
            if self.switchedtoDelivery {
            
            DispatchQueue.main.async {
                       if let receiveOrderPopup = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReceiveOrderPopupVC") as? ReceiveOrderPopupVC
                       {
                           receiveOrderPopup.modalPresentationStyle = .overCurrentContext
                           self.present(receiveOrderPopup, animated: false, completion: nil)
                           receiveOrderPopup.completionBlock = { (buttonPressed, deliveyType) -> Void in
                               
                               if buttonPressed == .moveNext {
                                   
                                   if deliveyType == DeliveryType.pickUp {
                                       SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "Yes", withMessage: "Are you sure you want to pickup?", withCancelButtonTitle: "No") {
                                           
                                           UserInfo.shared.isDelivery = deliveyType == DeliveryType.pickUp ? false : true
                                           self.dismiss(animated: false, completion: {
                                               if self.completionBlock != nil
                                               {
                                                  self.completionBlock!(.moveNext)
                                               }
                                           })
                                       }
                                   }else{
                                   
                                   UserInfo.shared.isDelivery = deliveyType == DeliveryType.pickUp ? false : true
                                  self.dismiss(animated: false, completion: {
                                       if self.completionBlock != nil
                                       {
                                          self.completionBlock!(.moveNext)
                                       }
                                   })
                              
                                   }
                               
                               }
                           }
                       }
                       
                   }
            }
            else{
            self.dismiss(animated: false, completion: {
                if self.completionBlock != nil
                {
                   self.completionBlock!(.moveNext)
                }
            })
            
            }
            
            
            
        }
    }
    
    @IBAction func continueDateSelection(_ sender: Any)
    {
        var selection: [Date] = self.calendarView!.selectedDates
        if selection != nil && selection.count > 0
        {
        isShowingNonDeliveryAlert = false
        Helper.shared.isOrderingOnNonDeliveryDay = false
            if UserInfo.shared.isDelivery {
            self.confirmationPopupLabel.text = "Is the selected delivery date correct?"
            }
            else {
                self.confirmationPopupLabel.text = "Is the selected pickup date correct?"
                
            }
        let df = DateFormatter()
        df.dateFormat = "EEEE,dd MMMM yyyy"
        let dateformat = DateFormatter()
        dateformat.dateFormat = "EEEE,dd/MMM/yyyy"
            
            df.dateFormat = "EEEE, dd MMMM"
            confirmationPopupDate.text = df.string(from: selection[0])
            Helper.shared.selectedDeliveryDate = selection[0]
            dateformat.dateFormat = "EEEE"
            let day = dateformat.string(from: selection[0])
            Helper.shared.customerAppendDic_List["dayOfDelivery"] = day
        
        
//        if let strDate = (self.arrDates[selectedMonthIndex]["dates"] as? Array<String>)?[selectedDateIndex]
//        {
//            if let strMonth = self.arrDates[selectedMonthIndex]["month"] as? String, let strYear = self.arrDates[selectedMonthIndex]["year"] as? String
//            {
//                let finalDateStr = "\(strDate) \(strMonth) \(strYear)"
//                if let date = df.date(from: finalDateStr)
//                {
//                    df.dateFormat = "EEEE, dd MMMM"
//                    confirmationPopupDate.text = df.string(from: selection[0])
//                    Helper.shared.selectedDeliveryDate = date
//                    dateformat.dateFormat = "EEEE"
//                    let day = dateformat.string(from: date)
//                    Helper.shared.customerAppendDic_List["dayOfDelivery"] = day
//                }
//                if let deliveryDate = dateformat.date(from: finalDateStr)
//                {
//                    if let customerCell = self.senderView?.clctn_CustomerDetail.cellForItem(at: IndexPath(item: 2, section:0)) as? CustomerDetailCell
//                    {
//                        dateformat.dateFormat = "dd/MM/yyyy"
//                        let dateOfDelvery = dateformat.string(from: selection[0])
//                        customerCell.txtFld_CustomerName.text = dateOfDelvery
//                        Helper.shared.customerAppendDic_List["dateOfDelivery"] = customerCell.txtFld_CustomerName.text
//                    }
//                    if let customerCell = self.senderView?.clctn_CustomerDetail.cellForItem(at: IndexPath(item: 3, section:0)) as? CustomerDetailCell
//                    {
//                        dateformat.dateFormat = "EEEE"
//                        let day = dateformat.string(from: selection[0])
//                        customerCell.txtFld_CustomerName.text = day
//                        Helper.shared.customerAppendDic_List["dayOfDelivery"] = customerCell.txtFld_CustomerName.text
//                    }
//                }
//            }
        
        
        pickerView.isHidden = true
        calendarparentview.isHidden = true
        confirmationView.isHidden = false
            
        }
        else {
             if UserInfo.shared.isDelivery {
                Helper.shared.showAlertOnController( message: "Please select delivery date", title: CommonString.alertTitle)
              }
             else{
                Helper.shared.showAlertOnController( message: "Please select pickup date", title: CommonString.alertTitle)
            }

        }
    }
    
    @IBAction func cancelDateSelectionAction(_ sender: Any)
    {
        confirmationView.isHidden = true
        pickerView.isHidden = false
        calendarparentview.isHidden = false
        
    }
    
    
    @IBAction func callBtnAction(_ sender: Any)
    {
        self.dismiss(animated: false) {
            self.completionBlock!(.backORFinishLator)
        }
//        if self.redirectedFrom == .login{
//            self.completionBlock!(.backORFinishLator)
//        }else{
//            if Helper.shared.customerPhoneNumber != nil
//            {
//                Helper.shared.placeCallFromController(controller: self, withPhone: Helper.shared.customerPhoneNumber!)
//            }
//            else
//            {
//                Helper.shared.showAlertOnController( message: "Cannot place call because number is not available.", title: CommonString.alertTitle)
//            }
//        }
    }
    
    override func viewDidLayoutSubviews() {
        self.adjustFontSize()
        
    }
    
    func adjustFontSize() -> Void {
        
        lblStaticText.font = UIFont.SFUI_SemiBold(baseScaleSize: 20.0)
        confirmationPopupDate.font = UIFont.SFUI_SemiBold(baseScaleSize: 20.0)
        confirmationPopupLabel.font = UIFont.SFUI_Regular(baseScaleSize: 19.0)
        
        
        btnFirstPreferredDate.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 17.0)
        btnLastPreferredDate.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 17.0)
        lblStaticText_orChoose.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
        
        lblDate.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
        lblMonth.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
        
        btnCall.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
        btnContinue.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
        
        btnYesConfirmation.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
        btnNoConfirmationPopup.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
        
        
        btnIncreaseDay.titleLabel?.font = UIFont.Roboto_Bold(baseScaleSize: 30.0)
        btnIncreaseMonth.titleLabel?.font = UIFont.Roboto_Bold(baseScaleSize: 30.0)
        
        btnDecreaseDay.titleLabel?.font = UIFont.Roboto_Bold(baseScaleSize: 30.0)
        btnDecreaseMonth.titleLabel?.font = UIFont.Roboto_Bold(baseScaleSize: 30.0)
        
        pickerView.layer.cornerRadius = 10.0 * Configration.scalingFactor()
        confirmationPopupDate.layer.cornerRadius = 7.0 * Configration.scalingFactor()
    }
    
    //    MARK:- Date Generation
    
    func getAllPossibleDaysForDelivery() -> Void
    {
        allowedDeliveryDays.removeAll()
        if AppFeatures.shared.isNonDeliveryDayOrdering == true
        {
            allowedDeliveryDays = [2,3,4,5,6,7]
            if AppFeatures.shared.isSundayOrderingEnabled{
                allowedDeliveryDays.append(1)
            }
        }else{
            if (Helper.shared.allowedWeekdaysForDelivery != nil) && (Helper.shared.allowedWeekdaysForDelivery?.count)! > 0
            {
                for i in 0...(Helper.shared.allowedWeekdaysForDelivery!.count - 1)
                {
                    switch Helper.shared.allowedWeekdaysForDelivery![i].lowercased()
                    {
                    case "sunday":
                        allowedDeliveryDays.append(1)
                    case "monday":
                        allowedDeliveryDays.append(2)
                    case "tuesday":
                        allowedDeliveryDays.append(3)
                    case "wednesday":
                        allowedDeliveryDays.append(4)
                    case "thursday":
                        allowedDeliveryDays.append(5)
                    case "friday":
                        allowedDeliveryDays.append(6)
                    case "saturday":
                        allowedDeliveryDays.append(7)
                    default:
                        print("Something went wrong. Unexpected Values.")
                    }
                }
            }
            else
            {
                allowedDeliveryDays = [2,3,4,5,6,7]
                if AppFeatures.shared.isSundayOrderingEnabled
                {
                    allowedDeliveryDays.append(1)
                }
            }
        }
    }
    
    func generateAllowedDatesDictionary() -> Void
    {
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "MMMM"
        
        let currentMonth = df.string(from: date)
        df.dateFormat = "yyyy"
        let currentYear = df.string(from: date)
        self.currentYear = currentYear
        self.generateDeliveryDatesForMonths(month: currentMonth, year: currentYear)
    }
    
    func generateDeliveryDatesForMonths(month : String, year : String)
    {
        let df = DateFormatter()
        df.dateFormat = "dd MMMM yyyy"
        var dateStr = "01 " + month + " \(year)"
        var date = df.date(from: dateStr)
        let currentMonthIndex = Calendar.current.component(Calendar.Component.month, from: date!)
        
        for i in currentMonthIndex...(currentMonthIndex+DatePickerView.maxMonthsAllowedForDelivery)
        {
            var monthIndex = i
            var currentYear = year
            if i > 12
            {
                monthIndex = i - 12
                currentYear = String(Int(year)! + 1)
            }
            
            dateStr = "01 " + arrMonths[monthIndex - 1] + " \(currentYear)"
            date = df.date(from: dateStr)
            
            let numberOfDays = Calendar.current.range(of: Calendar.Component.day, in: Calendar.Component.month, for: date!)
            print(numberOfDays!.count)
            
            var possibleDates = [] as Array<String>
            for i in 1...numberOfDays!.count
            {
                var strDate : String?
                if i < 10{
                    strDate = "0\(i)"
                }else{
                    strDate =  "\(i)"
                }
                let dateStr = strDate! + " " + arrMonths[monthIndex - 1] + " \(currentYear)"
                let date = df.date(from: dateStr)
                
                if date?.compare(minimumDate) == .orderedDescending || date?.compare(minimumDate) == .orderedSame
                {
                    let cal = Calendar(identifier: .gregorian)
                    let dateComponent = (cal.component(Calendar.Component.weekday, from: date!))
                    if (allowedDeliveryDays.contains(dateComponent)){
                        let df = DateFormatter()
                        df.dateFormat = "EEEE, dd"
                        // Future Delivery Date
                        if AppFeatures.shared.isShowFutureDate == true && UserInfo.shared.isSalesRepUser == false
                        {
                            if ((date?.compare(minimumDate.addingTimeInterval(7*24*60*60)))! == .orderedAscending)
                            {
                                possibleDates.append(df.string(from: date!))
                            }
                        }else{
                            possibleDates.append(df.string(from: date!))
                        }
                    }
                }
            }
            
            if possibleDates.count > 0
            {
                arrDates.append(["month" : arrMonths[monthIndex - 1], "year" : currentYear, "dates" : possibleDates])
            }
        }
        if UserInfo.shared.isSalesRepUser == true
        {
            self.generateCheckboxDates()
        }
    }
    
    func generateCheckboxDates()
    {
        var tempDates = Array<String>()
        if Helper.shared.nextOrderDates == nil
        {
            let df = DateFormatter()
            df.dateFormat = "EEE, dd MMM"
            var monthIndex = 0
            var dateIndex = 0
            repeat
            {
                if monthIndex < arrDates.count
                {
                    if dateIndex < (((arrDates[monthIndex]["dates"]) as? Array<String>)?.count)!
                    {
                        let dfIn = DateFormatter()
                        dfIn.dateFormat = "EEEE, dd MMM yyyyy"
                        let dateStr = (arrDates[monthIndex]["dates"] as! Array<String>)[dateIndex] + " \(arrDates[monthIndex]["month"]!)" + " \(arrDates[monthIndex]["year"]!)"
                        if let date = dfIn.date(from: dateStr)
                        {
                            tempDates.append(df.string(from: date))
                        }
                        dateIndex += 1
                    }
                    else
                    {
                        monthIndex += 1
                        dateIndex = 0
                    }
                }
            }
                while(tempDates.count <= 2 && monthIndex < arrDates.count)
            Helper.shared.nextOrderDates = tempDates
            refreshSuggestedDates()
        }
    }
    
    //    MARK:- Calendar Actions
    
    @IBAction func goToNextMonth(_ sender: Any)
    {
        selectedDateIndex = 0
        if selectedMonthIndex + 1 == arrDates.count
        {
            selectedMonthIndex = 0
        }
        else
        {
            selectedMonthIndex += 1
        }
        self.setDate()
    }
    
    @IBAction func goToPreviousMonth(_ sender: Any)
    {
        selectedDateIndex = 0
        if selectedMonthIndex - 1 == -1
        {
            selectedMonthIndex = arrDates.count - 1
        }
        else
        {
            selectedMonthIndex -= 1
        }
        self.setDate()
    }
    
    @IBAction func goToNextDate(_ sender : Any)
    {
        if let dates = arrDates[selectedMonthIndex]["dates"] as? Array<String>
        {
            if selectedDateIndex + 1 == dates.count
            {
                selectedDateIndex = 0
            }
            else
            {
                selectedDateIndex += 1
            }
            self.setDate()
        }
    }
    
    @IBAction func goToPreviousDate(_ sender : Any)
    {
        if let dates = arrDates[selectedMonthIndex]["dates"] as? Array<String>
        {
            if selectedDateIndex - 1 == -1
            {
                selectedDateIndex = dates.count - 1
            }
            else
            {
                selectedDateIndex -= 1
            }
            self.setDate()
        }
    }
    
    func setDate()
    {
        self.lblDate.text = (arrDates[selectedMonthIndex]["dates"] as? Array<String>)?[selectedDateIndex]
        self.lblMonth.text = arrDates[selectedMonthIndex]["month"] as? String
        let dateStr = self.lblDate.text! + " \(self.lblMonth.text!)" +  " \(currentYear)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMMM yyyy"
        if let date = dateFormatter.date(from: dateStr)
        {
            dateFormatter.dateFormat = " EEE, dd MMM"
            let comparisonStr = dateFormatter.string(from: date)
            
            if self.btnFirstPreferredDate.titleLabel?.text == comparisonStr
            {
                self.btnFirstPreferredDate.isSelected = true
                self.btnLastPreferredDate.isSelected = false
                
            }
            else if self.btnLastPreferredDate.titleLabel?.text == comparisonStr
            {
                self.btnFirstPreferredDate.isSelected = false
                self.btnLastPreferredDate.isSelected = true
            }
            else
            {
                btnFirstPreferredDate.isSelected = false
                btnLastPreferredDate.isSelected = false
            }
        }
    }
    
    @IBAction func dateSelectedAction(_ sender: Any)
    {
        (sender as! UIButton).isSelected = true
        let df = DateFormatter()
        df.dateFormat = "yyyy"
        let year = df.string(from: Date())
        df.dateFormat = " EEE, dd MMM yyyy"
        if let date = df.date(from: ((sender as! UIButton).titleLabel?.text)! + " \(year)")
        {
            df.dateFormat = "MMMM"
            self.lblMonth.text = df.string(from: date)
            
            df.dateFormat = "EEEE, dd"
            self.lblDate.text = df.string(from: date)
        }
        
        if (sender as! UIButton) == btnFirstPreferredDate
        {
            btnLastPreferredDate.isSelected = false
        }
        else
        {
            btnFirstPreferredDate.isSelected = false
        }
        
        
        if let dateIndex = (arrDates[0]["dates"] as? Array<String>)?.index(of: lblDate.text!)
        {
            self.selectedMonthIndex = 0
            self.selectedDateIndex = dateIndex
        }
        else if let dateIndex = (arrDates[1]["dates"] as? Array<String>)?.index(of: lblDate.text!)
        {
            self.selectedMonthIndex = 1
            self.selectedDateIndex = dateIndex
        }
        else
        {
            (sender as! UIButton).isSelected = false
            self.selectedDateIndex = 0
            //            Helper.shared.showAlertOnController( message: "Date already passed.", title: CommonString.alertTitle)
        }
    }
    
    //    MARK:- User interface
    func  makeUIChanges(){
        
       
        
        self.btnCall.backgroundColor = UIColor.primaryColor()
        self.btnContinue.backgroundColor = UIColor.primaryColor2()
        self.btnYesConfirmation.backgroundColor = UIColor.primaryColor2()
        self.btnNoConfirmationPopup.backgroundColor = UIColor.primaryColor()
        
        imgVwTick.image = #imageLiteral(resourceName: "check_White").withRenderingMode(.alwaysTemplate)
        imgVwTick.tintColor = UIColor.baseBlueColor()
        confirmationPopupDate.textColor = UIColor.baseBlueColor()
        lblStaticText.textColor = UIColor.baseBlueColor()
        lblStaticText_orChoose.textColor = UIColor.baseBlueColor()
        btnIncreaseDay.setTitleColor(UIColor.baseBlueColor(), for: .normal)
        btnIncreaseMonth.setTitleColor(UIColor.baseBlueColor(), for: .normal)
        btnDecreaseDay.setTitleColor(UIColor.baseBlueColor(), for: .normal)
        btnDecreaseMonth.setTitleColor(UIColor.baseBlueColor(), for: .normal)
        lblDate.textColor = UIColor.baseBlueColor()
        lblMonth.textColor = UIColor.baseBlueColor()
//        btnCall.setTitleColor(UIColor.baseBlueColor(), for: .normal)
//        btnContinue.setTitleColor(UIColor.baseBlueColor(), for: .normal)
        btnFirstPreferredDate.setTitleColor(UIColor.baseBlueColor(), for: .normal)
        btnLastPreferredDate.setTitleColor(UIColor.baseBlueColor(), for: .normal)
//        btnYesConfirmation.setTitleColor(UIColor.baseBlueColor(), for: .normal)
//        btnNoConfirmationPopup.setTitleColor(UIColor.baseBlueColor(), for: .normal)
        btnFirstPreferredDate.tintColor = UIColor.baseBlueColor()
        btnLastPreferredDate.tintColor = UIColor.baseBlueColor()
    }
    
    
}
extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}
