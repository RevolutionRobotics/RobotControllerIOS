//
//  SuccessfulUpdateModalView.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 14..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class SuccessfulUpdateModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var successfulUpdateLabel: UILabel!
    @IBOutlet private weak var doneButton: UIButton!

    // MARK: - Properties
    var doneCallback: Callback?
}

// MARK: - View lifecycle
extension SuccessfulUpdateModalView {
    override func awakeFromNib() {
        super.awakeFromNib()

        successfulUpdateLabel.text = ModalKeys.FirmwareUpdate.successfulUpdate.translate().uppercased()
        doneButton.setTitle(ModalKeys.FirmwareUpdate.done.translate(), for: .normal)
        doneButton.setBorder(fillColor: .clear, strokeColor: .white)
    }
}

// MARK: - Actions
extension SuccessfulUpdateModalView {
    @IBAction private func doneButtonTapped(_ sender: Any) {
        doneCallback?()
    }
}
