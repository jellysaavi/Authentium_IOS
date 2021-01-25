//
//  CurrentDetailsPopupVC.swift
//  Saavi
//
//  Created by gomad on 03/06/19.
//  Copyright © 2019 Saavi. All rights reserved.
//

import UIKit

class CurrentDetailsPopupVC: UIViewController {

    //MARK: - - Outlets
    @IBOutlet weak var viewPopupContainer: UIView!
    @IBOutlet weak var tblVwCurrentDetails: UITableView!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var tblVwStatus: UITableView!
    var dict:[String:Any]?
    
    //MARK: - - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
    }
    
    //MARK: - - Setup View
    private func setUpView(){
        self.viewPopupContainer.layer.cornerRadius = 10.0
        self.viewPopupContainer.clipsToBounds = true
        self.tblVwStatus.tableFooterView = UIView()
    }
    
    //MARK: - - tap geture action
    @IBAction func tappedOnBlurView(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: false, completion: nil)
    }
}

//MARK: - - TableView Delegates
extension CurrentDetailsPopupVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentCetailsPopupCell") as? CurrentCetailsPopupCell
        
        switch indexPath.row {
        case 0:
            cell?.lblTitle.text = "Terms:"
            cell?.lblDesc.text = (self.dict!["Terms"] as! String)
            break
        case 1:
            cell?.lblTitle.text = "Days Overdue:"
            cell?.lblDesc.text = "\(self.dict!["DaysOverdue"] ?? "")"
            break
        case 2:
            cell?.lblTitle.text = "Total Amount Owing:"
            let price = self.dict!["TotalBalance"] as? Double
            let price_final = Double(round(100*price!)/100)

            cell?.lblDesc.text = String(format: "\(CommonString.currencyType)%.2f", price_final)
            break
        default:
            break
        }
        return cell!
    }
}


//MARK: - - TableViewCell
class CurrentCetailsPopupCell:UITableViewCell{
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    
}
