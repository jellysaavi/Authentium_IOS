//
//  BarCodeScanViewController.swift
//  Saavi
//
//  Created by gomad on 16/05/19.
//  Copyright © 2019 Saavi. All rights reserved.
//

import UIKit
import AVFoundation
import NotificationCenter

class BarCodeScanViewController: UIViewController{
    
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var viewScannerContainer: UIView!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var btnPermissions: CustomButtonSalesRep!
    var barScannerView:BarCodeScanView?
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblBarcode: UILabel!
    @IBOutlet weak var lblBarcodeNumber: UILabel!
    @IBOutlet weak var viewBarcodeDetail: UIView!
    @IBOutlet weak var viewProductDetail: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addNavigationBarButtons()
        NotificationCenter.default.addObserver(self, selector: #selector(self.cameraPermissionDidChanged),name: NSNotification.Name.AVCaptureSessionDidStartRunning, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.callAPIToUpdateCartNumber),name: NSNotification.Name(rawValue: "addToCart"), object: nil)
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            DispatchQueue.main.async {
                self.viewBarcodeDetail.isHidden = false
                self.imgVw.image = #imageLiteral(resourceName: "readyToScan")
                self.btnPermissions.isHidden = true
                self.barScannerView = BarCodeScanView(frame: CGRect.init(x: 0, y: 0, width: self.viewScannerContainer.frame.size.width, height: self.viewScannerContainer.frame.size.height))
                self.barScannerView!.delegate = self
                self.viewScannerContainer.addSubview(self.barScannerView!)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.callAPIToUpdateCartNumber()
        self.tabBarController?.tabBar.isHidden = false
        self.checkCameraPermissions()
    }
    
    func addNavigationBarButtons(){
//        if UserInfo.shared.isSalesRepUser! && UIDevice.current.userInterfaceIdiom == .pad{
        Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
//        }
        self.navigationItem.rightBarButtonItems = nil
        Helper.shared.createCartIcon(onController: self)
        Helper.shared.setNavigationTitle(viewController: self, title: "Scan Barcode")
        self.btnPermissions.titleLabel?.textAlignment = .center
    }
    
    @IBAction func tappedOnRescan(_ sender: UITapGestureRecognizer) {
        if !self.barScannerView!.isRunning {
            self.barScannerView?.isRunning = true
            self.imgVw.image = #imageLiteral(resourceName: "readyToScan")
        }
    }
    
    func checkCameraPermissions(){
        
        self.lblDesc.text = "Place the barcode within the markers."
        self.barScannerView?.isRunning = true
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            DispatchQueue.main.async {
                self.imgVw.image = #imageLiteral(resourceName: "readyToScan")
            }
        }
    }
    
    @objc func cameraPermissionDidChanged(){
        self.btnPermissions.isHidden = true
    }
    
    //MARK: - - Back Button Action
    @objc func backBtnAction() -> Void{
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - - Permissions Button Action
    @IBAction func btnPermissionsAction(_ sender: CustomButtonSalesRep){
        self.imgVw.isHidden = true
        self.checkCameraPermissions()
        self.barScannerView = BarCodeScanView(frame: CGRect.init(x: 0, y: 0, width: self.viewScannerContainer.frame.size.width, height: self.viewScannerContainer.frame.size.height))
        self.barScannerView!.delegate = self
        self.viewScannerContainer.addSubview(self.barScannerView!)
    }
    
    func callGetProductIdAPI(barcode:String){
        
        let url = SyncEngine.baseURL + SyncEngine.ProductIdFromBarcode
        let params = ["Barcode":barcode]
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: params, strURL: url) { (response) in
            
            let dict = response as? NSDictionary
            DispatchQueue.main.async {
                
                for view in self.viewProductDetail.subviews
                {
                    view.removeFromSuperview()
                }
                if dict?.value(forKeyPath: "product.ProductCode") == nil{
                    
                    self.lblDesc.text = "This item could not be found.\nPlease try another item."
                    self.lblBarcodeNumber.text = "Does not exist!"
                    self.imgVw.image = #imageLiteral(resourceName: "alert-icon-red")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        self.checkCameraPermissions()
                    })
                }else{
                    
                    let childController = self.storyboard?.instantiateViewController(withIdentifier: "BarcodeProductListViewController") as? BarcodeProductListViewController
                    childController?.productId = "\(dict!.value(forKeyPath: "product.ProductCode") ?? "")"
                    childController?.delegate = self
                    self.addChildViewController(childController!)
                    self.viewProductDetail.addSubview(childController!.view)
                    childController!.didMove(toParentViewController: self)
                    childController?.willMove(toParentViewController: self)
                    self.barScannerView?.isRunning = false
                }
            }
        }
    }
    
    @objc func callAPIToUpdateCartNumber()
    {
        let request = [
            "CartID": 0,
            "IsSavedOrder": false,
            "UserID": UserInfo.shared.userId!,
            "CustomerID": UserInfo.shared.customerID!,
            "isRepUser": UserInfo.shared.isSalesRepUser as Any
            ] as [String : Any]
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: request, strURL: SyncEngine.baseURL + SyncEngine.getCartCount, withIndicator: false) { (response : Any) in
            if let obj = response as? Dictionary<String,Any>, let cartCount = obj["Count"] as? NSNumber
            {
                DispatchQueue.main.async {
                    Helper.shared.cartCount = Int(truncating: cartCount)
                    if !(self.navigationItem.titleView is UISearchBar)
                    {
                        self.addNavigationBarButtons()
                    }
                }
            }
        }
    }

    @objc func showCartScreen() -> Void
    {
        if UserInfo.shared.isGuest == true
        {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.guestUser, withCancelButtonTitle: "OK", completion: {
                Helper.shared.logoutAsGuest()
                return
            })
        }
        else if UserInfo.shared.customerOnHoldStatus==true && !AppFeatures.shared.isAllowOnHoldPlacingOrder {
            SaaviActionAlert.shared.showCommonAlertOnWindow(withTitle: CommonString.app_name, withSuccessButtonTitle: nil, withMessage: CommonString.holdCustomerStatus, withCancelButtonTitle: "OK", completion: {
                return
            })
        }
        else{
            if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cartVCStoryboardID") as? CartView
            {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension BarCodeScanViewController:BarScannerViewDelegate{
    
    func barScanningDidFail() {
        
    }
    
    func barScanningSucceededWithCode(_ str: String?) {
        self.lblBarcodeNumber.text = str
        self.callGetProductIdAPI(barcode: str!)
    }
    
    func barScanningDidStop() {
        
    }
}

extension BarCodeScanViewController:BarcodeListProtocols{

    func productFound(status:Bool) {
        
        if status{
            self.imgVw.image = #imageLiteral(resourceName: "rescan")
        }else{
            self.imgVw.image = #imageLiteral(resourceName: "alert-icon-red")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.checkCameraPermissions()
            })
        }
    }
}
