//
//  SaaviTabBarController.swift
//  Saavi
//
//  Created by Sukhpreet on 27/06/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class SaaviTabBarController: UITabBarController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var menuController : MenuHierarchyHandler?
    var customCollectionTabBarController: SwappingCollectionView!
    var TotalUnread_count_str = String()
    
    var index:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        /*Tab bar handling, were used earlier.*/
        self.tabBar.barTintColor = UIColor.white
        self.tabBar.tintColor = UIColor.baseBlueColor()
        self.tabBar.unselectedItemTintColor = UIColor(red: 146.0/255.0, green: 146.0/255.0, blue: 146.0/255.0, alpha: 1.0)
        self.tabBar.shadowImage = UIImage(named: "blue-shdow")
        
        self.removeTab(at: 0)
        /*Layout Collection*/
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.scrollDirection = .horizontal
        
        /*Tab bar view that will be used*/
        customCollectionTabBarController = SwappingCollectionView(frame: CGRect(x: 0, y: 0, width: self.tabBar.bounds.width, height: self.tabBar.bounds.height), collectionViewLayout: layout)
        customCollectionTabBarController.backgroundColor = UIColor.white
        self.tabBar.addSubview(customCollectionTabBarController)
        customCollectionTabBarController.delegate = self
        customCollectionTabBarController.dataSource = self
        customCollectionTabBarController.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:))))
        customCollectionTabBarController.showsHorizontalScrollIndicator = false
        
        /*Cell Nib*/
        let nib = UINib(nibName: "CustomTabBarCellCollectionViewCell", bundle: nil)
        customCollectionTabBarController.register(nib, forCellWithReuseIdentifier: "customTabCellIndentifier")
        
        if AppFeatures.shared.isShowNotifications == true
        {
            self.GetNotificationsList()
        }
        
        
    }
//    override func viewWillAppear(_ animated: Bool) {
//    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if index != nil {
            self.collectionView(self.customCollectionTabBarController, didSelectItemAt: IndexPath.init(item: index!, section: 100))
            self.index = nil
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        self.tabBar.invalidateIntrinsicContentSize()
    }
    
    func removeTab(at index:Int) {
        if let viewControllers = self.viewControllers {
            let controllers = NSMutableArray.init(array: viewControllers)
            controllers.removeObject(at: index)
            self.tabBarController?.viewControllers = (controllers as! [UIViewController])
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- COLLECTION HANDLING
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.viewControllers != nil
        {
            return (self.viewControllers?.count)!
        }
        else
        {
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
    {
        if self.selectedIndex == indexPath.row
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView .dequeueReusableCell(withReuseIdentifier: "customTabCellIndentifier", for: indexPath) as! CustomTabBarCellCollectionViewCell
        
        if let item =  (self.viewControllers![indexPath.row] as? UINavigationController)?.tabBarItem
        {
            cell.tabItemTextLabel.text = item.title
            
            cell.badgeCountLbl.isHidden = true
            cell.badgeCountLbl.layer.cornerRadius = 10
            cell.badgeCountLbl.clipsToBounds = true

            if selectedIndex == indexPath.row
            {
                cell.tabItemImageView.image = item.selectedImage
                cell.tabItemTextLabel.textColor = UIColor.baseBlueColor()
                cell.tabItemImageView.tintColor = UIColor.baseBlueColor()
            }
            else
            {
                cell.tabItemImageView.image = item.image
                cell.tabItemTextLabel.textColor = AppConfig.darkGreyColor()
                cell.tabItemImageView.tintColor = UIColor.baseBlueColor()
            }
            
            if AppFeatures.shared.isShowNotifications == true
            {
                if indexPath.row == 1
                {
                    if(self.TotalUnread_count_str != "0")
                    {
                        cell.badgeCountLbl.isHidden = false
                        cell.badgeCountLbl.text = self.TotalUnread_count_str
                        cell.badgeCountLbl.backgroundColor = UIColor.baseBlueColor()
                    }
                }
            }

        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.size.width/3.5, height: collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        let initialVC = viewControllers?[sourceIndexPath.row]
        let destVC = viewControllers?[destinationIndexPath.row]
        viewControllers?[sourceIndexPath.row] = destVC!
        viewControllers?[destinationIndexPath.row] = initialVC!
        self.tabBar.bringSubview(toFront: customCollectionTabBarController)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item =  (self.viewControllers![indexPath.row] as? UINavigationController)?.tabBarItem
        {
            if AppFeatures.shared.isShowNotifications == true
            {
                self.GetNotificationsList()
            }
            
            if (item.title != nil) && item.title == "Invoices"
            {
                if AppFeatures.shared.shouldShowPDFInvoice == false
                {
                    if let invoiceGenerator = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: InvoiceEmailGeneratorView.invoiceEmailGeneratorStoryboardIdentifier) as? InvoiceEmailGeneratorView
                    {
                        self.navigationController?.present(invoiceGenerator, animated: false, completion: nil)
                    }
                    return
                }
            }
            //            SpecialProductRequest
            if (item.title != nil) && item.title == "Request Product"
            {
                if let customerDocument = UIStoryboard.init(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "externalDocID") as? ExternalDocVC
                {
                    customerDocument.isSpecialProductReq = true
                    self.navigationController?.present(customerDocument, animated: false, completion: nil)
                }
                return
            }
        }
        /*
         if let items = self.tabBar.items
         {
         if (items[indexPath.row].title != nil) && items[indexPath.row].title == "Invoices"
         {
         if AppFeatures.shared.shouldShowPDFInvoice == false
         {
         if let invoiceGenerator = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: InvoiceEmailGeneratorView.invoiceEmailGeneratorStoryboardIdentifier) as? InvoiceEmailGeneratorView
         {
         self.navigationController?.present(invoiceGenerator, animated: false, completion: nil)
         }
         return
         }
         }
         //            SpecialProductRequest
         if (items[indexPath.row].title != nil) && items[indexPath.row].title == "SpecialProductRequest"
         {
         if let customerDocument = UIStoryboard.init(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "externalDocID") as? ExternalDocVC
         {
         self.navigationController?.present(customerDocument, animated: false, completion: nil)
         }
         return
         }        }*/
        
        if let controller = self.viewControllers?[indexPath.row] as? UINavigationController
        {
            controller.popToRootViewController(animated: false)
        }
        self.selectedIndex = indexPath.row
        collectionView.reloadData()
    }
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = customCollectionTabBarController.indexPathForItem(at: gesture.location(in: customCollectionTabBarController)) else {
                break
            }
            let playWithObj  =  customCollectionTabBarController?.beginInteractiveMovementForItem(at: selectedIndexPath)
            if playWithObj == true
            {
                print("let the game begin")
            }
        case UIGestureRecognizerState.changed:
            customCollectionTabBarController?.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizerState.ended:
            customCollectionTabBarController?.endInteractiveMovement()
        default:
            customCollectionTabBarController?.cancelInteractiveMovement()
        }
    }
    
     func GetNotificationsList(){
            
            let appendparmsInUrl = "?customerId=" + UserInfo.shared.customerID!

            SyncEngine.sharedInstance.sendGetRequestToServer(strURL: SyncEngine.baseURL + SyncEngine.GetNotificationsList + appendparmsInUrl) { (response: Any) in
                
                let TotalUnread = (response as? Dictionary<String,Any>)?["TotalUnread"] as! NSNumber
                self.TotalUnread_count_str = String(format: "%@",TotalUnread)
                DispatchQueue.main.async {
                    self.customCollectionTabBarController.reloadData()
                }

        }
    }
}

extension UIView {
    func snapshot() -> UIImage {
        UIGraphicsBeginImageContext(self.bounds.size)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension CGPoint {
    func distanceToPoint(p:CGPoint) -> CGFloat {
        return sqrt(pow((p.x - x), 2) + pow((p.y - y), 2))
    }
}

struct SwapDescription : Hashable {
    var firstItem : Int
    var secondItem : Int
    
    var hashValue: Int {
        get {
            return (firstItem * 10) + secondItem
        }
    }
}

func ==(lhs: SwapDescription, rhs: SwapDescription) -> Bool {
    return lhs.firstItem == rhs.firstItem && lhs.secondItem == rhs.secondItem
}

class SwappingCollectionView: UICollectionView {
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var interactiveIndexPath : NSIndexPath?
    var interactiveView : UIView?
    var interactiveCell : UICollectionViewCell?
    var swapSet : Set<SwapDescription> = Set()
    var previousPoint : CGPoint?
    
    static let distanceDelta:CGFloat = 2 // adjust as needed
    
    override func beginInteractiveMovementForItem(at indexPath: IndexPath) -> Bool {
        
        let indexPath = indexPath as NSIndexPath
        
        self.interactiveIndexPath = indexPath
        
        self.interactiveCell = self.cellForItem(at: indexPath as IndexPath)
        
        self.interactiveView = UIImageView(image: self.interactiveCell?.snapshot())
        self.interactiveView?.frame = self.interactiveCell!.frame
        
        self.addSubview(self.interactiveView!)
        self.bringSubview(toFront: self.interactiveView!)
        
        self.interactiveCell?.isHidden = true
        
        return true
    }
    
    override func updateInteractiveMovementTargetPosition(_ targetPosition: CGPoint) {
        
        if (self.shouldSwap(newPoint: targetPosition)) {
            
            if let hoverIndexPath = self.indexPathForItem(at: targetPosition), let interactiveIndexPath = self.interactiveIndexPath {
                
                let swapDescription = SwapDescription(firstItem: interactiveIndexPath.item, secondItem: hoverIndexPath.item)
                
                if (!self.swapSet.contains(swapDescription)) {
                    
                    self.swapSet.insert(swapDescription)
                    
                    self.performBatchUpdates({
                        self.moveItem(at: interactiveIndexPath as IndexPath, to: hoverIndexPath)
                        self.moveItem(at: hoverIndexPath, to: interactiveIndexPath as IndexPath)
                    }, completion: {(finished) in
                        self.swapSet.remove(swapDescription)
                        self.dataSource?.collectionView!(self, moveItemAt: interactiveIndexPath as IndexPath, to: hoverIndexPath)
                        self.interactiveIndexPath = hoverIndexPath as NSIndexPath
                        
                    })
                }
            }
        }
        
        self.interactiveView?.center = targetPosition
        self.previousPoint = targetPosition
    }
    
    override func endInteractiveMovement() {
        self.cleanup()
    }
    
    override func cancelInteractiveMovement() {
        self.cleanup()
    }
    
    func cleanup() {
        self.interactiveCell?.isHidden = false
        self.interactiveView?.removeFromSuperview()
        self.interactiveView = nil
        self.interactiveCell = nil
        self.interactiveIndexPath = nil
        self.previousPoint = nil
        self.swapSet.removeAll()
    }
    
    func shouldSwap(newPoint: CGPoint) -> Bool {
        if let previousPoint = self.previousPoint {
            let distance = previousPoint.distanceToPoint(p: newPoint)
            return distance < SwappingCollectionView.distanceDelta
        }
        
        return false
    }


}

