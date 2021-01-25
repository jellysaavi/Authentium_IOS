//
//  SalesRepWelcomeVc.swift
//  Saavi
//
//  Created by Priya on 13/03/18.
//  Copyright © 2018 Saavi. All rights reserved.
//

import UIKit

class SalesRepWelcomeVc: UIViewController {
    
    //MARK: - - Outlets 
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var btn_SearchByProduct: UIButton!
    @IBOutlet weak var btn_SearchByCustomer: UIButton!
    
    //MARK: - - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let mutableStr = NSMutableAttributedString(string: "\(CommonString.welcomeString) \((UserInfo.shared.name!).capitalized)")
        mutableStr.addAttributes([NSAttributedStringKey.font : UIFont.Roboto_Regular(baseScaleSize: 24.0), NSAttributedStringKey.foregroundColor : UIColor.black], range: NSRange(location: 0, length: mutableStr.length))
        mutableStr.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.darkGreyColor()], range: (mutableStr.string as NSString).range(of: "\(CommonString.welcomeString) "))
        self.userNameLbl.attributedText = mutableStr
        logoutBtn.tintColor = UIColor.baseBlueColor()
        btn_SearchByProduct.backgroundColor = UIColor.baseBlueColor()
        btn_SearchByCustomer.backgroundColor = UIColor.baseBlueColor()
        
        userImg.tintColor = UIColor.baseBlueColor()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOutAction(_ sender: Any)
    {
        Helper.shared.logout()
    }

    @IBAction func searchByCustomerAction(_ sender: Any) {
        let customerListVC = self.storyboard?.instantiateViewController(withIdentifier: "CustomerListVC") as? CustomerListVC
        self.navigationController?.pushViewController(customerListVC!, animated: true)
    }
    
    @IBAction func serachByProductAction(_ sender: Any) {
        let searchProductVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchProductVC") as? SearchProductVC
        self.navigationController?.pushViewController(searchProductVC!, animated: true)
    }
    
}

