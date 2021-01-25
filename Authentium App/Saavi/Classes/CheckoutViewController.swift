//
//  CheckoutViewController.swift
//  app
//
//  Created by Yuki Tokuhiro on 9/25/19.
//  Copyright © 2019 stripe-samples. All rights reserved.
//

import UIKit
import Stripe

/**
 * This example collects card payments, implementing the guide here: https://stripe.com/docs/payments/accept-a-payment-synchronously#ios
 *
 * To run this app, follow the steps here https://github.com/stripe-samples/accept-a-card-payment#how-to-run-locally
 */
class CheckoutViewController: UIViewController {
    
    var paymentIntentClientSecret: String?
    var orderID : NSNumber?
    var cartTotal : Double = 0.0
    var tempCartID : NSNumber = 0
    var autoAuthorize : Bool?
    var saveOrderRequest : [String : Any] = [:]
    var modelPayment = NSDictionary()
    var comingFromRecurringCart : Bool = false
    
    var daysDiffInCurrentAndOrderDate : Int?

    
    @IBOutlet var paymentView: UIView!
    @IBOutlet var recurrPaymentDetailView: UIView!
    
    @IBOutlet var statusLbl: UILabel!
    @IBOutlet var orderTypeLbl: UILabel!
    @IBOutlet var addressTextView: UITextView!
    @IBOutlet var startDateLbl: UILabel!
    @IBOutlet var frequencyLbl: UILabel!
    
    @IBOutlet var invoiceBgView: UIView!
    @IBOutlet var invoiceView: UIView!
    @IBOutlet var okBtn: UIButton!
    @IBOutlet var invoice_orderRefLbl: UILabel!
    @IBOutlet var invoice_deliveryDateLbl: UILabel!
    @IBOutlet var invoice_chargeDateLbl: UILabel!
    @IBOutlet var invoice_deliveryType: UILabel!
    @IBOutlet var invoice_frequency: UILabel!
    @IBOutlet var invoice_amount: UILabel!
    @IBOutlet var invoice_address: UITextView!
    
    
    @IBOutlet var invoiceScrollView: UIScrollView!
    
    @IBOutlet weak var txtPrice: UITextView!
    @IBOutlet weak var cardTextField: STPPaymentCardTextField!
    
    @IBOutlet weak var btnPay: UIButton!
    func displayAlert(title: String, message: Any, restartDemo: Bool = false) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message as? String, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))

            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardTextField.postalCodeEntryEnabled = false
        self.navigationItem.hidesBackButton = true
        Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)

        Helper.shared.setNavigationTitle(viewController: self, title: "Payment Details")
        
        SyncEngine.sharedInstance.sendGetRequestToServer(strURL: SyncEngine.baseURL + SyncEngine.GetStripeKeys) { (response: Any) in
            
            if let responseDic = response as? Dictionary<String,Any>
            {
                print(responseDic)
                
                Helper.shared.stripePublicKey = ((responseDic["PublicKey"] as? String))!
                Helper.shared.stripeAccountId = ((responseDic["ConnectedAccountID"] as? String))!
                Stripe.setDefaultPublishableKey(Helper.shared.stripePublicKey!)
                STPAPIClient.shared().stripeAccount = Helper.shared.stripeAccountId

//                self.startCheckout()
            }
            
        }
            
        let ordValue = self.cartTotal
        txtPrice.text = String(format: "$%@",ordValue.withCommas())
        
        if(comingFromRecurringCart == true)
        {
            paymentView.frame = CGRect(x: paymentView.frame.origin.x, y: (recurrPaymentDetailView.frame.origin.y + recurrPaymentDetailView.frame.size.height), width: paymentView.frame.size.width, height: paymentView.frame.size.height)
            recurrPaymentDetailView.isHidden = false
            
            if(UserInfo.shared.isSuspended == false)
            {
                statusLbl.text = "ACTIVE"
            }
            else
            {
                statusLbl.text = "NOT ACTIVE"
            }
            
            if (UserInfo.shared.Frequency == "Monthly")
            {
                frequencyLbl.text = "Monthly"
            }
            else if (UserInfo.shared.Frequency == "Weekly")
            {
                frequencyLbl.text = "Weekly"
            }
            else
            {
                frequencyLbl.text = "Fornightly"
            }
            
            if(UserInfo.shared.isDelivery == true)
            {
                orderTypeLbl.text = "Delivery"
                addressTextView.text = UserInfo.shared.deliveryAddressString
            }
            else
            {
                orderTypeLbl.text = "Pick-up"
                addressTextView.text = UserInfo.shared.pickupAddressString
            }
            
            let df = DateFormatter()
            df.dateFormat = "dd/MM/yyyy"
            startDateLbl.text = df.string(from: Helper.shared.selectedDeliveryDate ?? Date())
            
            let df_new = DateFormatter()
            df_new.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let orderDate : Date = Helper.shared.selectedDeliveryDate ?? Date()
//            let currentDate = Date()
//
//            let calendar = NSCalendar.current
//            let date1 = calendar.startOfDay(for: orderDate)
//            let date2 = calendar.startOfDay(for: currentDate)
//            let components = calendar.dateComponents([.day], from: date2, to: date1)
//
//            daysDiffInCurrentAndOrderDate = components.day
//            print(daysDiffInCurrentAndOrderDate!)
            
            
//            invoiceBgView.isHidden = false
//            self.navigationController?.isNavigationBarHidden = true
//            self.tabBarController?.tabBar.isHidden = true
            
            var dayComponent = DateComponents()
            dayComponent.day = -2 // For removing one day (yesterday): -1
            let theCalendar = Calendar.current
            let twoDaysBackDate = theCalendar.date(byAdding: dayComponent, to: orderDate)
            print("twoDaysBack : \(String(describing: twoDaysBackDate))")
            invoice_chargeDateLbl.text = df.string(from: twoDaysBackDate ?? Date())

            
            
            self.invoiceView.layer.cornerRadius = 25
            self.invoiceView.clipsToBounds = true
            self.okBtn.layer.cornerRadius = 15.0
            self.okBtn.titleLabel?.font = UIFont.Roboto_Bold(baseScaleSize: 18.0)
            self.okBtn.backgroundColor = UIColor.primaryColor()
            
            
            invoice_orderRefLbl.text = String(format: "%@%", self.tempCartID)
            invoice_deliveryDateLbl.text = df.string(from: Helper.shared.selectedDeliveryDate ?? Date())
            invoice_deliveryType.text = orderTypeLbl.text
            invoice_frequency.text = frequencyLbl.text
            invoice_amount.text = txtPrice.text
            invoice_address.text = addressTextView.text

        }
        else
        {
            paymentView.frame = CGRect(x: paymentView.frame.origin.x, y: paymentView.frame.origin.y + 50, width: paymentView.frame.size.width, height: paymentView.frame.size.height + 50)

        }
        
        invoiceScrollView.isScrollEnabled = false
        
        if (self.view.frame.size.height <= 736)
        {
            invoiceScrollView.isScrollEnabled = true
            invoiceScrollView.contentSize = CGSize(width: invoiceScrollView.frame.size.width, height: 950)
            invoiceView.frame = CGRect(x:invoiceView.frame.origin.x , y: invoiceView.frame.origin.y, width: invoiceView.frame.size.width, height: invoiceView.frame.size.height + 300)

        }
        else if (self.view.frame.size.height == 812)
        {
            invoiceScrollView.isScrollEnabled = true
            invoiceScrollView.contentSize = CGSize(width: invoiceScrollView.frame.size.width, height: 900)
            invoiceView.frame = CGRect(x:invoiceView.frame.origin.x , y: invoiceView.frame.origin.y, width: invoiceView.frame.size.width, height: invoiceView.frame.size.height + 250)
        }
        else if (self.view.frame.size.height > 812)
        {
            invoiceScrollView.isScrollEnabled = false
        }



    }
    
    @objc func backBtnAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func OkButtonAction(_ sender: Any)
    {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        invoiceBgView.isHidden = true
        
        self.navigationController?.popViewController(animated: true)

    }
    
    
    @IBAction func payAction(_ sender: Any) {
        
        print(self.paymentIntentClientSecret)
        
        cardTextField.resignFirstResponder()
        
//        guard let paymentIntentClientSecret = self.paymentIntentClientSecret else {
//            return;
//        }
        if cardTextField.cardNumber == nil
        {
            self.displayAlert(title: "Error!", message: "Please enter your card number first")
            return;
        }
        if cardTextField.expirationMonth == 0
        {
            self.displayAlert(title: "Error!", message: "Please enter your card expiration month")
            return;
        }
        if cardTextField.expirationYear == 0
        {
            self.displayAlert(title: "Error!", message: "Please enter your card expiration year")
            return;
        }
        if cardTextField.cvc == nil
        {
            self.displayAlert(title: "Error!", message: "Please enter your card cvc")
            return;
        }
        
        
        self.view.isUserInteractionEnabled = false
        Loader.shared.showLoader()
        let cardParams = STPCardParams()
        cardParams.number = cardTextField?.cardNumber
        cardParams.expMonth = (cardTextField?.expirationMonth)!
        cardParams.expYear = (cardTextField?.expirationYear)!
        cardParams.cvc = cardTextField?.cvc
        
        // Collect card details
        let cardParam = cardTextField.cardParams
        let paymentMethodParams = STPPaymentMethodParams(card: cardParam, billingDetails: nil, metadata: nil)
//        let paymentIntentParams = STPPaymentIntentParams(clientSecret: paymentIntentClientSecret)
//        paymentIntentParams.paymentMethodParams = paymentMethodParams

        
        STPAPIClient.shared().createPaymentMethod(with: paymentMethodParams) { (token: STPPaymentMethod?, error: Error?) in
            
            guard let token = token, error == nil else {
                
                self.displayAlert(title: "Error!", message: error.debugDescription)

                self.view.isUserInteractionEnabled = true
                Loader.shared.hideLoader()
                
                return
            }
            Loader.shared.hideLoader()
            
            print(token.stripeId)
            
            if(self.comingFromRecurringCart == true)
            {
                self.CreateSubscription(cardDetailsToken: token.stripeId)
            }
            else
            {
                self.startPaymentCheckout(cardDetailsToken: token.stripeId)
            }


        }
        
        
//        STPAPIClient.shared().createToken(withCard: cardParams) { (token: STPToken?, error: Error?) in
//            guard let token = token, error == nil else {
//
//                self.displayAlert(title: "Error!", message: error.debugDescription)
//
//                self.view.isUserInteractionEnabled = true
//                Loader.shared.hideLoader()
//
//                return
//            }
//            self.view.isUserInteractionEnabled = true
//            Loader.shared.hideLoader()
//
//            self.startPaymentCheckout(cardDetailsToken: token.tokenId)
//
//            print(token)
//            print(token.tokenId)
//        }


        
//        self.view.isUserInteractionEnabled = false
//        Loader.shared.showLoader()
//
//        // Collect card details
//        let cardParams = cardTextField.cardParams
//        let paymentMethodParams = STPPaymentMethodParams(card: cardParams, billingDetails: nil, metadata: nil)
//        let paymentIntentParams = STPPaymentIntentParams(clientSecret: paymentIntentClientSecret)
//        paymentIntentParams.paymentMethodParams = paymentMethodParams
//
//        // Submit the payment
//        let paymentHandler = STPPaymentHandler.shared()
//        paymentHandler.confirmPayment(withParams: paymentIntentParams, authenticationContext: self) { (status, paymentIntent, error) in
//            switch (status) {
//            case .failed:
//                self.displayAlert(title: "Payment failed", message: error?.localizedDescription ?? "")
//                self.view.isUserInteractionEnabled = true
//                Loader.shared.hideLoader()
//                self.SendPaymentLogsOnServer(logMessage: error?.localizedDescription ?? "")
//                break
//            case .canceled:
//                self.displayAlert(title: "Payment canceled", message: error?.localizedDescription ?? "")
//                self.view.isUserInteractionEnabled = true
//                Loader.shared.hideLoader()
//                self.SendPaymentLogsOnServer(logMessage: error?.localizedDescription ?? "")
//                break
//            case .succeeded:
////                self.displayAlert(title: "Payment succeeded", message: paymentIntent ?? "", restartDemo: true)
//                DispatchQueue.main.async {
//                    self.PlaceOrderAfterPayment(message: paymentIntent ?? "")
//                }
//                Loader.shared.hideLoader()
//                break
//            @unknown default:
//                self.view.isUserInteractionEnabled = true
//                fatalError()
//                break
//            }
//        }
    }
    
    func CreateSubscription(cardDetailsToken: Any) {
        
//        var immediatepayment = Bool()
//
//        if(daysDiffInCurrentAndOrderDate! <= 2)
//        {
//            immediatepayment = true
//        }
//        else
//        {
//            immediatepayment = false
//        }

            let dicCart = [
                "planid": self.tempCartID,
                "frequency": self.modelPayment["Frequency"] as! String,
                "paymentmethod": cardDetailsToken,
                "customerid": self.modelPayment["CustomerID"] as! NSNumber,
                "userid": 0,
                "devicetype": "iPhone",
                "price": self.cartTotal,
                "isupdate": true,
                "immediatepayment": false,
                "model": self.modelPayment
                ] as [String : Any]
        
        debugPrint("orderDetail==",dicCart)

        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: dicCart, strURL: SyncEngine.baseURL + SyncEngine.CreateSubscription) { (response : Any) in
            
            DispatchQueue.main.async {

                if (response as? NSDictionary) != nil
                {
                    self.view.isUserInteractionEnabled = true
//                    Helper.shared.showAlertOnController( message: "Your subscription has been created successfully.\(((((response as? Dictionary<String,Any>)?["OrderID"]) as? NSNumber) != nil) ? " Your order number is \((((response as? Dictionary<String,Any>)?["OrderID"]) as! NSNumber))" : "")", title: CommonString.app_name,hideOkayButton: true)

                    self.invoiceBgView.isHidden = false
                    self.navigationController?.isNavigationBarHidden = true
                    self.tabBarController?.tabBar.isHidden = true


                    self.SendRecurringPaymentLogsOnServer(logMessage: "Your subscription has been created successfully.\(((((response as? Dictionary<String,Any>)?["OrderID"]) as? NSNumber) != nil) ? " Your order number is \((((response as? Dictionary<String,Any>)?["OrderID"]) as! NSNumber))" : "")")

                    Helper.shared.dismissAlert()

//                    self.navigationController?.popViewController(animated: true)

                }
            }
        }


    }

    
    func startPaymentCheckout(cardDetailsToken: Any) {

            let dicCart = [
                "Status": "succeeded",
                "Id": "",
                "Amount": self.cartTotal * 100,
                "Currency": "",
                "CustomerId": self.saveOrderRequest["CustomerID"] as! String!,
                "Livemode": "",
                "ClientSecret": "",
                "ReceiptEmail": ""
                ] as [String : Any]
            self.saveOrderRequest["PaymentDetails"] = dicCart;
        
        let dicCartItem = [
            "CurrencyCode": "AUD",
            "OnlyAuthorize": self.autoAuthorize,
            "PaymentTotal": self.cartTotal,
            "DeviceType": "iPhone",
            "Token": cardDetailsToken,
            "OrderDetails": self.saveOrderRequest,
            "TempcartID": self.tempCartID
            ] as [String : Any]
        
        debugPrint("orderDetail==",dicCartItem)

        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: dicCartItem, strURL: SyncEngine.baseURL + SyncEngine.GetPaymentData) { (response : Any) in
            
            DispatchQueue.main.async {

                if (response as? NSDictionary) != nil
                {
                    self.view.isUserInteractionEnabled = true
                    Helper.shared.showAlertOnController( message: "Your order has been placed successfully.\(((((response as? Dictionary<String,Any>)?["OrderID"]) as? NSNumber) != nil) ? " Your order number is \((((response as? Dictionary<String,Any>)?["OrderID"]) as! NSNumber))" : "")", title: CommonString.app_name,hideOkayButton: true)


                    self.SendPaymentLogsOnServer(logMessage: "Your order has been placed successfully.\(((((response as? Dictionary<String,Any>)?["OrderID"]) as? NSNumber) != nil) ? " Your order number is \((((response as? Dictionary<String,Any>)?["OrderID"]) as! NSNumber))" : "")")

                    Helper.shared.dismissAlert()


                    Helper.shared.lastSetDateTimestamp = nil
                    Helper.shared.selectedDeliveryDate = nil
                    Helper.shared.cartCount = 0
                    NotificationCenter.default.post(name: Notification.Name("placeOrder"), object: nil, userInfo: nil)
//                    self.navigationController?.popViewController(animated: true)
//                    self.navigationController?.backToViewController(CategorySelectionVC.self)
                    for controller in self.navigationController!.viewControllers as Array {
                        if controller.isKind(of: OrderVC.self) {
                            self.navigationController!.popToViewController(controller, animated: true)
                            break
                        }
                    }
                }
            }
        }


    }
    
//    func PlaceOrderAfterPayment(message: Any)
//    {
//            if let jsonArray = try message as? STPPaymentIntent
//            {
//                let dicCartItem = [
//                    "Status": "succeeded",
//                    "Id": jsonArray.stripeId,
//                    "Amount": self.cartTotal * 100,
//                    "Currency": jsonArray.currency,
//                    "CustomerId": self.saveOrderRequest["CustomerID"] as! String!,
//                    "Livemode": jsonArray.livemode,
//                    "ClientSecret": jsonArray.clientSecret,
//                    "ReceiptEmail": ""
//                    ] as [String : Any]
//
//                self.saveOrderRequest["PaymentDetails"] = dicCartItem;
//
//                let requestURL  = SyncEngine.baseURL + SyncEngine.placeOrder
//                SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: self.saveOrderRequest, strURL: requestURL) { (response : Any) in
//                    DispatchQueue.main.async {
//
//                        self.view.isUserInteractionEnabled = true
//
//                        Helper.shared.showAlertOnController( message: "Your order has been placed successfully.\(((((response as? Dictionary<String,Any>)?["OrderID"]) as? NSNumber) != nil) ? " Your order number is \((((response as? Dictionary<String,Any>)?["OrderID"]) as! NSNumber))" : "")", title: CommonString.app_name,hideOkayButton: true)
//
//
//                        self.SendPaymentLogsOnServer(logMessage: "Your order has been placed successfully.\(((((response as? Dictionary<String,Any>)?["OrderID"]) as? NSNumber) != nil) ? " Your order number is \((((response as? Dictionary<String,Any>)?["OrderID"]) as! NSNumber))" : "")")
//
//                        Helper.shared.dismissAlert()
//
//
//                        Helper.shared.lastSetDateTimestamp = nil
//                        Helper.shared.selectedDeliveryDate = nil
//                        Helper.shared.cartCount = 0
//                        NotificationCenter.default.post(name: Notification.Name("placeOrder"), object: nil, userInfo: nil)
//                        self.navigationController?.popViewController(animated: true)
//                    }
//                }
//
//
//            } else {
//                print("bad json")
//                self.view.isUserInteractionEnabled = true
//            }
//}
    
    func SendPaymentLogsOnServer(logMessage : String) {
            
        let dicCartItem = [
            "PayResponse": logMessage,
            "TempCartID": self.tempCartID
            ] as [String : Any]
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: dicCartItem, strURL: SyncEngine.baseURL + SyncEngine.SavePaymentLogsOnServer) { (response : Any) in
            if (response as? String) != nil
            {
                
            }
        }

    }
    
    func SendRecurringPaymentLogsOnServer(logMessage : String) {
            
        let dicCartItem = [
            "payResponse": logMessage,
            "recurringId": self.tempCartID,
            "customerId": self.modelPayment["CustomerID"] as! NSNumber,
            "price": self.cartTotal,
            "userid":0,
            "devicetype": "iPhone"
            ] as [String : Any]
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: dicCartItem, strURL: SyncEngine.baseURL + SyncEngine.SaveRecurringPaymentLogsOnServer) { (response : Any) in
            if (response as? String) != nil
            {
                
            }
        }

    }
    
}



extension CheckoutViewController: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}
