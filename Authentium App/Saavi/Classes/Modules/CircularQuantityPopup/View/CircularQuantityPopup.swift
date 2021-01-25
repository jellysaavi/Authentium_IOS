//
//  CircularQuantityPopup.swift
//  Saavi
//
//  Created by Sukhpreet on 23/10/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit
typealias dateSelectionCompleted = () -> Void

class CircularQuantityPopup: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var baseReferenceFrameImageView: UIImageView!
    @IBOutlet weak var quantityPopup: UIView!
    @IBOutlet weak var staticLblAddQuantity: UILabel!
    @IBOutlet weak var btnDecreaseQuantity: UIButton!
    @IBOutlet weak var btnIncreaseQuantity: UIButton!
    @IBOutlet weak var txtFldQuantity: UITextField!
    @IBOutlet weak var btnAddToCart: CustomButton!
    var isEach:Bool = false
    var quantityPerUnit:Int = 0
    var completionBlock : dateSelectionCompleted? = nil
    let circularSlider = EFCircularSlider()
    var currentQuantity : String?
    var isEditedFromKeyboard : Bool = false
    
    //MARK:- View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapReco : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hidePopupAction(reco:)))
        tapReco.numberOfTapsRequired  = 1
        tapReco.cancelsTouchesInView = false
        tapReco.delegate = self
        self.view.addGestureRecognizer(tapReco)
        
        self.txtFldQuantity.delegate = self
        self.btnIncreaseQuantity.setTitleColor(UIColor.baseBlueColor(), for: .normal)
        self.btnDecreaseQuantity.setTitleColor(UIColor.baseBlueColor(), for: .normal)
        self.txtFldQuantity.keyboardType = UserInfo.shared.isSalesRepUser! ? .decimalPad:AppFeatures.shared.IsAllowDecimal ? .decimalPad:.numberPad
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        self.makeUIChanges()
        if AppFeatures.shared.isOrderMultiples && self.isEach{
            
            let quantity = Helper.shared.calculateQuantityMultiplier(units: Double(self.circularSlider.currentValue), quantityPerUnit: self.quantityPerUnit)
            self.circularSlider.currentValue = Float(quantity)
            
            self.txtFldQuantity.text  = AppFeatures.shared.IsAllowDecimal ? String(format: "%.2f",quantity):UserInfo.shared.isSalesRepUser! ? String(format: "%.2f",quantity):String(format: "%.0f",quantity)
        }else{
            
            if currentQuantity != nil, currentQuantity != "", Double(currentQuantity!)! > 0{
                
                if let value = currentQuantity{
                    if (value as NSString).doubleValue > 100.00{
                        let quantity1 = Helper.shared.calculateQuantityMultiplier(units: 100.00, quantityPerUnit: self.quantityPerUnit)
                        let value1 = (AppFeatures.shared.isOrderMultiples && self.isEach) ? quantity1:100.00
                        self.circularSlider.currentValue = Float(value1)
                    }else {
                        self.circularSlider.currentValue = Float(value)!
                    }
                }
                self.txtFldQuantity.text  = AppFeatures.shared.IsAllowDecimal ? String(format: "%.2f",Double(currentQuantity!)!):UserInfo.shared.isSalesRepUser! ? String(format: "%.2f",Double(currentQuantity!)!):String(format: "%.0f",Double(currentQuantity!)!)
            }else{
                self.sliderValueChanged(slider: self.circularSlider)
            }
        }
        self.view.layoutIfNeeded()
    }
    
    func makeUIChanges(){
        circularSlider.minimumValue = AppFeatures.shared.IsAllowDecimal ? 1.00:UserInfo.shared.isSalesRepUser! ? 1.00:1
        circularSlider.maximumValue = AppFeatures.shared.IsAllowDecimal ? 101.00:UserInfo.shared.isSalesRepUser! ? 101.60:101
        circularSlider.currentValue = 1.0
        circularSlider.handleType = EFHandleType.bigCircle
        circularSlider.handleColor = UIColor.baseBlueColor()
        circularSlider.unfilledColor = UIColor.lightGray.withAlphaComponent(0.1)
        circularSlider.filledColor = UIColor.baseBlueColor().withAlphaComponent(0.5)
        circularSlider.addTarget(self, action: #selector(self.sliderValueChanged), for: .touchUpInside)
        self.circularSlider.frame = self.baseReferenceFrameImageView.frame
        self.circularSlider.center = self.baseReferenceFrameImageView.center
        self.quantityPopup.addSubview(circularSlider)
        self.quantityPopup.bringSubview(toFront: self.txtFldQuantity)
        self.btnIncreaseQuantity.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 40.0)
        self.btnDecreaseQuantity.titleLabel?.font = UIFont.SFUI_Regular(baseScaleSize: 40.0)
        self.txtFldQuantity.font  = UIFont.SFUI_Regular(baseScaleSize: 25.0)
        self.staticLblAddQuantity.font = UIFont.SFUI_SemiBold(baseScaleSize: 20.0)
        self.quantityPopup.layer.cornerRadius = 7.0 * Configration.scalingFactor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //    MARK:- Slider changed
    
    @objc func sliderValueChanged(slider : EFCircularSlider){
        
        var sliderValue : Float
        
        let quantity = Helper.shared.calculateQuantityMultiplier(units: Double(slider.currentValue), quantityPerUnit: self.quantityPerUnit)
        
        let value = (AppFeatures.shared.isOrderMultiples && self.isEach) ? Float(quantity):slider.currentValue
        
        if(!isEditedFromKeyboard){
            sliderValue = value.rounded()
        }else{
            sliderValue = value
        }
        
        if (Float(sliderValue.rounded()) < circularSlider.minimumValue){
            self.txtFldQuantity.text = AppFeatures.shared.IsAllowDecimal ? String(format: "%.2f",slider.minimumValue):String(format: "%.0f",slider.minimumValue)
        }else{
            if Double(sliderValue.rounded()) > 101.60{
                
                let quantity1 = Helper.shared.calculateQuantityMultiplier(units: 100.00, quantityPerUnit: self.quantityPerUnit)
                let value1 = (AppFeatures.shared.isOrderMultiples && self.isEach) ? quantity1:100.00
                self.txtFldQuantity.text = value1.cleanValue
                
            }else{
                self.txtFldQuantity.text =  AppFeatures.shared.IsAllowDecimal ? String(format: "%.2f",sliderValue):String(format: "%.0f",sliderValue)
            }
        }
        
        if AppFeatures.shared.isOrderMultiples && self.isEach{
            DispatchQueue.main.async {
                self.circularSlider.currentValue = sliderValue
            }
        }
        isEditedFromKeyboard = false
    }
    
    
    @IBAction func decreaseQuantityAction(_ sender: Any) {
        
        let valueToBeDecreased:Double = (AppFeatures.shared.isOrderMultiples && self.isEach) ? Double(self.quantityPerUnit):1.0
        if let qty = Double(self.txtFldQuantity.text!), qty > valueToBeDecreased
        {
            let newQty = qty - valueToBeDecreased
            self.txtFldQuantity.text = newQty.cleanValue
            self.changeSliderIfApplicable()
            
        }
    }
    
    @IBAction func increaseQuantityAction(_ sender: Any)
    {
        let valueToBeAdded:Double = (AppFeatures.shared.isOrderMultiples && self.isEach) ? Double(self.quantityPerUnit):1.0
        if let qty = Double(self.txtFldQuantity.text!), qty < 99999
        {
            let newQty = qty + valueToBeAdded
            self.txtFldQuantity.text = newQty.cleanValue
            self.changeSliderIfApplicable()
        }
    }
    
    func changeSliderIfApplicable()
    {
        if let qty = Double(self.txtFldQuantity.text!), qty > 1, qty < 101
        {
            self.circularSlider.currentValue = Float(qty)
        }
    }
    
    @objc func hidePopupAction(reco : UITapGestureRecognizer)
    {
        if self.txtFldQuantity.isFirstResponder
        {
            self.view.endEditing(true)
        }
        else if  reco.view == self.view
        {
            self.dismiss(animated: false, completion: nil)
            self.view.endEditing(true)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == self.view
        {
            return true
        }
        return false
    }
    
    func showCommonAlertOnWindow(completion:@escaping dateSelectionCompleted)
    {
        completionBlock = completion
        UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: false, completion: {
        })
    }
    
    @IBAction func submitAction(_ sender: Any){
        if self.txtFldQuantity.isFirstResponder{
            self.view.endEditing(true)
        }
        
        guard let value = Double(self.txtFldQuantity.text!) else { return }
        
        self.dismiss(animated: false) {
            self.completionBlock!()
            
        }
    }
    
    //    MARK:- Text field delagtes
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if (textField.text?.isEmpty)!{
            // PK
            textField.text = AppFeatures.shared.IsAllowDecimal ? String(format: "%.2f",Double(currentQuantity!)!):UserInfo.shared.isSalesRepUser! ? String(format: "%.2f",Double(currentQuantity!)!):String(format: "%.0f",Double(currentQuantity!)!)
            
            self.circularSlider.currentValue = Float(textField.text ?? "0") ?? 0.0
            self.sliderValueChanged(slider : self.circularSlider)
            isEditedFromKeyboard = true
        }else{
            var val = textField.text
            
            let dotString = "."
            if val!.contains(dotString) {
                //Decimal
            }else{
                if AppFeatures.shared.IsAllowDecimal{
                    val = "\(textField.text ?? "0")\(".00")"
                    textField.text = val
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !AppFeatures.shared.IsAllowDecimal{
            
            if  string == "."{
                return false
            }
        }
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        guard let oldText = textField.text, let r = Range(range, in: oldText) else {
            return true
        }
        
        let newText = oldText.replacingCharacters(in: r, with: string)
        let isNumeric = newText.isEmpty || (Double(newText) != nil)
        let numberOfDots = newText.components(separatedBy: ".").count - 1
        
        let numberOfDecimalDigits: Int
        if let dotIndex = newText.index(of: ".") {
            numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
        } else {
            numberOfDecimalDigits = 0
        }
        let numberOfValidDigits : Int
        if newText.index(of: ".") != nil {
            // numberOfDigits = newText.distance(from: newText.startIndex, to: dotIndex)
            numberOfValidDigits = 8
        } else {
            numberOfValidDigits = 5
        }
        
        
        //return newString.count < 9 || isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2
        if newString.count > numberOfValidDigits
        {
            return false
        }
        else
        {
            return isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2
        }
        /*if newString.count > 8 || (string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted)) != nil
         {
         return false
         }
         else
         {
         return true
         }*/
    }
}

