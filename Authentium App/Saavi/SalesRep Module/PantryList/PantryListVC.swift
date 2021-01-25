//
//  PantryListVC.swift
//  SalesRepDemo
//
//  Created by Irmeen Sheikh on 09/02/18.
//  Copyright © 2018 Irmeen Sheikh. All rights reserved.
//

import UIKit

class PantryListVC: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UITextFieldDelegate,UIGestureRecognizerDelegate{
    
    @IBOutlet weak var clctn_CustomerDetail: UICollectionView!
    @IBOutlet weak var lblMargin: UILabel!
    @IBOutlet weak var lblMarginvalue: UILabel!
    @IBOutlet weak var clctn_SerachItems: UICollectionView!
    @IBOutlet weak var clctn_PantryList: UICollectionView!
    @IBOutlet weak var clctn_Features: UICollectionView!
    @IBOutlet weak var clctn_ItemType: UICollectionView!
    @IBOutlet weak var btn_HideDetails: UIButton!
    @IBOutlet weak var HideDetail: NSLayoutConstraint!
    @IBOutlet weak var lbl_topItemClctn: UILabel!
    @IBOutlet weak var lbl_PantryListName: UILabel!
    @IBOutlet weak var lbl_bottomItemClctn: UILabel!
    @IBOutlet var filtersClctnHeightConstant: NSLayoutConstraint!
    @IBOutlet var borderLineHeightConstant: NSLayoutConstraint!
    @IBOutlet var borderTopConstant: NSLayoutConstraint!
    @IBOutlet weak var pantryListHeaderView: UIView!
    @IBOutlet weak var country_world_wide_lbl: UILabel!
    @IBOutlet weak var lbl_SwipeToClose: UILabel!
    @IBOutlet weak var hideDetailBtnHeightConstant: VerticalSpacingConstraints!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchClctnHeightConstant: VerticalSpacingConstraints!
    @IBOutlet weak var swipe_to_closeImage: UIImageView!
    
    var customerDetailArr = [["Key":"Customer"],["Key":"Account No."],["Key":"Delivery Date"],["Key":"Delivery Day"],["Key":"Run No."],["Key":"Packing SEQ"],["Key":"External DOC"],["Key":"Order Value"]]
    var featuresArr = [["Feature":"Comment Line" ,"Image":"commentLine"],["Feature":"Price Info","Image":"priceInfo"],["Feature":"Item Availability","Image":"itemAvl"],["Feature":"Shipping","Image":"shipping"],["Feature":"Customer Info","Image":"customerInfo"],["Feature":"Delete Order","Image":"deleteOrder"],["Feature":"Release Order","Image":"releaseOrder"],["Feature":"Order Margin","Image":"orderMargin"]]
    var buttonsArr = [["Button":"HIDE GROUPS"],["Button":"PANTRY LIST"],["Button":"ORDER HISTORY"]]
    var pantryArr = [["Pantry":"Code"],["Pantry":"Description"],["Pantry":"Order QTY"],["Pantry":"Order UOM"],["Pantry":"SOH"],["Pantry":"N/P"],["Pantry":"Unit Price"],["Pantry":"Amount"],["Pantry":"GST"]]
    var searchItemArr = ["Selected Pantry List", "Search in Pantry List"]
    
    @IBOutlet weak var filterClctnWidthConstant: NSLayoutConstraint!
    var arrFilters = Array<Dictionary<String,Any>>()
    var arrPantryList = Array<Dictionary<String,Any>>()
    var productList = Array<Dictionary<String,Any>>()
    var allPantryItems = Array<Dictionary<String,Any>>()
    var selectedDicForInfo = Dictionary<String,Any>()
    var customerListDic = Dictionary<String,Any>()
    var getRepCustomerDic_list = Dictionary<String,Any>()
    var runNumberList = Array<Any>()
    //var customerID = NSNumber()
    var isHideDetail:Bool = false
    var isHideGroups:Bool = false
    var pantryListId = NSNumber()
    var pantryListIndex = Int()
    var isFirstTime :Bool = true
    var totalResults : NSNumber? = 0
    var allResults : NSNumber?
    var pageNumber : Int = 1
    var categoryId : NSNumber?
    var filterID : NSNumber = 0
    var isSearchingProduct : Bool = false
    var selectedIndexPath: IndexPath?
    var index : Int? = -1
    var selectFeatureIndex : IndexPath?
    var selectedFilter : Int? = 0
    var countLbl = UILabel()
    var activeTxtFld = UITextField()
    var activeTxtFldQty = UITextField()
    var longPressGesture : UILongPressGestureRecognizer?
    var isCountry_wide: Bool?
    var pantryListName = String()
    var isGlobalSearch : Bool = false
    var popTxtField = UITextField()
    var activeSearchTxtFld = UITextField()
    var btnClearSearch = UIButton()
    var tempCartId = NSNumber()
    var isAddingItemToPantrylist : Bool = false
    var clearOrder = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if customerListDic.keyExists(key: "ExistingCartID"){
            self.tempCartId = customerListDic["ExistingCartID"]  as! NSNumber
            Helper.shared.salesRepTempCartId = customerListDic["ExistingCartID"]  as! NSNumber
        }
        self.bgViewColor()
        self.getAllProductFilters()
        
        if (getRepCustomerDic_list ).keyExists(key: "CountryWide"), let CountryWide = (getRepCustomerDic_list )["CountryWide"] as? Bool
        {
            if CountryWide == true
            {
                country_world_wide_lbl.text = CommonString.countrywideString
                country_world_wide_lbl.isHidden = false
                country_world_wide_lbl.font = UIFont.Roboto_Medium(baseScaleSize: 15.0)
                country_world_wide_lbl.textColor = UIColor.init(hex: "#b0cf00")
            }
            else{
                country_world_wide_lbl.text = ""
            }
        }
        
        if (getRepCustomerDic_list).keyExists(key: "DefaultDeliveryDate"), let defaultDeliveryDay = (getRepCustomerDic_list)["DefaultDeliveryDate"] as? String
        {
            let df = DateFormatter()
            df.dateFormat = "dd/MM/yyyy"
            if let deliveryDay = df.date(from: defaultDeliveryDay)
            {
                
                Helper.shared.selectedDeliveryDate = deliveryDay
                Helper.shared.lastSetDateTimestamp = Date()
                self.setPackingSequence()
            }
        }
        
        self.longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        clctn_PantryList.addGestureRecognizer(longPressGesture!)
        
        swipe_to_closeImage.isUserInteractionEnabled = true
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.swipe_to_closeImage.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(gesture:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.swipe_to_closeImage.addGestureRecognizer(swipeLeft)
        self.lblMargin.textColor = UIColor.baseBlueColor()
        
        if AppFeatures.shared.isShowOrderMargin{
            self.lblMarginvalue.isHidden = false
            self.lblMargin.isHidden = false
        }else{
            self.lblMarginvalue.isHidden = true
            self.lblMargin.isHidden = true
        }
    }
    
    @objc func respondToSwipeGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == UISwipeGestureRecognizerDirection.left {
            for i in 0..<featuresArr.count{
                let cell = self.clctn_Features.cellForItem(at: IndexPath(item: i, section:0)) as? FeatureCell
                cell?.featureLblWidthConstant.constant = 0.0
                cell?.lbl_Feature.text = ""
            }
            DispatchQueue.main.async {
                self.clctn_Features.reloadData()
                self.clctn_PantryList.reloadData()
            }
            filterClctnWidthConstant.constant = 55.0
            lbl_SwipeToClose.text = ""
        }else if gesture.direction == UISwipeGestureRecognizerDirection.right {
            for i in 0..<featuresArr.count{
                let cell = self.clctn_Features.cellForItem(at: IndexPath(item: i, section:0)) as? FeatureCell
                cell?.featureLblWidthConstant.constant = 30.0
                cell?.lbl_Feature.text = self.featuresArr[i]["Feature"]
            }
            DispatchQueue.main.async {
                self.clctn_Features.reloadData()
                self.clctn_PantryList.reloadData()
            }
            filterClctnWidthConstant.constant = 120.0
            lbl_SwipeToClose.text = ""
            print("Swipe right")
        }
    }
    
    func bgViewColor()
    {
        self.view.backgroundColor = UIColor.bgViewColor()
        self.clctn_SerachItems.backgroundColor = UIColor.bgViewColor()
        self.clctn_ItemType.backgroundColor = UIColor.bgViewColor()
        self.clctn_Features.backgroundColor = UIColor.bgViewColor()
        self.clctn_PantryList.backgroundColor = UIColor.bgViewColor()
        self.clctn_CustomerDetail.backgroundColor = UIColor.lightGreyColor()
        self.btn_HideDetails.layer.borderWidth = 0.7 * Configration.scalingFactor()
        self.btn_HideDetails.layer.borderColor = UIColor.baseBlueColor().cgColor
        self.btn_HideDetails.titleLabel?.font = UIFont.Roboto_Medium(baseScaleSize: 12.0)
        self.btn_HideDetails.setTitleColor(UIColor.baseBlueColor(), for: .normal)
        self.pantryListHeaderView.backgroundColor = UIColor.baseBlueColor()
        self.lbl_topItemClctn.backgroundColor = UIColor.baseBlueColor()
        self.lbl_bottomItemClctn.backgroundColor = UIColor.baseBlueColor()
        self.swipe_to_closeImage.tintColor = UIColor.baseBlueColor()
        
        for view in pantryListHeaderView.subviews
        {
            if let label =  view as? UILabel
            {
                label.font = UIFont.Roboto_Regular(baseScaleSize: 14.0)
                label.textColor = UIColor.white
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if (self.navigationItem.titleView as? UISearchBar) == nil
        {
            self.index = -1
            self.getRepCustomerPantryLists()
            self.callAPIToUpdateCartNumber()
            self.setDefaultNavigation()
            isSearchingProduct = false
        }
        self.getCartItems(isReload: false)
        self.clctn_SerachItems.reloadData()
    }
    
    
    @IBAction func HideDetail_Action(_ sender: Any) {
        if isHideDetail == false{
            HideDetail.constant = 0.0
            isHideDetail = true
            btn_HideDetails.setTitle(CommonString.showDetailBtnTitle, for: .normal)
            btn_HideDetails.sizeToFit()
            btn_HideDetails.setTitleColor(UIColor.white, for: .normal)
            btn_HideDetails.backgroundColor = UIColor.baseBlueColor()
        }
        else{
            HideDetail.constant = 90.0
            isHideDetail = false
            btn_HideDetails.setTitle(CommonString.hideDetailBtnTitle, for: .normal)
            btn_HideDetails.setTitleColor(UIColor.baseBlueColor(), for: .normal)
            btn_HideDetails.backgroundColor = UIColor.clear
        }
        
        self.clctn_Features.reloadData()
    }
    
    //MARK: - - Set Packing Sequence
    private func setPackingSequence(){
        
        let date = Helper.shared.selectedDeliveryDate
        let day = date!.dayOfWeek()
        let daysDict = customerListDic["PackingSeq"] as? [String:Any]
        if Helper.shared.customerAppendDic_List["packingSEQ"] == nil{
            Helper.shared.customerAppendDic_List["packingSEQ"] = "0"
        }
        //let runNoDict = customerListDic["RunNo"] as? [String:Any]
        Helper.shared.customerAppendDic_List["dayOfDelivery"] = day
        //Helper.shared.customerAppendDic_List["RunNo"] = (runNoDict![day!] as? String) ?? ""
        //Helper.shared.customerAppendDic_List["packingSEQ"] = (daysDict![day!] as? String) ?? "0"
        self.clctn_CustomerDetail.reloadData()
    }
    
    //MARK:- CollectionView delegate and datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView == clctn_CustomerDetail
        {
            return customerDetailArr.count
        }
        else if collectionView == clctn_SerachItems
        {
            //           if isGlobalSearch == true{
            //            return buttonsArr.count
            //            }
            //           else{
            return max(5,searchItemArr.count)
            //}
        }
            
        else if collectionView == clctn_Features{
            return featuresArr.count
        }
        else if collectionView == clctn_ItemType{
            return arrFilters.count
        }
        else {
            return productList.count
        }
        //        else{
        //            return 0
        //        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView == clctn_CustomerDetail
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomerDetailCell", for: indexPath) as! CustomerDetailCell
            cell.lbl_Customer.text = customerDetailArr[indexPath.item]["Key"]
            cell.txtFld_CustomerName.isUserInteractionEnabled = true
            cell.txtFld_CustomerName.rightView = nil
            if customerListDic.count>0
            {
                if indexPath.row == 0
                {
                    if customerListDic.keyExists(key: "CustomerName"), let customerName = customerListDic["CustomerName"] as? String{
                        cell.txtFld_CustomerName.text = customerName
                        cell.txtFld_CustomerName.isUserInteractionEnabled = false
                        if cell.txtFld_CustomerName.text != nil
                        {
                            Helper.shared.customerAppendDic_List["CustomerName"] = cell.txtFld_CustomerName.text
                        }
                    }
                }
                else if indexPath.row == 1
                {
                    if customerListDic.keyExists(key: "AlphaCode"), let accountNo = customerListDic["AlphaCode"] as? String{
                        cell.txtFld_CustomerName.text = accountNo
                        if cell.txtFld_CustomerName.text != nil
                        {
                            Helper.shared.customerAppendDic_List["AlphaCode"] = cell.txtFld_CustomerName.text
                        }
                        cell.txtFld_CustomerName.isUserInteractionEnabled = false
                    }
                }
                else if indexPath.row == 2
                {
                    Helper.shared.setRightViewMode(textField:cell.txtFld_CustomerName, imageSelected: "tFDropDown", amount: 20)
                    if (getRepCustomerDic_list).keyExists(key: "DefaultDeliveryDate"), let defaultDeliveryDate = (getRepCustomerDic_list)["DefaultDeliveryDate"] as? String
                    {
                        if Helper.shared.customerAppendDic_List.keyExists(key: "dateOfDelivery"), let dateOfDelivery = Helper.shared.customerAppendDic_List["dateOfDelivery"] as? String{
                            
                            cell.txtFld_CustomerName.text = dateOfDelivery
                        }
                        else{
                            
                            cell.txtFld_CustomerName.text = defaultDeliveryDate
                            Helper.shared.customerAppendDic_List["dateOfDelivery"] = defaultDeliveryDate
                        }
                        
                    }
                }
                else if indexPath.row == 3
                {
                    if (getRepCustomerDic_list).keyExists(key: "DefaultDeliveryDay"), let defaultDeliveryDay = (getRepCustomerDic_list)["DefaultDeliveryDay"] as? String
                    {
                        
                        if Helper.shared.customerAppendDic_List.keyExists(key: "dayOfDelivery"), let dayOfDelivery = Helper.shared.customerAppendDic_List["dayOfDelivery"] as? String{
                            
                            cell.txtFld_CustomerName.text = dayOfDelivery
                            
                        }
                        else{
                            
                            cell.txtFld_CustomerName.text = defaultDeliveryDay
                            Helper.shared.customerAppendDic_List["dayOfDelivery"] = defaultDeliveryDay
                            
                        }
                        cell.txtFld_CustomerName.isUserInteractionEnabled = false
                    }
                }
                else if indexPath.row == 4 // runo
                {
                    if (getRepCustomerDic_list).keyExists(key: "RunNumbers"), let runNumbers = (getRepCustomerDic_list)["RunNumbers"] as? Array<Any>, runNumbers.count > 0
                    {
                        
                        if Helper.shared.customerAppendDic_List.keyExists(key: "RunNo"), let runNumber = Helper.shared.customerAppendDic_List["RunNo"] as? String{
                            
                            cell.txtFld_CustomerName.text = runNumber
                            
                        }else{
                            
                            if AppFeatures.shared.defaultRunNumber.isEmpty{
                                
                                cell.txtFld_CustomerName.text = runNumbers.first as? String
                                Helper.shared.customerAppendDic_List["RunNo"] = cell.txtFld_CustomerName.text
                                
                            }else{
                                
                                cell.txtFld_CustomerName.text = AppFeatures.shared.defaultRunNumber
                                Helper.shared.customerAppendDic_List["RunNo"] = AppFeatures.shared.defaultRunNumber
                                
                            }
                            
                        }
                        
                    }
                    else
                    {
                        cell.txtFld_CustomerName.text = "N/A"
                    }
                    Helper.shared.setRightViewMode(textField:cell.txtFld_CustomerName, imageSelected: "tFDropDown", amount: 20)
                }
                else if indexPath.row == 5{
                    
                    Helper.shared.setRightViewMode(textField:cell.txtFld_CustomerName, imageSelected: "tFDropDown", amount: 20)
                    
                    if Helper.shared.customerAppendDic_List["packingSEQ"] == nil// && cell.txtFld_CustomerName.text == ""
                    {
                        cell.txtFld_CustomerName.text = cell.txtFld_CustomerName.text == "" ? "0":cell.txtFld_CustomerName.text
                    }else{
                        // Helper.shared.customerAppendDic_List["packingSEQ"] = cell.txtFld_CustomerName.text == "" ? "0":cell.txtFld_CustomerName.text
                        cell.txtFld_CustomerName.text = (Helper.shared.customerAppendDic_List["packingSEQ"] as! String)
                    }
                }
                else if indexPath.row == 6
                {
                    cell.txtFld_CustomerName.text = "N/A"
                    Helper.shared.setRightViewMode(textField:cell.txtFld_CustomerName, imageSelected: "tFDropDown", amount: 20)
                    
                }
                else if indexPath.row == 7
                {
                    if self.clearOrder == "Clear Order"
                    {
                        cell.txtFld_CustomerName.text = "\(CommonString.currencyType)0.00"
                        self.clearOrder = ""
                    }
                    else
                    {
                        
                        cell.txtFld_CustomerName.text = String(format: "\(CommonString.currencyType)%@",Helper.shared.cartOrderValue.withCommas())
                        cell.txtFld_CustomerName.isUserInteractionEnabled = false
                    }
                    
                }
            }
            return cell
        }
        else if collectionView == clctn_SerachItems
        {
            //  if isGlobalSearch==false{
            if ((indexPath.row + 1) < self.buttonsArr.count)
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as! SearchCell
                cell.lbl_Search.text = searchItemArr[indexPath.item]
                if indexPath.item == 0
                {
                    if arrPantryList.count>0
                    {
                        cell.txtFld_Search.text = arrPantryList[pantryListIndex]["PantryListName"] as? String
                        Helper.shared.setRightViewMode(textField:cell.txtFld_Search, imageSelected: "tFDropDown", amount: 20)
                        self.lbl_PantryListName.text = (arrPantryList[pantryListIndex]["PantryListName"] as? String)?.capitalized
                    }
                    else{
                        cell.txtFld_Search.text = "No Pantry"
                        self.lbl_PantryListName.text = ""
                    }
                }
                else
                {
                    cell.txtFld_Search.text = ""
                    let attributes = [
                        NSAttributedStringKey.font : UIFont.Roboto_Italic(baseScaleSize: 14)]
                    cell.txtFld_Search.attributedPlaceholder = NSAttributedString(string: "Search for an item", attributes:attributes)
                    activeSearchTxtFld = cell.txtFld_Search
                    self.btnClearSearch = cell.btnCross
                    btnClearSearch.addTarget(self, action: #selector(self.clearSearch), for: .touchUpInside)
                    Helper.shared.setRightViewMode(textField:cell.txtFld_Search, imageSelected: "", amount: 0)
                }
                return cell
                
            }
            else
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonCell", for: indexPath) as! ButtonCell
                cell.btn_ShowOrder.setTitle(buttonsArr[(indexPath.row)-(searchItemArr.count)]["Button"], for: .normal)
                cell.btn_ShowOrder.tag = indexPath.row
                cell.btn_ShowOrder.addTarget(self, action: #selector(Clctn_ButtonAction(sender:)), for: .touchUpInside)
                if buttonsArr[(indexPath.row)-(searchItemArr.count)]["Button"] == "PANTRY LIST"{
                    cell.btn_ShowOrder.setImage(UIImage(named: "addPantry"), for: .normal)
                    cell.btn_ShowOrder.tintColor = UIColor.baseBlueColor()
                    cell.btn_ShowOrder.setTitleColor(UIColor.baseBlueColor(), for: .normal)
                    cell.btn_ShowOrder.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
                }
                if buttonsArr[(indexPath.row)-(searchItemArr.count)]["Button"] == "ORDER HISTORY"{
                    cell.btn_ShowOrder.backgroundColor = UIColor.clear
                    cell.btn_ShowOrder.setTitleColor(UIColor.baseBlueColor(), for: .normal)
                }
                if buttonsArr[(indexPath.row)-(searchItemArr.count)]["Button"] == CommonString.showGroupsBtnTitle || buttonsArr[(indexPath.row)-(searchItemArr.count)]["Button"] == CommonString.hideGroupsBtnTitle{
                    if isHideGroups == true
                    {
                        cell.btn_ShowOrder.setTitle(CommonString.showGroupsBtnTitle, for: .normal)
                        cell.btn_ShowOrder.setTitleColor(UIColor.white, for: .normal)
                        cell.btn_ShowOrder.backgroundColor = UIColor.baseBlueColor()
                    }
                    else
                    {
                        cell.btn_ShowOrder.setTitle(CommonString.hideGroupsBtnTitle, for: .normal)
                        cell.btn_ShowOrder.setTitleColor(UIColor.baseBlueColor(), for: .normal)
                        cell.btn_ShowOrder.backgroundColor = UIColor.clear
                    }
                }
                return cell
            }
        }
        else if collectionView == clctn_Features
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeatureCell", for: indexPath) as! FeatureCell
            // cell.btn_Feature.setTitle(self.featuresArr[indexPath.row]["Feature"], for: .normal)
            // cell.btn_Feature.titleLabel?.lineBreakMode = .byWordWrapping
            cell.lbl_Feature.text = self.featuresArr[indexPath.row]["Feature"]
            cell.btn_Feature.tag = indexPath.row
            cell.btn_Feature.addTarget(self, action: #selector(selectedFeature(sender:)), for: .touchUpInside)
            let image = UIImage(named:self.featuresArr[indexPath.row]["Image"]!)?.withRenderingMode(.alwaysTemplate)
            cell.img_Feature.image = image
            cell.btn_Feature.backgroundColor = UIColor.clear
            if index == indexPath.row{
                cell.lbl_Feature.textColor = UIColor.white
                cell.view_BgFeature.backgroundColor = UIColor.baseBlueColor()
                cell.img_Feature.tintColor = UIColor.white
                cell.contentView.backgroundColor = UIColor.baseBlueColor()
            }
            else{
                cell.lbl_Feature.textColor = UIColor.black
                cell.view_BgFeature.backgroundColor = UIColor.white
                cell.img_Feature.tintColor = UIColor.baseBlueColor()
                cell.contentView.backgroundColor = UIColor.white
            }
            
            return cell
        }
        else if collectionView == clctn_ItemType
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemTypeCell", for: indexPath) as! ItemTypeCell
            cell.btn_Item.removeTarget(self, action: nil, for: .touchUpInside)
            cell.btn_Item.tag = indexPath.item
            cell.btn_Item.addTarget(self, action: #selector(self.selectFilter), for: .touchUpInside)
            if self.arrFilters.count > indexPath.row
            {
                cell.btn_Item.setTitle((self.arrFilters[indexPath.row]["FilterName"] as? String)?.uppercased(), for: .normal)
            }
            // Toggle Selected Btn
            if selectedFilter == indexPath.row
            {
                if collectionView.viewWithTag(298) != nil
                {
                    (collectionView.viewWithTag(298))?.removeFromSuperview()
                }
                
//                if indexPath.item != 0
//                {
//                    let label = UILabel()
//                    label.tag = 298
//                    label.backgroundColor = UIColor.red
//                    label.font = UIFont.SFUI_SemiBold(baseScaleSize: 13.0)
//                    label.textColor = UIColor.white
//                    label.text = "\(self.totalResults!)"
//                    label.sizeToFit()
//                    let expectedWidth = label.frame.size.width + 10.0
//                    label.layer.cornerRadius = (expectedWidth)/2.0
//                    label.frame = CGRect(x: cell.frame.maxX - ((expectedWidth)/2.0), y: cell.frame.minY - ((expectedWidth)/2.0), width: expectedWidth, height: expectedWidth)
//                    label.clipsToBounds = true
//                    label.textAlignment = NSTextAlignment.center
//                    collectionView.addSubview(label)
//                    collectionView.bringSubview(toFront: label)
//                    collectionView.clipsToBounds = false
//                }
                cell.btn_Item.backgroundColor = UIColor.baseBlueColor()
                cell.btn_Item.setTitleColor(UIColor.white, for: .normal)
            }
            else
            {
                cell.btn_Item.backgroundColor = UIColor.white
                cell.btn_Item.setTitleColor(UIColor.priceInfoLightGreyColor(), for: .normal)
            }
            return cell
        }
        else //if collectionView == clctn_PantryList
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PantryListCell", for: indexPath) as! PantryListCell
            if let recoganizes = cell.containerView.gestureRecognizers
            {
                for gesture in recoganizes
                {
                    cell.containerView.removeGestureRecognizer(gesture)
                }
            }
            if self.selectedIndexPath == indexPath
            {
                cell.containerView.backgroundColor = UIColor(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1.0)
            }
            else
            {
                cell.containerView.backgroundColor = UIColor.white
            }
            
            cell.btn_Info.tag = indexPath.item
            cell.btn_Cart.tag = indexPath.item
            cell.btn_NP.tag = indexPath.item
            cell.btn_QtyPopUp.tag = indexPath.item
            cell.btn_Info.addTarget(self, action: #selector(self.sendToDetailAction(sender:)), for: .touchUpInside)
            cell.btn_Cart.addTarget(self, action: #selector(self.addToCart(sender:)), for: .touchUpInside)
            cell.btn_QtyPopUp.addTarget(self, action: #selector(showQuantityPopupAction(_:)), for: .touchUpInside)
            cell.btn_NP.addTarget(self, action: #selector(notPantryAction(sender:)), for: .touchUpInside)
            cell.txtFld_Qty.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonClicked))
            if productList.count>0{
                
                var productDescDic = productList[indexPath.item]
                //                asyncAfter(deadline: .now() + 0.5)
                DispatchQueue.main.async {
                    
                    if productDescDic.keyExists(key: "WeeklySales"),let weeklySaleDic = productDescDic["WeeklySales"] as? Dictionary<String,Any>
                    {
                        cell.weekDetailDict = weeklySaleDic
                    }
                    cell.updateWeekDetail()
                }
                
                if productDescDic.keyExists(key: "ProductImage"),let productImage = productDescDic["ProductImage"] as? String
                {
                    if productImage == ""
                    {
                        if productDescDic.keyExists(key: "ProductImages"), let imagesArray = productDescDic["ProductImages"] as? Array<Dictionary<String,Any>>, imagesArray.count > 0
                        {
                            let urlString = imagesArray[0]["ImageName"] as? String
                            cell.img_Item.setImageWith(URL(string: urlString ?? ""), placeholderImage: #imageLiteral(resourceName: "ImagePlaceholder"))
                        }

                    }
                    else
                    {
                        let urlString:String = productImage.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
                        cell.img_Item.setImageWith(URL(string: urlString), placeholderImage: #imageLiteral(resourceName: "ImagePlaceholder"))
                    }
                }
                
                if productDescDic.keyExists(key: "ProductCode"), let PantryItemID = productDescDic["ProductCode"] as? String
                {
                    cell.lbl_code.text = ""
                }
                if productDescDic.keyExists(key: "StockQuantity"), let StockQuantity = productDescDic["StockQuantity"] as? Double{
                    cell.lbl_SOH.text = String(format: "%.0f", StockQuantity)
                }
                
                cell.txtFld_Qty.tag = indexPath.item
                if productDescDic.keyExists(key: "Quantity"), let number = productDescDic["Quantity"] as? Double, number != 0.0{
                    
                    cell.txtFld_Qty.text = number.cleanValue
                    //cell.txtFld_Qty.isUserInteractionEnabled = false
                }
                else{
                    
                    cell.txtFld_Qty.text = AppFeatures.shared.IsAllowDecimal ? "1.00": UserInfo.shared.isSalesRepUser! ? "1.00":"1"
                    //cell.txtFld_Qty.isUserInteractionEnabled = false
                }
                
                cell.txtFld_Qty.textColor = UIColor.priceInfoLightGreyColor()
//                if productDescDic.keyExists(key: "ProductName"), let ProductName = productDescDic["ProductName"] as? String{
//                    cell.lbl_Description.text = ProductName
//                }
                let desc1 = ((productDescDic)["ProductName"] as? String) ?? ""
                let desc2 = productDescDic["Description2"] as? String ?? ""
                let desc3 = productDescDic["Description3"] as? String ?? ""
                var features = ""
                if !desc1.isEmpty{
                    features += "\(desc1)"
                }
                if !desc2.isEmpty{
                    features += "\n\(desc2)"
                }
                if !desc3.isEmpty{
                    features += "\n\(desc3)"
                }
                
                cell.lbl_Description.text = features//((productDescDic)["ProductName"] as? String)
                
                if productDescDic.keyExists(key: "IsGST"),let isGST =  productDescDic["IsGST"] as? Bool, isGST == true
                {
                    cell.btn_GST.setImage(UIImage(named:"shape1"), for: .normal)
                }
                else{
                    cell.btn_GST.setImage(UIImage(named:""), for: .normal)
                }
                if productDescDic.keyExists(key: "IsInCart"),let isInCart =  productDescDic["IsInCart"] as? Bool, isInCart == true
                {
                    cell.btn_Cart.setImage(#imageLiteral(resourceName: "cart"), for: .normal)
                }
                else{
                    cell.btn_Cart.setImage(#imageLiteral(resourceName: "SalesRepEmptyCart"), for: .normal)
                }
                
                if productDescDic.keyExists(key: "IsNonPantry"),let isNonPantry =  productDescDic["IsNonPantry"] as? Bool, isNonPantry == true
                {
                    cell.btn_NP.setImage(#imageLiteral(resourceName: "check1"), for: .normal)
                    cell.btn_NP.tintColor = UIColor.baseBlueColor()
                }
                else
                {
                    cell.btn_NP.setImage(#imageLiteral(resourceName: "unCheck1"), for: .normal)
                    cell.btn_NP.tintColor = UIColor.darkGreyColor()
                }
                
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.swipeMoved(sender:)))
                panGesture.delegate = self
                cell.containerView.addGestureRecognizer(panGesture)
                
//                if productDescDic.keyExists(key: "IsStatusIN"),productDescDic["IsStatusIN"] as? Bool == true{
//                    cell.lbl_Description.textColor = UIColor.blue
//                }
//                else
                
                if AppFeatures.shared.isHighlightRewardItem
                {
                    if productDescDic.keyExists(key: "IsCountrywideRewards"),productDescDic["IsCountrywideRewards"] as? Bool == false{
                        
                        cell.lbl_Description.textColor = UIColor.darkGreyColor()
                    }
                    else{
                        self.country_world_wide_lbl.isHidden = false
                        cell.lbl_Description.textColor = UIColor.init(hex: "#b0cf00")
                    }
                }
                else
                {
                    cell.lbl_Description.textColor = UIColor.darkGreyColor()
                }
                
                if let isBuyIn =  productDescDic["BuyIn"] as? Bool, isBuyIn == true
                {
                    cell.lbl_Description.textColor = UIColor.init(hex: "#2a99f3")
                }

                cell.btn_UOM.tag = indexPath.row
                cell.btn_UOM.addTarget(self, action: #selector(self.uOMChanged(sender:)), for: .touchUpInside)
                
                if productDescDic.keyExists(key: "DynamicUOM"), let obj = productDescDic["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1{
                    
                    cell.arrowUOMDropdown.constant = 10.0
                }
                else
                {
                    cell.arrowUOMDropdown.constant = 0.0
                }
                var arrPrices : Array<Dictionary<String,Any>>?
                if productDescDic.keyExists(key: "DynamicUOM"),let prices = productDescDic["DynamicUOM"] as? Array<Dictionary<String,Any>>
                {
                    arrPrices = prices
                }
                else if productDescDic.keyExists(key: "Prices"),let prices = productDescDic["Prices"] as? Array<Dictionary<String,Any>>
                {
                    arrPrices = prices
                }
                else if productDescDic.keyExists(key: "Prices"),let prices = productDescDic["Prices"] as? Dictionary<String,Any>
                {
                    arrPrices = [prices]
                }
                
                if (arrPrices != nil), arrPrices!.count > 0
                {
                    let testIndex = arrPrices?.index(where: { (testdic : Dictionary<String, Any>) -> Bool in
                        testdic["UOMID"] as? NSNumber == productDescDic["UOMID"] as? NSNumber
                    })
                    
                    if (testIndex != nil)
                    {
                        productDescDic["selectedIndex"] = testIndex
                    }
                    
                    
                    var selectedIndex = 0
                    if productDescDic.keyExists(key: "selectedIndex"),let index = productDescDic["selectedIndex"] as? Int
                    {
                        selectedIndex = index
                    }
                    let objToFetch = arrPrices![selectedIndex]
                    if let price = objToFetch["Price"] as? Double{
                        
                        
                        let price_final = Double(round(100*price)/100)

                        let priceStr = String(format: "\(CommonString.currencyType)%.2f", price_final)
                        cell.lbl_UnitPrice.text = price <= 0 ? CommonString.marketprice:priceStr
                        let totalPrice = String(format: "\(CommonString.currencyType)%.2f",price * Double(cell.txtFld_Qty.text!)!)
                        cell.lbl_Amount.text = price <= 0 ? CommonString.marketprice:totalPrice
                        cell.lbl_Each.text = objToFetch["UOMDesc"] as? String
                    }
                    
                    cell.lbl_Each.textColor = UIColor.gray
                    if productDescDic.keyExists(key: "LastOrderUOMID"), let lastUom = productDescDic["LastOrderUOMID"] as? Int, lastUom == objToFetch["UOMID"] as? Int, lastUom > 0{
                        cell.lbl_Each.textColor = UIColor.gray
                    }
                    
                    if objToFetch["IsSpecial"] as? Bool == true && objToFetch["IsPromotional"] as? Bool == true{
                        cell.lbl_UnitPrice.textColor = UIColor.red
                        cell.lbl_Amount.textColor = UIColor.red
                    }
                    else if objToFetch["IsSpecial"] as? Bool == true{
                        cell.lbl_UnitPrice.textColor = UIColor.red
                        cell.lbl_Amount.textColor = UIColor.red
                    }
                    else if objToFetch["IsPromotional"] as? Bool == true{
                        cell.lbl_UnitPrice.textColor = UIColor.promotionalProductYellowColor()
                        cell.lbl_Amount.textColor = UIColor.promotionalProductYellowColor()
                    }
                    else{
                        cell.lbl_UnitPrice.textColor = UIColor.priceInfoLightGreyColor()
                        cell.lbl_Amount.textColor = UIColor.priceInfoLightGreyColor()
                    }
                    
                    let price = objToFetch["Price"] as? Double
                    let companyPrice = objToFetch["CostPrice"] as? Double
                    cell.lblMarginValue.text = Helper.shared.calculateMarginPercentage(price: price ?? 0.0, companyPrice: companyPrice ?? 0.0)
                    if (price! - companyPrice!) < 0{
                        
                        cell.lblMarginValue.textColor = UIColor.red
                    }else {
                        cell.lblMarginValue.textColor = UIColor.primaryColor()
                    }
                    
                }else {
                    
                    let price = productDescDic["Price"] as? Double
                    let companyPrice = productDescDic["CompanyPrice"] as? Double
                    cell.lblMarginValue.text = Helper.shared.calculateMarginPercentage(price: price ?? 0.0, companyPrice: companyPrice ?? 0.0)
                    
                    if (price! - companyPrice!) < 0{
                        
                        cell.lblMarginValue.textColor = UIColor.red
                    }else {
                        cell.lblMarginValue.textColor = UIColor.primaryColor()
                    }
                    
                }
                cell.txtFld_Qty.resizeFont()
                
                if let new = productDescDic["IsNew"] as? Bool, new == true {
                    cell.lblStatus.isHidden = false
                    cell.lblStatus.text = "NEW"
                    cell.lblStatus.backgroundColor = UIColor.primaryColor()
                }else if let new = productDescDic["IsOnSale"] as? Bool, new == true {
                    cell.lblStatus.isHidden = false
                    cell.lblStatus.text = "SALE"
                    cell.lblStatus.backgroundColor = UIColor.primaryColor2()
                }else if let new = productDescDic["IsBackSoon"] as? Bool, new == true {
                    cell.lblStatus.isHidden = false
                    cell.lblStatus.text = "INCOMING"
                    cell.lblStatus.backgroundColor = UIColor.primaryColor3()
                }else{
                    cell.lblStatus.text = ""
                    cell.lblStatus.isHidden = true
                }
            }
            
            if AppFeatures.shared.isShowOrderMargin{
                cell.lblMarginValue.isHidden = false
                cell.lblMargin.isHidden = false
            }else{
                cell.lblMarginValue.isHidden = true
                cell.lblMargin.isHidden = true
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if collectionView == clctn_CustomerDetail
        {
            return CGSize(width: (collectionView.bounds.size.width-CGFloat(customerDetailArr.count+1))/CGFloat(customerDetailArr.count), height: collectionView.bounds.size.height)
        }
        if collectionView == clctn_SerachItems
        {
            if ((indexPath.row + 1) < self.buttonsArr.count)
            {
                return CGSize(width: ((collectionView.bounds.size.width * 0.5)-CGFloat(3))/2.0, height: collectionView.bounds.size.height)
            }
            else
            {
                return CGSize(width: ((collectionView.bounds.size.width * 0.5)-CGFloat(4))/3.0, height: collectionView.bounds.size.height)
            }
        }
        if collectionView==clctn_Features{
            return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height/CGFloat(featuresArr.count)-10)
        }
        if collectionView == clctn_ItemType
        {
            return CGSize(width: 180, height: collectionView.bounds.size.height)
        }
        if collectionView==clctn_PantryList
        {
            return CGSize(width: collectionView.bounds.size.width - 2.0, height: 130.0)
        }
        else
        {
            return CGSize(width: (collectionView.bounds.size.width * 0.123), height: collectionView.bounds.size.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == clctn_PantryList
        {
            self.selectedIndexPath = indexPath
            selectedDicForInfo = productList[indexPath.item]
            collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if collectionView == clctn_PantryList{
            return true
        }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        if collectionView == clctn_PantryList{
            print("Source : \(sourceIndexPath.item), Destination : \(destinationIndexPath.item)")
            let objToMove = self.productList[sourceIndexPath.item]
            
            if sourceIndexPath.row < destinationIndexPath.row
            {
                for i in sourceIndexPath.item...destinationIndexPath.item
                {
                    if i == destinationIndexPath.item
                    {
                        self.productList[i] = objToMove
                    }
                    else
                    {
                        self.productList[i] = self.productList[i+1]
                    }
                }
            }
            else
            {
                var i = sourceIndexPath.item
                repeat
                {
                    self.productList[i] = self.productList[i-1]
                    i = i-1
                }
                    while(i > destinationIndexPath.item)
                
                productList[destinationIndexPath.item] = objToMove
                
            }
            var reqArr = Array<Any>()
            if(productList.count > 0)
            {
                for i in 0..<productList.count{
                    let productDescDic = productList[i]
                    if(productDescDic.count > 0){
                        reqArr.append(productDescDic["ProductID"]!)
                    }
                }
            }
            self.setPantryItemsSortOrder(reqArr: reqArr, pantryListId: pantryListId)
        }
    }
    //MARK:- cell Button Action
    
    @objc func selectedFeature(sender:UIButton){
        
        if featuresArr[sender.tag]["Feature"] == "Price Info"{
            if selectedIndexPath == nil {
                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: "Please select item first.", withCancelButtonTitle: "OK", completion: {
                })
            }
            else{
                index = sender.tag
                let priceInfoVCObj = UIStoryboard.init(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "PriceInfoVC") as! PriceInfoVC
                DispatchQueue.main.async {
                    priceInfoVCObj.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    priceInfoVCObj.productDic = self.selectedDicForInfo
                    priceInfoVCObj.senderView = self
                    //priceInfoVCObj.customerId = UserInfo.shared.customerID
                    priceInfoVCObj.prodId = self.selectedDicForInfo["ProductID"] as? NSNumber ?? 0
                    priceInfoVCObj.UOMID = self.selectedDicForInfo["UOMID"] as? NSNumber ?? 0
                    self.present(priceInfoVCObj, animated: false, completion: nil)
                }
            }
            
            
        }
        if featuresArr[sender.tag]["Feature"] == "Comment Line"{
            if Helper.shared.cartCount>0{
                index = sender.tag
                let commentLineVCObj = UIStoryboard.init(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "CommentLineVC") as! CommentLineVC
                DispatchQueue.main.async {
                    commentLineVCObj.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    commentLineVCObj.senderView = self
                    //   commentLineVCObj.prodId = self.selectedDicForInfo["ProductID"] as! NSNumber
                    //commentLineVCObj.customerId = UserInfo.shared.customerID
                    self.present(commentLineVCObj, animated: false, completion: nil)
                }
            }
            else{
                index = sender.tag
                SalesRepAlert.shared.showCommonAlertOnWindow(withImage: "salesRepCart", withTitle: "", withSuccessButtonTitle: nil, withMessage: "Your cart is empty.", withCancelButtonTitle: "OK", completion: {
                    self.index = -1
                    self.clctn_Features.reloadData()
                })
            }
        }
        if featuresArr[sender.tag]["Feature"] == "Customer Info"{
            //                        if selectedIndexPath == nil {
            //                            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: "Please select item first.", withCancelButtonTitle: "OK", completion: {
            //
            //                            })
            //                        }
            //                        else{
            
            index = sender.tag
            let customerInfoVCObj = UIStoryboard.init(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "CustomerInfoVC") as! CustomerInfoVC
            DispatchQueue.main.async {
                customerInfoVCObj.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                customerInfoVCObj.senderView = self
                customerInfoVCObj.customerInfoData = self.customerListDic
                self.present(customerInfoVCObj, animated: false, completion: nil)
            }
            //                     }
        }
        if featuresArr[sender.tag]["Feature"] == "Item Availability"{
            if selectedIndexPath == nil {
                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: "Please select item first.", withCancelButtonTitle: "OK", completion: {
                })
            }
            else{
                index = sender.tag
                let itemAvailabiltyVCObj = UIStoryboard.init(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "ItemAvailabiltyVC") as! ItemAvailabiltyVC
                DispatchQueue.main.async {
                    itemAvailabiltyVCObj.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    itemAvailabiltyVCObj.prodId = self.selectedDicForInfo["ProductID"] as! NSNumber
                    itemAvailabiltyVCObj.senderView = self
                    itemAvailabiltyVCObj.prod_name = self.selectedDicForInfo["ProductName"] as? String
                    self.present(itemAvailabiltyVCObj, animated: false, completion: nil)
                }
            }
        }
        if featuresArr[sender.tag]["Feature"] == "Order Margin"
        {
            //            if selectedIndexPath == nil {
            //                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: "Please select item first.", withCancelButtonTitle: "OK", completion: {
            //
            //                })
            //            }
            //            else{
            index = sender.tag
            if Helper.shared.cartCount != 0 {
                self.getCartItems(isReload: true)
            }
            else{
                SalesRepAlert.shared.showCommonAlertOnWindow(withImage: "salesRepCart", withTitle: "", withSuccessButtonTitle: nil, withMessage: "Please add at least one item into the cart to check the order margin.", withCancelButtonTitle: "OK", completion: {
                    self.index = -1
                    self.clctn_Features.reloadData()
                })
            }
            //   }
        }
        if featuresArr[sender.tag]["Feature"] == "Delete Order"
        {
            if Helper.shared.cartCount>0{
                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: "YES", withMessage: "Are you sure you want to delete this order?", withCancelButtonTitle: "NO", completion:{
                    if self.tempCartId != 0{
                        self.deleteSaveOrder()
                    }
                })
            }
            else{
                SalesRepAlert.shared.showCommonAlertOnWindow(withImage: "salesRepCart", withTitle: CommonString.alertTitle, withSuccessButtonTitle: nil, withMessage: "Your cart is empty.", withCancelButtonTitle: "OK", completion: {
                })
            }
        }
        
        if featuresArr[sender.tag]["Feature"] == "Shipping"
        {
            getUserAddresses()
        }
        if featuresArr[sender.tag]["Feature"] == "Release Order"
        {
            if Helper.shared.cartCount>0{
                index = sender.tag
                if let vc = UIStoryboard.init(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "MyCartVC") as? MyCartVC
                {
                    //vc.customerId = UserInfo.shared.customerID
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else{
                SalesRepAlert.shared.showCommonAlertOnWindow(withImage: "salesRepCart", withTitle: CommonString.alertTitle, withSuccessButtonTitle: nil, withMessage: "Your cart is empty.", withCancelButtonTitle: "OK", completion: {
                })
            }
        }
        
        clctn_Features.reloadData()
    }
    
    
    @objc func selectFilter(sender:UIButton)
    {
        if selectedFilter != sender.tag
        {
            self.selectedIndexPath = nil
            selectedDicForInfo = Dictionary<String,Any>()
            clctn_PantryList.reloadData()
            self.filterID = (self.arrFilters[sender.tag]["FilterID"] as? NSNumber)!
            selectedFilter = sender.tag
            pageNumber = 1
            let customerCell = self.clctn_SerachItems.cellForItem(at: IndexPath(item: 2, section:0)) as? SearchCell
            customerCell?.txtFld_Search.text = ""
            if let searchBar = self.navigationItem.titleView as? UISearchBar
            {
                searchBar.text = ""
            }
            // Move the filter and make it visible.
            if let superViewFrame = (sender.superview?.superview as? ItemTypeCell)?.frame
            {
                UIView.animate(withDuration: 0.5, animations: {
                    if superViewFrame.maxX > (self.clctn_ItemType.contentOffset.x + self.clctn_ItemType.frame.size.width)
                    {
                        self.clctn_ItemType.contentOffset = CGPoint(x: superViewFrame.maxX  - self.clctn_ItemType.frame.size.width + 20.0, y: 0)
                    }
                    else if superViewFrame.minX < self.clctn_ItemType.contentOffset.x
                    {
                        self.clctn_ItemType.contentOffset = CGPoint(x: superViewFrame.minX - 10.0, y: 0)
                    }
                })
            }
            self.clctn_PantryList.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            getAllDefaultPantryItems(searchText: "")
            var searchText = ""
            if self.navigationItem.titleView is UISearchBar
            {
                searchText = (self.navigationItem.titleView as! UISearchBar).text!
            }
            
            
            //  if isSearchingProduct == true{
            if searchText != ""{
                self.callSearchProductWebService(with: searchText)
            }
            //  }
            DispatchQueue.main.async {
                self.clctn_SerachItems.reloadData()
                self.clctn_ItemType.reloadData()
            }
        }
        else
        {
            
        }
    }
    
    @objc func Clctn_ButtonAction(sender:UIButton){
        var tag = Int()
        if isGlobalSearch==true{
            tag = sender.tag
        }
        else{
            tag = sender.tag-2
        }
        if buttonsArr[tag]["Button"] == "PANTRY LIST"{
            if let favorietController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addFavoriteListPopupSroryID") as? AddFavoriteListView
            {
                self.isFirstTime = false
                favorietController.parentController = self
                favorietController.isCreatedByRepUser = true
                favorietController.titleOfPopup = "Add Pantry List"
                UIApplication.shared.keyWindow?.rootViewController?.present(favorietController, animated: false, completion: nil)
            }
        }
        else if buttonsArr[tag]["Button"] == "ORDER HISTORY"{
            let orderHistoryVC = UIStoryboard.init(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "OrderHistoryVC") as! OrderHistoryVC
            //orderHistoryVC.customerId = UserInfo.shared.customerID
            self.navigationController?.pushViewController(orderHistoryVC, animated: false)
        }
            
        else if buttonsArr[tag]["Button"] == CommonString.hideGroupsBtnTitle || buttonsArr[tag]["Button"] == CommonString.showGroupsBtnTitle{
            if isHideGroups == false
            {
                isHideGroups = true
                filtersClctnHeightConstant.constant = 0.0
                if clctn_ItemType.viewWithTag(298) != nil
                {
                    clctn_ItemType.viewWithTag(298)?.isHidden = true
                }
                
            }
            else
            {
                isHideGroups = false
                if self.arrPantryList.count > 0{
                    
                    isHideGroups = false
                    filtersClctnHeightConstant.constant = 35.0 * VerticalSpacingConstraints.spacingConstant
                    if clctn_ItemType.viewWithTag(298) != nil
                    {
                        clctn_ItemType.viewWithTag(298)?.isHidden = false
                    }
                    
                    
                }
            }
            clctn_SerachItems.reloadItems(at:[IndexPath(item: sender.tag, section:0)])
        }
        
    }
    
    //MARK: TextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.text == "", string == " "
        {
            return false
        }
        else if textField == popTxtField
        {
            let aSet = NSCharacterSet(charactersIn:"0123456789.").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            return string == numberFiltered && newText.count <= 20
            
        }else if textField == self.activeTxtFldQty{
            //            if !AppFeatures.shared.IsAllowDecimal{
            //                if  string == "."{
            //                    return false
            //                }
            //            }
            
            let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
            guard let oldText = textField.text, let r = Range(range, in: oldText) else {
                return true
            }
            
            let newText = oldText.replacingCharacters(in: r, with: string)
            let isNumeric = newText.isEmpty || (Double(newText) != nil)
            let numberOfDots = newText.components(separatedBy: ".").count - 1
            
            let numberOfDecimalDigits: Int
            if let dotIndex = newText.index(of: ".") {
                numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
            } else {
                numberOfDecimalDigits = 0
            }
            let numberOfValidDigits : Int
            if newText.index(of: ".") != nil {
                // numberOfDigits = newText.distance(from: newText.startIndex, to: dotIndex)
                numberOfValidDigits = 8
            } else {
                numberOfValidDigits = 5
            }
            
            //return newString.count < 9 || isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2
            if newString.count > numberOfValidDigits
            {
                return false
            }
            else
            {
                return isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2
            }
        }
        
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == activeSearchTxtFld
        {
            self.btnClearSearch.isHidden = false
        }
        
        activeTxtFld = textField
        let cell = self.clctn_SerachItems.cellForItem(at: IndexPath(item: 0, section:0)) as? SearchCell
        
        let customerCell = self.clctn_CustomerDetail.cellForItem(at: IndexPath(item: 2, section:0)) as? CustomerDetailCell
        
        let customerRunNmCell = self.clctn_CustomerDetail.cellForItem(at: IndexPath(item: 4, section:0)) as? CustomerDetailCell
        
        let customerPackingCell = self.clctn_CustomerDetail.cellForItem(at: IndexPath(item: 5, section:0)) as? CustomerDetailCell
        
        let customerDocumentCell = self.clctn_CustomerDetail.cellForItem(at: IndexPath(item: 6, section:0)) as? CustomerDetailCell
        
        if textField == cell?.txtFld_Search{
            //self.view.endEditing(true)
            
            if arrPantryList.count>0{
                self.showDropDownPickerAction()
            }
            
            return false
        }
        else if textField == customerCell?.txtFld_CustomerName
        {
            if AppFeatures.shared.IsDatePickerEnabled == true {
                self.showDeliveryTypePopup()
            }
            return false
        }
        else if textField == customerRunNmCell?.txtFld_CustomerName
        {
            if runNumberList.count > 0{
                
                self.showDropDownPickerAction()
            }
            return false
        }
        else if textField == customerPackingCell?.txtFld_CustomerName
        {
            let alertController = UIAlertController(title:CommonString.app_name, message: "Please enter the packing sequence", preferredStyle: .alert)
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Packing sequence"
                self.popTxtField = textField
                textField.keyboardType = .numberPad
                textField.delegate = self
            }
            
            let saveAction = UIAlertAction(title: "OK", style: .default, handler: { alert -> Void in
                
                let firstTextField = alertController.textFields![0] as UITextField
                
                let customerCell = self.clctn_CustomerDetail.cellForItem(at: IndexPath(item: 5, section:0)) as? CustomerDetailCell
                customerCell?.txtFld_CustomerName.text = firstTextField.text
                if firstTextField.text == ""
                {
                    customerCell?.txtFld_CustomerName.text = "0"
                }
                else
                {
                    customerCell?.txtFld_CustomerName.text = firstTextField.text
                    Helper.shared.customerAppendDic_List["packingSEQ"] = firstTextField.text
                }
                //Helper.shared.customerAppendDic_List["packingSEQ"] = firstTextField.text
                
            })
            
            let cancelAction = UIAlertAction(title: "CANCEL", style: .default, handler: { (action : UIAlertAction!) -> Void in })
            
            alertController.addAction(cancelAction)
            alertController.addAction(saveAction)
            self.present(alertController, animated: true, completion: nil)
            
            return false
        }
        else if textField == customerDocumentCell?.txtFld_CustomerName
        {
            let customerDocument = UIStoryboard.init(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "externalDocID") as! ExternalDocVC
            customerDocument.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            customerDocument.senderView = self
            self.present(customerDocument, animated: false, completion: nil)
            return false
        }
        else{
            //            self.activeTxtFldQty = textField
            //            self.activeTxtFldQty.text = ""
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == activeSearchTxtFld
        {
            pantry_localSearch()
            textField.resignFirstResponder()
        }
        return true
    }
    
    
    @objc func doneButtonClicked(_ textField: UITextField) {
        
        if textField == self.activeTxtFldQty{
            
            var product = self.productList[textField.tag]
            let qtyDoubleValue:Double = (textField.text?.isEmpty)! ? 1.00:Double(textField.text!)!
            let qtyValue = qtyDoubleValue <= 0 ? 1.00:qtyDoubleValue
            product["Quantity"] = NSNumber(value: qtyValue)
            self.productList[textField.tag] = product
            product = self.productList[textField.tag]
            self.addProductToCartwithDatePicker(productDetail: product, actualIndex: textField.tag)
        }
        
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField){
        
        self.clctn_PantryList.isScrollEnabled = true
        if textField == activeSearchTxtFld
        {
            pantry_localSearch()
            
        }else if textField.tag == self.activeTxtFldQty.tag{
            
            self.activeTxtFldQty.text = ((textField.text?.isEmpty)!) ? (AppFeatures.shared.IsAllowDecimal ? 0.00.cleanValue: UserInfo.shared.isSalesRepUser! ? 0.00.cleanValue:"0"):textField.text
            self.clctn_PantryList.reloadData()
        }
        
    }
    
    
    func getCartItems(isReload:Bool) -> Void{
        
        let serviceURL = SyncEngine.baseURL + SyncEngine.getCartItems
        let requestToGetCartItems = [
            "UserID": UserInfo.shared.userId!,
            "CustomerID": UserInfo.shared.customerID ?? 0,
            "IsPlacedByRep": true,
            "IsSavedOrder" : false,
            "CartID" : 0
            ] as Dictionary<String,Any>
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestToGetCartItems, strURL: serviceURL) { (response : Any) in
            if let items = (response as? Dictionary<String,Any>)?["CartItems"] as? Array<Dictionary<String,Any>>
            {
                
                var CostPrice : Double = 0
                var Price : Double = 0
                for i in 0..<items.count
                {
                    var productDic = items[i]
                    var objToFetch : Dictionary<String,Any>?
                    var arrPrices : Array<Dictionary<String,Any>>?
                    if let prices = productDic["DynamicUOM"] as? Array<Dictionary<String,Any>>
                    {
                        arrPrices = prices
                    }
                    else if let prices = productDic["Prices"] as? Array<Dictionary<String,Any>>
                    {
                        arrPrices = prices
                    }
                    else if let prices = productDic["Prices"] as? Dictionary<String,Any>
                    {
                        arrPrices = [prices]
                    }
                    
                    if (arrPrices != nil), arrPrices!.count > 0
                    {
                        let testIndex = arrPrices?.index(where: {
                            
                            (testdic : Dictionary<String, Any>) -> Bool in
                            testdic["UOMID"] as? NSNumber == productDic["UOMID"] as? NSNumber
                            
                            
                        })
                        
                        if (testIndex != nil)
                        {
                            productDic["selectedIndex"] = testIndex
                        }
                        
                        var selectedIndex = 0
                        if let index = productDic["selectedIndex"] as? Int
                        {
                            selectedIndex = index
                        }
                        objToFetch = arrPrices![selectedIndex]
                        
                        //                        let index = arrPrices?.index(where: { (testdic : Dictionary<String, Any>) -> Bool in
                        //                            testdic["UOMDesc"] as? String == productDic["UnitName"] as? String
                        //                        })
                        //                        objToFetch = arrPrices![index ?? 0]
                    }
                    
                    if let price = objToFetch?["Price"] as? Double , let priceComp = objToFetch?["CostPrice"] as? Double
                    {
                        CostPrice = priceComp + CostPrice
                        Price = price + Price
                    }
                    
                }
                
                DispatchQueue.main.async {
                    
                    let margin = Helper.shared.calculateMarginPercentage(price: Price, companyPrice: CostPrice)
                    self.lblMarginvalue.text = margin
                    self.lblMargin.text = "Margin: "
                    self.lblMarginvalue.textColor = (Price - CostPrice) < 0 ? UIColor.red:UIColor.primaryColor()
                    let string = "The margin percentage is \(margin)"
                    
                    if isReload{
                        
                        SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: "Order Margin Percentage", withSuccessButtonTitle: nil, withMessage: string, withCancelButtonTitle: "OK", completion:{
                            self.index = -1
                            self.clctn_Features.reloadData()
                        })
                    }
                }
            }
        }
    }
    
    func showDeliveryTypePopup(){
        
        DispatchQueue.main.async {
            
            if let receiveOrderPopup = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReceiveOrderPopupVC") as? ReceiveOrderPopupVC
            {
                receiveOrderPopup.modalPresentationStyle = .overCurrentContext
                self.present(receiveOrderPopup, animated: false, completion: nil)
                receiveOrderPopup.completionBlock = { (buttonPressed, deliveyType) -> Void in
                    
                    if buttonPressed == DeliveryStatus.moveNext {
                        if deliveyType == DeliveryType.pickUp{
                            UserInfo.shared.isDelivery = false;
                        }else{
                            UserInfo.shared.isDelivery = true;
                        }
                        
                       
                        self.showDatePicker{
                            self.setPackingSequence()
                        }
                    }
                }
            }
        }
    }
    
    @objc func showSearchBar() -> Void
    {
        
        //        productList.removeAll()
        //        clctn_PantryList.reloadData()
        self.pantryListName = self.lbl_PantryListName.text!
        self.searchClctnHeightConstant.constant = 0.0
        self.hideDetailBtnHeightConstant.constant = 0.0
        self.btn_HideDetails.setTitle("", for: .normal)
        HideDetail.constant = 0.0
        
        self.clctn_SerachItems.reloadData()
        self.lbl_PantryListName.text = ""
        self.navigationItem.rightBarButtonItems = nil
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        let cancelSearchBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(searchBarCancelButtonClicked(_:)))
        cancelSearchBarButtonItem.tintColor = UIColor.baseBlueColor()
        if self.isSearchingProduct == false
        {
            self.navigationItem.setRightBarButton(cancelSearchBarButtonItem, animated: true)
        }
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        isSearchingProduct = true
        self.lblMargin.isHidden = true
        self.lblMarginvalue.isHidden = true
        self.navigationItem.titleView = searchBar
        
        filtersClctnHeightConstant.constant = 0.0
        if clctn_ItemType.viewWithTag(298) != nil
        {
            clctn_ItemType.viewWithTag(298)?.isHidden = true
            
        }
    }
    
    @objc func clearSearch(){
        self.activeSearchTxtFld.text = ""
        self.pantry_localSearch()
        self.activeSearchTxtFld.resignFirstResponder()
    }
    
    //    MARK: - Search Bar Delegate -
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        
        if AppFeatures.shared.isShowOrderMargin{
            self.lblMargin.isHidden = false
            self.lblMarginvalue.isHidden = false
        }
        
        if isHideGroups == false
        {
            filtersClctnHeightConstant.constant = 35.0 * VerticalSpacingConstraints.spacingConstant
            if clctn_ItemType.viewWithTag(298) != nil
            {
                clctn_ItemType.viewWithTag(298)?.isHidden = false
                
            }
        }
        
        if isHideDetail == false
        {
            HideDetail.constant = 90.0
            btn_HideDetails.setTitle(CommonString.hideDetailBtnTitle, for: .normal)
            btn_HideDetails.setTitleColor(UIColor.baseBlueColor(), for: .normal)
        }
        
        self.searchClctnHeightConstant.constant = 65.0 * VerticalSpacingConstraints.spacingConstant
        self.hideDetailBtnHeightConstant.constant = 30.0 * VerticalSpacingConstraints.spacingConstant
        if isHideDetail == false{
            self.btn_HideDetails.setTitle(CommonString.hideDetailBtnTitle, for: .normal)
        }
        else{
            self.btn_HideDetails.setTitle(CommonString.showDetailBtnTitle, for: .normal)
        }
        
        self.lbl_PantryListName.text = self.pantryListName
        self.clctn_SerachItems.reloadData()
        self.navigationItem.titleView = nil
        self.setDefaultNavigation()
        isSearchingProduct = false
        hideNoItemsLabel()
        self.view.endEditing(true)
        //        self.productList = self.allPantryItems
        //        self.totalResults = self.allResults
        getAllDefaultPantryItems(searchText: "")
        self.clctn_PantryList.reloadData()
        self.clctn_ItemType.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == ""
        {
            hideNoItemsLabel()
            self.productList.removeAll()
            self.clctn_PantryList.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if searchBar.text == "", text == " "
        {
            return false
        }
        else{
            return true
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        self.selectedIndexPath = nil
        selectedDicForInfo = Dictionary<String,Any>()
        if isSearchingProduct == true
        {
            searchBar.resignFirstResponder()
        }
        pageNumber = 1
        self.view.endEditing(true)
        self.callSearchProductWebService(with: searchBar.text!)
        
    }
    
    
    //    MARK:- Show DropDown
    func showDropDownPickerAction()
    {
        if let pantryListVc = self.storyboard?.instantiateViewController(withIdentifier: "DropDownPickerID") as? DropDownPicker
        {
            DispatchQueue.main.async {
                pantryListVc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                pantryListVc.senderView = self
                pantryListVc.parentView = self
                
                let cell1 = self.clctn_SerachItems.cellForItem(at: IndexPath(item: 0, section:0)) as! SearchCell
                
                var customerCell:CustomerDetailCell!
                
                if !self.isHideDetail{
                    
                    customerCell = self.clctn_CustomerDetail.cellForItem(at: IndexPath(item: 4, section:0)) as! CustomerDetailCell
                }
                
                
                if self.activeTxtFld == cell1.txtFld_Search
                {
                    let newFrame = self.activeTxtFld.convert(self.activeTxtFld.frame, to: self.view)
                    pantryListVc.frame = CGRect(x: newFrame.minX, y: newFrame.minY+15, width: newFrame.size.width, height: 180.0)
                    
                    if self.arrPantryList.count>0{
                        pantryListVc.dropDownArr = self.arrPantryList
                    }
                }
                else if !self.isHideDetail, self.activeTxtFld == customerCell.txtFld_CustomerName
                {
                    let newFrame = self.activeTxtFld.convert(self.activeTxtFld.frame, to: self.view)
                    pantryListVc.frame = CGRect(x: newFrame.minX-5, y: newFrame.minY, width: newFrame.size.width, height: 180.0)
                    // pantryListVc.frame = CGRect(x: newFrame.minX, y: newFrame.maxY, width: newFrame.size.width, height: 180.0)
                    //                 //  pantryListVc.frame = CGRect(x: (customerCell.txtFld_CustomerName.superview?.superview?.frame.origin.x)!, y: (customerCell.txtFld_CustomerName.superview?.superview?.frame.origin.y)!+40, width: customerCell.txtFld_CustomerName.frame.size.width, height: 180)
                    //                    pantryListVc.frame = CGRect(x: ((16.5+customerCell.txtFld_CustomerName.frame.size.width)*4)-17.0 , y: self.clctn_CustomerDetail.frame.origin.y+customerCell.txtFld_CustomerName.frame.origin.y+40, width: customerCell.txtFld_CustomerName.frame.size.width, height: 180)
                    if self.runNumberList.count > 0
                    {
                        pantryListVc.dropDownValue = self.runNumberList
                    }
                }
                
                self.present(pantryListVc, animated: false, completion: nil)
            }
        }
    }
    
    func getUserAddresses()
    {
        let dicCartItem = [
            "CustomerID": UserInfo.shared.customerID
        ]
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: dicCartItem, strURL: SyncEngine.baseURL + SyncEngine.getCustomerAddressesRep) { (response : Any) in
            if let arrObj = response as? Array<Dictionary<String,Any>>, arrObj.count > 0
            {
                self.showAddressChoosePopup(suggestedAddresses: arrObj)
            }
            else
            {
                Helper.shared.showAlertOnController( message: "No shipping addresses found.", title: CommonString.app_name)
            }
        }
    }
    
    func showAddressChoosePopup(suggestedAddresses : Array<Dictionary<String,Any>>)
    {
        DispatchQueue.main.async {
            if let multipleObj = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: MultipleOptionPicker.storyboardIdentifier) as? MultipleOptionPicker
            {
                multipleObj.showMultipleOptionPickerOnWindow(forDisplayKeyName: "Address1", withDataSource: suggestedAddresses, withTitle: "Shipping Addresses", withSuccessButtonTitle: "OK", withCancelButtonTitle: "CANCEL", withAlertMessage: "Please choose shipping address.") { (selectedVal : Int) in
                    // Handle Response here.
                    if let addressID = suggestedAddresses[0]["AddressId"] as? NSNumber
                    {
                        Helper.shared.customerAppendDic_List["addressId"] = addressID
                    }
                }
            }
        }
    }
    
    @objc func notPantryAction(sender:UIButton)
    {
        if self.productList.count > sender.tag
        {
            var dic = self.productList[sender.tag]
            if let isNonPantry =  dic["IsNonPantry"] as? Bool, isNonPantry == true
            {
                dic["IsNonPantry"] = false
            }
            else
            {
                dic["IsNonPantry"] = true
            }
            productList[sender.tag] = dic
        }
        clctn_PantryList.reloadItems(at:[IndexPath(item: sender.tag, section:0)])
    }
    
    @objc func showQuantityPopupAction(_ sender : UIButton?)
    {
        let cell = self.clctn_PantryList.cellForItem(at: IndexPath.init(row: (sender?.tag)!, section: 0)) as? PantryListCell
        
        if  AppFeatures.shared.IsShowQuantityPopup == true {
            if true{
                if cell != nil{
                    if let index = self.clctn_PantryList.indexPath(for: cell!){
                        var product = productList[index.row]

                        if let circularPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "circularQuantityStoryboardID") as? CircularQuantityPopup
                        {
                            circularPopup.quantityPerUnit = Helper.shared.getSelectedUomNameQuantity(product: product).quantity
                            circularPopup.isEach =  Helper.shared.getSelectedUomNameQuantity(product: product).isEach
                            
                            if product.keyExists(key: "Quantity"), let number = product["Quantity"] as? NSNumber
                            {
                                circularPopup.circularSlider.currentValue = Float(truncating: number)
                                circularPopup.currentQuantity = "\(Double(truncating: number))"
                                
                                circularPopup.showCommonAlertOnWindow
                                    {
                                        product["Quantity"] = NSNumber(value: Double(circularPopup.txtFldQuantity.text!)!)
                                        self.productList[index.row] = product
                                        self.clctn_PantryList.reloadData()
                                        self.addProductToCartwithDatePicker(productDetail: product, actualIndex: index.row)
                                }
                            }
                            else
                            {
                                circularPopup.circularSlider.currentValue = 1.0
                                circularPopup.showCommonAlertOnWindow
                                    {
                                        product["Quantity"] = NSNumber(value: Double(circularPopup.txtFldQuantity.text!)!)
                                        self.productList[index.row] = product
                                        self.clctn_PantryList.reloadData()
                                        self.addProductToCartwithDatePicker(productDetail: product, actualIndex: index.row)
                                }
                            }
                            
                            if let bool = product["IsInCart"] as? Bool, bool == true
                            {
                                circularPopup.btnAddToCart.setTitle("UPDATE CART", for: .normal)
                            }
                        }
                    }
                }
            }
            else{
                self.showDatePicker {
                    self.showQuantityPopupAction(sender)
                }
            }
        }else {
            if cell != nil{
                self.activeTxtFldQty = cell!.txtFld_Qty
                self.clctn_PantryList.isScrollEnabled = false
                self.activeTxtFldQty.text = ""
                self.activeTxtFldQty.becomeFirstResponder()
            }
        }
    }
    
    func showDatePicker(withCompletion completion : @escaping dateSelectionCompleted) -> Void
    {
        if Helper.shared.isDateSelected() == false
        {
            if let orderDatePicker = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "datePickerStoryID") as? DatePickerView
            {
                orderDatePicker.modalPresentationStyle = .overCurrentContext
                self.present(orderDatePicker, animated: false, completion: nil)
                orderDatePicker.completionBlock = {(buttonPressed) -> Void in
                    if buttonPressed! != .backORFinishLator{
                        completion()
                        self.setPackingSequence()
                    }
                }
            }
            return
        }
        
    }
    
    @objc func addToCart(sender:UIButton){
        self.addProductToCartwithDatePicker(productDetail: productList[sender.tag], actualIndex: sender.tag)
    }
    
    func addProductToCartwithDatePicker ( productDetail : Dictionary<String, Any>, actualIndex : Int = -1)
    {
        let stockQuantity = productDetail["StockQuantity"] as? Double ?? 0.0

        if stockQuantity != 0.0 {
            
            if AppFeatures.shared.IsDatePickerEnabled == true {
                
                if true
                {
                    
                    self.showBuyInPopup(productDetail: productDetail, actualIndex: actualIndex)
                }
                else
                {
                    self.showDatePicker {
                        self.showBuyInPopup(productDetail: productDetail, actualIndex: actualIndex)
                    }
                }
            }else {
                
                self.showBuyInPopup(productDetail: productDetail, actualIndex: actualIndex)
            }
        }else {
            Helper.shared.showAlertOnController( message: "No stock available", title: CommonString.alertTitle)
        }
    }
    
    func showBuyInPopup( productDetail : Dictionary<String, Any>, actualIndex : Int = -1){
        
        let isBuyIn = productDetail["BuyIn"] as? Bool
        if /*AppFeatures.shared.isBuyIn*/ isBuyIn == true{
            
            if let buyInPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BuyInViewController") as? BuyInViewController
            {
                
                buyInPopup.showCommonAlertOnWindow {
                    
                    self.backOrder(productDetail: productDetail, actualIndex: actualIndex)
                }
            }
        }else {
            self.backOrder(productDetail: productDetail, actualIndex: actualIndex)
        }
    }
    
    func backOrder( productDetail : Dictionary<String, Any>, actualIndex : Int = -1){
        
        let sohValue = productDetail["StockQuantity"] as? Double ?? 0.0
        var qtyValue = Double(truncating:(productDetail["Quantity"] as? NSNumber) ?? 0.0)
        qtyValue = qtyValue == 0.0 ? 1.0:qtyValue
        var qtyPerUnit = 1.0
        
        var arrPrices : Array<Dictionary<String,Any>>?
        if let prices = productDetail["DynamicUOM"] as? Array<Dictionary<String,Any>>
        {
            arrPrices = prices
        }
        else if let prices = productDetail["Prices"] as? Array<Dictionary<String,Any>>
        {
            arrPrices = prices
        }
        else if let prices = productDetail["Prices"] as? Dictionary<String,Any>
        {
            arrPrices = [prices]
        }
        
        if let obj = productDetail["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1
        {
            var index : Int = 0
            if let selectedIndex = productDetail["selectedIndex"] as? Int
            {
                index = selectedIndex
            }else if index + 1 < obj.count{
                let testIndex = arrPrices?.index(where: { (testdic : Dictionary<String, Any>) -> Bool in
                    testdic["UOMID"] as? NSNumber == productDetail["UOMID"] as? NSNumber
                })
                if (testIndex != nil)
                {
                    index = testIndex!
                }
            }
            if (arrPrices != nil), arrPrices!.count > 0
            {
                let objToFetch = arrPrices![index]
                if let packSize = objToFetch["QuantityPerUnit"] as? Int {
                    
                    qtyPerUnit = Double(packSize)
                    qtyValue = qtyValue * Double(packSize)
                }
            }
        }
        var product = productDetail
        if !AppFeatures.shared.isBackOrder{
            product["Quantity"] = Int(qtyValue/qtyPerUnit)
            self.checkOrderMultiplies(productDetail: product, actualIndex: actualIndex)
        }else if sohValue > qtyValue{
            product["Quantity"] = Int(qtyValue/qtyPerUnit)
            self.checkOrderMultiplies(productDetail: product, actualIndex: actualIndex)
        }else {
            
            if let buyInPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:SaaviActionAlert.storyboardIdentifier) as? SaaviActionAlert
            {
                if sohValue <= 0{
                    
                    buyInPopup.showCommonAlertOnWindow(withTitle: "Important", withSuccessButtonTitle: "", withMessage: "Sorry, this product is out of stock at this moment.", withCancelButtonTitle: "Ok") {
                        product["Quantity"] = 1.0
                        self.productList[actualIndex] = product
                        self.clctn_PantryList.reloadData()
                    }
                }else if sohValue < qtyPerUnit || (sohValue < qtyValue && qtyPerUnit != 1) {
                    
                    buyInPopup.showCommonAlertOnWindow(withTitle: "Important", withSuccessButtonTitle: "", withMessage: "Sorry, there are only \(sohValue) units available. Only this quantity will be added to the cart", withCancelButtonTitle: "Ok") {
                        if let obj = productDetail["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1{
                            
                            for index in 0..<arrPrices!.count
                            {
                                let objToFetch = arrPrices![index]
                                if let packSize = objToFetch["QuantityPerUnit"] as? Int {
                                    
                                    if packSize == 1{
                                        
                                        product["UnitName"] = objToFetch["UOMDesc"] as? String
                                        product["OrderUnitName"] = objToFetch["UOMDesc"] as? String
                                        product["UOMID"] = objToFetch["UOMID"] as? NSNumber
                                        product["OrderUnitId"] = objToFetch["UOMID"] as? NSNumber
                                        product["Price"] = objToFetch["Price"]
                                        product["IsSpecial"] = objToFetch["IsSpecial"]
                                        product["IsPromotional"] = objToFetch["IsPromotional"]
                                        product["QuantityPerUnit"] = objToFetch["QuantityPerUnit"]
                                        product["selectedIndex"] = index
                                        product["Quantity"] = sohValue
                                        self.productList[actualIndex] = product
                                        self.clctn_PantryList.reloadData()
                                        self.checkOrderMultiplies(productDetail: product, actualIndex: actualIndex)
                                        break
                                    }
                                }
                            }
                        }
                    }
                }else {
                    
                    buyInPopup.showCommonAlertOnWindow(withTitle: "Important", withSuccessButtonTitle: "", withMessage: "Your order quantity is greater than  the stock on hand quantity of \(sohValue). Only the available quantity will be added to the cart.", withCancelButtonTitle: "Ok") {
                        
                        product["Quantity"] = Int(sohValue/qtyPerUnit)
                        self.productList[actualIndex] = product
                        self.clctn_PantryList.reloadData()
                        self.checkOrderMultiplies(productDetail: product, actualIndex: actualIndex)
                    }
                }
            }
        }
    }
    
    func checkOrderMultiplies(productDetail : Dictionary<String, Any>, actualIndex : Int = -1){

        var productDict = productDetail
        var unitToBedded = (productDetail.keyExists(key: "Quantity") && productDetail["Quantity"] as? Double != nil && Float(truncating: productDetail["Quantity"] as! NSNumber) != 0) ? (productDetail["Quantity"] as! Double) : 1

        let objToFetch = Helper.shared.getSelectedUOM(productDetail: productDetail)
        let arrayUomEach = ["EA","EACH"]
        let uomName = objToFetch["UOMDesc"] as? String
        let quantityPerUnit = objToFetch["QuantityPerUnit"] as? Int ?? 0

        unitToBedded = Helper.shared.calculateQuantityMultiplier(units: unitToBedded,quantityPerUnit:quantityPerUnit)

        if AppFeatures.shared.isOrderMultiples && arrayUomEach.contains((uomName?.uppercased())!.trimmingCharacters(in: .whitespacesAndNewlines)) {

            productDict["Quantity"] = unitToBedded
            DispatchQueue.main.async {
//                SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: "This item can only be ordered in multiples of \(quantityPerUnit). We are adding \(unitToBedded.cleanValue) to the cart.", withCancelButtonTitle: "OK", completion: {

                    self.addProductToCart(productDetail: productDict, actualIndex: actualIndex)
//                })
            }
        }else{
            self.addProductToCart(productDetail: productDetail, actualIndex: actualIndex)
        }
    }
    
    func addProductToCart( productDetail : Dictionary<String, Any>, actualIndex : Int = -1)
    {
        
        let objToFetch =  Helper.shared.getSelectedUOM(productDetail: productDetail)
        
        let requestDic = [
            "CartID": 0,
            "CustomerID": UserInfo.shared.customerID,
            "IsOrderPlpacedByRep": UserInfo.shared.isSalesRepUser!,
            "RunNo": "",
            "CommentLine": "",
            "PackagingSequence": 0,
            "CartItem": [
                "CartItemID": 0,
                "CartID":0,
                "ProductID": productDetail["ProductID"],
                "IsGstApplicable" : productDetail["IsGST"] as? Bool ?? false,
                "Quantity": (productDetail.keyExists(key: "Quantity") && productDetail["Quantity"] as? NSNumber != nil && Float(truncating: productDetail["Quantity"] as! NSNumber) != 0) ? (productDetail["Quantity"] as! NSNumber) : 1,
                "Price": objToFetch["Price"],
                "IsNoPantry": (productDetail["IsNonPantry"] as? Bool != nil) ? productDetail["IsNonPantry"] as! Bool : false,
                "UnitId": objToFetch["UOMID"],
                "IsSpecialPrice":  objToFetch["IsSpecial"]
            ]
            ] as [String : Any]

        let serviceURL = SyncEngine.baseURL + SyncEngine.addItemsToCart
        
        var uomDesc:String = ""
        
        switch objToFetch["UOMDesc"] as? String {
        case "EA","ea","Ea","EACH","each","Each":
            uomDesc = Int(truncating: (requestDic["CartItem"] as! Dictionary<String,Any>)["Quantity"] as! NSNumber) > 1 ? "units":"unit"
            break
        case "CARTON","Carton","carton":
            uomDesc = Int(truncating: (requestDic["CartItem"] as! Dictionary<String,Any>)["Quantity"] as! NSNumber) > 1 ? "cartons":"carton"
            break
        default:
            uomDesc = objToFetch["UOMDesc"] as? String ?? "EACH"
            break
        }
        
        var startStr = "Order Qty:1.00 UOM:\(uomDesc)"
        if Int(truncating: (requestDic["CartItem"] as! Dictionary<String,Any>)["Quantity"] as! NSNumber) > 1
        {
        let qtyStr = ((requestDic["CartItem"] as! Dictionary<String,Any>)["Quantity"] as! Double).cleanValue
        startStr = "\nOrder Qty: \(qtyStr)\nUOM: \(uomDesc)\n"
        }
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestDic, strURL: serviceURL) { (response : Any) in
            
            if let isAlreadyInCart = self.productList[actualIndex]["IsInCart"] as? Bool, isAlreadyInCart == false
            {
//                Helper.shared.showAlertOnController( message: startStr + " added to cart successfully", title: productDetail["ProductName"] as! String,hideOkayButton: true
                Helper.shared.showAlertOnController(message:"Added to cart successfully", title: "",hideOkayButton: true

                )
                Helper.shared.dismissAddedToCartAlert()
            }
            else
            {
//                Helper.shared.showAlertOnController( message: startStr + " updated in cart successfully", title: productDetail["ProductName"] as! String,hideOkayButton: true
                Helper.shared.showAlertOnController(message:"Updated in cart successfully", title: "",hideOkayButton: true

                )
                Helper.shared.dismissAddedToCartAlert()
            }
            
            
            if actualIndex > -1
            {
                self.productList[actualIndex] = productDetail
                self.productList[actualIndex]["IsInCart"] = true
                DispatchQueue.main.async {
                    self.clctn_PantryList.reloadData()
                }
            }
            
            self.callAPIToUpdateCartNumber()
        }
        
    }
    
    func callAPIToUpdateCartNumber()
    {
        let request = [
            "CartID": 0,
            "IsSavedOrder": false,
            "UserID": UserInfo.shared.userId!,
            "CustomerID": UserInfo.shared.customerID,
            "isRepUser": UserInfo.shared.isSalesRepUser!
            ] as [String : Any]
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: request, strURL: SyncEngine.baseURL + SyncEngine.getCartCountRep, withIndicator: false) { (response : Any) in
            if let obj = response as? Dictionary<String,Any>, let cartCount = obj["Count"] as? NSNumber ,let totalValue = (obj["TotalPrice"] as? Double) ,(obj["TotalPrice"] as? Double) != nil ,let cartID = obj["CartID"] as? NSNumber
            {
                DispatchQueue.main.async {
                    if cartCount == 0
                    {
                        Helper.shared.cartCount = 0
                        Helper.shared.cartOrderValue = 0
                        if (self.navigationItem.titleView as? UISearchBar) != nil
                        {
                            self.setDefaultNavigation()
                        }
                        self.clctn_CustomerDetail.reloadData()
                    }
                    else
                    {
                        Helper.shared.cartCount = Int(truncating: cartCount)
                        Helper.shared.cartOrderValue = totalValue
                        self.tempCartId = cartID
                        Helper.shared.salesRepTempCartId = cartID
                        self.clctn_CustomerDetail.reloadItems(at:[IndexPath(item: 7, section:0)])
                        if !(self.navigationItem.titleView is UISearchBar)
                        {
                            self.setDefaultNavigation()
                            self.clctn_CustomerDetail.reloadData()
                        }
                    }
                }
            }
            else{
                DispatchQueue.main.async {
                    Helper.shared.cartCount = 0
                    Helper.shared.cartOrderValue = 0
                    self.setDefaultNavigation()
                    self.clctn_CustomerDetail.reloadData()
                }
            }
            self.getCartItems(isReload: false)
        }
    }
    
    //MARK: WebService
    func setPantryItemsSortOrder(reqArr:Array<Any>,pantryListId:NSNumber)
    {
        
        let requestParameter = ["PantryListID": pantryListId,
                                "ProductID": reqArr] as [String : Any]
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestParameter, strURL: SyncEngine.baseURL + SyncEngine.setPantryItemsSortOrder) { (response: Any) in
            
            
        }
    }
    
    func getAllProductFilters()
    {
        let serviceUrl = SyncEngine.baseURL + SyncEngine.GetAllFilters
        
        SyncEngine.sharedInstance.sendGetRequestToServer(strURL: serviceUrl) { (response : Any) in
            
            if response is Array<Dictionary<String,Any>> && (response as! Array<Dictionary<String,Any>>).count > 0
            {
                self.arrFilters = (response as! Array<Dictionary<String,Any>>)
                DispatchQueue.main.async {
                    self.clctn_ItemType.reloadData()
                }
            }
        }
    }
    
    func getRepCustomerPantryLists()
    {
        let requestParameters = NSMutableDictionary()
        requestParameters.setValue(UserInfo.shared.customerID, forKey: "CustomerID")
        let serviceURL = SyncEngine.baseURL + SyncEngine.repCustomerPantryLists
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestParameters as! Dictionary<String, Any>, strURL: serviceURL) { (response : Any) in
            if (response as? Array<Dictionary<String,Any>>) != nil
            {
                self.arrPantryList = (response as! Array<Dictionary<String,Any>>)
                print(self.arrPantryList)
                if self.arrPantryList.count>0{
                    if self.isFirstTime == true{
                        self.pantryListIndex = 0
                    }
                    
                    self.pantryListId = (self.arrPantryList[self.pantryListIndex]["PantryListID"] as? NSNumber)!
                    self.pageNumber = 1
                    self.getAllDefaultPantryItems(searchText:"")
                    DispatchQueue.main.async {
                        self.filtersClctnHeightConstant.constant = 35.0 * VerticalSpacingConstraints.spacingConstant
                        if self.clctn_ItemType.viewWithTag(298) != nil
                        {
                            self.clctn_ItemType.viewWithTag(298)?.isHidden = false
                        }
                    }
                    
                }else{
                    DispatchQueue.main.async {
                        self.country_world_wide_lbl.isHidden = true
                        self.showNoItemsLabel()
                        self.filtersClctnHeightConstant.constant = 0.0
                        if self.clctn_ItemType.viewWithTag(298) != nil
                        {
                            self.clctn_ItemType.viewWithTag(298)?.isHidden = true
                        }
                    }
                    
                }
            }
            DispatchQueue.main.async {
                self.clctn_SerachItems.reloadData()
            }
        }
    }
    
    func getAllDefaultPantryItems(searchText:String)
    {
        self.totalResults = 0
        let requestParameters = NSMutableDictionary()
        requestParameters.setValue(10, forKey: "PageSize")
        requestParameters.setValue(pageNumber-1, forKey: "PageIndex")
        requestParameters.setValue(pantryListId, forKey: "PantryListID")
        requestParameters.setValue(self.filterID, forKey: "FilterID")
        requestParameters.setValue(searchText, forKey: "Searchtext")
        requestParameters.setValue(true, forKey: "IsRepUser")
        requestParameters.setValue(UserInfo.shared.customerID, forKey: "CustomerID")
        requestParameters.setValue(UserInfo.shared.userId!, forKey: "UserID")
        
        let serviceURL = SyncEngine.baseURL + SyncEngine.GetDefaultPantry
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestParameters as! Dictionary<String, Any>, strURL: serviceURL) { (response : Any) in
            if (response as? Dictionary<String,AnyObject>) != nil
            {
                if (self.pageNumber == 1)
                {
                    self.productList.removeAll()
                    self.allPantryItems.removeAll()
                }
                if (response is Dictionary<String,Any>) && (response as! Dictionary<String,Any>).keyExists(key: "products"), let productListArray = (response as! Dictionary<String,Any>)["products"] as? Array<Dictionary<String,Any>>
                {
                    self.hideNoItemsLabel()
                    self.productList += productListArray
                    self.allPantryItems += productListArray
                }
                
                if (response as! Dictionary<String,Any>).keyExists(key: "TotalResults"), let totalResults = (response as! Dictionary<String,Any>)["TotalResults"] as? NSNumber
                {
                    self.totalResults = totalResults
                    // if searchText == ""{
                    self.allResults = totalResults
                    //  }
                }
            }
            else
            {
                self.productList.removeAll()
                self.allPantryItems.removeAll()
            }
            
            DispatchQueue.main.async {
                
                if self.productList.count == 0 {
                    self.showNoItemsLabel()
                    self.country_world_wide_lbl.isHidden = true
                }
                self.clctn_PantryList.reloadData()
                self.clctn_ItemType.reloadData()
            }
        }
        
    }
    
    func callSearchProductWebService(with searchText : String = "")
    {
        let requestParameters = NSMutableDictionary()
        requestParameters.setValue(UserInfo.shared.customerID, forKey: "CustomerID")
        requestParameters.setValue(UserInfo.shared.customerID!, forKey: "listCustomerId")
        requestParameters.setValue(((self.categoryId) != nil) ? self.categoryId : 0, forKey: "MainCategoryID")
        requestParameters.setValue(0, forKey: "SubCategoryID")
        requestParameters.setValue(0, forKey: "FilterID")
        requestParameters.setValue(searchText, forKey: "Searchtext")
        requestParameters.setValue(false, forKey: "IsSpecial")
        requestParameters.setValue(10, forKey: "PageSize")
        requestParameters.setValue(pageNumber-1, forKey: "PageIndex")
        
        let serviceURL = SyncEngine.baseURL + SyncEngine.SearchProductsList
        
        
        if pageNumber == 1
        {
            self.productList.removeAll()
            self.clctn_PantryList.reloadData()
        }
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestParameters as! Dictionary<String, Any>, strURL: serviceURL) { (response : Any) in
            if (response as? Dictionary<String,AnyObject>) != nil
            {
                if (response is Dictionary<String,Any>) && (response as! Dictionary<String,Any>).keyExists(key: "products"), let productListArray = (response as! Dictionary<String,Any>)["products"] as? Array<Dictionary<String,Any>>
                {
                    self.productList += productListArray
                    
                    if self.productList.count == 0
                    {
                        self.showNoItemsLabel()
                    }
                    else
                    {
                        self.country_world_wide_lbl.isHidden = true
                        
                        self.hideNoItemsLabel()
                    }
                    
                    if (response as! Dictionary<String,Any>).keyExists(key: "TotalResults"), let totalResults = (response as! Dictionary<String,Any>)["TotalResults"] as? NSNumber
                    {
                        self.totalResults = totalResults
                        DispatchQueue.main.async {
                            self.clctn_PantryList.reloadData()
                            self.clctn_ItemType.reloadData()
                            
                        }
                    }
                }
            }
            else
            {
                DispatchQueue.main.async {
                    self.clctn_PantryList.reloadData()
                    self.clctn_ItemType.reloadData()
                    self.showNoItemsLabel()
                    self.country_world_wide_lbl.isHidden = true
                }
            }
        }
    }
    
    
    func showNoItemsLabel()
    {
        DispatchQueue.main.async
            {
                if self.view.viewWithTag(57) == nil
                {
                    let label = Helper.shared.createLabelWithMessage(message: "No items found.")
                    label.tag = 57
                    label.center = self.clctn_PantryList.center
                    self.view.addSubview(label)
                }
        }
    }
    
    func hideNoItemsLabel()
    {
        DispatchQueue.main.async {
            if let noRecordsLabel = self.view.viewWithTag(57) as? UILabel
            {
                noRecordsLabel.removeFromSuperview()
            }
            
        }
    }
    //    MARK:- Scroll View -
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate
        {
            if scrollView == clctn_PantryList {
                self.handlePaginationIfRequired(scrollView:  scrollView)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        if scrollView == clctn_PantryList{
            self.handlePaginationIfRequired(scrollView:  scrollView)
        }
    }
    
    func handlePaginationIfRequired(scrollView: UIScrollView)
    {
        if scrollView.contentSize.height < (scrollView.contentOffset.y + scrollView.frame.size.height + 5.0), totalResults != nil, Int(self.totalResults!) > self.productList.count
        {
            pageNumber += 1
            var searchText = ""
            if self.navigationItem.titleView is UISearchBar
            {
                searchText = (self.navigationItem.titleView as! UISearchBar).text!
            }
            
            
            if isSearchingProduct == true{
                if searchText != ""{
                    self.callSearchProductWebService(with: searchText)
                }
            }
            else{
                let cell = self.clctn_SerachItems.cellForItem(at: IndexPath(item: 1, section:0)) as! SearchCell
                self.getAllDefaultPantryItems(searchText: cell.txtFld_Search.text!)
            }
        }
    }
    
    //MARK:- UOM change method
    @objc func uOMChanged(sender : UIButton)
    {
        if let obj = self.productList[sender.tag]["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1
        {
            var index : Int = 0
            if let selectedIndex = self.productList[sender.tag]["selectedIndex"] as? Int
            {
                index = selectedIndex
            }
            
            if index + 1 < obj.count
            {
                var objToChange = self.productList[sender.tag]
                var newObj = obj[index+1]
                objToChange["UnitName"] = newObj["UOMDesc"] as? String
                objToChange["OrderUnitName"] = newObj["UOMDesc"] as? String
                objToChange["UOMID"] = newObj["UOMID"] as? NSNumber
                objToChange["OrderUnitId"] = newObj["UOMID"] as? NSNumber
                objToChange["Price"] = newObj["Price"]
                objToChange["IsSpecial"] = newObj["IsSpecial"]
                objToChange["IsPromotional"] = newObj["IsPromotional"]
                objToChange["QuantityPerUnit"] = newObj["QuantityPerUnit"]
                objToChange["selectedIndex"] = index + 1
                self.productList[sender.tag] = objToChange
                self.clctn_PantryList.reloadData()
            }
            else
            {
                var objToChange = productList[sender.tag]
                var newObj = obj[0]
                objToChange["selectedIndex"] = 0
                objToChange["UnitName"] = newObj["UOMDesc"] as? String
                objToChange["OrderUnitName"] = newObj["UOMDesc"] as? String
                objToChange["UOMID"] = newObj["UOMID"] as? NSNumber
                objToChange["OrderUnitId"] = newObj["UOMID"] as? NSNumber
                objToChange["Price"] = newObj["Price"]
                objToChange["IsSpecial"] = newObj["IsSpecial"]
                objToChange["IsPromotional"] = newObj["IsPromotional"]
                objToChange["QuantityPerUnit"] = newObj["QuantityPerUnit"]
                self.productList[sender.tag] = objToChange
                self.clctn_PantryList.reloadData()
            }
        }
        selectedDicForInfo = self.productList[sender.tag]
        self.getCartItems(isReload: false)
    }
    @objc func sendToDetailAction(sender:UIButton){
        if let destinationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrderDescriptionView") as? OrderDescriptionView{
            destinationViewController.productID = (self.productList[sender.tag]["ProductID"] as? NSNumber)!
            destinationViewController.isSalesRep = true
            //destinationViewController.salesRepCustomerId = UserInfo.shared.customerID
            self.navigationController?.pushViewController(destinationViewController, animated: true)
        }
    }
    
    @objc func showNotesScreen(){
        if let customerNotesVC = UIStoryboard.init(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "CustomerNotesVC") as? CustomerNotesVC
                      {
                           customerNotesVC.modalPresentationStyle = .fullScreen
                          self.present(customerNotesVC, animated: false, completion: nil)
                          
                     }
    }
    
    @objc func showEmailScreen(){
        if let sendPantryCopyPopup = UIStoryboard.init(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "SendPantryCopyPopup") as? SendPantryCopyPopup
                {
                    sendPantryCopyPopup.pantryListId = self.pantryListId
                    
                    sendPantryCopyPopup.modalPresentationStyle = .fullScreen
                    self.present(sendPantryCopyPopup, animated: false, completion: nil)
                    
               }
    }

    
    //MARK:- Navigation
    
    func setDefaultNavigation() -> Void
    {
        self.navigationItem.rightBarButtonItems = nil
        Helper.shared.createCartIcon(onController: self)
        Helper.shared.createSearchIcon(onController: self)
        Helper.shared.createCopyPantryItem(onController: self)
        Helper.shared.createNotesButtonItem(onController: self)
        Helper.shared.createEmailButtonItem(onController: self)

        if customerListDic.keyExists(key: "CustomerName"), let customerName = customerListDic["CustomerName"] as? String
        {
            Helper.shared.setNavigationTitle(viewController: self, title: customerName)
            Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
            UserInfo.shared.navigationTitle = customerName
        }
        else
        {
            Helper.shared.setNavigationTitle(viewController: self, title: CommonString.pantryListTitle)
            Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
            UserInfo.shared.navigationTitle = CommonString.pantryListTitle
        }
        
        if AppFeatures.shared.isShowBarcode{
            let barcodeButton = UIBarButtonItem(image:#imageLiteral(resourceName: "barcodeGray") , style: .plain, target: self, action: #selector(self.barCodeScanButtonAction))
            self.navigationItem.rightBarButtonItems?.append(barcodeButton)
        }
    }
    
    @objc func barCodeScanButtonAction()
    {
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BarCodeScanViewController") as? BarCodeScanViewController
        {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc func backBtnAction()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:-Copy PantryList Method
    func copyPantryListAction()
    {
        if let favorietController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addFavoriteListPopupSroryID") as? AddFavoriteListView
        {
            self.isFirstTime = false
            favorietController.parentController = self
            favorietController.isCopyingExistingPantry = true
            favorietController.isCreatedByRepUser = true
            favorietController.titleOfPopup = CommonString.addPantryTitle
            if Int(truncating: self.pantryListId) > 0
            {
                favorietController.pantryListToBeCopiedId = pantryListId as NSNumber
            }
            else
            {
                if self.productList.count > 0 , let pantryid = self.productList[0]["PantryListID"] as? NSNumber
                {
                    favorietController.pantryListToBeCopiedId = pantryid
                }
                else
                {
                    
                    Helper.shared.showAlertOnController( message: CommonString.emptyPantryListString, title: CommonString.alertTitle)
                    
                }
            }
            let pantryName = (arrPantryList[pantryListIndex]["PantryListName"] as! String).capitalized
            favorietController.titleOfPopup =  "\(CommonString.newPantryNameTitle) \(pantryName)."
            // }
            UIApplication.shared.keyWindow?.rootViewController?.present(favorietController, animated: false, completion: nil)
        }
    }
    
    @objc func showCartScreen() -> Void
    {
        if Helper.shared.cartCount == 0{
            Helper.shared.showAlertOnController( message: CommonString.noItemsAddedCartString, title: CommonString.app_name)
        }
        else{
            if let vc = UIStoryboard.init(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "MyCartVC") as? MyCartVC
            {
                //vc.customerId = UserInfo.shared.customerID
                //  vc.customerAppend_dic = customerAppendDic_List
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func deleteSaveOrder()
    {
        let request = [
            "orderID": self.tempCartId
            ] as [String : Any]
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: request, strURL: SyncEngine.baseURL + SyncEngine.deleteSavedOrder) { (response : Any) in
            Helper.shared.showAlertOnController( message: CommonString.orderDeletedString, title: CommonString.app_name)
            self.tempCartId = 0
            Helper.shared.cartCount = 0
            self.lblMarginvalue.text = ""
            self.lblMargin.text = ""
            DispatchQueue.main.async {
                self.clearOrder = "Clear Order"
                self.index = -1
                self.clctn_Features.reloadData()
                self.clctn_CustomerDetail.reloadData()
                self.getAllDefaultPantryItems(searchText: "")
                self.setDefaultNavigation()
            }
        }
    }
    
    func pantry_localSearch(){
        
        let cell = self.clctn_SerachItems.cellForItem(at: IndexPath(item: 1, section:0)) as! SearchCell
        isSearchingProduct = false
        self.selectedIndexPath = nil
        selectedDicForInfo = Dictionary<String,Any>()
        let searchText = cell.txtFld_Search.text
        if searchText == ""{
            self.btnClearSearch.isHidden = true
            self.productList.removeAll()
            self.productList = self.allPantryItems
            hideNoItemsLabel()
        }else{
            self.productList.removeAll()
            let namePredicate = NSPredicate(format: "ProductName contains[c] %@", "\(searchText!)")
            self.productList = self.allPantryItems.filter { namePredicate.evaluate(with: $0) }
        }
        self.clctn_PantryList.reloadData()
    }
    
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
            
        case .began:
            
            guard let selectedIndexPath = clctn_PantryList.indexPathForItem(at: gesture.location(in: clctn_PantryList)) else {
                
                break
                
            }
            
            clctn_PantryList.beginInteractiveMovementForItem(at: selectedIndexPath)
            
        case .changed:
            
            clctn_PantryList.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            
        case .ended:
            
            clctn_PantryList.endInteractiveMovement()
            
        default:
            
            clctn_PantryList.cancelInteractiveMovement()
            
        }
        
    }
    @objc func swipeMoved(sender : Any?) -> Void
    {
        if sender is UIPanGestureRecognizer, let gestureRecognizer = sender as? UIPanGestureRecognizer
        {
            if  gestureRecognizer.state == .changed {
                
                let translation = gestureRecognizer.translation(in: self.view)
                print(translation.x)
                if (gestureRecognizer.view?.frame.origin.x)! + translation.x > CGFloat(0)
                {
                    if ((gestureRecognizer.view?.center.x)! + translation.x) <  (gestureRecognizer.view?.bounds.width)!
                    {
                        UIView.transition(with: self.view, duration: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                            gestureRecognizer.view!.center = CGPoint(x: (gestureRecognizer.view!.center.x + translation.x) > (gestureRecognizer.view?.bounds.width)! ? (gestureRecognizer.view?.bounds.width)! : (gestureRecognizer.view!.center.x + translation.x) , y: gestureRecognizer.view!.center.y )
                        }, completion: { (finished: Bool) -> () in
                            
                        })
                    }
                    gestureRecognizer.view?.superview?.backgroundColor = UIColor.primaryColor()
                }
                else
                {
                    gestureRecognizer.view?.superview?.backgroundColor = UIColor.primaryColor()
                    if (gestureRecognizer.view?.center.x)! > 0.0
                    {
                        UIView.transition(with: self.view, duration: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                            gestureRecognizer.view!.center = CGPoint(x: (gestureRecognizer.view!.center.x + translation.x) < 0.0 ? 0.0 : (gestureRecognizer.view!.center.x + translation.x) , y: gestureRecognizer.view!.center.y )
                        }, completion: { (finished: Bool) -> () in
                            // completion
                        })
                    }
                }
            }
            else if gestureRecognizer.state == .ended
            {
                if (gestureRecognizer.view?.frame.minX)! > (((gestureRecognizer.view?.frame.size.width)! - (gestureRecognizer.view?.frame.size.width)!/2.0) - 20.0)
                {
                    print("add to cart.")
                    
                    if gestureRecognizer.view?.superview?.superview is PantryListCell
                    {
                        let cell = gestureRecognizer.view?.superview?.superview as! PantryListCell
                        var product = self.productList[(clctn_PantryList.indexPath(for: cell)?.row)!]
                        var quantity = Double(exactly:(product["Quantity"] as? NSNumber) ?? 0.0) ?? 0.0
                        if quantity > 0.0{
                            quantity += quantity
                        }
                        product["Quantity"] = quantity
             
                        self.addProductToCartwithDatePicker(productDetail: product, actualIndex: (clctn_PantryList.indexPath(for: cell)?.row)!)
                    }
                }
                    
                else if (gestureRecognizer.view?.frame.minX)! < ((0.0 - (gestureRecognizer.view?.frame.size.width)!/2.0) + 20.0)
                {
                    if gestureRecognizer.view?.superview?.superview is PantryListCell
                    {
                        let cell = gestureRecognizer.view?.superview?.superview as! PantryListCell
                        var product = self.productList[(clctn_PantryList.indexPath(for: cell)?.row)!]
                        var quantity = Double(exactly:(product["Quantity"] as? NSNumber) ?? 0.0) ?? 0.0
                        if quantity > 0.0{
                            quantity += quantity
                        }
                        product["Quantity"] = quantity
                        
                        self.addProductToCartwithDatePicker(productDetail: product, actualIndex: (clctn_PantryList.indexPath(for: cell)?.row)!)
                    }
                }
                UIView.transition(with: self.view, duration: 0.3, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    gestureRecognizer.view!.frame = (gestureRecognizer.view?.bounds)!
                }, completion: { (finished: Bool) -> () in
                })
            }
            gestureRecognizer.setTranslation(CGPoint.zero, in: gestureRecognizer.view?.superview)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func addProductToFavoriteList(productID : NSNumber,index:Int)
    {
        if AppFeatures.shared.isFavoriteList{
            if let chooseFavorite = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "choosefavouriteListPopupStoryboardIdentifier") as? ChooseFavouriteListPopup{
                chooseFavorite.productID = productID
                chooseFavorite.productID = productID
                chooseFavorite.showCommonAlertOnWindow(completion: { (isFav : Bool) in
                    self.productList[index]["IsInPantry"] = isFav
                    self.clctn_PantryList.reloadData()
                })
            }
        }else{
            self.addItemToDefaultPantry(productID: productID, index: index)
        }
    }
    
    func addItemToDefaultPantry(productID : NSNumber? ,index:Int){
        
        if productID != nil{
            let requestObj = [
                "PantryListID": 0,
                "ProductID": productID!,
                "Quantity": 0,
                "PantryType" : "F",
                "CustomerID":UserInfo.shared.customerID!
                ] as [String:Any]
            
            let serviceURL = SyncEngine.baseURL + SyncEngine.addItemToPantryList
            
            SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestObj, strURL: serviceURL) { (response : Any) in
                DispatchQueue.main.async {
                    
                    self.productList[index]["IsInPantry"] = true
                    self.clctn_PantryList.reloadData()
                    Helper.shared.showAlertOnController( message: "Product added successfully.", title: CommonString.app_name,hideOkayButton: true)
                    Helper.shared.dismissAlert()
                }
            }
        }
    }
}

class CustomerDetailCell: UICollectionViewCell {
    @IBOutlet weak var lbl_Customer: UILabel!
    @IBOutlet weak var txtFld_CustomerName: UITextField!
    
    override func awakeFromNib() {
        self.txtFld_CustomerName.font = UIFont.Roboto_Medium(baseScaleSize: 13.0)
        self.lbl_Customer.font = UIFont.Roboto_Medium(baseScaleSize: 15.0)
        self.lbl_Customer.textColor = UIColor.baseBlueColor()
        Helper.shared.setTextFieldBorder(textField: txtFld_CustomerName)
        self.txtFld_CustomerName.textColor = UIColor.priceInfoLightGreyColor()
    }
}

class SearchCell: UICollectionViewCell {
    
    @IBOutlet weak var lbl_Search: UILabel!
    @IBOutlet weak var txtFld_Search: UITextField!
    @IBOutlet weak var btnCross: UIButton!
    
    override func awakeFromNib() {
        
        self.txtFld_Search.font = UIFont.Roboto_Regular(baseScaleSize: 13.0)
        self.txtFld_Search.textColor = UIColor.darkGreyColor()
        //        Helper.shared.setTextFieldBorder(textField: txtFld_Search)
        self.txtFld_Search.backgroundColor = UIColor.white
        self.txtFld_Search.layer.borderWidth = 0.7 * Configration.scalingFactor()
        self.txtFld_Search.layer.borderColor = UIColor.baseBlueColor().cgColor
        
        self.lbl_Search.font = UIFont.Roboto_Medium(baseScaleSize: 15.0)
        self.lbl_Search.textColor = UIColor.baseBlueColor()
        
        Helper.shared.setLeftPaddingPoints(amount: 5.0, textField: self.txtFld_Search)
    }
}

class ButtonCell: UICollectionViewCell {
    @IBOutlet weak var btn_ShowOrder: UIButton!
    
    //  @IBOutlet weak var btn_ShowOrder: CustomButton!
    override func awakeFromNib() {
        self.btn_ShowOrder.titleLabel?.font = UIFont.Roboto_Medium(baseScaleSize: 12.0)
        self.btn_ShowOrder.titleLabel?.textColor = UIColor.baseBlueColor()
        self.btn_ShowOrder.layer.borderWidth = 0.6 * Configration.scalingFactor()
        self.btn_ShowOrder.layer.cornerRadius = 5.0 * Configration.scalingFactor()
        self.btn_ShowOrder.layer.borderColor = UIColor.baseBlueColor().cgColor
    }
}
class PantryListCell: UICollectionViewCell,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var lbl_code: UILabel!
    @IBOutlet weak var imgVwFavoriteIcon: UIImageView!
    @IBOutlet weak var lblStatus: PaddingLabel!
    @IBOutlet weak var lbl_Description: UILabel!
    @IBOutlet weak var lblMargin: UILabel!
    @IBOutlet weak var lblMarginValue: UILabel!
    @IBOutlet weak var img_Item: UIImageView!
    @IBOutlet weak var lbl_SalesHistory: UILabel!
    @IBOutlet weak var clctn_Week: UICollectionView!
    @IBOutlet weak var btn_Info: UIButton!
    @IBOutlet weak var btn_Sort: UIButton!
    @IBOutlet weak var btn_Cart: UIButton!
    @IBOutlet weak var txtFld_Qty: UITextField!
    @IBOutlet weak var lbl_priceEA: UILabel!
    @IBOutlet weak var lbl_Each: UILabel!
    @IBOutlet weak var img_UOM: UIImageView!
    @IBOutlet weak var btn_UOM: UIButton!
    @IBOutlet weak var lbl_SOH: UILabel!
    @IBOutlet weak var btn_NP: UIButton!
    @IBOutlet weak var lbl_UnitPrice: UILabel!
    @IBOutlet weak var lbl_Amount: UILabel!
    @IBOutlet weak var btn_GST: UIButton!
    @IBOutlet weak var arrowUOMDropdown: NSLayoutConstraint!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var btn_QtyPopUp: UIButton!
    
    @IBOutlet weak var salesHistoryWidthConstant: NSLayoutConstraint!
    @IBOutlet weak var weakClctnHeightConstant: NSLayoutConstraint!
    var weekDetailDict:Dictionary<String,Any> = [:]
    var weakArr = [["Weak":"Last\nMonth"],["Weak":"2\nMonths"],["Weak":"3\nMonths"],["Weak":"4\nMonths"],["Weak":"5\nMonths"],["Weak":"Last 6\nMonths"]]
    override func awakeFromNib()
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.img_Item.tintColor = UIColor.baseBlueColor()
        self.txtFld_Qty.layer.borderWidth = 1.0
        self.txtFld_Qty.layer.borderColor = UIColor.baseBlueColor().cgColor
        self.lbl_SalesHistory.font = UIFont.Roboto_Medium(baseScaleSize: 12.0)
        self.lblMargin.font = UIFont.Roboto_Medium(baseScaleSize: 15.0)
        self.lblMarginValue.font = UIFont.Roboto_Medium(baseScaleSize: 15.0)
        self.lbl_SalesHistory.textColor = UIColor.darkGreyColor()
        self.lbl_SalesHistory.adjustsFontSizeToFitWidth = true
        
        if AppFeatures.shared.isShowProductHistory == true {
            self.salesHistoryWidthConstant.constant = 60.0
            self.weakClctnHeightConstant.constant = 60.5
        }
        else{
            self.salesHistoryWidthConstant.constant = 0.0
            self.weakClctnHeightConstant.constant = 0.0
        }
        self.btn_Info.tintColor = UIColor.baseBlueColor()
        
        self.txtFld_Qty.keyboardType = UserInfo.shared.isSalesRepUser! ? .decimalPad:AppFeatures.shared.IsAllowDecimal ? .decimalPad:.numberPad
        self.imgVwFavoriteIcon.image =  #imageLiteral(resourceName: "add_to_cart").withRenderingMode(.alwaysTemplate)
        self.imgVwFavoriteIcon.tintColor = UIColor.white
    }
    
    func updateWeekDetail(){
        
        self.clctn_Week.delegate = self
        self.clctn_Week.dataSource = self
        self.clctn_Week.reloadData()
        
    }
    
    //MARK: - - Collectionview delegates & DataSources
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.weakArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let weakCell = collectionView.dequeueReusableCell(withReuseIdentifier: "weakCell", for: indexPath) as! weakCell
        weakCell.lbl_weakCount.text = self.weakArr[indexPath.row]["Weak"]
        weakCell.lbl_weakValue.text = "0"
        //var weekSalesDic = Dictionary<String,Any>()
        
        //        if indexPath.row<productList.count{
        //
        //            if let weeklySaleDic = productList[indexPath.row]["WeeklySales"] as? Dictionary<String,Any> , productList[indexPath.row]["WeeklySales"] as? Dictionary<String,Any> != nil{
        //                weekSalesDic = weeklySaleDic
        //            }
        //        }
        
        if indexPath.row == 0 {
            if (weekDetailDict.keyExists(key: "Week1Sales")), let weekSales = weekDetailDict["Week1Sales"] as? Double{
                let weekSalesStr = String(format: "%.0f", weekSales)
                weakCell.lbl_weakValue.text = weekSalesStr
            }
        }
        else if indexPath.row == 1 {
            if (weekDetailDict.keyExists(key: "Week2Sales")), let weekSales = weekDetailDict["Week2Sales"] as? Double{
                let weekSalesStr = String(format: "%.0f", weekSales)
                weakCell.lbl_weakValue.text = weekSalesStr
            }
        }
        else if indexPath.row == 2 {
            if (weekDetailDict.keyExists(key: "Week3Sales")), let weekSales = weekDetailDict["Week3Sales"] as? Double{
                let weekSalesStr = String(format: "%.0f", weekSales)
                weakCell.lbl_weakValue.text = weekSalesStr
            }
        }
        else if indexPath.row == 3 {
            if (weekDetailDict.keyExists(key: "Week4Sales")), let weekSales = weekDetailDict["Week4Sales"] as? Double{
                let weekSalesStr = String(format: "%.0f", weekSales)
                weakCell.lbl_weakValue.text = weekSalesStr
            }
        }
        else if indexPath.row == 4 {
            if (weekDetailDict.keyExists(key: "Week5Sales")), let weekSales = weekDetailDict["Week5Sales"] as? Double{
                let weekSalesStr = String(format: "%.0f", weekSales)
                weakCell.lbl_weakValue.text = weekSalesStr
            }
        }
        else if indexPath.row == 5 {
            if (weekDetailDict.keyExists(key: "Week6Sales")), let weekSales = weekDetailDict["Week6Sales"] as? Double{
                let weekSalesStr = String(format: "%.0f", weekSales)
                weakCell.lbl_weakValue.text = weekSalesStr
            }
        }
        else if indexPath.row == 6 {
            if (weekDetailDict.keyExists(key: "Week7Sales")), let weekSales = weekDetailDict["Week7Sales"] as? Double{
                let weekSalesStr = String(format: "%.0f", weekSales)
                weakCell.lbl_weakValue.text = weekSalesStr
            }
        }
        else if indexPath.row == 7 {
            if (weekDetailDict.keyExists(key: "Week8Sales")), let weekSales = weekDetailDict["Week8Sales"] as? Double{
                let weekSalesStr = String(format: "%.0f", weekSales)
                weakCell.lbl_weakValue.text = weekSalesStr
            }
        }
        return weakCell
    }
}

class FeatureCell: UICollectionViewCell {
    @IBOutlet weak var btn_Feature: UIButton!
    @IBOutlet weak var img_Feature: UIImageView!
    @IBOutlet weak var lbl_Feature: UILabel!
    @IBOutlet weak var view_BgFeature: UIView!
    @IBOutlet weak var featureLblWidthConstant: NSLayoutConstraint!
    
    override func awakeFromNib()
    {
        self.view_BgFeature.layer.borderWidth = 1.0
        self.view_BgFeature.layer.borderColor = UIColor.baseBlueColor().cgColor
        self.btn_Feature.semanticContentAttribute = .forceRightToLeft
        self.btn_Feature.setTitleColor(UIColor.black, for: .normal)
        self.lbl_Feature.font = UIFont.Roboto_Regular(baseScaleSize: 12.0)
    }
    
}
class ItemTypeCell: UICollectionViewCell {
    
    @IBOutlet weak var btn_Item: UIButton!
    
    override func awakeFromNib() {
        self.btn_Item.backgroundColor = UIColor.white
        self.btn_Item.titleLabel?.font = UIFont.Roboto_Regular(baseScaleSize: 14.0)
        self.btn_Item.setTitleColor(UIColor.priceInfoLightGreyColor(), for: .normal)
    }
}

class weakCell : UICollectionViewCell {
    
    @IBOutlet weak var lbl_weakCount: UILabel!
    @IBOutlet weak var lbl_weakValue: UILabel!
    
    override func awakeFromNib() {
        
        self.lbl_weakValue.layer.borderWidth = 0.6
        self.lbl_weakValue.layer.borderColor = UIColor.priceInfoLightGreyColor().cgColor
    }
}



