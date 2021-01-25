//
//  Walkthrough.swift
//  Saavi
//
//  Created by Sukhpreet on 15/11/17.
//  Copyright © 2017 Saavi. All rights reserved.
//

import UIKit

class Walkthrough: UIViewController
{
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var btnNext: UIButton!

    static let storyboardID = "walkthroughStoryboardIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    @IBAction func NextButton(_ sender: Any)
    {
//        let parentVC = CarouselPageViewController()
//        parentVC.MoveToNextPage()
        NotificationCenter.default.post(name: Notification.Name("NextTutorialView"), object: nil)
    }
    
    @IBAction func SkipButton(_ sender: Any)
    {
        let loginWireframe = LoginWireFrame()
        loginWireframe.makeRootViewController(onWindow: UIApplication.shared.keyWindow!, isShowChild: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
}


