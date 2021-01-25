//
//  ItemAvailabiltyVC.swift
//  Saavi
//
//  Created by Irmeen Sheikh on 22/02/18.
//  Copyright © 2018 Saavi. All rights reserved.
//

import UIKit

class ItemAvailabiltyVC: UIViewController,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var lbl_ItemAvlb: UILabel!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var view_Header: UIView!
    @IBOutlet weak var tbl_ItemsAvlbl: UITableView!
    @IBOutlet weak var btn_OK: CustomButton!
    @IBOutlet weak var view_main: UIView!
    @IBOutlet weak var lbl_warehouse: UILabel!
    @IBOutlet weak var lbl_qtyOnHand: UILabel!
    @IBOutlet weak var lbl_qtyOnOrder: UILabel!
    @IBOutlet weak var lbl_dueDate: UILabel!
    var prod_name: String?
    var prodId = NSNumber()
    var warehousesDetailArr = Array<Dictionary<String,Any>>()
    var senderView : PantryListVC?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
   lbl_title.text = prod_name
   lbl_ItemAvlb.font = UIFont.Roboto_Bold(baseScaleSize: 18.0)
   lbl_title.font = UIFont.Roboto_Regular(baseScaleSize: 18.0)
   bgColor()
   getRepProductDetails()
        
    }
    
    func bgColor()
    {
        view_Header.backgroundColor = UIColor.lightGreyColor()
        lbl_warehouse.backgroundColor = UIColor.baseBlueColor()
        lbl_qtyOnHand.backgroundColor = UIColor.baseBlueColor()
        lbl_qtyOnOrder.backgroundColor = UIColor.baseBlueColor()
        lbl_dueDate.backgroundColor = UIColor.baseBlueColor()
        tbl_ItemsAvlbl.backgroundColor = UIColor.lightGreyColor()
        view_main.layer.cornerRadius = 7.0 * Configration.scalingFactor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    MARK:- Table View Handling
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if warehousesDetailArr.count>0{
        return warehousesDetailArr.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemAvailabilityCell") as? ItemAvailabilityCell
        var warehousesDic = Dictionary<String,Any>()
        warehousesDic = warehousesDetailArr[indexPath.row]
        if warehousesDic.keyExists(key: "Warehouse"), let warehouseName = warehousesDic["Warehouse"] as? String{
        cell?.lbl_warehouseValue.text = warehouseName
        }
        else{
           cell?.lbl_warehouseValue.text = "-"
        }
        if warehousesDic.keyExists(key: "StockOnHand"), let stockOnHand = warehousesDic["StockOnHand"] as? Double{
        let stockOnHandStr = String(format: "%.0f", stockOnHand)
        cell?.lbl_qtyOnHandValue.text = stockOnHandStr
        }
        else{
           cell?.lbl_qtyOnHandValue.text = "-"
        }
        if warehousesDic.keyExists(key: "StockOnOrder"), let stockOnOrder = warehousesDic["StockOnOrder"] as? Double{
        
        cell?.lbl_qtyOnOrderValue.text = String(format: "%.0f", stockOnOrder)
        }
        else{
          cell?.lbl_qtyOnOrderValue.text = "-"
        }
        if warehousesDic.keyExists(key: "OrderDueDate"), let orderDueDate = warehousesDic["OrderDueDate"] as? String{
        cell?.lbl_dueDateValue.text = orderDueDate
        }
        else{
         cell?.lbl_dueDateValue.text = "-"
        }
        if indexPath.row % 2 == 0{
            cell?.lbl_warehouseValue.backgroundColor =  UIColor.evenRowColor()
             cell?.lbl_qtyOnHandValue.backgroundColor =  UIColor.evenRowColor()
             cell?.lbl_qtyOnOrderValue.backgroundColor =  UIColor.evenRowColor()
             cell?.lbl_dueDateValue.backgroundColor =  UIColor.evenRowColor()
        }
        else{
            cell?.lbl_warehouseValue.backgroundColor =  UIColor.oddRowColor()
            cell?.lbl_qtyOnHandValue.backgroundColor =  UIColor.oddRowColor()
            cell?.lbl_qtyOnOrderValue.backgroundColor =  UIColor.oddRowColor()
            cell?.lbl_dueDateValue.backgroundColor =  UIColor.oddRowColor()
        }
        cell?.contentView.backgroundColor = UIColor.lightGreyColor()
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height/4.0
    }
    

    @IBAction func OK_Action(_ sender: Any) {
        self.dismiss(animated: false, completion: {
            self.senderView?.index = -1
            self.senderView?.selectedIndexPath = nil
            self.senderView?.clctn_PantryList.reloadData()
            self.senderView?.clctn_Features.reloadData()
        })
    }
    
   
    //MARK:- Web Service to get customer list
    func getRepProductDetails(){
        let requestParameters = NSMutableDictionary()
        requestParameters.setValue(prodId , forKey: "ProductID")

        let serviceURL = SyncEngine.baseURL + SyncEngine.getRepProductDetails
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestParameters as! Dictionary<String, Any>, strURL: serviceURL) { (response : Any) in
            if (response as? Dictionary<String,Any>) != nil
            {
                if (response is Dictionary<String,Any>) && (response as! Dictionary<String,Any>).keyExists(key: "Warehouses"), let warehousesArr = (response as! Dictionary<String,Any>)["Warehouses"] as? Array<Dictionary<String,Any>>
                {
                 self.warehousesDetailArr = warehousesArr
                 print(self.warehousesDetailArr)
                }
                
            }
            DispatchQueue.main.async(execute:
                {
                    self.tbl_ItemsAvlbl.reloadData()
            })
        }
    }
    
}

class ItemAvailabilityCell: UITableViewCell {
    @IBOutlet weak var lbl_warehouseValue: UILabel!
    @IBOutlet weak var lbl_qtyOnHandValue: UILabel!
    @IBOutlet weak var lbl_qtyOnOrderValue: UILabel!
    @IBOutlet weak var lbl_dueDateValue: UILabel!
    override func awakeFromNib() {
        
    }
}
