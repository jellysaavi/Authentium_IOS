//
//  MessageDetailVC.swift
//  Saavi
//
//  Created by Irmeen Sheikh on 22/01/18.
//  Copyright © 2018 Saavi. All rights reserved.
//

import UIKit

class MessageDetailVC: UIViewController {

    @IBOutlet weak var lbl_msgDetail: UILabel!
    @IBOutlet weak var btn_msg: UIButton!
    var message = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btn_msg.titleLabel?.font = UIFont.SFUI_SemiBold(baseScaleSize: 18.0)
        self.lbl_msgDetail.font = UIFont.SFUI_Regular(baseScaleSize: 16.5)
      //  self.lbl_msgDetail.textColor = UIColor.lightGray
        self.btn_msg.tintColor = UIColor.baseBlueColor()
        self.lbl_msgDetail.text = message
        self.btn_msg.setTitleColor(UIColor.baseBlueColor(), for: .normal)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
          self.navigationController?.navigationBar.isHidden = false
          Helper.shared.setNavigationTitle(withTitle: "Message", withLeftButton: .backButton, onController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func BackAction(_ sender: Any) {
    self.navigationController?.popViewController(animated: false)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
