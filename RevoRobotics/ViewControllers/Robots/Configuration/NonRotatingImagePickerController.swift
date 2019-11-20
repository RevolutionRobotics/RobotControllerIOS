//
//  NonRotatingImagePickerController.swift
//  RevolutionRobotics
//
//  Created by Pável Áron on 2019. 09. 09..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class NonRotatingImagePickerController: UIImagePickerController {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
}
