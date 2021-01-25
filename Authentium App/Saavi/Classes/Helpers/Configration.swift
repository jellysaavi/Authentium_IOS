//
//  Configration.swift
//  Saavi
//
//  Created by Sukhpreet Singh on 15/06/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class Configration: NSObject {
    
    static func scalingFactor() -> CGFloat
    {
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad
        {
            return (UIScreen.main.bounds.size.height/700.0)

        }
        else
        {
            return (UIScreen.main.bounds.size.height/667.0)
        }
    }
    
    static func mainStoryboard() -> UIStoryboard
    {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
}

struct AppConfig {

//    static func themeColor() -> UIColor
//    {
//        return UIColor(red: 58.0/255.0, green: 190.0/255.0, blue: 238.0/255.0, alpha: 1.0)
//    }
    
    static func darkGreyColor() -> UIColor
    {
        return UIColor(red: 92.0/255.0, green: 92.0/255.0, blue: 92.0/255.0, alpha: 1.0)
    }
    static func redColor() -> UIColor
    {
        return UIColor(red: 255.0/255.0, green: 56.0/255.0, blue: 56.0/255.0, alpha: 1.0)
    }
    
    static func attributedPlaceholderString(withFont font : UIFont, withColor color : UIColor) -> Dictionary<NSAttributedStringKey , NSObject>
    {
        let placeHolderAttributes = [NSAttributedStringKey.foregroundColor:color, NSAttributedStringKey.font:font]
        return placeHolderAttributes
    }
}

class AppFeatures : NSObject
{
    static var shared:AppFeatures = AppFeatures()
    /*  Show walkthrough   */
    var shouldShowWalkthrough = true
    var isProductAdded = false // to reload pantry list if product is added in pantry list from search items
    
    /*  MANAGE ADMIN FEATURES   */
    var isNonFoodVersion : Bool = false
    /*Advanced Pantry : Will toggle filters on off on top*/
    var IsShowSubCategory : Bool = false
    var IsShowQuantityPopup : Bool = false
    var IsSuggestiveSell : Bool = false
    var IsDatePickerEnabled : Bool = false
    var IsEnableRepToAddSpecialPrice : Bool = false
    var isBackOrder : Bool = false
    var isShowOrderMargin : Bool = false
    var isSlaesRepLocationEnabled : Bool = false 
    var Currency = "$"    
    var isAdvancedPantry : Bool = true
    var isAddSpecialPriceFromPantry : Bool = true
    var isRepProductBrowsing : Bool = true
    var isHighlightRewardItem : Bool = true
    var isShowOrderStatus : Bool = true
    var isShowTermConditionsPopup : Bool = true
    var isShowProductClasses : Bool = true
    var isShowOnlyStockItems : Bool = true
    var isMultipleAddresses : Bool = true
    var isShowContactDetails : Bool = true
    var isLiquorControlPopup : Bool = true
    /** Allow to show enquiry popup **/
    var isItemEnquiryPopup : Bool = true
    /** Show cost of product on orders screen **/
    var isShowProductCost : Bool = true
    var isShowProductHistory : Bool = true
    var isPDFSpecialProducts : Bool = true
    var shoudlShowProductImages : Bool = false
    var shoudlSmallShowProductImages : Bool = false
    var isNoticeBoard : Bool = false
    var isTargetMarketing : Bool = false
    var isNonDeliveryDayOrdering : Bool = false
    var isShowFutureDate : Bool = false
    var isShowNotifications : Bool = false
    var isShowStandingOrder : Bool = false
    var isSpecialProductRequest : Bool = false
    var isMinOrderQuantity : Bool = false
    var isMaxOrderQuantity : Bool = false
    var isBrowsingEnabledForHoldCust : Bool = false
    var isCheckDelivery : Bool = false
    var isSundayOrderingEnabled  = false
    var isParent : Bool = false
    var isBuyIn : Bool = false
    var slotsByDate  = false
    
    /*  MANAGE CUSTOMER FEATURES   */
    var showPOPopupWhileOrdering : Bool = true
    var saveOrderPermitted : Bool = true
    var shouldShowPDFInvoice : Bool = true
    var showNoticeboardPdf : Bool = false
    var showOrderDateInHistory : Bool = true
    var allowDyanamicUOM : Bool = true
    var shouldShowInvoices : Bool = true
    var isDynamicUOM : Bool = true
    var shouldShowFreightCharges = true
    var shouldShowLongDetail = true
    var isUserAllowedToAddPantryList = true
    var isUserAllowedToAddItemsToPantryList = true
    var shouldShowProductPrice = true
    var shouldShowBrandNameInProductList = true
    var hasAccessToDefaultPantry = true
    var shouldHighlightStock : Bool = false
    var shouldShowStock : Bool = false
    var isStripePayment : Bool =  false
    var canSearchProduct : Bool = true
    var canShowLatestSpecials : Bool = false
    var isShowSupplier : Bool = false
    var canSortPantry : Bool = false
    var showOrderHistory : Bool = false
    var isShowBarcode : Bool = false
    var isAllowOnHoldPlacingOrder : Bool = false
    var isShowCategory:Bool = false
    var isShowPackSize:Bool = false
    var isOrderMultiples:Bool = false
    var isFavoriteList:Bool = false
    var isShareButtons:Bool = false
    var isShowAccount:Bool = false
    var isUserAllowedToAddItemsToDefaultPantry : Bool = false
    var defaultRunNumber = ""
    var IsAllowDecimal :Bool = false
    // Miscellanous 
    var showPantryList : Bool = true
    /** Allow to show copy icon on every favourite list **/
    var copyPantryEnabled : Bool = true
    var showCategoriesWihEmptyItems = true
}






