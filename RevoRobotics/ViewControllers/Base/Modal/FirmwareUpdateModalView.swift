//
//  FirmwareUpdateModalView.swift
//  RevoRobotics
//
//  Created by Pável Áron on 2020. 01. 21..
//  Copyright © 2020. Revolution Robotics. All rights reserved.
//

import UIKit

final class FirmwareUpdateModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var firmwareModalMessage: UILabel!
    @IBOutlet private weak var updateButton: RRButton!
    @IBOutlet private weak var continueButton: RRButton!

    // MARK: - Properties
    var updatePressedCallback: Callback?
    var continuePressedCallback: Callback?
}

// MARK: - View lifecycle
extension FirmwareUpdateModalView {
    override func awakeFromNib() {
        super.awakeFromNib()

        firmwareModalMessage.text = FirmwareUpdateKeys.Modal.title.translate()
        updateButton.setBorder(fillColor: Color.black26, strokeColor: .white, croppedCorners: [.bottomLeft])
        continueButton.setBorder(fillColor: Color.black26, strokeColor: .clear, croppedCorners: [.topRight])
        updateButton.setTitle(FirmwareUpdateKeys.Modal.updateButton.translate(), for: .normal)
        continueButton.setTitle(FirmwareUpdateKeys.Modal.continueButton.translate(), for: .normal)
    }
}

// MARK: - Actions
extension FirmwareUpdateModalView {
    @IBAction private func updateButtonTapped(_ sender: Any) {
        updatePressedCallback?()
    }

    @IBAction private func continueButtonTapped(_ sender: Any) {
        continuePressedCallback?()
    }
}
