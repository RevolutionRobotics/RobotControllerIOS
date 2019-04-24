//
//  TurnOnBrainView.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class TurnOnBrainView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var brainImageView: UIImageView!
    @IBOutlet private weak var instructionLabel: UILabel!
    @IBOutlet private weak var nextStepLabel: UILabel!
    @IBOutlet private weak var laterButton: UIButton!
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var tipsButton: UIButton!
}

// MARK: - View lifecycle
extension TurnOnBrainView {
    override func awakeFromNib() {
        super.awakeFromNib()

        laterButton.setBorder(fillColor: Color.black26,
                              strokeColor: Color.blackTwo,
                              croppedCorners: [.bottomLeft])
        tipsButton.setBorder(fillColor: Color.black26,
                             strokeColor: Color.blackTwo,
                             croppedCorners: [])
        startButton.setBorder(fillColor: Color.blackTwo,
                              strokeColor: UIColor.white,
                              croppedCorners: [.topRight])
        instructionLabel.text = RobotsKeys.BuildRobot.turnOnTheBrainInstruction.translate().uppercased()
        nextStepLabel.text = RobotsKeys.BuildRobot.turnOnTheBrainTip.translate().uppercased()
    }
}

// MARK: - Event handlers
extension TurnOnBrainView {
    @IBAction private func laterButtonTapped(_ sender: Any) {
    }

    @IBAction private func startButtonTapped(_ sender: Any) {
    }

    @IBAction private func tipsButtonTapped(_ sender: Any) {
    }
}
