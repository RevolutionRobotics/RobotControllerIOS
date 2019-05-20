//
//  ConfigurableControllerView.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 20..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

protocol ConfigurableControllerView: UIView {
    var selectionCallback: CallbackType<Int>? { get set }
    func set(state: ControllerButton.ControllerButtonState, on buttonNumber: Int, title: String?)
}
