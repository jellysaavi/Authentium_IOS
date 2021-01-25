//
//  SearchProductVC.swift
//  Saavi
//
//  Created by Irmeen Sheikh on 14/03/18.
//  Copyright © 2018 Saavi. All rights reserved.
//

import UIKit
import Lightbox

class SearchProductVC: UIViewController,UITableViewDelegate,UITableViewDataSource ,UISearchBarDelegate,UIGestureRecognizerDelegate{
    
    @IBOutlet weak var tbl_productSearch: UITableView!
    @IBOutlet weak var view_Header: customview!
    @IBOutlet weak var lbl_DescHeader: UILabel!
    @IBOutlet weak var lbl_CostPHeader: UILabel!
    @IBOutlet weak var lbl_custPHeader: UILabel!
    @IBOutlet weak var lbl_UOMHeader: UILabel!
    @IBOutlet var btnGenerateQuote: CustomButton!
    
    @IBAction func btnGenerateQuoteAction(_ sender: Any) {
        
        
        
               if let generateQuotePopupVC = UIStoryboard.init(name: "SalesRep", bundle: nil).instantiateViewController(withIdentifier: "GenerateQuotePopupVC") as? GenerateQuotePopupVC
                {
                    
                    var product = Array<Dictionary<String,Any>>()
                    
                    for (prod) in productList
                    {
                        if prod["IsSelected"] as? Bool == true {
                            var item = Dictionary<String,Any>()
                            item["ProductID"] = prod["ProductID"]
                            item["ProductCode"] = prod["ProductCode"]
                            item["CurrentPrice"] = prod["CurrentPrice"]
                            item["SuggestedPrice"] = prod["SuggestedPrice"]
                            product.append(item)
                        }
                    }
                    generateQuotePopupVC.products = product
                    generateQuotePopupVC.modalPresentationStyle = .fullScreen
                    if product.count > 0 {
                        self.present(generateQuotePopupVC, animated: false, completion: nil)
                    }
                    else {
                        Helper.shared.showAlertOnController( message: "Please select products to generate quote.", title: CommonString.alertTitle)
                    }
                    
        
                   
               }
        

    }
    @IBOutlet weak var lbl_ProductName: customLabel!
    var productList = Array<Dictionary<String,Any>>()
    var allPantryItems = Array<Dictionary<String,Any>>()
    var pageNumber : Int = 1
    var totalResults : NSNumber? = 0
    var allResults : NSNumber?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        lbl_ProductName.font = UIFont.Roboto_Medium(baseScaleSize: 20.0)
        self.view.backgroundColor = UIColor.bgViewColor()
        self.tbl_productSearch.backgroundColor = UIColor.bgViewColor()
        self.callSearchProductWebService(with: "")
        self.setDefaultNavigation()
        self.view_Header.backgroundColor = UIColor.baseBlueColor()
        self.btnGenerateQuote.backgroundColor = UIColor.baseBlueColor()
        // Do any additional setup after loading the view.
        
    }
    @objc func showLargeImage(urlStr:String){
      
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
        return productList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchProductCell") as? SearchProductCell
        cell?.lbl_Each.font = UIFont.Roboto_Regular(baseScaleSize: 13.0)
        cell?.contentView.backgroundColor = UIColor.bgViewColor()
        if indexPath.row % 2 == 0{
            cell?.view_bg.backgroundColor = UIColor.oddRowColor()
        }
        else{
            cell?.view_bg.backgroundColor = UIColor.evenRowColor()
        }
        var productDescDic = productList[indexPath.item]
        if productDescDic.keyExists(key: "ProductName"), let ProductName = productDescDic["ProductName"] as? String{
            cell?.lbl_Description.text = ProductName
        }
        if productDescDic.keyExists(key: "CompanyPrice"), let companyPrice = productDescDic["CompanyPrice"] as? Double{
            let companyPriceStr = String(format: "\(CommonString.currencyType)%.2f", companyPrice)
            cell?.lbl_costPrice.text = companyPrice <= 0 ? CommonString.marketprice:companyPriceStr
        }
        cell?.btn_UOM.tag = indexPath.row
        cell?.btn_UOM.addTarget(self, action: #selector(self.uOMChanged(sender:)), for: .touchUpInside)
        if let obj = productDescDic["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1
        {
            cell?.arrowUOMDropdown.constant = 10.0
        }
        else
        {
            cell?.arrowUOMDropdown.constant = 0.0
        }
        
        cell?.btnAddToQuote.addTarget(self, action: #selector(self.addToQuote(sender:)), for: .touchUpInside)
        
        var arrPrices : Array<Dictionary<String,Any>>?
        if let prices = productDescDic["DynamicUOM"] as? Array<Dictionary<String,Any>>
        {
            arrPrices = prices
        }
        else if let prices = productDescDic["Prices"] as? Array<Dictionary<String,Any>>
        {
            arrPrices = prices
        }
        else if var prices = productDescDic["Prices"] as? Dictionary<String,Any>
        {
            prices["UOMDesc"] = productDescDic["UOMDesc"] as? String
            prices["UOMID"] = productDescDic["UOMID"] as? NSNumber
            arrPrices = [prices]
        }
        if (arrPrices != nil), arrPrices!.count > 0
        {
            var selectedIndex = 0
            if let index = productDescDic["selectedIndex"] as? Int
            {
                selectedIndex = index
            }
            let objToFetch = arrPrices![selectedIndex]
            if let price = objToFetch["Price"] as? Double{
                
                let price_final = Double(round(100*price)/100)
                
                let priceStr = String(format: "\(CommonString.currencyType)%.2f", price_final)
                cell?.lbl_custPrice.text = price <= 0 ? CommonString.marketprice:priceStr
                cell?.lbl_Each.text = objToFetch["UOMDesc"] as? String
                productList[indexPath.item]["CurrentPrice"] = price
                productList[indexPath.item]["SuggestedPrice"] = price
            }
        }
        
        cell?.lbl_custPrice.addTarget(self, action: #selector(ViewController.textFieldDidEndEditing(_:)), for: .editingChanged)
        
        cell?.imgInfo.tag = indexPath.row
        let tapRecog2 = UITapGestureRecognizer(target: self, action: #selector(self.objTapped(_:)))
        tapRecog2.delegate = self
        cell?.imgInfo.addGestureRecognizer(tapRecog2)
        
        if let images = productDescDic["ProductImages"] as? Array<Dictionary<String,Any>>, images.count > 0
        {
            let originalString:String = (images[0]["ImageName"]! as! String)
            let urlString:String = originalString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
            cell?.productImage.setImageWith(URL(string: urlString), placeholderImage: #imageLiteral(resourceName: "ImagePlaceholder"))
            cell?.productImage.contentMode = .scaleAspectFill
            cell?.productImage.tag = indexPath.row
            
            let tapRecog1 = UITapGestureRecognizer(target: self, action: #selector(self.objTappedForDetails(_:)))
            tapRecog1.delegate = self
            cell?.productImage.addGestureRecognizer(tapRecog1)
            
//            let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:tapGestureRecognizer, urlStr: urlString)))
//
//            //let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.showLargeImage(urlStr: urlString)))
//            cell?.productImage.isUserInteractionEnabled = true
//            cell?.productImage.addGestureRecognizer(tapGestureRecognizer1)
            
        }else{
            cell?.productImage.image = #imageLiteral(resourceName: "ImagePlaceholder")
        }
        
        if self.productList[indexPath.item]["IsSelected"] != nil && self.productList[indexPath.item]["IsSelected"] as? Bool == true  {
            cell?.btnAddToQuote.isSelected = true;
        }
        else {
            cell?.btnAddToQuote.isSelected = false;
        }
       
       
    
    
        
        return cell!
    }
    
    @objc func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let cell = (textField).superview?.superview?.superview as? SearchProductCell
        {
            if let indexPath = self.tbl_productSearch.indexPath(for: cell)
            {
                self.productList[indexPath.row]["SuggestedPrice"] = textField.text?.replacingOccurrences(of: "$", with: "")
                
            }
        }
        
    }
    
    @objc func objTappedForDetails (_ sender : Any?) -> Void
    {
        if sender is UITapGestureRecognizer, let cell = (sender as! UITapGestureRecognizer).view?.superview?.superview?.superview as? SearchProductCell
        {
            if let indexPath = self.tbl_productSearch.indexPath(for: cell)
            {
                let images = self.productList[indexPath.row]["ProductImages"] as? Array<Dictionary<String,Any>>
                let originalString:String = (images![0]["ImageName"]! as! String)
                    let urlString:String = originalString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
                
                let images1 = [LightboxImage.init(imageURL: URL.init(string:urlString)!)]
                let controller = LightboxController(images: images1)
                controller.pageDelegate = self
                controller.dismissalDelegate = self
                controller.dynamicBackground = true
                self.present(controller, animated: true, completion: nil)
                
            }
        }
    }
    
    
    @objc func objTapped (_ sender : Any?) -> Void
    {
        if sender is UITapGestureRecognizer, let cell = (sender as! UITapGestureRecognizer).view?.superview?.superview?.superview as? SearchProductCell
        {
            if let indexPath = self.tbl_productSearch.indexPath(for: cell)
            {
                Helper.shared.showAlertOnController( message: "Item Cost Price \n" + String(format: "\(CommonString.currencyType)%.2f",(productList[indexPath.item]["CompanyPrice"] as? Double)!), title: productList[indexPath.item]["ProductName"] as! String)
                
            }
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer, urlStr: String)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        let images = [LightboxImage.init(imageURL: URL.init(string:urlStr)!)]
        let controller = LightboxController(images: images)
        controller.pageDelegate = self
        controller.dismissalDelegate = self
        controller.dynamicBackground = true
        self.present(controller, animated: true, completion: nil)
        // Your action
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    
    //MARK:- WEB SERVICE
    
    func callSearchProductWebService(with searchText : String = "")
    {
        if self.navigationItem.titleView is UISearchBar, (self.navigationItem.titleView as? UISearchBar)?.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            self.searchBarCancelButtonClicked((self.navigationItem.titleView as! UISearchBar))
        }
        else
        {
            let requestParameters = NSMutableDictionary()
            requestParameters.setValue(UserInfo.shared.customerID!, forKey: "CustomerID")
            requestParameters.setValue(UserInfo.shared.customerID!, forKey: "listCustomerId")
            requestParameters.setValue(0, forKey: "MainCategoryID")
            requestParameters.setValue(0, forKey: "SubCategoryID")
            requestParameters.setValue(0, forKey: "FilterID")
            requestParameters.setValue(searchText, forKey: "Searchtext")
            requestParameters.setValue(false, forKey: "IsSpecial")
            requestParameters.setValue(10, forKey: "PageSize")
            requestParameters.setValue(pageNumber-1, forKey: "PageIndex")
            
            let serviceURL = SyncEngine.baseURL + SyncEngine.SearchProductsList
            
            
            if pageNumber == 1
            {
                self.productList.removeAll()
                self.tbl_productSearch.reloadData()
            }
            
            SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: requestParameters as! Dictionary<String, Any>, strURL: serviceURL) { (response : Any) in
                if (response as? Dictionary<String,AnyObject>) != nil
                {
                    if (response is Dictionary<String,Any>) && (response as! Dictionary<String,Any>).keyExists(key: "products"), let productListArray = (response as! Dictionary<String,Any>)["products"] as? Array<Dictionary<String,Any>>
                    {
                        self.productList += productListArray
                        if searchText == ""{
                            self.allPantryItems += productListArray
                        }
                        if self.productList.count == 0
                        {
                            self.showNoItemsLabel()
                        }
                        else
                        {
                            self.hideNoItemsLabel()
                        }
                        
                        if (response as! Dictionary<String,Any>).keyExists(key: "TotalResults"), let totalResults = (response as! Dictionary<String,Any>)["TotalResults"] as? NSNumber
                        {
                            self.totalResults = totalResults
                            if searchText == ""{
                                self.allResults = totalResults
                            }
                            DispatchQueue.main.async {
                                self.tbl_productSearch.reloadData()
                                
                            }
                        }
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        self.tbl_productSearch.reloadData()
                        self.showNoItemsLabel()
                    }
                }
            }
        }
    }
    
    func showNoItemsLabel()
    {
        DispatchQueue.main.async
            {
                if self.view.viewWithTag(57) == nil
                {
                    let label = Helper.shared.createLabelWithMessage(message: "No items found.")
                    label.tag = 57
                    label.center = self.tbl_productSearch.center
                    self.view.addSubview(label)
                }
        }
    }
    
    func hideNoItemsLabel(){
        
        DispatchQueue.main.async {
            if let noRecordsLabel = self.view.viewWithTag(57) as? UILabel
            {
                noRecordsLabel.removeFromSuperview()
            }
            
        }
    }
    
    //    MARK:- Scroll View -
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate
        {
            self.handlePaginationIfRequired(scrollView:  scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        self.handlePaginationIfRequired(scrollView:  scrollView)
    }
    
    func handlePaginationIfRequired(scrollView: UIScrollView){
        
        if scrollView.contentSize.height < (scrollView.contentOffset.y + scrollView.frame.size.height + 5.0), totalResults != nil, Int(truncating: self.totalResults!) > self.productList.count
        {
            pageNumber += 1
            var searchText = ""
            if self.navigationItem.titleView is UISearchBar
            {
                searchText = (self.navigationItem.titleView as! UISearchBar).text!
            }
            
            if searchText != ""{
                self.callSearchProductWebService(with: searchText)
            }
            else{
                self.callSearchProductWebService(with: "")
            }
            
        }
    }
    
    //MARK:- Navigation
    
    func setDefaultNavigation() -> Void{
        
        self.navigationItem.rightBarButtonItems = nil
        Helper.shared.createSearchIcon(onController: self)
        Helper.shared.setNavigationTitle(withTitle: CommonString.searchProductTitle, withLeftButton: .backButton, onController: self)
    }
    
    @objc func backBtnAction(){
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func showSearchBar() -> Void{
        
        self.navigationItem.rightBarButtonItems = nil
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        let cancelSearchBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(searchBarCancelButtonClicked(_:)))
        cancelSearchBarButtonItem.tintColor = UIColor.baseBlueColor()
        self.navigationItem.setRightBarButton(cancelSearchBarButtonItem, animated: true)
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        self.navigationItem.titleView = searchBar
    }
    
    //    MARK: - Search Bar Delegate -
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        self.navigationItem.titleView = nil
        self.setDefaultNavigation()
        hideNoItemsLabel()
        self.view.endEditing(true)
        self.productList = self.allPantryItems
        self.totalResults = self.allResults
        self.tbl_productSearch.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == ""
        {
            hideNoItemsLabel()
            self.productList.removeAll()
            self.tbl_productSearch.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if searchBar.text == "", text == " "
        {
            return false
        }
        else{
            return true
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
        pageNumber = 1
        self.view.endEditing(true)
        self.callSearchProductWebService(with: searchBar.text!)
        
    }
    
    @objc func addToQuote(sender : UIButton){
        if sender is UIButton, let cell = (sender).superview?.superview?.superview as? SearchProductCell
        {
            if let indexPath = self.tbl_productSearch.indexPath(for: cell)
            {
                if self.productList[indexPath.item]["IsSelected"] == nil {
                    self.productList[indexPath.item]["IsSelected"] = true
                     sender.isSelected = true;
                }
                else if self.productList[indexPath.item]["IsSelected"] as? Bool == false {
                    self.productList[indexPath.item]["IsSelected"] = true
                    sender.isSelected = true;
                }
                else{
                    productList[indexPath.item]["IsSelected"] = false
                    sender.isSelected = false;
                }
            }
        }
       
    }
    
    //MARK:- UOM change method
    @objc func uOMChanged(sender : UIButton)
    {
        if let obj = self.productList[sender.tag]["DynamicUOM"] as? Array<Dictionary<String,Any>>, obj.count > 1
        {
            var index : Int = 0
            if let selectedIndex = self.productList[sender.tag]["selectedIndex"] as? Int
            {
                index = selectedIndex
            }
            
            if index + 1 < obj.count
            {
                var objToChange = self.productList[sender.tag]
                objToChange["selectedIndex"] = index + 1
                self.productList[sender.tag] = objToChange
                self.tbl_productSearch.reloadData()
            }
            else
            {
                var objToChange = productList[sender.tag]
                objToChange["selectedIndex"] = 0
                self.productList[sender.tag] = objToChange
                self.tbl_productSearch.reloadData()
            }
            
        }
    }
}


class SearchProductCell: UITableViewCell {
    
    
    @IBOutlet var productImage: UIImageView!
    @IBOutlet weak var view_bg: UIView!
    @IBOutlet weak var lbl_Description: UILabel!
    @IBOutlet weak var lbl_Each: customLabelGrey!
    @IBOutlet weak var btn_UOM: UIButton!
    @IBOutlet weak var lbl_costPrice: UILabel!
    
    @IBOutlet var lbl_custPrice: UITextField!
    @IBOutlet var imgInfo: UIImageView!
    
    @IBOutlet var btnAddToQuote: UIButton!
    
    @IBAction func btnAddToQuoteAction(_ sender: Any) {
    }
    @IBOutlet weak var arrowUOMDropdown: NSLayoutConstraint!
    override func awakeFromNib() {
        self.lbl_Description.font = UIFont.Roboto_Regular(baseScaleSize: 13.0)
        self.lbl_Each.font = UIFont.Roboto_Regular(baseScaleSize: 13.0)
        self.lbl_costPrice.font = UIFont.Roboto_Regular(baseScaleSize: 13.0)
        self.lbl_custPrice.font = UIFont.Roboto_Regular(baseScaleSize: 13.0)
    }
}
extension SearchProductVC: LightboxControllerPageDelegate ,LightboxControllerDismissalDelegate{
    
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        
    }
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
    }
}
