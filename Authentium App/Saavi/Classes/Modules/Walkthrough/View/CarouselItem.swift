import Foundation
import UIKit

@IBDesignable
class CarouselItem: UIView {
    static let CAROUSEL_ITEM_NIB = "CarouselItem"
    
    @IBOutlet var vwContent: UIView!
    @IBOutlet var vwBackground: UIView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var bgImageView: UIImageView!
    @IBOutlet var descLbl: UILabel!
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithNib()
    }
    
    convenience init(titleText: String? = "", background: UIColor? = .red, imageName: String? = "", descText: String? = "") {
        self.init()
        lblTitle.text = titleText
        descLbl.text = descText

        vwBackground.backgroundColor = background
        bgImageView.image = UIImage.init(named: imageName!)
        bgImageView.contentMode = .scaleAspectFit
    }
    
    fileprivate func initWithNib() {
        Bundle.main.loadNibNamed(CarouselItem.CAROUSEL_ITEM_NIB, owner: self, options: nil)
        vwContent.frame = bounds
        vwContent.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(vwContent)
    }
}
