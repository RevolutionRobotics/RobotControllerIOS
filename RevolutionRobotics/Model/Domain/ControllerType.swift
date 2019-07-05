//
//  ControllerType.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import UIKit

enum ControllerType: String {
    case gamer
    case multiTasker
    case driver

    var image: UIImage? {
        switch self {
        case .gamer:
            return Image.Controller.gamer
        case .multiTasker:
            return Image.Controller.multiTasker
        case .driver:
            return Image.Controller.driver
        }
    }

    var displayName: String {
        switch self {
        case .gamer:
            return ControllerKeys.gamer.translate()
        case .multiTasker:
            return ControllerKeys.multiTasker.translate()
        case .driver:
            return ControllerKeys.driver.translate()
        }
    }
}
