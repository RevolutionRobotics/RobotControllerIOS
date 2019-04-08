//
//  UIViewController+NibLoadable.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 01..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

extension NibLoadable where Self: UIViewController {
    static var nibName: String {
        return String(describing: self)
    }
}
