//
//  MyCartVC.swift
//  Saavi
//
//  Created by Irmeen Sheikh on 08/03/18.
//  Copyright © 2018 Saavi. All rights reserved.
//

import UIKit
import Lightbox

class MyCartVC: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate{
    
    @IBOutlet weak var clctn_customerInfo: UICollectionView!
    @IBOutlet weak var view_OrderValue: UIView!
    @IBOutlet weak var tbl_CartDetail: UITableView!
    @IBOutlet weak var lblMargin: UILabel!
    @IBOutlet weak var lblMarginValue: UILabel!
    @IBOutlet weak var lbl_TotalOrderValue: customLabelGrey!
    @IBOutlet weak var poPopupView: UIView!
    @IBOutlet weak var txtFldPONumber: CustomTextField!
    @IBOutlet weak var staticLblSelect: UILabel!
    @IBOutlet weak var txtVwCommentHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var btnSubmitPoNumber: UIButton!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var viewCommentBox: UIView!
    @IBOutlet weak var view_Header: UIView!
    @IBOutlet weak var sideView: UIView!
    @IBOutlet weak var btn_clear: UIButton!
    @IBOutlet weak var textViewAddComment: UITextView!
    @IBOutlet weak var poPopupBoudingView: UIView!
    @IBOutlet weak var lbl_AddComment: customLabelGrey!
    
    @IBOutlet weak var lblTitleSubTotal: UILabel!
    @IBOutlet weak var lblTitleGst: UILabel!
    @IBOutlet weak var lblSubTotal: UILabel!
    @IBOutlet weak var lblGst: UILabel!
    @IBOutlet weak var lblTitleTotal: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    
    var customerDetailArr = [["Key":"Customer"],["Key":"Account No."],["Key":"Delivery Date"],["Key":"Delivery Day"],["Key":"Run No."],["Key":"Packing SEQ"]]
    
    var isShowingSavedOrder = false
    var cartTotal : Double?
    var tempCartID : NSNumber = 0
    var arrCartItems = Array<Dictionary<String,Any>>()
    //var customerId : NSNumber = 0
    var poNumber: String?
    var addressId : NSNumber = 0
    var commentID : NSNumber?
    var commentString : String?
    var customerAppend_dic = Dictionary<String,Any>()
    var isNotPantry : Bool = false
    var txtFldActive = UITextField()
    var selectedIndexForComment = -1
    
    //MARK: - - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for view in view_Header.subviews
        {
            if view is UILabel
            {
                (view as! UILabel).font = UIFont.SFUI_Regular(baseScaleSize: 16.0)
            }
        }
        
        self.lblTitleSubTotal.font = UIFont.SFUIText_Regular(baseScaleSize: 18.0)
        self.lblTitleGst.font = UIFont.SFUIText_Regular(baseScaleSize: 18.0)
        self.lblSubTotal.font = UIFont.SFUIText_Regular(baseScaleSize: 18.0)
        self.lblGst.font = UIFont.SFUIText_Regular(baseScaleSize: 18.0)
        self.lblTitleTotal.font = UIFont.SFUIText_Regular(baseScaleSize: 18.0)
        self.lblTotal.font = UIFont.SFUIText_Semibold(baseScaleSize: 20.0)

        self.lbl_TotalOrderValue?.layer.borderWidth = 1.0
        self.lbl_TotalOrderValue?.layer.borderColor = UIColor.baseBlueColor().cgColor
        self.lbl_TotalOrderValue?.layer.cornerRadius = 5.0 * Configration.scalingFactor()
        self.view_Header.backgroundColor = UIColor.baseBlueColor()
        self.clctn_customerInfo.backgroundColor = UIColor.lightGreyColor()
        self.view_OrderValue.backgroundColor = UIColor.lightGreyColor()
        self.sideView.backgroundColor = UIColor.lightGreyColor()
        self.view.backgroundColor = UIColor.bgViewColor()
        self.tbl_CartDetail.backgroundColor = UIColor.bgViewColor()
        self.getCartItems()
        setDefaultNavigation()
        
        self.viewCommentBox.layer.borderWidth = 1.0
        self.viewCommentBox.layer.borderColor = UIColor.init(red: 229.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1.0).cgColor
        self.viewCommentBox.layer.cornerRadius = 5.0 * Configration.scalingFactor()
        
        self.lbl_AddComment.font = UIFont.Roboto_Italic(baseScaleSize: 17.0)
        self.staticLblSelect.font = UIFont.SFUIText_Semibold(baseScaleSize: 17.0)
        self.poPopupBoudingView.layer.cornerRadius = 0.7 * Configration.scalingFactor()
        
        self.txtFldPONumber.applyBorder()
        self.textViewAddComment.font = UIFont.Roboto_Italic(baseScaleSize: 15.0)
        self.textViewAddComment.text = "Add Delivery Comment"
        self.textViewAddComment.textColor = AppConfig.darkGreyColor()
        self.btnSubmitPoNumber.titleLabel?.font =  UIFont.SFUI_Regular(baseScaleSize: 16.0)
        self.btnSkip.titleLabel?.font =  UIFont.SFUI_Regular(baseScaleSize: 16.0)
        self.btnSkip.setTitleColor(UIColor.white, for: .normal)
        self.btnSubmitPoNumber.setTitleColor(UIColor.white, for: .normal)
        self.btnSkip.backgroundColor = UIColor.primaryColor()
        self.btnSubmitPoNumber.backgroundColor = UIColor.primaryColor2()
        
        self.txtFldPONumber.font = UIFont.SFUIText_Regular(baseScaleSize: 17.0)
        
        if Helper.shared.customerAppendDic_List.keyExists(key: "InvoiceDescription"), let commentString = Helper.shared.customerAppendDic_List["InvoiceDescription"] as? String{
            textViewAddComment.text = commentString
            self.btn_clear.isHidden = false
        }
        
        let tapReco : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hidePopupAction(reco:)))
        tapReco.numberOfTapsRequired  = 1
        tapReco.cancelsTouchesInView = true
        tapReco.delegate = self
        self.view.addGestureRecognizer(tapReco)
        self.lblMargin.textColor = UIColor.baseBlueColor()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.textViewAddComment.text.isEmpty || self.textViewAddComment.text == "Add Delivery Comment"{
            self.textViewAddComment.font = UIFont.Roboto_Italic(baseScaleSize: 15.0)
            self.textViewAddComment.text = "Add Delivery Comment"
        }else{
            self.textViewAddComment.font = UIFont.SFUIText_Regular(baseScaleSize: 15.0)
        }
        self.textViewAddComment.centerVertically()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:-  TableView delegate and datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrCartItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartCell") as? cartCell
        cell?.contentView.backgroundColor = UIColor.bgViewColor()
        
        cell?.btnShowImage.tag = indexPath.row
        cell?.btnShowImage.addTarget(self, action: #selector(self.btnShowImage), for: .touchUpInside)
        
        cell?.btnPencil.tag = indexPath.row
        cell?.btnPencil.addTarget(self, action: #selector(btnAddCommentAction), for: .touchUpInside)
        
        if indexPath.row%2 == 0{
            cell?.View_main.backgroundColor =  UIColor.evenRowColor()
        }
        else{
            cell?.View_main.backgroundColor = UIColor.oddRowColor()
        }
        let objToBeShownInRow = self.arrCartItems[indexPath.row]
        
        DispatchQueue.main.async {
            cell?.lblProductStatus.layer.cornerRadius = 12
        }
        if let new = objToBeShownInRow["ProductIsNew"] as? Bool, new == true {
            cell?.lblProductStatus.text = "NEW"
            cell?.lblProductStatus.backgroundColor = UIColor.primaryColor()
        }else if let new = objToBeShownInRow["ProductIsOnSale"] as? Bool, new == true {
            cell?.lblProductStatus.text = "SALE"
            cell?.lblProductStatus.backgroundColor = UIColor.primaryColor2()
        }else if let new = objToBeShownInRow["ProductIsBackSoon"] as? Bool, new == true {
            cell?.lblProductStatus.text = "INCOMING"
            cell?.lblProductStatus.backgroundColor = UIColor.primaryColor3()
        }else{
            cell?.lblProductStatus.text = ""
        }
        
        cell?.lbl_code.text = (objToBeShownInRow["ProductCode"] as? String)
        cell?.txtFld_qty.tag = indexPath.row
        cell?.txtFld_qty.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonClicked))
        cell?.lbl_ProductName.text = (objToBeShownInRow["ProductName"] as? String)?.trimmingCharacters(in: .whitespaces)
        
//        if objToBeShownInRow.keyExists(key: "IsStatusIN"),objToBeShownInRow["IsStatusIN"] as? Bool == true{
//            cell?.lbl_ProductName.textColor = UIColor.blue
//        }
        
        if AppFeatures.shared.isHighlightRewardItem
        {
            if objToBeShownInRow["IsCountrywideRewards"] as? Bool == false{
                cell?.lbl_ProductName.textColor = UIColor.darkGreyColor()
            }
            else{
                cell?.lbl_ProductName.textColor = UIColor.init(hex: "#b0cf00")
            }
        }
        else
        {
            cell?.lbl_ProductName.textColor = UIColor.darkGreyColor()
        }
        if let isBuyIn =  objToBeShownInRow["BuyIn"] as? Bool, isBuyIn == true
        {
            cell?.lbl_ProductName.textColor = UIColor.init(hex: "#2a99f3")
        }


        
        cell?.btn_NP.tag = indexPath.row
        cell?.btn_NP.addTarget(self, action: #selector(notPantryAction(sender:)), for: .touchUpInside)
        if let isInPantry =  objToBeShownInRow["IsNoPantry"] as? Bool, isInPantry == true
        {
            // self.isNotPantry = true
            cell?.btn_NP.setImage(#imageLiteral(resourceName: "check1"), for: .normal)
            cell?.btn_NP.tintColor = UIColor.baseBlueColor()
            
        }else{
            
            cell?.btn_NP.setImage(#imageLiteral(resourceName: "unCheck1"), for: .normal)
            cell?.btn_NP.tintColor = UIColor.activeTextFieldColor()
        }
        
        if let quantity = objToBeShownInRow["Quantity"] as? Double
        {
            cell?.txtFld_qty.text = quantity.cleanValue
        }
        if objToBeShownInRow.keyExists(key: "StockQuantity"), let StockQuantity = objToBeShownInRow["StockQuantity"] as? Double{
            cell?.lbl_SOH.text = String(format: "%.0f", StockQuantity) //String(describing: StockQuantity)
        }
        if let isGST =  objToBeShownInRow["IsGST"] as? Bool, isGST == true
        {
            cell?.btn_GST.setImage(UIImage(named:"shape1"), for: .normal)
        }
        else{
            cell?.btn_GST.setImage(UIImage(named:""), for: .normal)
        }
        cell?.btn_Dlt.tag = indexPath.row
        cell?.btn_Dlt.addTarget(self, action: #selector(self.removeProductFromCartAction(sender:)), for: UIControlEvents.touchUpInside)
        cell?.btn_UOM.tag = indexPath.row
        cell?.btn_UOM.addTarget(self, action: #selector(self.uOMChanged(sender:)), for: .touchUpInside)
        
        if let obj = objToBeShownInRow["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1
        {
            cell?.arrowUOMDropdown.constant = 10.0
        }
        else
        {
            cell?.arrowUOMDropdown.constant = 0.0
        }
        
        if objToBeShownInRow["IsSpecial"] as? Bool == true && objToBeShownInRow["IsPromotional"] as? Bool == true{
            cell?.lbl_Price.textColor = UIColor.red
        }
        else if objToBeShownInRow["IsSpecial"] as? Bool == true{
            cell?.lbl_Price.textColor = UIColor.red
        }
        else if objToBeShownInRow["IsPromotional"] as? Bool == true{
            cell?.lbl_Price.textColor = UIColor.promotionalProductYellowColor()
        }
        else{
            cell?.lbl_Price.textColor = UIColor.priceInfoLightGreyColor()
        }
        
        if objToBeShownInRow.keyExists(key: "OrderUnitName"), let orderUnitName = objToBeShownInRow["OrderUnitName"] as? String{
            cell?.lbl_each.text = orderUnitName
        }
        else
        {
            cell?.lbl_each.text = ""
        }
        if objToBeShownInRow.keyExists(key: "PriceTotal"), let amount = objToBeShownInRow["PriceTotal"] as? Double{
            let amountTotal = String(format: "\(CommonString.currencyType)%.2f", amount)
            cell?.lbl_Amount.text = amount <= 0 ? CommonString.marketprice:amountTotal
        }
        
        var arrPrices : Array<Dictionary<String,Any>>?
        if let prices = objToBeShownInRow["DynamicUOM"] as? Array<Dictionary<String,Any>>
        {
            arrPrices = prices
        }
        else if let prices = objToBeShownInRow["Prices"] as? Array<Dictionary<String,Any>>
        {
            arrPrices = prices
        }
        else if let prices = objToBeShownInRow["Prices"] as? Dictionary<String,Any>
        {
            //            prices["UOMDesc"] = objToBeShownInRow["OrderUnitName"] as? String
            //            prices["UOMID"] = objToBeShownInRow["OrderUnitId"] as? NSNumber
            arrPrices = [prices]
        }
        
        
        if (arrPrices != nil), arrPrices!.count > 0
        {
            let index = arrPrices?.index(where: { (testdic : Dictionary<String, Any>) -> Bool in
                testdic["UOMDesc"] as? String == objToBeShownInRow["OrderUnitName"] as? String
            })
            
            let objToFetch = arrPrices![index!]
            
            if objToFetch["IsSpecial"] as? Bool == true && objToFetch["IsPromotional"] as? Bool == true{
                cell?.lbl_Price.textColor = UIColor.red
                cell?.lbl_Amount.textColor = UIColor.red
            }
            else if objToFetch["IsSpecial"] as? Bool == true{
                cell?.lbl_Price.textColor = UIColor.red
                cell?.lbl_Amount.textColor = UIColor.red
            }
            else if objToFetch["IsPromotional"] as? Bool == true{
                cell?.lbl_Price.textColor = UIColor.promotionalProductYellowColor()
                cell?.lbl_Amount.textColor = UIColor.promotionalProductYellowColor()
            }
            else{
                cell?.lbl_Price.textColor = UIColor.priceInfoLightGreyColor()
                cell?.lbl_Amount.textColor = UIColor.priceInfoLightGreyColor()
            }
            
            var selectedIndex = 0
            if let index = objToBeShownInRow["selectedIndex"] as? Int
            {
                selectedIndex = index
            }
            if let price = objToFetch["Price"] as? Double
            {
                let price_final = Double(round(100*price)/100)

                let priceStr = String(format: "\(CommonString.currencyType)%.2f", price_final)
                cell?.lbl_Price.text = price <= 0 ? CommonString.marketprice:priceStr
                // cell?.lbl_Amount.text = String(format: "$%.2f",price * Double(cell!.txtFld_qty.text!)!)
                cell?.lbl_each.text = objToFetch["UOMDesc"] as? String
                
            }
            cell?.lbl_each.textColor = UIColor.gray
            if objToBeShownInRow.keyExists(key: "LastOrderUOMID"), let lastUom = objToBeShownInRow["LastOrderUOMID"] as? Int, lastUom == objToFetch["UOMID"] as? Int, lastUom > 0{
                cell?.lbl_each.textColor = UIColor.gray
            }
        }
        else
        {
            if let price = objToBeShownInRow["Price"] as? Double
            {
                let price_final = Double(round(100*price)/100)

                let priceStr = String(format: "\(CommonString.currencyType)%.2f", price_final)
                cell?.lbl_Price.text = price <= 0 ? CommonString.marketprice:priceStr
                //  cell?.lbl_Amount.text = String(format: "$%.2f",price * Double(cell!.txtFld_qty.text!)!)
            }
            cell?.lbl_each.text = objToBeShownInRow["UOMDesc"] as? String
            
            if objToBeShownInRow["IsSpecial"] as? Bool == true && objToBeShownInRow["IsPromotional"] as? Bool == true{
                cell?.lbl_Price.textColor = UIColor.red
                cell?.lbl_Amount.textColor = UIColor.red
            }
            else if objToBeShownInRow["IsSpecial"] as? Bool == true{
                cell?.lbl_Price.textColor = UIColor.red
                cell?.lbl_Amount.textColor = UIColor.red
            }
            else if objToBeShownInRow["IsPromotional"] as? Bool == true{
                cell?.lbl_Price.textColor = UIColor.promotionalProductYellowColor()
                cell?.lbl_Amount.textColor = UIColor.promotionalProductYellowColor()
            }
            else{
                cell?.lbl_Price.textColor = UIColor.priceInfoLightGreyColor()
                cell?.lbl_Amount.textColor = UIColor.priceInfoLightGreyColor()
            }
        }
        
        cell?.btnPencil.isSelected = false
        
        if Int(truncating: objToBeShownInRow["ProdCommentID"] as? NSNumber ?? 0) > 0 {
            
            cell?.btnPencil.isSelected = true
        }
        
        cell?.txtFld_qty.resizeFont()
        cell?.txtFld_qty.delegate = self
        
        
        
        
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    @objc func btnShowImage(sender : UIButton){
        
        let objToBeShownInRow = self.arrCartItems[sender.tag]
        
        if let images = objToBeShownInRow["ProductImages"] as? Array<Dictionary<String,Any>>, images.count > 0
        {
            let originalString:String = (images[0]["ImageName"]! as! String)
            let urlString:String = originalString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
            
            let images = [LightboxImage.init(imageURL:URL(string: urlString)!)]
            let controller = LightboxController(images: images)
            
            controller.pageDelegate = self
            controller.dismissalDelegate = self
            controller.modalPresentationStyle = .fullScreen
                      
          //  controller.dynamicBackground = true
            
            present(controller, animated: true, completion: nil)
        }
    }
    
    @objc func btnAddCommentAction(sender : UIButton)
    {
        if let commentListingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addCommentsStoryboardID") as? ChooseCommentView
        {
            commentListingVC.saleseRepSenderView = self
            let objToBeShownInRow = self.arrCartItems[sender.tag]
            
            let productId = (objToBeShownInRow["ProductID"] as! NSNumber)
            print(productId)
            commentListingVC.productId = productId
            commentListingVC.productDict = objToBeShownInRow
            self.commentID = objToBeShownInRow["ProdCommentID"] as? NSNumber ?? 0
            self.selectedIndexForComment = sender.tag
            UIApplication.shared.keyWindow?.rootViewController?.present(commentListingVC, animated: false, completion: nil)
        }
        
    }
    
    
    //MARK:- CollectionView delegate and datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return customerDetailArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CartCustomerInfoCell", for: indexPath) as! CartCustomerInfoCell
        cell.lbl_heading.text = customerDetailArr[indexPath.row]["Key"]
        cell.txtFld_CustomerDetail.isUserInteractionEnabled = false
        if Helper.shared.customerAppendDic_List.count>0{
            if indexPath.row == 0
            {
                if Helper.shared.customerAppendDic_List.keyExists(key: "CustomerName"), let customerName = Helper.shared.customerAppendDic_List["CustomerName"] as? String{
                    cell.txtFld_CustomerDetail.text = customerName
                }
                else{
                    cell.txtFld_CustomerDetail.text = "N/A"
                }
            }
            if indexPath.row == 1
            {
                if Helper.shared.customerAppendDic_List.keyExists(key: "AlphaCode"), let alphaCode = Helper.shared.customerAppendDic_List["AlphaCode"] as? String{
                    cell.txtFld_CustomerDetail.text = alphaCode
                }
                else{
                    cell.txtFld_CustomerDetail.text = "N/A"
                }
            }
            if indexPath.row == 2
            {
                if Helper.shared.customerAppendDic_List.keyExists(key: "dateOfDelivery"), let dateOfDelivery = Helper.shared.customerAppendDic_List["dateOfDelivery"] as? String{
                    cell.txtFld_CustomerDetail.text = dateOfDelivery
                }
                else{
                    cell.txtFld_CustomerDetail.text = "N/A"
                }
            }
            if indexPath.row == 3
            {
                
                if Helper.shared.customerAppendDic_List.keyExists(key: "dayOfDelivery"), let dayOfDelivery = Helper.shared.customerAppendDic_List["dayOfDelivery"] as? String{
                    cell.txtFld_CustomerDetail.text = dayOfDelivery
                }
                else{
                    cell.txtFld_CustomerDetail.text = "N/A"
                }
            }
            if indexPath.row == 4
            {
                if Helper.shared.customerAppendDic_List.keyExists(key: "RunNo"), let runNo = Helper.shared.customerAppendDic_List["RunNo"] as? String, runNo != ""{
                    cell.txtFld_CustomerDetail.text = runNo
                }
                else
                {
                    cell.txtFld_CustomerDetail.text = "N/A"
                }
            }
            if indexPath.row == 5
            {
                if Helper.shared.customerAppendDic_List.keyExists(key: "packingSEQ"), let packingSEQ = Helper.shared.customerAppendDic_List["packingSEQ"] as? String{
                    cell.txtFld_CustomerDetail.text = packingSEQ
                }
                else{
                    cell.txtFld_CustomerDetail.text = "0"
                }
            }
            
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: collectionView.bounds.size.width/CGFloat(customerDetailArr.count)-10, height: collectionView.bounds.size.height)
        
    }
    
    @objc func doneButtonClicked(_ textField: UITextField) {
        
        //
        if textField == txtFldActive{
            
            var product = self.arrCartItems[textField.tag]
            
            let qtyDoubleValue:Double = (textField.text?.isEmpty)! ? 1.00:Double(textField.text!)!
            let qtyValue = qtyDoubleValue <= 0 ? 1.00:qtyDoubleValue
            
            product["Quantity"] = NSNumber(value: qtyValue)
            self.arrCartItems[textField.tag] = product
            product = self.arrCartItems[textField.tag]
            self.backOrder(dic: product, index: textField.tag)
            
        }
        
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == self.txtFldActive{
            
            self.txtFldActive.text = ((textField.text?.isEmpty)!) ? (AppFeatures.shared.IsAllowDecimal ? 0.00.cleanValue: UserInfo.shared.isSalesRepUser! ? 0.00.cleanValue:"0"):textField.text
            self.tbl_CartDetail.reloadData()
        }
        
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == txtFldPONumber
        {
            return true
            
        }else{
            
            var viewToSearch = textField.superview
            repeat
            {
                viewToSearch = viewToSearch?.superview
            } while (viewToSearch as? cartCell) == nil
            
            
            if AppFeatures.shared.IsShowQuantityPopup == true{
                
                if let cell = viewToSearch as? cartCell
                {
                    if let index = self.tbl_CartDetail.indexPath(for: cell)
                    {
                        var product = arrCartItems[index.row]

                        if let circularPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "circularQuantityStoryboardID") as? CircularQuantityPopup
                        {
                            circularPopup.quantityPerUnit = Helper.shared.getSelectedUomNameQuantity(product: product).quantity
                            circularPopup.isEach =  Helper.shared.getSelectedUomNameQuantity(product: product).isEach
                            
                            if product.keyExists(key: "Quantity")
                            {
                                circularPopup.circularSlider.currentValue = Float((( product["Quantity"]) as? NSNumber)!)
                                circularPopup.currentQuantity = "\(Double(truncating: (( product["Quantity"]) as? NSNumber)!))"
                                
                            }
                            else
                            {
                                circularPopup.circularSlider.currentValue = 1.0
                            }
                            
                            circularPopup.showCommonAlertOnWindow
                                {
                                    product["Quantity"] = NSNumber(value: Double(circularPopup.txtFldQuantity.text!)!)
                                    self.arrCartItems[index.row] = product
                                    self.backOrder(dic: product, index: index.row)
                                    self.tbl_CartDetail.reloadData()
                            }
                            circularPopup.btnAddToCart.setTitle("UPDATE CART", for: .normal)
                        }
                    }
                }
                return false
            }else {
                self.txtFldActive = textField
                self.txtFldActive.text = ""
                return true
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text == "", string == " "{
            
            return false
        }else if string == "\n"{
            
            textField.resignFirstResponder()
            textField.endEditing(true)
            
        }/*else if textField == txtFldPONumber{
            
            let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            if textField == txtFldPONumber
            {
                return newText.count<=30
            }
            
        }*/else if textField == self.txtFldActive{
            
            if !UserInfo.shared.isSalesRepUser! && !AppFeatures.shared.IsAllowDecimal{
                if  string == "."{
                    return false
                }
            }
            
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
    
    func backOrder(dic : Dictionary<String,Any> ,index:Int){
        
        let sohValue = dic["StockQuantity"] as? Double ?? 0.0
        var qtyValue = Double(truncating:(dic["Quantity"] as? NSNumber) ?? 0.0)
        qtyValue = qtyValue == 0.0 ? 1.0:qtyValue
        var qtyPerUnit = 1.0
        var arrPrices : Array<Dictionary<String,Any>>?
        if let prices = dic["DynamicUOM"] as? Array<Dictionary<String,Any>>
        {
            arrPrices = prices
        }
        else if let prices = dic["Prices"] as? Array<Dictionary<String,Any>>
        {
            arrPrices = prices
        }
        else if let prices = dic["Prices"] as? Dictionary<String,Any>
        {
            arrPrices = [prices]
        }
        
        if (arrPrices != nil), arrPrices!.count > 0
        {
            let testIndex = arrPrices?.index(where: { (testdic : Dictionary<String, Any>) -> Bool in
                testdic["UOMID"] as? NSNumber == dic["UOMID"] as? NSNumber
            })
            
            let objToFetch = arrPrices![testIndex ?? 0]
            if let packSize = objToFetch["QuantityPerUnit"] as? Int {
                qtyPerUnit = Double(packSize)
                qtyValue = qtyValue * Double(packSize)
            }
        }
        var product = dic
        if !AppFeatures.shared.isBackOrder{
            product["Quantity"] = qtyValue
            self.updateCartItemObjWithObj(dic :product,index:index )
        }else if sohValue > qtyValue{
            product["Quantity"] = qtyValue
            self.updateCartItemObjWithObj(dic :product,index:index )
        }else {
            
            if let buyInPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:SaaviActionAlert.storyboardIdentifier) as? SaaviActionAlert
            {
                if sohValue <= 0{
                    
                    buyInPopup.showCommonAlertOnWindow(withTitle: "Important", withSuccessButtonTitle: "", withMessage: "Sorry, this product is out of stock at this moment.", withCancelButtonTitle: "Ok") {
                        self.getCartItems()
                    }
                }else if sohValue < qtyPerUnit || (sohValue < qtyValue && qtyPerUnit != 1) {
                    buyInPopup.showCommonAlertOnWindow(withTitle: "Important", withSuccessButtonTitle: "", withMessage: "Sorry, there are only \(sohValue) units available. Only this quantity will be added to the cart", withCancelButtonTitle: "Ok") {
                        if let obj = dic["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1{
                            
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
                                        self.updateCartItemObjWithObj(dic :product,index:index )
                                        break
                                    }
                                }
                            }
                        }
                    }
                }else {
                    buyInPopup.showCommonAlertOnWindow(withTitle: "Important", withSuccessButtonTitle: "", withMessage: "Your order quantity is greater than  the stock on hand quantity of \(sohValue). Only the available quantity will be added to the cart.", withCancelButtonTitle: "Ok") {
                        
                        product["Quantity"] = Int(sohValue/qtyPerUnit)
                        
                        self.updateCartItemObjWithObj(dic :product,index:index )
                    }
                }
            }
        }
    }
    
    func updateCartItemObjWithObj(dic : Dictionary<String,Any> ,index:Int)
    {
        
        var arrPrices : Array<Dictionary<String,Any>>?
        if let prices = dic["DynamicUOM"] as? Array<Dictionary<String,Any>>
        {
            arrPrices = prices
        }
        else if let prices = dic["Prices"] as? Array<Dictionary<String,Any>>
        {
            arrPrices = prices
        }
        else if let prices = dic["Prices"] as? Dictionary<String,Any>
        {
            arrPrices = [prices]
        }
        
        
        if (arrPrices != nil), arrPrices!.count > 0
        {
            let index = arrPrices?.index(where: { (testdic : Dictionary<String, Any>) -> Bool in
                testdic["UOMDesc"] as? String == dic["OrderUnitName"] as? String
            })
            let objToFetch = arrPrices![index!]
            
            let dic = [
                "CartItemID": (dic["CartItemID"] as? NSNumber)!,
                "CartID": (dic["CartID"] as? NSNumber)!,
                "ProductID": (dic["ProductID"] as? NSNumber)!,
                "Quantity": (dic["Quantity"] as? NSNumber)!,
                "IsNoPantry":(dic["IsNoPantry"] as? Bool)!,
                "Price": (objToFetch["Price"] as? Double)!,
                "UnitId": (objToFetch["UOMID"] as? NSNumber)!,
                "IsSpecialPrice":  (dic["IsSpecial"] as? Bool)!,
                "CommentID": self.commentID == nil ? (dic["ProdCommentID"] as? NSNumber ?? 0)!: self.commentID!
                ] as [String : Any]
            
            SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: dic, strURL: SyncEngine.baseURL + SyncEngine.updateCartItem) { (response : Any) in
                NotificationCenter.default.post(name: Notification.Name("addToCart"), object: nil, userInfo: ["ProductID":(dic["ProductID"] as? NSNumber)! , "Quantity":(dic["Quantity"] as? NSNumber) ?? 1])
                
                self.commentID = nil
                Helper.shared.showAlertOnController( message: "Product Updated successfully.", title: CommonString.app_name,hideOkayButton: true)
                Helper.shared.dismissAlert()
                //             if let items = (response as? Dictionary<String,Any>){
                //                if items.keyExists(key: "PriceTotal"), let amount = items["PriceTotal"] as? Double{
                //                DispatchQueue.main.async {
                //                let cell = self.tbl_CartDetail.cellForRow(at: IndexPath(row: index, section: 0)) as? cartCell
                //                cell?.lbl_Amount.text =  String(format: "$%.2f", amount)
                //                }
                //            }
                //            }
                self.getCartItems()
            }
        }
    }
    
    @objc func notPantryAction(sender:UIButton){
        
        if let isInPantry =  self.arrCartItems[sender.tag]["IsNoPantry"] as? Bool, isInPantry == true {
            self.arrCartItems[sender.tag]["IsNoPantry"] = false
        }
        else {
            self.arrCartItems[sender.tag]["IsNoPantry"] = true
        }
        let product = arrCartItems[sender.tag]
        self.backOrder(dic: product, index: sender.tag)
        self.tbl_CartDetail.reloadRows(at:[IndexPath(item: sender.tag, section:0)] , with: .none)
    }
    
    @objc func removeProductFromCartAction(sender : UIButton)
    {
        if let itemID = self.arrCartItems[sender.tag]["CartItemID"] as? NSNumber,let productID = self.arrCartItems[sender.tag]["ProductID"] as? NSNumber, let itemName = (self.arrCartItems[sender.tag]["ProductName"] as? String)
        {
            
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.deleteProdTitle, withSuccessButtonTitle: "Yes", withMessage: "Are you sure you want to remove \(itemName) from cart?", withCancelButtonTitle: "No", completion:{
                self.callAPIToRemoveItemFromCart(cartItemID: itemID, productID: productID,index: sender.tag)
            })
        }
    }
    
    func callAPIToRemoveItemFromCart(cartItemID : NSNumber , productID : NSNumber,index:Int)
    {
        let dicCartItem = [
            "CartItemID": cartItemID,
            ]
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: dicCartItem, strURL: SyncEngine.baseURL + SyncEngine.deleteItemFromCart) { (response : Any) in
            
            
            if Helper.shared.cartCount == 1{
                NotificationCenter.default.post(name: Notification.Name("UpdateCart"), object: nil, userInfo: ["ProductID":productID])
            }else{
                DispatchQueue.main.async {
                    Helper.shared.showAlertOnController( message: CommonString.prodDeletedString, title: CommonString.app_name,hideOkayButton: true)
                    Helper.shared.dismissAlert()
                }
            }
            
            if self.arrCartItems.count <= 1{
                DispatchQueue.main.async {
                    Helper.shared.cartCount = 0
                    self.navigationController?.popViewController(animated: true)
                    Helper.shared.showAlertOnController( message: "No items found in cart. Please add items to continue.", title: CommonString.app_name,hideOkayButton: true)
                    Helper.shared.dismissAlert()
                }
            }else{
                self.arrCartItems.remove(at: index)
                self.getCartItems()
            }
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.showCommentsScreenAction()
        return false
    }
    func showCommentsScreenAction()
    {
        if let commentListingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addCommentsStoryboardID") as? ChooseCommentView
        {
            commentListingVC.saleseRepSenderView = self
            UIApplication.shared.keyWindow?.rootViewController?.present(commentListingVC, animated: false, completion: nil)
        }
    }
    
    func getCartItems() -> Void
    {
        let serviceURL = SyncEngine.baseURL + SyncEngine.getCartItems
        let requestToGetCartItems = [
            "UserID": UserInfo.shared.userId!,
            "CustomerID": UserInfo.shared.customerID!,
            "IsPlacedByRep": true,
            "IsSavedOrder" : isShowingSavedOrder,
            "CartID" :  0
            ] as Dictionary<String,Any>
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestToGetCartItems, strURL: serviceURL) { (response : Any) in
            if let items = (response as? Dictionary<String,Any>)?["CartItems"] as? Array<Dictionary<String,Any>>
            {
            
                self.arrCartItems.removeAll()
                self.arrCartItems += items
                self.updateMargin(items: self.arrCartItems)
                Helper.shared.cartCount = self.arrCartItems.count
                DispatchQueue.main.async {
                    self.tbl_CartDetail.reloadData()
                }
                
                if self.arrCartItems.count > 0
                {
                    self.tempCartID = (self.arrCartItems[0]["CartID"] as? NSNumber)!
                    self.createAndShowOrderValue()
                    if self.arrCartItems[0].keyExists(key: "CartTotal"){
                        let string = String(format: "\(CommonString.currencyType)%@", ((self.arrCartItems[0]["CartTotal"] as? Double)?.withCommas())!)
                        self.lbl_TotalOrderValue?.text = string
                    }
                    //  self.calculateOrderValue()
                }
                else
                {
                    Helper.shared.cartCount = 0
//                    SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.noItemFoundCartString, withCancelButtonTitle: "OK", completion: {
//                        DispatchQueue.main.async {
//                          //  self.navigationController?.popViewController(animated: true)
//                        }
//                    })
                }
                
                if let cartTotalValue = (response as? Dictionary<String,Any>)?["CartTotal"] as? Double
                {
                    self.cartTotal = cartTotalValue
                    //  self.calculateOrderValue()
                    let string = String(format: "\(CommonString.currencyType)%.2f", cartTotalValue)
                    DispatchQueue.main.async {
                        self.lbl_TotalOrderValue?.text = string
                    }
                }
            }
        }
    }
    
    func updateMargin(items:Array<Dictionary<String,Any>>){
        
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
          
            }
            
            if let price = objToFetch?["Price"] as? Double , let priceComp = objToFetch?["CostPrice"] as? Double
            {
                CostPrice = priceComp + CostPrice
                Price = price + Price
            }
            
        }
        
        DispatchQueue.main.async {
            if AppFeatures.shared.isShowOrderMargin{
                self.lblMarginValue.isHidden = false
                self.lblMargin.isHidden = false
            }else {
                self.lblMarginValue.isHidden = true
                self.lblMargin.isHidden = true
            }
            let margin = Helper.shared.calculateMarginPercentage(price: Price, companyPrice: CostPrice)
            self.lblMarginValue.text = margin
            self.lblMargin.text = "Margin: "
            self.lblMarginValue.textColor = (Price - CostPrice) < 0 ? UIColor.red:UIColor.primaryColor()
        }
    }
    
    func calculateOrderValue(){
        DispatchQueue.main.async {
            var totalOrderValue : Double = 0
            for i in 0..<self.arrCartItems.count{
                totalOrderValue = Double(Double(truncating: (self.arrCartItems[i]["Price"] as? NSNumber)!)*Double(truncating: (self.arrCartItems[i]["Quantity"] as? NSNumber)!))+totalOrderValue
                
            }
            let string = String(format: "\(CommonString.currencyType)%.2f", totalOrderValue)
            let attrStr = NSMutableAttributedString(string: string)
            attrStr.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.darkGreyColor(), NSAttributedStringKey.font : UIFont.SFUI_Bold(baseScaleSize: 18.0)], range: NSRange(location: 0, length: string.count))
            attrStr.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.activeTextFieldColor(), NSAttributedStringKey.font : UIFont.SFUI_Regular(baseScaleSize: 14.0)], range: (string as NSString).range(of: ""))
        }
    }
    
    func createAndShowOrderValue(){
        
        DispatchQueue.main.async {
            if self.cartTotal != nil
            {
                let string = String(format: " \(CommonString.currencyType)%.2f", self.cartTotal!)
                let attrStr = NSMutableAttributedString(string: string)
                attrStr.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.darkGreyColor(), NSAttributedStringKey.font : UIFont.SFUI_Bold(baseScaleSize: 14.0)], range: NSRange(location: 0, length: string.count))
                
                attrStr.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.activeTextFieldColor(), NSAttributedStringKey.font : UIFont.SFUI_Regular(baseScaleSize: 14.0)], range: (string as NSString).range(of: ""))
                self.lbl_TotalOrderValue?.attributedText = attrStr
                self.showOrderDetailWithGST(total: self.cartTotal!)
            }
            else
            {
                self.manuallyCreateCartValue()
            }
            
        }
    }
    
    func showOrderDetailWithGST(total:Double){
        
        let gst = total * 10 / 100
        let grandTotal = total + gst
        self.lblSubTotal.text = "\(CommonString.currencyType)\(total.withCommas())"
        self.lblGst.text = "\(CommonString.currencyType)\(gst.withCommas())"
        self.lblTotal.text = "\(CommonString.currencyType)\(grandTotal.withCommas())"
    }
    
    func manuallyCreateCartValue()
    {
        if self.arrCartItems.count > 0
        {
            var total : Double = 0.0
            for i in 0...self.arrCartItems.count - 1
            {
                if let expectedPrice = self.arrCartItems[i]["Price"] as? Double
                {
                    if let quantitty = self.arrCartItems[i]["Quantity"] as? Double
                    {
                        total = total + (expectedPrice*quantitty)
                    }
                }
            }
            let priceStr = total.withCommas()
            DispatchQueue.main.async {
                let string = "Order Value : \(CommonString.currencyType)\(priceStr)"
                let attrStr = NSMutableAttributedString(string: string)
                attrStr.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.baseBlueColor(), NSAttributedStringKey.font : UIFont.SFUI_Regular(baseScaleSize: 14.0)], range: NSRange(location: 0, length: string.count))
                attrStr.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.activeTextFieldColor()], range: (string as NSString).range(of: "Order Value :"))
                self.lbl_TotalOrderValue?.attributedText = attrStr
                self.showOrderDetailWithGST(total: total)
            }
        }
        else
        {
            let string = "Order Value : \(CommonString.currencyType)0.0"
            let attrStr = NSMutableAttributedString(string: string)
            attrStr.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.baseBlueColor(), NSAttributedStringKey.font : UIFont.SFUI_Regular(baseScaleSize: 14.0)], range: NSRange(location: 0, length: string.count))
            attrStr.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.activeTextFieldColor()], range: (string as NSString).range(of: "Order Value :"))
            self.lbl_TotalOrderValue.attributedText = attrStr
            self.showOrderDetailWithGST(total: 0.0)
            
        }
    }
    
    /*
     var total = 0
     //obj[price] * obj[Quantity]
     */
    
    //MARK:- UOM change method
    @objc func uOMChanged(sender : UIButton)
    {
        if let obj = self.arrCartItems[sender.tag]["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1
        {
            let index = obj.index(where: { (testdic : Dictionary<String, Any>) -> Bool in
                testdic["UOMDesc"] as? String == self.arrCartItems[sender.tag]["OrderUnitName"] as? String
            })
            
            if index! + 1 < obj.count
            {
                var newObj = obj[index!+1]
                var objToChange = self.arrCartItems[sender.tag]
                objToChange["UnitName"] = newObj["UOMDesc"] as? String
                objToChange["OrderUnitName"] = newObj["UOMDesc"] as? String
                objToChange["UOMID"] = newObj["UOMID"] as? NSNumber
                objToChange["OrderUnitId"] = newObj["UOMID"] as? NSNumber
                objToChange["Price"] = newObj["Price"]
                objToChange["IsSpecial"] = newObj["IsSpecial"]
                objToChange["IsPromotional"] = newObj["IsPromotional"]
                objToChange["QuantityPerUnit"] = newObj["QuantityPerUnit"]
                objToChange["selectedIndex"] = index! + 1
                self.arrCartItems[sender.tag] = objToChange
                backOrder(dic: objToChange, index: sender.tag)
                self.tbl_CartDetail.reloadData()
            }
            else
            {
                var newObj = obj[0]
                var objToChange = arrCartItems[sender.tag]
                objToChange["UnitName"] = newObj["UOMDesc"] as? String
                objToChange["OrderUnitName"] = newObj["UOMDesc"] as? String
                objToChange["UOMID"] = newObj["UOMID"] as? NSNumber
                objToChange["OrderUnitId"] = newObj["UOMID"] as? NSNumber
                objToChange["Price"] = newObj["Price"]
                objToChange["IsSpecial"] = newObj["IsSpecial"]
                objToChange["IsPromotional"] = newObj["IsPromotional"]
                objToChange["QuantityPerUnit"] = newObj["QuantityPerUnit"]
                objToChange["selectedIndex"] = 0
                self.arrCartItems[sender.tag] = objToChange
                backOrder(dic: objToChange, index: sender.tag)
                self.tbl_CartDetail.reloadData()
            }
            
        }
    }
    @objc func hidePopupAction(reco : UITapGestureRecognizer)
    {
        if  reco.view == self.view
        {
            self.poPopupView.isHidden = true
            self.navigationController?.isNavigationBarHidden = false
        }
    }
    @IBAction func placeOrder_Action(_ sender: Any) {
        
        if UserInfo.shared.isGuest == true
        {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.guestUser, withCancelButtonTitle: "OK", completion: {
                Helper.shared.logoutAsGuest()
                return
            })
        }
        else if UserInfo.shared.customerOnHoldStatus && !AppFeatures.shared.isAllowOnHoldPlacingOrder{
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                return
            })
            return 
        }
        if self.arrCartItems.count == 0
        {
            Helper.shared.showAlertOnController( message: CommonString.productBeforeOrderPopUpString, title: CommonString.app_name)
            self.navigationController?.popViewController(animated: false)
            return
        }
        self.perform(#selector(self.processOrder), with: nil, afterDelay: 0.2)
    }
    
    @objc func processOrder() -> Void
    {
       
        self.showPONumberPopup()
    }
    
    func showPONumberPopup()
    {
        self.poPopupView.isHidden = false
        self.txtFldPONumber.text = ""
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func hidePoPopupNumber()
    {
        self.poPopupView.isHidden = true
        self.txtFldPONumber.text = ""
        self.view.endEditing(true)
        self.navigationController?.isNavigationBarHidden = false
        
        
        if Helper.shared.customerAppendDic_List.keyExists(key: "addressId")
        {
            print("address selected")
            self.showBuyInPopup()
        }
        else{
            self.getUserAddresses()
        }
        
    }
    @IBAction func handlePONumber(_ sender: Any)
    {
        if (txtFldPONumber.text?.count)! > 0
        {
            self.poNumber = self.txtFldPONumber.text
            self.hidePoPopupNumber()
        }
        else
        {
            Helper.shared.showAlertOnController( message: CommonString.poNumberPopUpString, title: CommonString.alertTitle)
        }
    }
    func getUserAddresses()
    {
        let dicCartItem = [
            "CustomerID": UserInfo.shared.customerID!
        ]
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: dicCartItem, strURL: SyncEngine.baseURL + SyncEngine.getCustomerAddressesRep) { (response : Any) in
            if let arrObj = response as? Array<Dictionary<String,Any>>, arrObj.count > 0
            {
                if arrObj.count == 1
                {
                    if let addressId = arrObj[0]["AddressId"] as? NSNumber
                    {
                        Helper.shared.customerAppendDic_List["addressId"] = addressId
                    }
                    self.showBuyInPopup()
                }
                else
                {
                    self.showAddressChoosePopup(suggestedAddresses: arrObj)
                }
            }
            else
            {
                Helper.shared.customerAppendDic_List["addressId"] = 0
                self.showBuyInPopup()
            }
            
        }
    }
    func showAddressChoosePopup(suggestedAddresses : Array<Dictionary<String,Any>>)
    {
        DispatchQueue.main.async {
            if let multipleObj = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: MultipleOptionPicker.storyboardIdentifier) as? MultipleOptionPicker
            {
                multipleObj.showMultipleOptionPickerOnWindow(forDisplayKeyName: "Address1", withDataSource: suggestedAddresses, withTitle: CommonString.shippingAdresTitle, withSuccessButtonTitle: "OK", withCancelButtonTitle: "CANCEL", withAlertMessage: CommonString.chooseShippingAdres) { (selectedVal : Int) in
                    // Handle Response here.
                    if let addressID = suggestedAddresses[0]["AddressId"] as? NSNumber
                    {
                        //  self.addressId =  addressID
                        Helper.shared.customerAppendDic_List["addressId"] = addressID
                        self.showBuyInPopup()
                    }
                }
            }
        }
    }
    
    //MARK: - - Show Buiy In products
    func showBuyInPopup(){
        
        var buyInPruducts = ""
        
        for product in self.arrCartItems{
            
            if product["BuyIn"] as? Bool == true{
                
                let productName = (product["ProductName"] as? String) ?? ""
                buyInPruducts.append("\(productName)\n")
                
            }
            
        }
        
        if buyInPruducts.isEmpty{
            
            self.callAPIForPlacingOrder()
        }else {
            
            if let buyInPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BuyInProductListPopupViewController") as? BuyInProductListPopupViewController
            {
                
                buyInPopup.showAlertOnWindow(products: buyInPruducts){
                    self.callAPIForPlacingOrder()
                }
            }
        }
        
    }
    
    func callAPIForPlacingOrder()
    {
        
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        
        DispatchQueue.main.async {
            
            if let orderPlacePopup = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrderPlacePopupVC") as? OrderPlacePopupVC{
                
                //"Are you sure you want to place this order for \(dayStr),\(date)?"
                orderPlacePopup.modalPresentationStyle = .overCurrentContext
                self.present(orderPlacePopup, animated: false, completion: nil)
                orderPlacePopup.completionBlock = { (value) -> Void in
                    
                    if value == .yes{
                        
                        var extDoc = String()
                        var packingSEQ = String()
                        var addressId = String()
                        var pickSlipCommentID : NSNumber?
                        var invoiceCommentID : NSNumber?
                        var CommentStrng = String()
                        var pickSlipBool : Bool = false
                        var invoiceSlipBool : Bool = false
                        var strRunNumber = ""
                        if Helper.shared.customerAppendDic_List.keyExists(key: "ExtDoc"), let extDocument = Helper.shared.customerAppendDic_List["ExtDoc"] as? String{
                            extDoc = extDocument
                        }
                        
                        if Helper.shared.customerAppendDic_List.keyExists(key: "packingSEQ"), let PackingSEQ = Helper.shared.customerAppendDic_List["packingSEQ"] as? String{
                            packingSEQ = PackingSEQ
                        }
                        
                        if Helper.shared.customerAppendDic_List.keyExists(key: "addressId"), let addressID = Helper.shared.customerAppendDic_List["addressId"] as? String{
                            addressId = addressID
                        }
                        
                        if Helper.shared.customerAppendDic_List.keyExists(key: "UnloadCommentID"), let pickSlipCommentId = Helper.shared.customerAppendDic_List["UnloadCommentID"] as? NSNumber{
                            pickSlipCommentID = pickSlipCommentId
                            pickSlipBool = true
                        }
                        
                        if Helper.shared.customerAppendDic_List.keyExists(key: "CommentID"), let inoiceCommentId = Helper.shared.customerAppendDic_List["CommentID"] as? NSNumber{
                            invoiceCommentID = inoiceCommentId
                            invoiceSlipBool = true
                        }
                        
                        if Helper.shared.customerAppendDic_List.keyExists(key:"InvoiceDescription"), let commentString = Helper.shared.customerAppendDic_List["InvoiceDescription"] as? String{
                            CommentStrng = commentString
                        }
                        
                        if Helper.shared.customerAppendDic_List.keyExists(key: "RunNo"), let runNumber = Helper.shared.customerAppendDic_List["RunNo"] as? String{
                            strRunNumber = runNumber
                        }
                        
                        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        var saveOrderRequest = [
                            "CustomerID": UserInfo.shared.customerID!,
                            "TempCartID": self.tempCartID,
                            "UserID": UserInfo.shared.userId!,
                            "CartID": self.tempCartID,
                            // "CommentID": self.commentID == nil ? 0 : self.commentID!,
                            "CommentID": (invoiceCommentID as? Int) ?? 0,
                            "AddressID": addressId,
                            "PONumber": (self.poNumber == nil) ? "" : self.poNumber!,
                            "OrderStatus": 1,
                            // "Comment": self.commentString == nil ? "" : self.commentString!,
                            "Comment": CommentStrng,
                            "OrderDate": df.string(from: Helper.shared.selectedDeliveryDate ?? Date()),
                            "CutOffTime": "",
                            "ExtDoc": extDoc,
                            "PackagingSequence": packingSEQ,
                            "IsAutoOrdered": false,
                            "DeviceToken": "",
                            "DeviceType": "iPhone",
                            "DeviceVersion": "",
                            "DeviceModel": "",
                            "AppVersion": "",
                            "RunNo":strRunNumber,
                            "SaveOrder": false,
                            "IsInvoiceComment": invoiceSlipBool,
                            "IsUnloadComment": pickSlipBool,
                            //  "InvoiceCommentID": Int(inoiceCommentID) as Any,
                            "UnloadCommentID": (pickSlipCommentID as? Int) ?? 0,
                            "IsOrderPlpacedByRep" : UserInfo.shared.isSalesRepUser!,
                            "IsContactless":Helper.shared.IsContactless,
                            "IsLeave":Helper.shared.IsLeave,
                            "IsDelivery":UserInfo.shared.isDelivery] as [String : Any]
                        
                        if UserInfo.shared.isSalesRepUser!{
                            saveOrderRequest["Latitude"] = UserLocationManager.shared.lattitude
                            saveOrderRequest["Longitude"] = UserLocationManager.shared.longitude
                        }
                        
                        let requestURL  = SyncEngine.baseURL + SyncEngine.placeOrder
                        
                        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: saveOrderRequest, strURL: requestURL) { (response : Any) in
                            DispatchQueue.main.async {
                                
                                if let orderSubmittedPopup = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrderSubmittedPopupVC") as? OrderSubmittedPopupVC
                                {
                                    //"Are you sure you want to place this order for \(dayStr),\(date)?"
                                    orderSubmittedPopup.modalPresentationStyle = .overCurrentContext
                                    self.present(orderSubmittedPopup, animated: false, completion: nil)
                                    orderSubmittedPopup.completionBlock = {
                                        
                                        DispatchQueue.main.async {
                                            Helper.shared.lastSetDateTimestamp = nil
                                            Helper.shared.selectedDeliveryDate = nil
                                            Helper.shared.cartCount = 0
                                            Helper.shared.customerAppendDic_List["ExtDoc"] = nil
                                            Helper.shared.customerAppendDic_List["packingSEQ"] = nil
                                            Helper.shared.customerAppendDic_List["addressId"] = nil
                                            Helper.shared.customerAppendDic_List["UnloadCommentID"] = nil
                                            Helper.shared.customerAppendDic_List["CommentID"] = nil
                                            Helper.shared.customerAppendDic_List["InvoiceDescription"] = nil
                                            self.addItem_Action(nil)
                                        }
                                    }
                                }
                                
                                //                            })
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func skipPONumberEntry(_ sender: Any)
    {
        self.hidePoPopupNumber()
    }
    
    @IBAction func addItem_Action(_ sender: Any?)
    {
        var isAlreadyPresent : Bool = false
        for defaultPantryController in (self.navigationController?.viewControllers)!
        {
            if defaultPantryController is PantryListVC
            {
                isAlreadyPresent = true
                self.navigationController?.popToViewController(defaultPantryController, animated: false)
                break
            }
        }
        if isAlreadyPresent == false
        {
            if let defaultPantryController = UIStoryboard(name: "Sales", bundle: nil).instantiateViewController(withIdentifier: "PantryListVC") as? PantryListVC
            {
                self.navigationController?.pushViewController(defaultPantryController, animated: false)
            }
        }
    }
    
    @IBAction func clearTV_Action(_ sender: Any) {
        
        Helper.shared.customerAppendDic_List["CommentID"] = nil
        Helper.shared.customerAppendDic_List["InvoiceDescription"] = ""
        textViewAddComment.text = ""
        self.txtVwCommentHeightConstant.constant = 30.0 * VerticalSpacingConstraints.spacingConstant
        self.btn_clear.isHidden = true
    }
    
    //MARK:- Navigation
    func setDefaultNavigation() -> Void
    {
        if UserInfo.shared.isSalesRepUser! {
            Helper.shared.setNavigationTitle(viewController: self, title: UserInfo.shared.navigationTitle)
        }else {
            Helper.shared.setNavigationTitle(viewController: self, title: "My Cart")
        }
        Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
    }
    
    @objc func backBtnAction()
    {
        self.navigationController?.popViewController(animated: true)
    }
}

class CartCustomerInfoCell: UICollectionViewCell {
    
    @IBOutlet weak var lbl_heading: customLabel!
    @IBOutlet weak var txtFld_CustomerDetail: CustomTextField!
    
    override func awakeFromNib() {
        self.txtFld_CustomerDetail.textColor = UIColor.priceInfoLightGreyColor()
        self.txtFld_CustomerDetail.font = UIFont.Roboto_Medium(baseScaleSize: 13.0)
        Helper.shared.setTextFieldBorder(textField: txtFld_CustomerDetail)
    }
}

class cartCell: UITableViewCell {
    
    @IBOutlet weak var View_main: UIView!
    @IBOutlet weak var lbl_code: customLabelGrey!
    @IBOutlet weak var lbl_ProductName: UILabel!
    @IBOutlet weak var lblProductStatus: PaddingLabel!
    @IBOutlet weak var lbl_each: customLabelGrey!
    @IBOutlet weak var btn_UOM: UIButton!
    @IBOutlet weak var lbl_SOH: customLabelGrey!
    @IBOutlet weak var txtFld_qty: CustomBlueBoxTextField!
    @IBOutlet weak var btn_NP: CustomButtonGreyBorder!
    @IBOutlet weak var lbl_Price: customLabelGrey!
    @IBOutlet weak var lbl_Amount: customLabelGrey!
    @IBOutlet weak var btn_GST: UIButton!
    @IBOutlet weak var btn_Dlt: UIButton!
    @IBOutlet weak var arrowUOMDropdown: NSLayoutConstraint!
    @IBOutlet weak var btnShowImage: UIButton!
    @IBOutlet weak var btnPencil: UIButton!
    
    override func awakeFromNib() {
        self.lbl_ProductName.font = UIFont.Roboto_Medium(baseScaleSize: 18.0)
        self.lblProductStatus.font = UIFont.Roboto_Medium(baseScaleSize: 15.0)
        self.txtFld_qty.keyboardType = UserInfo.shared.isSalesRepUser! ? .decimalPad:AppFeatures.shared.IsAllowDecimal ? .decimalPad:.numberPad
    }
}

extension MyCartVC: LightboxControllerPageDelegate ,LightboxControllerDismissalDelegate{
    
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        
    }
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
    }
}
