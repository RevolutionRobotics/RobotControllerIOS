//
//  UIView+Reusable.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 01..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

extension Reusable where Self: UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionViewCell: Reusable {
}
