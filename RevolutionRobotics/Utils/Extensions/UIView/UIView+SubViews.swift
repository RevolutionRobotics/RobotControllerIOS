//
//  UIView+SubViews.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

extension UIView {
    func allSubViews() -> [UIView] {
        return subviews + subviews.flatMap { $0.allSubViews() }
    }
}
