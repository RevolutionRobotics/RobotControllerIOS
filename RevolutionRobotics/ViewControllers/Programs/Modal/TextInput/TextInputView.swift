//
//  TextInputView.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 14..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import RevolutionRoboticsBlockly

final class TextInputView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var inputField: RRInputField!
    @IBOutlet private weak var doneButton: RRButton!
    @IBOutlet private weak var cancelButton: RRButton!

    // MARK: - Callbacks
    var doneCallback: CallbackType<String?>?
    var cancelCallback: Callback?
}

// MARK: - View lifecycle
extension TextInputView {
    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.text = ModalKeys.Program.newVariableName.translate().uppercased()
        doneButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
        cancelButton.setBorder(fillColor: .clear, croppedCorners: [.bottomLeft])
    }
}

// MARK: - Setup
extension TextInputView {
    func setup(inputHandler: InputHandler) {
        inputField.setup(title: ModalKeys.Program.newVariableName.translate(), placeholder: nil, characterLimit: nil)
        inputField.text = inputHandler.defaultInput
    }
}

// MARK: - Action handlers
extension TextInputView {
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        cancelCallback?()
    }

    @IBAction private func doneButtonTapped(_ sender: Any) {
        doneCallback?(inputField.text)
    }
}
