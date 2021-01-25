//
//  SpacingConstraints.swift
//  PamperMe
//
//  Created by Sukhpreet on 24/07/17.
//  Copyright © 2017 Sukhpreet. All rights reserved.
//

import UIKit


class HorizontalSpacingConstraints: NSLayoutConstraint
{
    static let spacingConstant = UIScreen.main.bounds.size.height/320.0
    override func awakeFromNib() {
        super.awakeFromNib()
        self.constant = self.constant/320.0 * UIScreen.main.bounds.size.width
    }
}


class VerticalSpacingConstraints: NSLayoutConstraint
{
    static let spacingConstant = UIScreen.main.bounds.size.height/568.0
    override func awakeFromNib() {
        super.awakeFromNib()
        self.constant = self.constant/568.0 * UIScreen.main.bounds.size.height
    }
}
