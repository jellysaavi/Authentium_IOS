//
//  CustomerNotesVC.swift
//  Saavi
//
//  Created by goMad on 02/07/20.
//  Copyright © 2020 Saavi. All rights reserved.
//

import Foundation

class CustomerNotesVC: UIViewController,UICollectionViewDelegate ,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.getRepCustomerDic.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemNotecell", for: indexPath) as! ItemNotecell
        cell.lblNotes.text = self.getRepCustomerDic[indexPath.item]["Note"] as! String
        cell.lblSalesRep.text = self.getRepCustomerDic[indexPath.item]["RepName"] as! String
        cell.lblDate.text = self.getRepCustomerDic[indexPath.item]["Datetime"] as! String
        cell.lblNotes.numberOfLines = 0
        cell.lblNotes.lineBreakMode = NSLineBreakMode.byClipping
        cell.lblNotes.sizeToFit()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
       {
           
               return CGSize(width: (collectionView.bounds.size.width ), height: 300)
           
       }
    
    
    @IBOutlet weak var titleCustomerNotes: customLabel!
    @IBOutlet weak var cvCustomerNotes: UICollectionView!
    
    @IBOutlet weak var btnAddANote: UIButton!
    
    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet weak var lblNoNotes: UILabel!
    var getRepCustomerDic = Array<Dictionary<String,Any>>()
    
    @IBAction func btnAddNoteAction(_ sender: Any) {
        if let addNotePopupVC = UIStoryboard.init(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "AddNotePopupVC") as? AddNotePopupVC
         {
            addNotePopupVC.modalPresentationStyle = .fullScreen
            addNotePopupVC.completionBlock = { (buttonPressed) -> Void in
                
                if buttonPressed == .moveNext {
                    self.getCustomerNotes()
                }
            }

             self.present(addNotePopupVC, animated: false, completion: nil)
             
        }
        
    }
    
    
    
    override func viewDidLoad() {
          super.viewDidLoad()
        
        self.titleCustomerNotes?.font = UIFont.Roboto_Bold(baseScaleSize: 20.0)
        
        let tapRecog1 = UITapGestureRecognizer(target: self, action: #selector(self.backPressed(_:)))
        tapRecog1.delegate = self
        imgBack.addGestureRecognizer(tapRecog1)
        
        
        getCustomerNotes()
        setDefaultNavigation()
    }
    @objc func backPressed(_ sender: UIImageView) {
        self.dismiss(animated: true, completion: nil)
        
    }
    func setDefaultNavigation() -> Void
      {
          self.navigationItem.rightBarButtonItems = nil
          Helper.shared.createCartIcon(onController: self)
          Helper.shared.createSearchIcon(onController: self)
          
          Helper.shared.setNavigationTitle(viewController: self, title: CommonString.pantryListTitle)
                   Helper.shared.setNavigationTitle(withTitle: "", withLeftButton: .backButton, onController: self)
                   UserInfo.shared.navigationTitle = CommonString.pantryListTitle
          
         
      }
    //MARK:- Web Service to get customer list
       func getCustomerNotes(){
           
           let requestParameters = NSMutableDictionary()
           
           requestParameters.setValue(UserInfo.shared.customerID!, forKey: "CustomerID")
            let serviceURL = SyncEngine.baseURL + SyncEngine.GetCustomerNotes
           SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestParameters as! Dictionary<String, Any>, strURL: serviceURL) { (response : Any) in
               if (response as? Array<Dictionary<String,Any>>) != nil
               {
                self.getRepCustomerDic = (response as? Array<Dictionary<String,Any>>)!
                   
                   DispatchQueue.main.async(execute:
                       {
                         self.cvCustomerNotes.reloadData()
                        if self.getRepCustomerDic.count==0{
                            self.lblNoNotes.isHidden = false
                               
                           }
                           else{
                               self.lblNoNotes.isHidden = true
                           }
                   })
                  
               }
           }
           
       }
    
}
    
    class ItemNotecell: UICollectionViewCell {
       
        @IBOutlet weak var lblNotes: UILabel!
        @IBOutlet weak var titleDate: UILabel!
        @IBOutlet weak var titleSalesRep: UILabel!
        @IBOutlet weak var lblSalesRep: UILabel!
        @IBOutlet weak var titleNotes: UILabel!
        
        @IBOutlet weak var lblDate: UILabel!
        override func awakeFromNib() {
           self.titleDate?.font = UIFont.Roboto_Regular(baseScaleSize: 15.0)
           self.titleDate?.textColor = UIColor.priceInfoLightGreyColor()
            self.titleSalesRep?.font = UIFont.Roboto_Regular(baseScaleSize: 15.0)
            self.titleSalesRep?.textColor = UIColor.priceInfoLightGreyColor()
            
            self.titleNotes?.font = UIFont.Roboto_Regular(baseScaleSize: 15.0)
            self.titleNotes?.textColor = UIColor.priceInfoLightGreyColor()
            
            self.lblDate?.font = UIFont.Roboto_Bold(baseScaleSize: 15.0)
            self.lblSalesRep?.font = UIFont.Roboto_Bold(baseScaleSize: 15.0)
            self.lblNotes?.font = UIFont.Roboto_Bold(baseScaleSize: 15.0)
            self.lblDate?.textColor = UIColor.priceInfoLightGreyColor()
            self.lblSalesRep?.textColor = UIColor.priceInfoLightGreyColor()
            self.lblNotes?.textColor = UIColor.priceInfoLightGreyColor()
            
            
            
           
       }
        
        
    }
    

