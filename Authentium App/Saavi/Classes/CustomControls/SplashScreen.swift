//
//  SplashScreen.swift
//  Saavi
//
//  Created by Sukhpreet on 01/06/18.
//  Copyright © 2018 Saavi. All rights reserved.
//

import UIKit

class SplashScreen: NSObject
{
    var parentView : UIView?
    func createSplashScreen() -> Void
    {
        let topImageVw = UIImageView(frame: CGRect(x: 0, y: 0, width: (parentView?.bounds.width)!, height: (parentView?.bounds.height)!/2))
        parentView?.addSubview(topImageVw)
        
        let bottonImageVw = UIImageView(frame: CGRect(x: 0, y: (parentView?.bounds.height)!/2, width: (parentView?.bounds.width)!, height: (parentView?.bounds.height)!/2))
        parentView?.addSubview(bottonImageVw)
        
       let imageRef = #imageLiteral(resourceName: "Splash").cgImage
        
        let topImageRef = imageRef?.cropping(to: CGRect(x: 0, y: 0, width: (imageRef?.width)!, height: (imageRef?.height)!/2))
        let topImage = UIImage(cgImage: topImageRef!)
        topImageVw.image = topImage
        topImageVw.contentMode = .scaleAspectFill
        
        let tbottomImageRef = imageRef?.cropping(to: CGRect(x: 0, y: (imageRef?.height)!/2, width: (imageRef?.width)!, height: (imageRef?.height)!/2))
        let bottomImage = UIImage(cgImage: tbottomImageRef!)
        bottonImageVw.image = bottomImage
        bottonImageVw.contentMode = .scaleAspectFill
        parentView?.addSubview(topImageVw)
        parentView?.addSubview(bottonImageVw)
        
        self.animateLoader(topImageVw: topImageVw, bottonImageVw: bottonImageVw)
    }
    
    func split(topImageVw : UIImageView, bottonImageVw: UIImageView)
    {
        UIView.animate(withDuration: 0.45, delay: 0.0, options: .curveLinear, animations: {
            topImageVw.frame = CGRect(x: 0, y: -self.parentView!.frame.size.height/2, width: (self.parentView?.bounds.width)!, height: (self.parentView?.bounds.height)!/2)
            bottonImageVw.frame = CGRect(x: 0, y: self.parentView!.bounds.height, width: (self.parentView?.bounds.width)!, height: (self.parentView?.bounds.height)!/2)
        }) { (completion:Bool) in
            if completion
            {
                topImageVw.removeFromSuperview()
                bottonImageVw.removeFromSuperview()
            }
        }
    }
    
    
    func animateLoader(topImageVw : UIImageView, bottonImageVw: UIImageView) -> Void
    {
        let progress = UIImageView(frame: CGRect(x: self.parentView!.center.x, y: parentView!.center.y - 0.35, width: 0, height: 0.7))
        progress.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        progress.layer.cornerRadius  = 0.3
        self.parentView?.addSubview(progress)
        
        UIView.animateKeyframes(withDuration: 1.5, delay: 0.6, options: UIViewKeyframeAnimationOptions.beginFromCurrentState, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 2/3, animations: {
                
                let expectedX = 0.9 * self.parentView!.frame.size.width
                let expectedWidth = self.parentView!.frame.size.width - (expectedX * 2)
                progress.frame = CGRect(x: expectedX, y: progress.frame.origin.y, width: expectedWidth, height: progress.frame.size.height)
            })
            
            
            
            UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: {
                let expectedX = 0.0 * self.parentView!.frame.size.width
                let expectedWidth = self.parentView!.frame.size.width - (expectedX * 2)
                progress.frame = CGRect(x: expectedX, y: progress.frame.origin.y, width: expectedWidth, height: progress.frame.size.height)
            })
            
        }) { (animated : Bool) in
            if animated
            {
                progress.removeFromSuperview()
                self.split(topImageVw: topImageVw, bottonImageVw: bottonImageVw)
            }
        }
    }
}
