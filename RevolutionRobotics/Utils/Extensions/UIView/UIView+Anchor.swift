//
//  UIView+Anchor.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 23..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

extension UIView {
    func anchorToSuperview(top: Bool = true, bottom: Bool = true, leading: Bool = true, trailing: Bool = true) {
        guard let superview = self.superview else {
            return
        }

        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superview.topAnchor).isActive = top
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = bottom
        leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = leading
        trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = trailing
    }
}
