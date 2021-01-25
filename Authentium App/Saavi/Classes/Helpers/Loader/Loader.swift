//
//  Loader.swift
//  Saavi
//
//  Created by Sukhpreet on 30/06/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class Loader: UIView {
    
    var spinner : UIImageView?
    static let shared = Loader()
    var loaderShowRequests = 0
    
    func showLoader()
    {
        DispatchQueue.main.async {
            let rotatingBallsGif = UIImage.gifImageWithName("rotatingBallsSpinner")

            if self.spinner == nil
            {
                self.frame = (UIApplication.shared.keyWindow?.bounds)!
                //                let image = #imageLiteral(resourceName: "Loader").withRenderingMode(.alwaysTemplate)
                self.spinner = UIImageView(image: rotatingBallsGif)
                self.backgroundColor = UIColor.black.withAlphaComponent(0.1)
                self.spinner?.frame = CGRect(x: 0, y: 0, width: 50*Configration.scalingFactor(), height:  50*Configration.scalingFactor())
                self.spinner?.center = self.center
                self.addSubview(self.spinner!)
                //                self.spinner?.backgroundColor = .lightGray
                //                self.spinner?.tintColor = UIColor.baseBlueColor()
            }
            else{
                self.spinner?.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                self.spinner = UIImageView(image: rotatingBallsGif)
            }
            UIApplication.shared.keyWindow?.addSubview(self)
//            self.startAnimatingLoader()
        }
    }
    
    func startAnimatingLoader()
    {
        loaderShowRequests += 1
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 2 * Double.pi
        rotation.duration = 1.1
        rotation.repeatCount = Float.infinity
        spinner?.layer.add(rotation, forKey: "Spin")
    }
    
    func hideLoader()
    {
        if loaderShowRequests > 0
        {
        loaderShowRequests -= 1
        }
        if loaderShowRequests == 0
        {
        DispatchQueue.main.async {
            self.spinner?.layer.removeAllAnimations()
            self.removeFromSuperview()
        }
        }
    }
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
