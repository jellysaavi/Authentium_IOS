//
//  CommonMethod.swift
//  Saavi
//
//  Created by Irmeen Sheikh on 13/03/18.
//  Copyright © 2018 Saavi. All rights reserved.
//

import UIKit
/*
class CommonMethod: NSObject {

    func showQuantityPopupAction(_ sender : Any?,collectionView:UICollectionView?, view: UIViewController, List:Array<Dictionary<String,Any>>, index:Int)
    {
        if Helper.shared.isDateSelected() == true
        {
            var viewToSearch = sender as? UIView
            repeat
            {
                viewToSearch = viewToSearch?.superview
            } while (viewToSearch as? UICollectionViewCell ) == nil

            if let cell = viewToSearch as? clctnCell
            {
                if let index = collectionView?.indexPath(for: cell)
                {
                    var product = List[index]
                    if let circularPopup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "circularQuantityStoryboardID") as? CircularQuantityPopup
                    {
                        if product.keyExists(key: "Quantity"), let number = product["Quantity"] as? NSNumber
                        {
                            circularPopup.circularSlider.currentValue = Float(number)
                            circularPopup.showCommonAlertOnWindow
                                {
                                    product["Quantity"] = NSNumber(value: Int(circularPopup.txtFldQuantity.text!)!)
                                    self.productList[index.row] = product
                                    collectionView?.reloadData()
                                    self.addProductToCart(productDetail: product, actualIndex: index.row)
                            }
                        }
                        else
                        {
                            circularPopup.circularSlider.currentValue = 1.0
                            circularPopup.showCommonAlertOnWindow
                                {
                                    product["Quantity"] = NSNumber(value: Int(circularPopup.txtFldQuantity.text!)!)
                                    self.productList[index.row] = product
                                    collectionView?.reloadData()
                                    self.addProductToCart(productDetail: product, actualIndex: index.row)
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
        else
        {
            self.showDatePicker(view: view)
        }
    }

    func showDatePicker(view: UIViewController) -> Void
    {
        if Helper.shared.isDateSelected() == false
        {
            let orderDatePicker = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "datePickerStoryID") as! DatePickerView
            view.present(orderDatePicker, animated: false, completion: nil)
            return
        }
    }

    func addProductToCart( productDetail : Dictionary<String, Any>, actualIndex : Int = -1)
    {
        if Helper.shared.isDateSelected() == true
        {
            print(productDetail)
            var arrPrices : Array<Dictionary<String,Any>>?
            if let prices = productDetail["DynamicUOM"] as? Array<Dictionary<String,Any>>
            {
                arrPrices = prices
            }
            else if var prices = productDetail["Prices"] as? Dictionary<String,Any>
            {
                prices["UOMDesc"] = productDetail["UOMDesc"] as? String
                prices["UOMID"] = productDetail["UOMID"] as? NSNumber
                arrPrices = [prices]
            }

            if (arrPrices != nil), arrPrices!.count > 0
            {
                var selectedIndex = 0
                if let index = productDetail["selectedIndex"] as? Int
                {
                    selectedIndex = index
                }
                let objToFetch = arrPrices![selectedIndex]

                let requestDic = [
                    "CartID": 0,
                    "CustomerID": UserInfo.shared.customerID ?? "0",
                    "IsOrderPlpacedByRep": false,
                    "RunNo": "",
                    "CommentLine": "",
                    "PackagingSequence": 0,
                    "CartItem": [
                        "CartItemID": 0,
                        "CartID":0,
                        "ProductID": productDetail["ProductID"],
                        "Quantity": (productDetail.keyExists(key: "Quantity") && productDetail["Quantity"] as? NSNumber != nil && Int(productDetail["Quantity"] as! NSNumber) != 0) ? (productDetail["Quantity"] as! NSNumber) : 1,
                        "Price": objToFetch["Price"],
                        "IsNoPantry": false,
                        "UnitId": objToFetch["UOMID"]
                    ]
                    ] as [String : Any]

                let serviceURL = SyncEngine.baseURL + SyncEngine.addItemsToCart

                var startStr = "1 unit"
                if Int((requestDic["CartItem"] as! Dictionary<String,Any>)["Quantity"] as! NSNumber) > 1
                {
                    startStr = "\((requestDic["CartItem"] as! Dictionary<String,Any>)["Quantity"] as! NSNumber) units"
                }

                SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestDic, strURL: serviceURL) { (response : Any) in

                    if let isAlreadyInCart = self.productList[actualIndex]["IsInCart"] as? Bool, isAlreadyInCart == false
                    {
                        Helper.shared.showAlertOnController(controller: self , message: startStr + " added to cart successfully", title: productDetail["ProductName"] as! String
                        )
                    }
                    else
                    {
                        Helper.shared.showAlertOnController(controller: self , message: startStr + " updated in cart successfully", title: productDetail["ProductName"] as! String
                        )
                    }


                    if actualIndex > -1
                    {
                        self.productList[actualIndex]["IsInCart"] = true

                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }

                    self.callAPIToUpdateCartNumber()
                }
            }
        }
        else
        {
            self.showDatePicker()
        }
    }

    func callAPIToUpdateCartNumber()
    {
        let request = [
            "CartID": 0,
            "IsSavedOrder": false,
            "UserID": UserInfo.shared.userId!,
            "CustomerID": UserInfo.shared.customerID!
            ] as [String : Any]

        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: request, strURL: SyncEngine.baseURL + SyncEngine.getCartCount, withIndicator: false) { (response : Any) in
            if let obj = response as? Dictionary<String,Any>, let cartCount = obj["Count"] as? NSNumber
            {
                DispatchQueue.main.async {
                    Helper.shared.cartCount = Int(cartCount)
                    if !(self.navigationItem.titleView is UISearchBar)
                    {
                        self.setDefaultNavigation()
                    }
                }
            }
        }
    }
}
 */

