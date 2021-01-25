//
//  CommonString.swift
//  Saavi
//
//  Created by Dhanotia on 05/02/18.
//  Copyright © 2018 Saavi. All rights reserved.
//

import UIKit

class CommonString: NSString {
    
    static let sorry = "Sorry"
    
    static let alertTitle = "Oops!!"
    static let app_name = "Authentium"
    static let marketprice = "Market \(AppFeatures.shared.Currency)"
    static var termsAndConditionString = ""
    static let currencyType = AppFeatures.shared.Currency
    static let liquorPopUpHeading = "Under the Liquor Control Reform Act 1998 it is an offence\n\n"
    static let liquorpopUpString = " To supply alcohol to a person under the age of 18 years (Penalty exceeds \(AppFeatures.shared.Currency)8,000)\n\n For a person under the age 17 years to purchase or receive liquor.(penalty exceeds \(AppFeatures.shared.Currency)700)"
    static var nonDeliveryPopUpString = "You have selected a non delivery day for placing order. Additional charges may apply. Do you want to proceed ?"//"Is the selected delivery date correct?"
    static var frieghtChargesMessage = ""
    static var noticeboardPDF = ""
    static var tarketMarketingPDF = ""
    //p
    static var logOutString = "Are you sure you want to logout ?"
    static var logOutTitle = "Logout?"
    static var selectCustomerTitle = "Select Customer"
    static var noResultFoundString = "No result found."
    static var countrywideString = "* Denotes Countrywide Rewards Item"
    static var showDetailBtnTitle = "SHOW DETAILS"
    static var hideDetailBtnTitle = "HIDE DETAILS"
    static var showGroupsBtnTitle = "SHOW GROUPS"
    static var hideGroupsBtnTitle = "HIDE GROUPS"
    static var pantryListTitle = "My Pantry List"
    static var emptyPantryListString = "Could not copy empty pantry list"
    static var noItemsAddedCartString = "No items added in cart"
    static var newPantryNameTitle = "Please enter new name for"
    static var addPantryTitle = "Add Pantry List"
    static var orderDeletedString = "Order deleted successfully"
    static var priceOrMarginPopUp = "Please enter either price or margin"
    static var commentAddedString = "Comment added successfully."
    static var addCommentString = "Please add comment"
    static var orderHistoryTitle = "Order History"
    static var welcomeString = "Welcome"
    static var enterPriceString = "Please enter the price"
    static var searchProductTitle = "Search Product"
    static var orderDetailsTitle = "Order Details "
    static var selectReorderItemsString = "Please select items to reorder"
    static var detailHere = "Enter detail here"
    static var noItemFoundCartString = "No items found in cart. Please add items to continue"
    static var productBeforeOrderPopUpString = "Please add products before placing order."
    static var poNumberPopUpString = "Please enter PO number to continue"
    static var chooseShippingAdres = "Please choose shipping address"
    static var shippingAdresTitle = "Shipping Addresses"
    static var placeOrderPopUpString = "Are you sure you want to place this order?"
    static var placedOrderSucesfulPopUpString = "Your order has been placed successfully" //test
    static var holdCustomerStatus = "This action cannot be completed because your account is on hold. Please contact your company administrator"
    static var guestUser = "Sorry, you are unable to place orders as a guest. Please logout and click the registration button on the login page to get instant access."
    
    static var deleteProdTitle = "Delete Product"
    static var prodDeletedString = "Product deleted successfully"
    //  static var  = "Are you sure you want to remove"
    static var noContactInfoFound = "No contact information found"
    static var timeOutString = "Sorry your session has timed out"
   
    static var datepickerText = "Based on your delivery location and our order cut off times, the available delivery/pick up days for your selected suburb are highlighted green in the calendar below. Please select the next available date you wish to receive your delivery or pick up. Refer to the calendar legend for further assistance."
    
    

    }
