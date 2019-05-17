//
//  SaveControllerModal.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class SaveControllerModal: UIView {
    // MARK: - SaveData
    public typealias SaveData = (name: String, description: String?)

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var nameInputField: RRInputField!
    @IBOutlet private weak var descriptionInputField: RRInputField!
    @IBOutlet private weak var doneButton: RRButton!

    // MARK: - Callbacks
    var saveCallback: CallbackType<SaveData>?
}

// MARK: - View lifecycle
extension SaveControllerModal {
    override func awakeFromNib() {
        super.awakeFromNib()

        doneButton.setBorder(fillColor: .clear, strokeColor: .white)
        doneButton.isEnabled = false
        nameInputField.setup(title: ModalKeys.Controller.nameTitle.translate(),
                             placeholder: ModalKeys.Controller.namePlaceholder.translate())
        nameInputField.textFieldResigned = { [weak self] text in
            if let name = text, !name.isEmpty {
                self?.doneButton.isEnabled = true
            } else {
                self?.doneButton.isEnabled = false
            }
        }
        descriptionInputField.setup(title: ModalKeys.Controller.descriptionTitle.translate(),
                                    placeholder: ModalKeys.Controller.descriptionPlaceholder.translate())
    }
}

// MARK: - Event handlers
extension SaveControllerModal {
    @IBAction private func doneButtonTapped(_ sender: Any) {
        guard let text = nameInputField.text else {
            return
        }
        saveCallback?((text, descriptionInputField.text))
    }
}
