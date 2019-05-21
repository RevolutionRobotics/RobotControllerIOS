//
//  DriverConfigurationView.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 20..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class DriverConfigurationView: UIView, ConfigurableControllerView {
    var selectionCallback: CallbackType<Int>?

    func set(state: ControllerButton.ControllerButtonState, on buttonNumber: Int, title: String?) {
    }
}
