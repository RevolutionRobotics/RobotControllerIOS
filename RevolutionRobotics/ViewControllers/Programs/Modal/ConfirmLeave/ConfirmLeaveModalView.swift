//
//  ConfirmLeaveModalView.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 07. 03..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ConfirmLeaveModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var leaveButton: RRButton!
    @IBOutlet private weak var cancelButton: RRButton!

    // MARK: - Callbacks
    var cancelCallback: Callback?
    var leaveCallback: Callback?
}

// MARK: - View lifecycle
extension ConfirmLeaveModalView {
    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.text = ProgramsKeys.navigateBackTitle.translate()
        subtitleLabel.text = ProgramsKeys.navigateBackDescription.translate()
        leaveButton.setTitle(ProgramsKeys.navigateBackPositive.translate(), for: .normal)
        leaveButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
        cancelButton.setTitle(CommonKeys.cancel.translate(), for: .normal)
        cancelButton.setBorder(fillColor: .clear, strokeColor: .clear, croppedCorners: [.bottomLeft])
    }
}

// MARK: - Action handlers
extension ConfirmLeaveModalView {
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        cancelCallback?()
    }

    @IBAction private func leaveButtonTapped(_ sender: Any) {
        leaveCallback?()
    }
}
