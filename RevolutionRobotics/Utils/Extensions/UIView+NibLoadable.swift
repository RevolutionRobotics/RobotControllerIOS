//
//  UIView+NibLoadable.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 01..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

extension NibLoadable where Self: UIView {
    static var nibName: String {
        return String(describing: self)
    }
}

extension UICollectionViewCell: NibLoadable {
}
