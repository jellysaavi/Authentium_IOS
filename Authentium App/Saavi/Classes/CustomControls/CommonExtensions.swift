//
//  CommonExtensions.swift
//  FameFlight
//
//  Created by Sukhpreet Singh on 17/05/17.
//  Copyright © 2017 Sukhpreet Singh. All rights reserved.
//


import UIKit

class CommonExtensions: NSObject {
}

extension String
{
    func isEmptyString() -> Bool
    {
        if self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
        {
            return true
        }
        return false
    }
    
    func isValidEmailAddressFormat() -> Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func heightOfText(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return boundingBox.height + 1.0
    }
    
    func isValidPassword() -> Bool
    {
        var newCharSet = CharacterSet.alphanumerics
        newCharSet.formUnion(CharacterSet.decimalDigits)
        newCharSet.formUnion(CharacterSet.uppercaseLetters)
        
        if self.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil && (self.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil) && self.rangeOfCharacter(from: newCharSet.inverted) != nil
        {
            return true
        }
        else
        {
            return false
        }
        
        /*
         let stricterFilterString = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&#])[A-Za-z\\d$@$!%*?&#]{8,16}"
         let passwordTest = NSPredicate(format: "SELF MATCHES %@", stricterFilterString)
         return passwordTest.evaluate(with:self)*/
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
}



extension UITextField
{
    func Underline()
    {
        let border = CALayer()
        
        let borderWidth = CGFloat(1.0)
        
        border.backgroundColor = UIColor.init(red: 229.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1.0).cgColor
        
        border.frame = CGRect(x: 0.0, y: self.frame.size.height - borderWidth, width: self.frame.size.width, height: borderWidth)
        
        self.borderStyle = UITextBorderStyle.none
        
        self.font = UIFont.SFUI_Regular(baseScaleSize: 17.0)
        
        self.textColor = AppConfig.darkGreyColor()
        
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: AppConfig.attributedPlaceholderString(withFont: UIFont.Roboto_Italic(baseScaleSize: 16.0), withColor: UIColor.lightGray))
        
        self.layer.addSublayer(border)
        
        self.layer.masksToBounds = true
    }
    
    func applyBorder()
    {
        self.font = UIFont.SFUI_Regular(baseScaleSize: 17.0)
        self.textColor = AppConfig.darkGreyColor()
        if self.placeholder != nil
        {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: AppConfig.attributedPlaceholderString(withFont: UIFont.Roboto_Italic(baseScaleSize: 16.0), withColor: UIColor.lightGray))
        }
        
        
        self.layer.borderColor = UIColor.init(red: 229.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1.0).cgColor
        
        self.layer.borderWidth = 1.0
        
        self.font = UIFont.SFUI_Regular(baseScaleSize: 17.0)
        
        self.layer.cornerRadius = 5.0 * Configration.scalingFactor()
        
        let image = UIImageView()
        image.frame = CGRect(x: 0, y: 0, width: 10.0, height: 0)
        self.leftViewMode = UITextFieldViewMode.always
        self.leftView = image
    }
    
    func resizeFont() {
        guard let font = self.font, let text = self.text else {
            return
        }
        
        let textBounds = self.textRect(forBounds: self.bounds)
        let maxWidth = textBounds.size.width
        
        for fontSize in stride(from: 17.0, through: 10.0, by: -0.5) {
            let size = (text as NSString).size(withAttributes: [NSAttributedStringKey.font: font.withSize(CGFloat(fontSize))])
            self.font = font.withSize(CGFloat(fontSize))
            if size.width <= maxWidth {
                break
            }
        }
    }
}

extension Date
{
    init(dateFromEPOCHTime : String)
    {
        let modifiedUNIXDateStr = dateFromEPOCHTime.replacingOccurrences(of: "Date", with: "").trimmingCharacters(in: CharacterSet(charactersIn: "/()")).replacingOccurrences(of: " ", with: "")
        self.init(timeIntervalSince1970: (Double(modifiedUNIXDateStr)!)/1000)
    }
    public func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
    }
}

extension Dictionary
{
    func keyExists(key : String) -> Bool
    {
        return (self as? Dictionary<String,Any>) != nil && ((self as! Dictionary<String,Any>)[key] != nil)
    }
}


extension UIFont
{
    
    /*class private func setFontSize(baseScaleSize:CGFloat)-> CGFloat{
        
        if UIDevice().userInterfaceIdiom == .phone {
            
            switch UIScreen.main.nativeBounds.height {
                
            case 1136:
                return baseScaleSize * Configration.scalingFactor()
                //print("iPhone 5 or 5S or 5C")
            case 1334:
                return  baseScaleSize * Configration.scalingFactor()
                //print("iPhone 6/6S/7/8")
            case 1920, 2208:
                return  baseScaleSize * Configration.scalingFactor()
                //print("iPhone 6+/6S+/7+/8+")
            case 2436:
                return baseScaleSize
                //print("iPhone X, Xs")
            case 2688:
                return baseScaleSize
                //print("iPhone Xs Max")
            case 1792:
                return baseScaleSize
                //print("iPhone Xr")
            default:
                return baseScaleSize * Configration.scalingFactor()
                //print("unknown")
            }
        }
        return baseScaleSize * Configration.scalingFactor()
    }*/
    
    
    class func SFUI_Light(baseScaleSize : CGFloat) -> UIFont
    {
        
        return UIFont(name: "SFUIDisplay-Light", size: baseScaleSize  * (UIDevice.current.userInterfaceIdiom == .phone ? 1:Configration.scalingFactor()))!
    }
    
    class func SFUI_Regular(baseScaleSize : CGFloat) -> UIFont
    {
        return UIFont(name: "SFUIDisplay-Regular", size: baseScaleSize  * (UIDevice.current.userInterfaceIdiom == .phone ? 1:Configration.scalingFactor()))!
    }
    
    class func SFUI_SemiBold(baseScaleSize : CGFloat) -> UIFont
    {
        return UIFont(name: "SFUIDisplay-Semibold", size: baseScaleSize  * (UIDevice.current.userInterfaceIdiom == .phone ? 1:Configration.scalingFactor()))!
    }
    
    class func SFUI_Bold(baseScaleSize : CGFloat) -> UIFont
    {
        return UIFont(name: "SFUIDisplay-Bold", size: baseScaleSize  * (UIDevice.current.userInterfaceIdiom == .phone ? 1:Configration.scalingFactor()))!
    }
    
    class func Roboto_Light(baseScaleSize : CGFloat) -> UIFont
    {
        return UIFont(name: "Roboto-Light", size: baseScaleSize * (UIDevice.current.userInterfaceIdiom == .phone ? 1:Configration.scalingFactor()))!
    }
    
    class func Roboto_Regular(baseScaleSize : CGFloat) -> UIFont
    {
        return UIFont(name: "Roboto-Regular", size: baseScaleSize * (UIDevice.current.userInterfaceIdiom == .phone ? 1:Configration.scalingFactor()))!
    }
    
    class func Roboto_Medium(baseScaleSize : CGFloat) -> UIFont
    {
        return UIFont(name: "Roboto-Medium", size: baseScaleSize * (UIDevice.current.userInterfaceIdiom == .phone ? 1:Configration.scalingFactor()))!
    }
    
    class func Roboto_Bold(baseScaleSize : CGFloat) -> UIFont
    {
        return UIFont(name: "Roboto-Bold", size: baseScaleSize * (UIDevice.current.userInterfaceIdiom == .phone ? 1:Configration.scalingFactor()))!
    }
    
    class func Roboto_Italic(baseScaleSize : CGFloat) -> UIFont
    {
        return UIFont(name: "Roboto-Italic", size: baseScaleSize * (UIDevice.current.userInterfaceIdiom == .phone ? 1:Configration.scalingFactor()))!
    }
    
    
    class func SFUIText_Regular(baseScaleSize : CGFloat) -> UIFont
    {
        return UIFont(name: "SFUIText-Regular", size: baseScaleSize * (UIDevice.current.userInterfaceIdiom == .phone ? 1:Configration.scalingFactor()))!
    }
    
    
    class func SFUIText_Semibold(baseScaleSize : CGFloat) -> UIFont
    {
        return UIFont(name: "SFUIText-Semibold", size: baseScaleSize * (UIDevice.current.userInterfaceIdiom == .phone ? 1:Configration.scalingFactor()))!
    }
}

enum SaaviLeftBarButtonType
{
    case profileButton
    case backButton
}

extension UIColor
{
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    class func activeTextFieldColor() -> UIColor
    {
        return UIColor(red: 63.0/255.0, green: 63.0/255.0, blue: 63.0/255.0, alpha: 1.0)
    }
    
    class func errorTextFieldColor() -> UIColor
    {
        return UIColor(red: 239.0/255.0, green: 90.0/255.0, blue: 90.0/255.0, alpha: 1.0)
        
    }
    
    //TODO: - - Change Color
    class func baseBlueColor() -> UIColor{
//        return UIColor.init(hex: "#0066b3")
        return UIColor(red: 46.0/255.0, green: 145.0/255.0, blue: 234.0/255.0, alpha: 1.0)

    }
    
    //TODO:
    class func primaryColor() -> UIColor{
//        return UIColor.init(hex: "#0066b3")
        return UIColor(red: 46.0/255.0, green: 145.0/255.0, blue: 234.0/255.0, alpha: 1.0)
    }
    
    class func primaryColor2() -> UIColor{
//        return UIColor.init(hex: "#0066b3")
        return UIColor(red: 46.0/255.0, green: 145.0/255.0, blue: 234.0/255.0, alpha: 1.0)

    }
    
    class func primaryColor3() -> UIColor{
        return UIColor.init(hex: "#bd271c")
    }
    
    class func yellowStarColor() -> UIColor{
        return UIColor.init(hex: "#ffe552")
    }
    
    class func buttonBackgroundColor() -> UIColor
    {
//        return UIColor.init(hex: "#0066b3")
        return UIColor(red: 46.0/255.0, green: 145.0/255.0, blue: 234.0/255.0, alpha: 1.0)

    }
    
    class func addToCartGreenColor() -> UIColor
    {
        return UIColor.init(hex: "#1bcfc9") //UIColor(red: 176.0/255.0, green: 201.0/255.0, blue: 63.0/255.0, alpha: 1.0)
    }
    
    static func darkGreyColor() -> UIColor
    {
        return UIColor(red: 92.0/255.0, green: 92.0/255.0, blue: 92.0/255.0, alpha: 1.0)
    }
    
    //SalesRep
    
    static func bgViewColor() -> UIColor
    {
        return UIColor(red: 244.0/255.0, green: 248.0/255.0, blue: 249.0/255.0, alpha: 1.0)
    }
    static func evenRowColor() -> UIColor
    {
        return UIColor(red: 244.0/255.0, green: 252.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    }
    static func oddRowColor() -> UIColor
    {
        return UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    }
    static func lightGreyColor() -> UIColor
    {
        return UIColor(red: 246.0/255.0, green: 246.0/255.0, blue: 246.0/255.0, alpha: 1.0)
    }
    static func priceInfoLightGreyColor() -> UIColor
    {
        return UIColor(red: 95.0/255.0, green: 95.0/255.0, blue: 95.0/255.0, alpha: 1.0)
    }
    
    static func promotionalProductYellowColor() -> UIColor
    {
        return UIColor(red: 247.0/255.0, green: 207.0/255.0, blue: 95.0/255.0, alpha: 1.0)
    }
}

struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}


extension Double {
    
    func withCommas() -> String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.alwaysShowsDecimalSeparator = true
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: NSNumber(value:self))!
        
    }
    
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    var cleanValue: String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        if AppFeatures.shared.IsAllowDecimal{
            return numberFormatter.string(from: NSNumber(value:self))!
        }
        let format  = "%.0f"
        return String(format: format, self)
    }
}

extension UITextView {
    
//    func centerVertically() {
//
//        self.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 30);
//        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
//        let size = sizeThatFits(fittingSize)
//        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
//        let positiveTopOffset = max(1, topOffset)
//        contentOffset.y = -positiveTopOffset
//    }
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}

extension CATransition {
    func fadeTransition() -> CATransition {
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        return transition
    }
}


