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
    @IBOutlet private weak var laterButton: RRButton!
    @IBOutlet private weak var startButton: RRButton!
    @IBOutlet private weak var tipsButton: RRButton!

    // MARK: - Properties
    var laterHandler: Callback?
    var tipsHandler: Callback?
    var startHandler: Callback?
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
        laterHandler?()
    }

    @IBAction private func startButtonTapped(_ sender: Any) {
        startHandler?()
    }

    @IBAction private func tipsButtonTapped(_ sender: Any) {
        tipsHandler?()
    }
}
