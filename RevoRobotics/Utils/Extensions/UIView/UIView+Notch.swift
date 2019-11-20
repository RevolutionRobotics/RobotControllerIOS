//
//  UIView+Notch.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 07. 01..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

extension UIView {
    static let notchSize = UIApplication.shared.keyWindow?.safeAreaInsets.left ?? 0.0
    static let actualNotchSize = notchSize - 14
}
