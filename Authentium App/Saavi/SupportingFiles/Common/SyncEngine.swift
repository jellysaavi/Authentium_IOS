//
//  SyncEngine.swift
//  Saa0vi
//
//  Created by Sukhpreet on 30/06/17.
//  Copyright © 2017 Saavi. All rights reserved.
//
extension String {
    func stringByAddingPercentEncodingForRFC3986(str:NSString) -> String? {
        let unreserved = "-._~/?:"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return str.addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
}
import UIKit

class SyncEngine: NSObject {
    
    static let sharedInstance = SyncEngine()
    
        
    // BASE URL PRODUCTION
    static let baseURLType = ""
    static let baseURL = "http://52.66.73.23/api/v0.1/"

    
    // AUTHENTIUM APP END POINTS 
    static let Login = "account/login"
    static let RegisterSeller = "account/register/seller"
    
    // AUTHENTIUM APP END POINTS 

    
    
    
    
    
    
    
    
    var accessToken :  String?
    static let getMainFeaturesOfApplication = "api/Account/GetMainFeatures"
    static let Register = "api/Account/Register"
    static let ForgotPassword = "api/Account/ForgotPassword"
    static let changePassword = "api/Account/SetPassword"
    static let GetIntroPopupDetails = "api/Account/GetDefaultOrderingInfo"
    static let SearchProductsList = "api/products/SearchProducts"
    static let ProductCategories = "api/Products/ProductCategories"
    static let GetUserProfile = "api/Account/GetUserProfile"
    static let GetAllFilters = "api/Products/ProductFilters"
    static let GetDefaultPantry = "api/Products/GetPantryItems"
    static let addItemsToCart = "api/Products/InsertUpdateTempCart"
    static let getCustomerPantryList = "api/Products/GetCustomerPantry"
    static let addUpdatePantryList = "api/Products/AddUpdatePantry"
    static let addItemToPantryList = "api/Products/AddItemsToPantry"
    static let getCartItems = "api/Products/GetTempCartItems"
    static let getRecurryCartItems = "/api/Orders/GetRecurringOrders"
    static let getAllCommentsForOrder = "api/Orders/GetComments"
    static let addNewOrderComment = "api/Orders/AddComments"
    static let deleteComment = "api/Orders/DeleteComment"
    static let deleteItemFromCart = "api/Orders/DeleteCartItems"
    static let deleteItemFromRecurringCart = "/api/Orders/DeleteRecurrOrderItem"
    static let getUserAddresses = "api/Account/GetCustomerAddresses"
    static let getUserOrderHistory = "api/Orders/GetOrderHistory"
    static let getOrderItems = "api/Orders/GetOrderDetails"
    static let getUserInvoices = "api/Orders/GetInvoices"
    static let placeOrder = "api/Orders/PlaceOrder"
    static let ManageRecurringOrders = "/api/Orders/ManageRecurringOrders"
    static let reorderItems = "api/Orders/AppendOrderToTempCartForReorder"
    static let updateCartItem = "api/Products/UpdateCartItem"
    static let updateRecurringCartItem = "/api/Orders/AddUpdateItemInRecurringOrder"
    static let getCartCount = "api/Orders/GetCartCount"
    static let getCustomerFeatures = "api/Account/GetCustomerDetailsAndFeatures"
    static let getLatestSpecial = "api/Products/GetLatestSpecials"
    static let deleteItemFromFavoriteList = "api/Products/DeleteFavoriteList"
    static let setPantryItemsSortOrder = "api/Products/SetPantryItemsSortOrder"
    static let deleteSavedOrder = "api/Orders/DeleteSavedOrder"
    static let sendItemEnquiry = "api/Products/SendItemEnquiry"
    static let getProductDetailByID = "api/Products/GetProductDetailByID"
    static let specialRequestProductRequest = "api/Products/SendSpecialProductRequest"
    static let deleteItemFromFavorite = "api/Products/DeleteItemFromPantry"
   
    //SalesRep Service
    static let repCustomerPantryLists = "api/Rep/RepCustomerPantryLists"
    static let getRepCustomers = "api/Rep/GetRepCustomers"
    static let getRepProductDetails = "api/Rep/GetRepProductDetails"
    static let getCustomerAddressesRep = "api/Rep/GetCustomerAddressesRep"
    static let getOrderHistoryRep = "api/Rep/GetOrderHistoryRep"
    static let getCartCountRep = "api/Rep/GetCartCountRep"
    static let AddCommentsRep = "api/Rep/AddCommentsRep"
    static let AddSpecialPrice = "api/Rep/AddSpecialPrice"
    static let SaveLocation = "api/Rep/SaveLocation"
    static let ProductIdFromBarcode = "api/Products/GetProuctByBarCode"
    static let GanerateQuote = "api/Products/SendProductQuote"

    //payment
    static let GetPaymentData = "api/Payment/GetMobilePaymentToken"
    static let GetStripeKeys = "api/Payment/GetStripePublicKeys"
    static let SavePaymentLogsOnServer = "/api/Payment/LogPayment"
    static let SendProductPantryList = "api/Products/SendProductPantryList"
    static let  AddCustomerNotes = "api/Rep/AddCallNote"
    static let GetCustomerNotes = "api/Rep/GetCallNotes"
    static let SaveRecurringPaymentLogsOnServer = "/api/Payment/SaveSubcriptionPaymentLog"
    
    //Notifications
    static let GetNotificationsList = "api/Notification/GetNotifications"
    static let UpdateUnreadNotificationStatus = "/api/Notification/update"

    

    //Recurring Subscriptions
    
    static let CreateSubscription = "api/Payment/CreateSubscription"



    //Help
    static let GetHelp = "api/account/getPagehelp?page="
    
    //cartsuggestion
    static let getSuggestions = "api/Products/GetSuggestiveItems"
    
    //promo
    static let applyPromo = "api/Orders/ApplyCoupon"
    
    static let addAddress = "api/Account/AddDeliveryAddress"
    
    static let getPickupAddress = "api/Account/GetPickupLocations"
    
    static let getPickupDates = "api/Account/GetPickupDeliveryDates"
       
    static let deleteDeliveryAddress = "api/Account/DeleteDeliveryAddress"
    
//https://devsaavi5.saavi.com.au/8aRfbA/swagger/ui/index#!/Products/Products_InsertTempCart
    
    func sendGetRequestToServer(strURL:String, completion : @escaping (Any) -> ())
    {
        if !strURL.contains(SyncEngine.getMainFeaturesOfApplication)
        {
            Loader.shared.showLoader()
        }
        var serverRequest = URLRequest(url: URL(string: strURL)!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 30.0)
        serverRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        serverRequest.httpMethod = "GET"
        
        if accessToken != nil
        {
            serverRequest.setValue("bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        }
        
        let serviceSession = URLSession(configuration: URLSessionConfiguration.default)
        let task = serviceSession.dataTask(with: serverRequest) { (data : Data?, urlResponse : URLResponse?, serverError: Error?) in
            
            if data != nil && serverError == nil
            {
                DispatchQueue.main.async {
                    Loader.shared.hideLoader()
                }
                do
                {
                    print(String.init(data: data!, encoding: String.Encoding.utf8)!)
                    let obj = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    
                    if obj is Dictionary<String,Any> && ((obj as! Dictionary<String,Any>).index(forKey: "ResponseCode") != nil) && (obj as! Dictionary<String,Any>)["ResponseCode"] as? String == "200" && ((obj as! Dictionary<String,Any>).index(forKey: "Result") != nil)
                    {
                        completion((obj as! Dictionary<String,Any>)["Result"] as Any)
                    }
                    else if obj is Dictionary<String,Any> && ((obj as! Dictionary<String,Any>).index(forKey: "ResponseCode") != nil) && (obj as! Dictionary<String,Any>)["ResponseCode"] as? String == "201"
                    {
                        completion([])
                    }
                    else if  obj is Dictionary<String,Any> && ((obj as! Dictionary<String,Any>).index(forKey: "Message") != nil) && (((obj as! Dictionary<String,Any>)["Message"] as? String) != nil)
                    {
                        Loader.shared.hideLoader()
                        
                        
                        if let sessionExpire = UserDefaults.standard.value(forKey: "sessionExpire") as? Bool, sessionExpire == false {
                            
                            if let httpResponse = urlResponse as? HTTPURLResponse{
                                if httpResponse.statusCode == 401{
                                    
                                    UserDefaults.standard.set(true, forKey: "sessionExpire")
                                    DispatchQueue.main.async {
                                        
                                        SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle:  CommonString.alertTitle, withSuccessButtonTitle: nil, withMessage: CommonString.timeOutString, withCancelButtonTitle: "OK",hideOkayButton: false , completion: {
                                            
                                            Helper.shared.logOutUser()
                                        })
                                    }
                                    return
                                }else{
                                    
                                    if let errorStr = (obj as! Dictionary<String,Any>)["Message"] as? String
                                    {
                                        DispatchQueue.main.async {
                                            Helper.shared.showAlertOnController( message: errorStr, title: CommonString.alertTitle)
                                        }
                                    }
                                }
                            }
                        }
                        
                        //                        if let errorStr = (obj as! Dictionary<String,Any>)["Message"] as? String
                        //                        {
                        //                            Helper.shared.showAlertOnController( message: errorStr, title: CommonString.alertTitle)
                        //                        }
                    }
                    else if obj is Dictionary<String,Any>
                    {
                        completion(obj as! Dictionary<String,Any>)
                    }
                    else
                    {
                        Helper.shared.showAlertOnController( message: "Something went wrong. Please try again later.", title: CommonString.alertTitle)
                    }
                }
                catch
                {
                    print("json error: \(error)")
                }
            }
            else
            {
                DispatchQueue.main.async {
                    Loader.shared.hideLoader()
                    //                    Helper.sharedInstance.showAlertOnController(controller: (UIApplication.shared.keyWindow?.rootViewController)!, message: (serverError?.localizedDescription)!, title: "FameFlight")
                }
            }
        }
        task.resume()
    }
    
    func sendPostRequestToServer(dictionary : Any, strURL:String, withIndicator showIndicator : Bool = true, completion : @escaping (Any) -> ())
    {
        if showIndicator
        {
            Loader.shared.showLoader()
        }
        var serverRequest = URLRequest(url: URL(string: strURL)!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 120.0)
        serverRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        serverRequest.httpMethod = "POST"
        
        do {
            let dataBody = try JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
            serverRequest.httpBody = dataBody
            
            print(strURL + "\n" + String.init(data: dataBody, encoding: String.Encoding.utf8)! + "\n")
        } catch {
            print("json error: \(error)")
            return
        }
        
        if accessToken != nil
        {
            serverRequest.setValue("bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        }
        
        let serviceSession = URLSession(configuration: URLSessionConfiguration.default)
        let task = serviceSession.dataTask(with: serverRequest) { (data : Data?, urlResponse : URLResponse?, serverError: Error?) in
            
            if data != nil && serverError == nil
            {
                DispatchQueue.main.async {
                    if showIndicator
                    {
                        Loader.shared.hideLoader()
                    }
                }
                
                do
                {
                    print(String.init(data: data!, encoding: String.Encoding.utf8)!)
                    let obj = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    
//                    if obj is Dictionary<String,Any> && ((obj as! Dictionary<String,Any>).index(forKey: "ResponseCode") != nil) && (obj as! Dictionary<String,Any>)["ResponseCode"] as? String == "200" && ((obj as! Dictionary<String,Any>).index(forKey: "Result") != nil)
//                    {
//                        completion((obj as! Dictionary<String,Any>)["Result"] as Any)
//                    }
//                    else if obj is Dictionary<String,Any> && ((obj as! Dictionary<String,Any>).index(forKey: "ResponseCode") != nil) && (obj as! Dictionary<String,Any>)["ResponseCode"] as? String == "201"
//                    {
//                        if showIndicator
//                        {
//                            Loader.shared.hideLoader()
//                            if let errorStr = (obj as! Dictionary<String,Any>)["Message"] as? String
//                            {
//                                DispatchQueue.main.async {
//                                    Helper.shared.showAlertOnController( message: errorStr, title: CommonString.alertTitle)
//                                }
//                            }
//                        }
//                    }
//                        else if obj is Dictionary<String,Any> && ((obj as! Dictionary<String,Any>).index(forKey: "ResponseCode") != nil) && (obj as! Dictionary<String,Any>)["ResponseCode"] as? String == "500"
//                                               {
//                                              let message = (obj as! Dictionary<String,Any>)["Message"] as? String
//
//                                                                   if  message != nil {
//                                                                    DispatchQueue.main.async {
//                                                                        Helper.shared.showAlertOnController( message: message!, title: CommonString.app_name, hideOkayButton: false)
//                                                                    }
//                                                                   }
//
//                                               }
//                        else if obj is Dictionary<String,Any> && ((obj as! Dictionary<String,Any>).index(forKey: "ResponseCode") != nil) && (obj as! Dictionary<String,Any>)["ResponseCode"] as? String == "404"
//                                               {
//                                              let message = (obj as! Dictionary<String,Any>)["Message"] as? String
//
//                                                                   if  message != nil {
//                                                                       Helper.shared.showAlertOnController( message: message!, title: CommonString.app_name, hideOkayButton: true)
//                                                                                          Helper.shared.dismissAlert()
//                                                                   }
//
//                                               }
                                              
//                    else if  obj is Dictionary<String,Any> && ((obj as! Dictionary<String,Any>).index(forKey: "Message") != nil) && (((obj as! Dictionary<String,Any>)["Message"] as? String) != nil)
//                    {
//                        if showIndicator
//                        {
//                            Loader.shared.hideLoader()
//
//                            if let sessionExpire = UserDefaults.standard.value(forKey: "sessionExpire") as? Bool, sessionExpire == false {
//
//                                if let httpResponse = urlResponse as? HTTPURLResponse{
//                                    if httpResponse.statusCode == 401{
//
//                                        UserDefaults.standard.set(true, forKey: "sessionExpire")
//                                        DispatchQueue.main.async {
//
//                                            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle:  CommonString.alertTitle, withSuccessButtonTitle: nil, withMessage: CommonString.timeOutString, withCancelButtonTitle: "OK",hideOkayButton: false , completion: {
//
//                                                Helper.shared.logOutUser()
//                                            })
//                                        }
//                                        return
//                                    }else{
//
//                                        if let errorStr = (obj as! Dictionary<String,Any>)["Message"] as? String
//                                        {
//                                            DispatchQueue.main.async {
//                                                Helper.shared.showAlertOnController( message: errorStr, title: CommonString.alertTitle)
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
                    if  obj is Dictionary<String, Any> && ((obj as? Dictionary<String, Any>) != nil)
                    {
                        completion((obj as! Dictionary<String,Any>))
                    }
                    else
                    {
                        Helper.shared.showAlertOnController(message: "Something went wrong. Please try again later.", title: CommonString.alertTitle)
                    }
                }
                catch
                {
                    print("json error: \(error)")
                }
            }
            else
            {
                DispatchQueue.main.async {
                    if showIndicator
                    {
                        Loader.shared.hideLoader()
                    }
                    //                    Helper.sharedInstance.showAlertOnController(controller: (UIApplication.shared.keyWindow?.rootViewController)!, message: (serverError?.localizedDescription)!, title: "FameFlight")
                }
            }
        }
        task.resume()
    }
    
    func authenticateUserWith(email username : String, password : String, client_id : String, completion : @escaping (Any) -> ())
    {
        Loader.shared.showLoader()
        let strURL = SyncEngine.baseURL + SyncEngine.Login
        let user = username
        
        let user_email : String = (user.stringByAddingPercentEncodingForRFC3986(str: user as NSString))!
        let user_pass : String = (password.stringByAddingPercentEncodingForRFC3986(str: password as NSString))!

        let requestStr = "email=\(user_email)&password=\(user_pass.replacingOccurrences(of: "&", with: "%26"))&client_id=\(client_id)"
        
        
        print(requestStr)
        
        var serverRequest = URLRequest(url: URL(string: strURL)!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 30.0)
        serverRequest.httpMethod = "POST"
        let dataBody  = requestStr.data(using: .utf8)
        serverRequest.httpBody = dataBody
        
        let serviceSession = URLSession(configuration: URLSessionConfiguration.default)
        let task = serviceSession.dataTask(with: serverRequest) { (data : Data?, urlResponse : URLResponse?, serverError: Error?) in
            
            if data != nil && serverError == nil
            {
                DispatchQueue.main.async {
                    Loader.shared.hideLoader()
                }
                do
                {
                    print(String.init(data: data!, encoding: String.Encoding.utf8)!)
                    let objtemp = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    debugPrint(objtemp)
                    
                    let obj = (objtemp as! Dictionary<String,Any>)["user"]
                    if obj == nil
                    {
                        Helper.shared.showAlertOnController( message: "Invalid email or password", title: CommonString.alertTitle)
                        return
                    }
                    
                    if (obj as! Dictionary<String,Any>)["id"] as! NSInteger > 0
                    {
                        completion((objtemp as! Dictionary<String,Any>) as Any)
                    }
                    else if  obj is Dictionary<String,Any> && ((obj as! Dictionary<String,Any>).index(forKey: "error_description") != nil) && (((obj as! Dictionary<String,Any>)["error_description"] as? String) != nil)
                    {
                        Loader.shared.hideLoader()
                        if let errorStr = (obj as! Dictionary<String,Any>)["error_description"] as? String
                        {
                            DispatchQueue.main.async {
                                Helper.shared.showAlertOnController(message: errorStr, title: CommonString.alertTitle)
                            }
                        }
                    }
                    else
                    {
                        Helper.shared.showAlertOnController( message: "Something went wrong. Please try again later.", title: CommonString.alertTitle)
                    }
                }
                catch
                {
                    print("json error: \(error)")
                }
            }
            else
            {
                DispatchQueue.main.async {
                    Loader.shared.hideLoader()
                    //                    Helper.sharedInstance.showAlertOnController(controller: (UIApplication.shared.keyWindow?.rootViewController)!, message: (serverError?.localizedDescription)!, title: "FameFlight")
                }
            }
        }
        task.resume()
    }
}






