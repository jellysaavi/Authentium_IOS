//
//  PriceInfoVC.swift
//  Saavi
//
//  Created by Irmeen Sheikh on 20/02/18.
//  Copyright © 2018 Saavi. All rights reserved.
//

import UIKit

class PriceInfoVC: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextFieldDelegate{
    @IBOutlet weak var clctn_Price: UICollectionView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_PriceInfo: UILabel!
    @IBOutlet weak var lbl_changeMargin: UILabel!
    @IBOutlet weak var lbl_changePrice: UILabel!
    @IBOutlet weak var txtFld_changePrice: UITextField!
    @IBOutlet weak var txtFld_changeMargin: UITextField!
    @IBOutlet weak var btn_Cancel: UIButton!
    @IBOutlet weak var btn_apply: UIButton!
    @IBOutlet weak var btn_update: UIButton!
    @IBOutlet weak var view_main: UIView!
    var priceArr = [["Image":"price1","Heading":"Cost Price:"],["Image":"price2","Heading":"Customer price:"],["Image":"price3","Heading":"% Profit:"]]
    var productDic = Dictionary<String,Any>()
    var profit : Double?
    var senderView : PantryListVC?
    var isFirstShow :Bool = true
    var prodId : NSNumber = 0
   // var customerId :NSNumber = 0
    var userID : NSNumber = 0
    var UOMID : NSNumber = 0
    var qtyPerUnit : NSNumber = 0
    var customerPrice : Double?
    var costPrice : Double?
    var activeTextField : UITextField?
    override func viewDidLoad() {
        super.viewDidLoad()
        //   text2 = text2.textureName.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range:nil)
        print(productDic)
        
        view_main.backgroundColor = UIColor.lightGreyColor()
        clctn_Price.backgroundColor = UIColor.lightGreyColor()
        view_main.layer.cornerRadius =  7.0 * Configration.scalingFactor()
        lbl_title.font = UIFont.Roboto_Regular(baseScaleSize: 18.0)
        lbl_PriceInfo.font = UIFont.Roboto_Bold(baseScaleSize: 18.0)
        lbl_title.textColor = UIColor.priceInfoLightGreyColor()
        
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
            let index = arrPrices?.index(where: { (testdic : Dictionary<String, Any>) -> Bool in
                testdic["UOMID"] as? NSNumber == UOMID //productDic["OrderUnitName"] as? String
            })
            objToFetch = arrPrices![index ?? 0]
        }
        
        
        if let price = objToFetch?["Price"] as? Double , let priceComp = objToFetch?["CostPrice"] as? Double , let uomID = objToFetch?["UOMID"] as? NSNumber
        {
            customerPrice = price
            UOMID = uomID
            costPrice = priceComp
            qtyPerUnit = objToFetch?["QuantityPerUnit"] as? NSNumber ?? 1
            calculateProfit(price: price, priceComp: priceComp)
        }
        if productDic.keyExists(key: "ProductName"), let productName = productDic["ProductName"] as? String{
            self.lbl_title.text = productName
        }
        if AppFeatures.shared.isShowProductCost == false{
            priceArr = [["Image":"price2","Heading":"Customer price:"],["Image":"price3","Heading":"% Profit:"]]
        }
        
        if !AppFeatures.shared.IsEnableRepToAddSpecialPrice{
            self.btn_apply.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:- CollectionView delegate and datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return priceArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PriceInfoCell", for: indexPath) as! PriceInfoCell
        cell.img_price.image = UIImage(named:priceArr[indexPath.row]["Image"]!)
        cell.img_price.tintColor = UIColor.baseBlueColor()
        cell.lbl_priceHeading.text = priceArr[indexPath.row]["Heading"]
        cell.contentView.backgroundColor = UIColor.bgViewColor()
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.baseBlueColor().cgColor
        if priceArr[indexPath.row]["Heading"] == "Cost Price:"{
            //        if let priceComp = productDic["CompanyPrice"] as? Double
            //        {
            let priceStr = String(format: "\(CommonString.currencyType)%.2f", costPrice!)
            cell.lbl_priceValue.text = priceStr
            //  }
        }
        else if priceArr[indexPath.row]["Heading"] == "Customer price:"{
            if let price = customerPrice
            {
                let priceCompStr = String(format: "\(CommonString.currencyType)%.2f", price)
                cell.lbl_priceValue.text = priceCompStr
            }
        }
        else if priceArr[indexPath.row]["Heading"] == "% Profit:"
        {
            if let profitNum = profit
            {
                let profitStr = String(format: "%.2f%%", profitNum)
                cell.lbl_priceValue.text = profitStr
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: (collectionView.frame.size.width/CGFloat(priceArr.count))-CGFloat(10.0), height: collectionView.bounds.size.height)
    }
    
    func calculateProfit(price:Double ,priceComp:Double ){
        let margin = ((price - priceComp) / price)
        let marginPercentage = margin * 100
        profit = marginPercentage
    }
    
    func calculateMargin(profit:Double ,costPrice:Double){
        
        let margin = (profit * costPrice)/100
        let selling_price = costPrice + margin
        txtFld_changePrice.text = String(format: "\(CommonString.currencyType)%.2f",selling_price)
        print(selling_price)
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
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if txtFld_changePrice.isFirstResponder{
            txtFld_changeMargin.text = ""
            activeTextField = txtFld_changePrice
            let costVAlue = ((txtFld_changePrice.text)?.replacingOccurrences(of: CommonString.currencyType, with: "", options: NSString.CompareOptions.literal, range:nil))
            txtFld_changePrice.text = costVAlue
        }
        else{
            txtFld_changePrice.text = ""
            activeTextField = txtFld_changeMargin
            let marginVAlue = ((txtFld_changeMargin.text)?.replacingOccurrences(of: "%", with: "", options: NSString.CompareOptions.literal, range:nil))
            txtFld_changeMargin.text = marginVAlue
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isFirstShow = false
        if activeTextField == txtFld_changePrice {
            if txtFld_changePrice.text != ""{
                let customerPriceStr = String(format: "\(CommonString.currencyType)%.2f", customerPrice!)
                let txtFieldPrice =  Double(txtFld_changePrice.text!) ?? 0.0
                if  txtFld_changePrice.text != "", customerPrice! <  txtFieldPrice
                {
                    Helper.shared.showAlertOnController( message: "Customer normal price is \(customerPriceStr).Applied price must not be higher than the customer price.", title: CommonString.app_name)
                }
                else{
                    //  if let priceComp = productDic["CompanyPrice"] as? Double{
                    let costVAlue = Double(((txtFld_changePrice.text)?.replacingOccurrences(of: CommonString.currencyType, with: "", options: NSString.CompareOptions.literal, range:nil))!)
                    calculateProfit(price: costVAlue!, priceComp: costPrice!)
                    //  txtFld_changePrice.text = String(Double(txtFld_changePrice.text!)!)
                    txtFld_changePrice.text =  String(format: "\(CommonString.currencyType)%.2f",costVAlue!)
                    txtFld_changeMargin.text = String(format: "%.2f%%",profit!)
                    self.view.endEditing(true)
                }
            }
        }
        
        if activeTextField == txtFld_changeMargin {
            if txtFld_changeMargin.text != ""{
                //  if let costPrice = productDic["CompanyPrice"] as? Double{
                let marginVAlue = Double(((txtFld_changeMargin.text)?.replacingOccurrences(of: "%", with: "", options: NSString.CompareOptions.literal, range:nil))!)
                calculateMargin(profit: marginVAlue!, costPrice: costPrice!)
                if txtFld_changeMargin.text != ""
                {
                    
                }
                //  txtFld_changeMargin.text = String(Double(txtFld_changeMargin.text!)!)
                txtFld_changeMargin.text =  String(format: "%.2f%%",Double(txtFld_changeMargin.text!)!)
                self.view.endEditing(true)
                //  }
            }
        }
    }
    
    //MARK:-Button Action
    @IBAction func Cancel_Action(_ sender: Any) {
        self.dismiss(animated: false, completion: {
            
            self.senderView?.index = -1
            self.senderView?.selectedIndexPath = nil
            if let searchBar = self.senderView?.navigationItem.titleView as? UISearchBar
            {
                self.senderView?.searchBarCancelButtonClicked(searchBar)
            }
            else
            {
                self.senderView?.getAllDefaultPantryItems(searchText: "")
            }
            self.senderView?.clctn_Features.reloadData()
            self.senderView?.clctn_PantryList.reloadData()
        })
    }
    
    @IBAction func Apply_Action(_ sender: Any) {
        
        self.view.endEditing(true)
        if txtFld_changePrice.text == "" && txtFld_changeMargin.text == ""
        {
            Helper.shared.showAlertOnController( message: CommonString.priceOrMarginPopUp, title: CommonString.app_name)
        }
        else if txtFld_changeMargin.text != ""{
            
            let specialPriceVCObj = UIStoryboard.init(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "SpecailPriceAlertID") as! SpecailPriceAlert
            DispatchQueue.main.async {
                specialPriceVCObj.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                specialPriceVCObj.priceInfoSenderView = self
                // specialPriceVCObj.customerID = UserInfo.shared.customerID!
                specialPriceVCObj.productID = self.prodId
                let costVAlue = Double(((self.txtFld_changePrice.text)?.replacingOccurrences(of: CommonString.currencyType, with: "", options: NSString.CompareOptions.literal, range:nil))!)
                specialPriceVCObj.price = costVAlue! as NSNumber
                specialPriceVCObj.specialPrice =  costVAlue! as NSNumber
                specialPriceVCObj.UOMId = self.UOMID
                specialPriceVCObj.qtyPerUnit = self.qtyPerUnit
                if self.productDic.keyExists(key: "IsInCart") ,let isInCart = self.productDic["IsInCart"] as? Bool{
                    specialPriceVCObj.isInCart = isInCart
                }
                self.present(specialPriceVCObj, animated: false, completion: nil)
            }
        }else{
            // if let customerPrice = customerPrice
            let customerPriceStr = String(format: "\(CommonString.currencyType)%.2f", customerPrice!)
            let txtFieldPrice =  Double(txtFld_changePrice.text!)
            if  txtFld_changePrice.text != "", customerPrice! <  txtFieldPrice!
            {
                Helper.shared.showAlertOnController( message: "Customer normal price is \(customerPriceStr).Applied price must not be higher than the customer price.", title: CommonString.app_name)
            }
            else{
                
                let costVAlue = Double(((txtFld_changePrice.text)?.replacingOccurrences(of: CommonString.currencyType, with: "", options: NSString.CompareOptions.literal, range:nil))!)
                calculateProfit(price: costVAlue!, priceComp: costPrice!)
                //  }
                let specailPriceVCObj = UIStoryboard.init(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "SpecailPriceAlertID") as! SpecailPriceAlert
                DispatchQueue.main.async {
                    specailPriceVCObj.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    specailPriceVCObj.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    specailPriceVCObj.priceInfoSenderView = self
                    //specailPriceVCObj.customerID = UserInfo.shared.customerID!
                    specailPriceVCObj.productID = self.prodId
                    let costVAlue = Double(((self.txtFld_changePrice.text)?.replacingOccurrences(of: CommonString.currencyType, with: "", options: NSString.CompareOptions.literal, range:nil))!)
                    specailPriceVCObj.price = costVAlue! as NSNumber
                    specailPriceVCObj.specialPrice =  costVAlue! as NSNumber
                    specailPriceVCObj.UOMId = self.UOMID
                    self.present(specailPriceVCObj, animated: false, completion: nil)
                }
            }
        }
    }
    
    func dismissSuperView(){
        self.senderView?.index = -1
        self.senderView?.selectedIndexPath = nil
        self.senderView?.clctn_Features.reloadData()
        if let searchBar = self.senderView?.navigationItem.titleView as? UISearchBar
        {
            self.senderView?.searchBarCancelButtonClicked(searchBar)
        }
        else
        {
            self.senderView?.getAllDefaultPantryItems(searchText: "")
        }
        self.dismiss(animated: false, completion: nil)
    }
    
    func getAddSpecialPrice()
    {
        let dicCartItem = [
            "CustomerID": UserInfo.shared.customerID,
            "ProductID": prodId,
            "RepUserID": UserInfo.shared.userId!,
            "UOMID": UOMID,
            "Price": txtFld_changePrice.text!,
            "AlwaysApply": false
            
            ] as [String : Any]
        
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: dicCartItem, strURL: SyncEngine.baseURL + SyncEngine.AddSpecialPrice) { (response : Any) in
            DispatchQueue.main.async {
                self.senderView?.index = -1
                self.senderView?.clctn_Features.reloadData()
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
}

class PriceInfoCell: UICollectionViewCell {
    
    @IBOutlet weak var img_price: UIImageView!
    @IBOutlet weak var lbl_priceHeading: UILabel!
    @IBOutlet weak var lbl_priceValue: UILabel!
    
    override func awakeFromNib() {
        self.lbl_priceHeading.font = UIFont.Roboto_Medium(baseScaleSize: 15.0)
        self.lbl_priceHeading.textColor = UIColor.darkGreyColor()
        self.lbl_priceValue.font = UIFont.Roboto_Medium(baseScaleSize: 15.0)
        self.lbl_priceValue.textColor = UIColor.black
        
    }
}

