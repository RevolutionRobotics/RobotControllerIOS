//
//  BuildFinishedModal.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 06..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class BuildFinishedModal: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var allSetLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var homeButton: RRButton!
    @IBOutlet private weak var driveButton: RRButton!

    // MARK: - Callbacks
    var homeCallback: Callback?
    var driveCallback: Callback?
}

// MARK: - View lifecycle
extension BuildFinishedModal {
    override func awakeFromNib() {
        super.awakeFromNib()

        allSetLabel.text = RobotsKeys.BuildRobot.buildFinishedAllSet.translate()
        messageLabel.text = RobotsKeys.BuildRobot.buildFinishedMessage.translate()
        driveButton.setTitle(RobotsKeys.BuildRobot.buildFinishedDrive.translate(), for: .normal)
        homeButton.setTitle(RobotsKeys.BuildRobot.buildFinishedHome.translate(), for: .normal)
        driveButton.setBorder(fillColor: . clear, strokeColor: .white, croppedCorners: [.topRight])
        homeButton.setBorder(fillColor: Color.black26, strokeColor: . clear, croppedCorners: [.bottomLeft])
    }
}

// MARK: - Event handlers
extension BuildFinishedModal {
    @IBAction private func homeButtonTapped(_ sender: Any) {
        homeCallback?()
    }

    @IBAction private func driveButtonTapped(_ sender: Any) {
        driveCallback?()
    }
}
