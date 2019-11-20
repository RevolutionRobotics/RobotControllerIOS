//
//  RRNavigationController.swift
//  RevolutionRobotics
//
//  Created by Csaba Vidó on 2019. 04. 30..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class RRNavigationController: UINavigationController {
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
}
