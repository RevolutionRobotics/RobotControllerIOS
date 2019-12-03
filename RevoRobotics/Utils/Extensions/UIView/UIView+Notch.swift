//
//  UIView+Notch.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 07. 01..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

extension UIView {
    static let notchSize = getSafeAreaInsets().left
    static let safeAreaRight = getSafeAreaInsets().right
    static let safeAreaTop = getSafeAreaInsets().top
    static let safeAreaBottom = getSafeAreaInsets().bottom
    static let actualNotchSize = notchSize - 14

    static func getSafeAreaInsets() -> UIEdgeInsets {
        return UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
    }
}
