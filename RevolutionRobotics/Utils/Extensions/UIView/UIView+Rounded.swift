//
//  UIView+Rounded.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 05. 13..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

extension UIView {
    func roundToCircle() {
        round(cornerRadius: frame.size.width / 2)
    }

    func round(cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
    }
}
