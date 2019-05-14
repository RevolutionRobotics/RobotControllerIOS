//
//  SuccessfulUpdateModal.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 14..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class SuccessfulUpdateModal: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var successfulUpdateLabel: UILabel!
    @IBOutlet private weak var doneButton: UIButton!

    // MARK: - Variables
    var doneCallback: Callback?
}

// MARK: - View lifecycle
extension SuccessfulUpdateModal {
    override func awakeFromNib() {
        super.awakeFromNib()

        successfulUpdateLabel.text = ModalKeys.Settings.firmwareSuccessfulUpdate.translate().uppercased()
        doneButton.setTitle(ModalKeys.Settings.firmwareDoneButton.translate(), for: .normal)
        doneButton.setBorder(fillColor: .clear, strokeColor: .white)
    }
}

// MARK: - Event handlers
extension SuccessfulUpdateModal {
    @IBAction private func doneButtonTapped(_ sender: Any) {
        doneCallback?()
    }
}
