//
//  ConfirmModalView.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 06. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ConfirmModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var cancelButton: RRButton!
    @IBOutlet private weak var okButton: RRButton!

    // MARK: - Properties
    private var confirmSelected: CallbackType<Bool>?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        setupButtons()
    }
}

// MARK: - Setup
extension ConfirmModalView {
    func setup(message: String, confirmSelected: CallbackType<Bool>?) {
        self.confirmSelected = confirmSelected
        titleLabel.text = message.uppercased()
    }

    private func setupButtons() {
        okButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
        okButton.setTitle(ModalKeys.Blockly.ok.translate(), for: .normal)
        cancelButton.setBorder(fillColor: Color.black26, strokeColor: Color.blackTwo, croppedCorners: [.bottomLeft])
        cancelButton.setTitle(ModalKeys.Blockly.cancel.translate(), for: .normal)
    }
}

// MARK: - Action
extension ConfirmModalView {
    @IBAction private func okButtonTapped(_ sender: Any) {
        confirmSelected?(true)
    }

    @IBAction private func cancelButtonTapped(_ sender: Any) {
        confirmSelected?(false)
    }
}
