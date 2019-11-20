//
//  TextInputModalView.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 14..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import RevolutionRoboticsBlockly

final class TextInputModalView: UIView {
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
extension TextInputModalView {
    override func awakeFromNib() {
        super.awakeFromNib()

        doneButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
        cancelButton.setBorder(fillColor: .clear, croppedCorners: [.bottomLeft])
    }
}

// MARK: - Setup
extension TextInputModalView {
    func setup(inputHandler: InputHandler) {
        titleLabel.text = inputHandler.title.uppercased()
        if inputHandler.subtitle != nil {
            inputField.setup(title: inputHandler.subtitle!)
        } else {
            inputField.setup(title: inputHandler.title)
        }
        inputField.text = inputHandler.defaultInput
    }
}

// MARK: - Action handlers
extension TextInputModalView {
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        cancelCallback?()
    }

    @IBAction private func doneButtonTapped(_ sender: Any) {
        doneCallback?(inputField.text)
    }
}
