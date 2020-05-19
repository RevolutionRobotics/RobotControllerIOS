//
//  RenameModalView.swift
//  RevoRobotics
//
//  Created by Pável Áron on 2020. 05. 14..
//  Copyright © 2020. Revolution Robotics. All rights reserved.
//

import UIKit

final class RenameModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var inputField: RRInputField!
    @IBOutlet private weak var renameButton: UIButton!

    // MARK: - Properties
    var renameTappedCallback: CallbackType<String>?

    func setup(with defaultName: String) {
        titleLabel.text = FirmwareUpdateKeys.Modal.changeRobotName.translate().uppercased()

        inputField.setup(title: FirmwareUpdateKeys.Modal.changeRobotNameHint.translate())
        inputField.text = defaultName

        inputField.textFieldResigned = { [weak self] text in
            self?.renameButton.isEnabled = !(text ?? "").isEmpty
        }

        renameButton.setTitle(FirmwareUpdateKeys.Modal.rename.translate(), for: .normal)
        renameButton.setBorder(fillColor: .clear, strokeColor: .white)
    }
}

// MARK: - Actions
extension RenameModalView {
    @IBAction private func renameButtonTapped(_ sender: Any) {
        guard let name = inputField.text else { return }
        renameTappedCallback?(name)
    }
}
