//
//  DateTimeCorrectionPopupVC.swift
//  Saavi
//

import UIKit

enum DateConfirmStatus {
    case no
    case yes
}

typealias DateConfirmCompleted = (_ status: DateConfirmStatus?) -> Void

class DateConfirmationPopupVC: UIViewController {
    
    //MARK: - - Outlets/Variables
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var viewDate: UIView!
    @IBOutlet weak var imgViewCheck: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var btnYes: UIButton!
    var strDate : String?
    // Handle completion if needed.
    var completionBlock : DateConfirmCompleted? = nil
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.makeUIChanges()
    }
    
    //MARK: - Implement UI changes
    private func makeUIChanges() -> Void {
        //Set corner radius
        self.viewAlert.layer.cornerRadius = 10
        self.viewAlert.clipsToBounds = true
        
        self.lblDate.text = strDate
        self.lblDescription.font = UIFont.SFUI_Regular(baseScaleSize: 20.0)
        self.viewDate.backgroundColor = UIColor.baseBlueColor()
        self.lblDate.font = UIFont.SFUI_SemiBold(baseScaleSize: 28.0)
        self.btnNo.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
        self.btnYes.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 18.0)
    }
    
    //MARK: Buttons Actions
    /// No button click action
    @IBAction func btnNoAction(_ sender: Any) {
        self.dismiss(animated: false, completion: {
            if self.completionBlock != nil
            {
                self.completionBlock!(DateConfirmStatus.no)
            }
        })
    }
    
    /// Yes button click action
    @IBAction func btnYesAction(_ sender: Any) {
        self.dismiss(animated: false, completion: {
            if self.completionBlock != nil
            {
                self.completionBlock!(DateConfirmStatus.yes)
            }
        })
    }
    
}

