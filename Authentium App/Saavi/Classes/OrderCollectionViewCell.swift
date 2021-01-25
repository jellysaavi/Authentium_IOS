//
//  OrderCollectionViewself.swift
//  Saavi
//
//  Created by gomad on 28/06/19.
//  Copyright © 2019 Saavi. All rights reserved.
//

import UIKit

class OrderCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var LblUomDescription: UILabel!
    @IBOutlet weak var lblCompanyPrice: UILabel!
    @IBOutlet weak var imgVwFavoriteIcon: UIImageView!
    @IBOutlet weak var lblStatus: PaddingLabel!
    @IBOutlet weak var btnZoomThumbnail: UIButton!
    @IBOutlet weak var lblDryOrder : UILabel!
    @IBOutlet weak var lblGst: UILabel!
    @IBOutlet weak var lblSupplierName: UILabel!
    @IBOutlet weak var imgVwProductSmall: UIImageView!
    @IBOutlet weak var imgVwMove: UIImageView!
    @IBOutlet weak var productCode: UILabel!
    @IBOutlet weak var btnAvailable: UIButton!
    @IBOutlet weak var txtQuantity: UITextField!
    @IBOutlet weak var btnAddToFavourite: UIButton!
    @IBOutlet weak var btnIncreaseQuantity: UIButton!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var lblPackSize: UILabel!
    @IBOutlet weak var btnAddToCart: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var btnChangeUOM: UIButton!
    @IBOutlet weak var btnShowQuantityPopup: UIButton!
    @IBOutlet weak var btnTrash: UIButton!
    @IBOutlet weak var arrowUOMDropdown: NSLayoutConstraint!
    @IBOutlet weak var cnstWidthSmallImageIcon: NSLayoutConstraint!
    @IBOutlet weak var imageWidthConstant: NSLayoutConstraint!
    @IBOutlet weak var cnstIconsContainerLeading: NSLayoutConstraint!
    @IBOutlet weak var cnstTrashBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var cnstBtnAvailableWidth: NSLayoutConstraint!
    @IBOutlet weak var cnstBtnMoveWidth: NSLayoutConstraint!
    @IBOutlet weak var cnstBtnFavoriteWidth: NSLayoutConstraint!
    @IBOutlet var brandLbl: UILabel!
    @IBOutlet var suplierLbl: UILabel!
    
    
    var parentView : OrderVC?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addShadowToCell()
        self.adjustFontSizeAsPerScreen()
    }
    
    func addShadowToCell(){
        
        self.contentView.layer.cornerRadius = 2.0
        self.lblStatus.layer.cornerRadius = 8.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        self.layer.shadowRadius = 3.0
        self.layer.shadowOpacity = 0.2
        self.layer.masksToBounds = false
        self.imgVwFavoriteIcon.image =  #imageLiteral(resourceName: "LS_add_to_cart").withRenderingMode(.alwaysTemplate)
        self.imgVwFavoriteIcon.tintColor = UIColor.white
    }
    
    func adjustFontSizeAsPerScreen() -> Void{
        
        self.txtQuantity.keyboardType = UserInfo.shared.isSalesRepUser! ? .decimalPad:AppFeatures.shared.IsAllowDecimal ? .decimalPad:.numberPad
        self.lblDryOrder.font = UIFont.SFUI_Bold(baseScaleSize: 14.0)
        self.lblCompanyPrice.font = UIFont.SFUI_SemiBold(baseScaleSize: 16.0)
        
        //self.lblSupplierName.font = UIFont.SFUI_Regular(baseScaleSize: 15.0)
        self.productCode.font = UIFont.SFUI_Regular(baseScaleSize: 14.0)
        self.brandLbl.font = UIFont.SFUI_Regular(baseScaleSize: 14.0)
        self.suplierLbl.font = UIFont.SFUI_Regular(baseScaleSize: 14.0)

        self.LblUomDescription.font = UIFont.SFUI_Regular(baseScaleSize: 14.0)
        self.lblPackSize.font = UIFont.SFUI_Regular(baseScaleSize: 14.0)
        self.btnAvailable.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 13.0)
        self.btnIncreaseQuantity.titleLabel?.font = UIFont.Roboto_Medium(baseScaleSize: 12.0)
        self.lblGst.font = UIFont.SFUI_SemiBold(baseScaleSize: 11.0) /*self.btnDecreaseQuantity.titleLabel?.font = UIFont.Roboto_Medium(baseScaleSize: 10.0)*/
        
        self.txtQuantity.font = UIFont.Roboto_Medium(baseScaleSize: 14.0)
        
        self.txtQuantity.layer.borderWidth = 1.0
        self.btnIncreaseQuantity.layer.borderWidth = 1.0
        self.btnIncreaseQuantity.layer.borderColor = UIColor.baseBlueColor().cgColor
        self.txtQuantity.layer.borderColor = UIColor.baseBlueColor().cgColor
        self.btnIncreaseQuantity.backgroundColor = UIColor.baseBlueColor()
        self.btnIncreaseQuantity.setTitleColor(UIColor.white, for: .normal)
        
        if AppFeatures.shared.shoudlShowProductImages == false
        {
            self.cnstIconsContainerLeading.constant = 0.0
            self.cnstWidthSmallImageIcon.constant = 0.0
            self.imageWidthConstant.constant = 0.0
        }else{
            
            //if AppFeatures.shared.shoudlSmallShowProductImages{
                
//                self.cnstIconsContainerLeading.constant = 0.0
//                self.imageWidthConstant.constant = 0.0
//            }else{
//
//                self.cnstIconsContainerLeading.constant = 0.0
//                self.cnstWidthSmallImageIcon.constant = 0.0
            //}
        }
    }
    
    func showData(productList:Array<Dictionary<String,Any>>,index:Int){

        self.txtQuantity.tag = index
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        
        if AppFeatures.shared.shouldHighlightStock{
            
            self.btnAvailable.isHidden = false
            self.cnstBtnAvailableWidth.constant = 18.0
        }else{
            self.btnAvailable.isHidden = true
            self.cnstBtnAvailableWidth.constant = 0.0
        }
        
        if(productList.count > 0)
        {
            var productDescDic = productList[index]
            if(productDescDic.count > 0){
                
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
                
                self.lblDryOrder.text = features//((productDescDic)["ProductName"] as? String)
                self.productCode.text = ((productDescDic)["ProductCode"] as? String)
                
//                if productDescDic["IsStatusIN"] as? Bool == true{
//
//                    self.lblDryOrder.textColor = UIColor.blue
//                }
//                else if AppFeatures.shared.isHighlightRewardItem
//                {
//                }
//                else{
//                    self.lblDryOrder.textColor = UIColor.baseBlueColor()
//                }
                
                if AppFeatures.shared.isHighlightRewardItem
                {
                    if let isCountrywideReward =  productDescDic["IsCountrywideRewards"] as? Bool, isCountrywideReward == true
                    {
                        self.lblDryOrder.textColor = UIColor.init(hex: "#b0cf00")
                    }
                    else
                    {
                        self.lblDryOrder.textColor = UIColor.baseBlueColor()
                    }
                }
                else
                {
                    self.lblDryOrder.textColor = UIColor.baseBlueColor()
                }
                
                if let isBuyIn =  productDescDic["BuyIn"] as? Bool, isBuyIn == true
                {
                    self.lblDryOrder.textColor = UIColor.init(hex: "#2a99f3")
                }

                
                var arrPrices : Array<Dictionary<String,Any>>?
                if let prices = productDescDic["DynamicUOM"] as? Array<Dictionary<String,Any>>
                {
                    arrPrices = prices
                }
                else if let prices = productDescDic["Prices"] as? Array<Dictionary<String,Any>>
                {
                    arrPrices = prices
                }
                else if let prices = productDescDic["Prices"] as? Dictionary<String,Any>
                {
                    arrPrices = [prices]
                }
                
                
                if (arrPrices != nil), arrPrices!.count > 0
                {
                    var selectedIndex = 0
                    let testIndex = arrPrices?.index(where: { (testdic : Dictionary<String, Any>) -> Bool in
                        testdic["UOMID"] as? NSNumber == productDescDic["UOMID"] as? NSNumber
                    })
                    if (testIndex != nil) && (productDescDic["selectedIndex"] == nil)
                    {
                        productDescDic["selectedIndex"] = testIndex
                    }

                    if let index = productDescDic["selectedIndex"] as? Int
                    {
                        selectedIndex = index
                    }
                    let objToFetch = arrPrices![selectedIndex]
                    
                    self.lblPackSize.isHidden = true
                    if let packSize = objToFetch["QuantityPerUnit"] as? Int,AppFeatures.shared.isShowPackSize == true{
                        self.lblPackSize.isHidden = false
                        self.lblPackSize.text = "[CTN QTY: \(packSize)]"
                    }
                    
                    if let price = objToFetch["Price"] as? Double
                    {
                        if AppFeatures.shared.shouldShowProductPrice
                        {
                            let price_final = Double(round(100*price)/100)

                            let priceStr = String(format: "\(CommonString.currencyType)%.2f", price_final)
                            self.lblCompanyPrice.text = price <= 0 ? CommonString.marketprice:priceStr
                            self.LblUomDescription.text = objToFetch["UOMDesc"] as? String
                        }else{
                            self.lblCompanyPrice.text = ""
                            self.LblUomDescription.text = objToFetch["UOMDesc"] as? String
                        }
                        
                        self.LblUomDescription.textColor = UIColor.gray
                        if productDescDic.keyExists(key: "LastOrderUOMID"), let lastUom = productDescDic["LastOrderUOMID"] as? Int, lastUom == objToFetch["UOMID"] as? Int, lastUom > 0{
                            self.LblUomDescription.textColor = UIColor.gray
                        }
                        
                        if UserInfo.shared.isSalesRepUser == true{
                            
                            if objToFetch["IsSpecial"] as? Bool == true && objToFetch["IsPromotional"] as? Bool == true{
                                self.lblCompanyPrice.textColor = UIColor.red
                            }
                            else if objToFetch["IsSpecial"] as? Bool == true{
                                self.lblCompanyPrice.textColor = UIColor.red
                            }
                            else if objToFetch["IsPromotional"] as? Bool == true{
                                self.lblCompanyPrice.textColor = UIColor.promotionalProductYellowColor()
                            }
                            else{
                                self.lblCompanyPrice.textColor = UIColor.baseBlueColor()
                            }
                        }
                        else{
                            self.lblCompanyPrice.textColor = UIColor.baseBlueColor()
                        }
                    }
                }else{
                    self.lblCompanyPrice.text = ""
                    self.LblUomDescription.text = productDescDic["UOMDesc"] as? String
                }
                
                if let quantity = productDescDic["StockQuantity"] as? Double, quantity > 0.0 && AppFeatures.shared.shouldHighlightStock
                {
                    self.btnAvailable.setTitle("", for: .normal)
                    self.btnAvailable.setImage(#imageLiteral(resourceName: "check_available"), for: .normal)
                }
                else
                {
                    self.btnAvailable.setTitle("", for: .normal)
                    self.btnAvailable.setImage(#imageLiteral(resourceName: "NotAvailable"), for: .normal)
                }
                self.btnAddToFavourite.imageView?.tintColor = UIColor.yellowStarColor()
                if productDescDic.keyExists(key: "Quantity"), let number = productDescDic["Quantity"] as? NSNumber, Float(truncating: number) != 0.0
                {
                    let quantityStr = ((Double(truncating: number))*100).rounded()/100
                    self.txtQuantity.text =  quantityStr.cleanValue
                }
                else{
                    self.txtQuantity.text =  AppFeatures.shared.IsAllowDecimal ? 0.00.cleanValue: UserInfo.shared.isSalesRepUser! ? 0.00.cleanValue:"0"
                }
                if AppFeatures.shared.isUserAllowedToAddItemsToPantryList == true
                {
                    if let isPantryItem =  productDescDic["IsInPantry"] as? Bool, isPantryItem == true{
                        self.btnAddToFavourite.isSelected = true
                    }else{
                        self.btnAddToFavourite.isSelected = false
                    }
                    self.btnAddToFavourite.isHidden = false
                    self.cnstBtnFavoriteWidth.constant = 18.0
                }
                else{
                    self.btnAddToFavourite.isHidden = true
                    self.cnstBtnFavoriteWidth.constant = 0.0
                }
                
                if AppFeatures.shared.shouldShowBrandNameInProductList
                {
                    self.brandLbl.text = productDescDic["Brand"] as? String
                }
                if AppFeatures.shared.isShowSupplier
                {
                    self.suplierLbl.text = productDescDic["Supplier"] as? String
                }
                
                if let isCartItem =  productDescDic["IsInCart"] as? Bool, isCartItem == true
                {
                    self.btnAddToCart.isSelected = true
                }
                else
                {
                    self.btnAddToCart.isSelected = false
                }
                
                if AppFeatures.shared.isDynamicUOM
                {
                    self.btnChangeUOM.isHidden = false
                    if let obj = productList[index]["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1
                    {
                        self.arrowUOMDropdown.constant = 10.0
                    }
                    else
                    {
                        self.arrowUOMDropdown.constant = 0.0
                    }
                }else{
                    self.btnChangeUOM.isHidden = true
                }
                
                self.productImage.tintColor = UIColor.baseBlueColor()
                self.productImage.contentMode = .scaleToFill
                
                if AppFeatures.shared.shoudlShowProductImages == true, let images = productDescDic["ProductImages"] as? Array<Dictionary<String,Any>>, images.count > 0
                {
                    let originalString:String = (images[0]["ImageName"]! as! String)
                    let urlString:String = originalString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
                    self.productImage.setImageWith(URL(string: urlString), placeholderImage: #imageLiteral(resourceName: "ImagePlaceholder"))
                    self.productImage.contentMode = .scaleAspectFill
                }else{
                    self.productImage.image = #imageLiteral(resourceName: "ImagePlaceholder")
                }
            }
            
            if let new = productDescDic["IsNew"] as? Bool, new == true {
                self.lblStatus.isHidden = false
                self.lblStatus.text = "NEW"
                self.lblStatus.backgroundColor = UIColor.primaryColor()
            }else if let new = productDescDic["IsOnSale"] as? Bool, new == true {
                self.lblStatus.isHidden = false
                self.lblStatus.text = "SALE"
                self.lblStatus.backgroundColor = UIColor.primaryColor2()
            }else if let new = productDescDic["IsBackSoon"] as? Bool, new == true {
                self.lblStatus.isHidden = false
                self.lblStatus.text = "INCOMING"
                self.lblStatus.backgroundColor = UIColor.primaryColor3()
            }else{
                self.lblStatus.text = ""
                self.lblStatus.isHidden = true
            }
        }
    }
}
