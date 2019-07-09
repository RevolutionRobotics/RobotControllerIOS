//
//  ResetTutorialModalView.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 10..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ResetTutorialModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var resetMessageLabel: UILabel!
}

// MARK: - Setup
extension ResetTutorialModalView {
    func setup(with message: String) {
        resetMessageLabel.text = message
    }
}
