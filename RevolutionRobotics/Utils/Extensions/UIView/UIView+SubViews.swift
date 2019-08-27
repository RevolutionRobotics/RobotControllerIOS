//
//  UIView+SubViews.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

extension UIView {
    func allSubviews() -> [UIView] {
        return subviews + subviews.flatMap { $0.allSubviews() }
    }

    func removeAllSubViews() {
        allSubviews().forEach({ $0.removeFromSuperview() })
    }

    var visualEffectsSubview: UIVisualEffectView? {
        if let visualEffectView = self as? UIVisualEffectView {
            return visualEffectView
        }

        for subview in subviews {
            if let visualEffectView = subview.visualEffectsSubview {
                return visualEffectView
            }
        }

        return nil
    }
}
