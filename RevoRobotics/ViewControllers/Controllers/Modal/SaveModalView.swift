//
//  SaveModal.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class SaveModalView: UIView {
    // MARK: - Type
    enum ModalType {
        case configuration
        case controller
        case program
    }

    // MARK: - SaveData
    typealias SaveData = (name: String, description: String?)

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var nameInputField: RRInputField!
    @IBOutlet private weak var descriptionInputField: RRInputField!
    @IBOutlet private weak var doneButton: RRButton!

    // MARK: - Callbacks
    var saveCallback: CallbackType<SaveData>?
    var name: String? {
        get {
            return nameInputField.text
        }
        set {
            nameInputField.text = newValue
            setDoneButton(enabled: newValue != nil && !newValue!.isEmpty)
        }
    }
    var descriptionTitle: String? {
        get {
            return descriptionInputField.text
        }
        set {
            descriptionInputField.text = newValue
        }
    }
    var type: ModalType = .configuration {
        didSet {
            updateLocalization()
        }
    }
}

// MARK: - View lifecycle
extension SaveModalView {
    override func awakeFromNib() {
        super.awakeFromNib()

        doneButton.setBorder(fillColor: .clear, strokeColor: .white)
        doneButton.isEnabled = false
        doneButton.setBorder(fillColor: .clear, strokeColor: Color.black)
        nameInputField.setup(title: ModalKeys.Controller.nameTitle.translate(),
                             placeholder: ModalKeys.Controller.namePlaceholder.translate())
        nameInputField.textFieldResigned = { [weak self] text in
            self?.setDoneButton(enabled: text != nil && !text!.isEmpty)
        }
        descriptionInputField.setup(title: ModalKeys.Controller.descriptionTitle.translate(),
                                    placeholder: ModalKeys.Controller.descriptionPlaceholder.translate())
    }

    private func setDoneButton(enabled: Bool) {
        doneButton.isEnabled = enabled
        doneButton.setBorder(fillColor: .clear, strokeColor: enabled ? .white : Color.black)
    }
}

// MARK: - Event handlers
extension SaveModalView {
    @IBAction private func doneButtonTapped(_ sender: Any) {
        guard let text = nameInputField.text else {
            return
        }
        saveCallback?((text, descriptionInputField.text))
    }
}

extension SaveModalView {
    private func updateLocalization() {
        switch type {
        case .configuration:
            titleLabel.text = ModalKeys.Save.Configuration.title.translate()
            nameInputField.setup(title: ModalKeys.Save.Configuration.nameTitle.translate(),
                                 placeholder: ModalKeys.Save.Configuration.nameHint.translate())
            descriptionInputField.setup(title: ModalKeys.Save.Configuration.descriptionTitle.translate(),
                                        placeholder: ModalKeys.Save.Configuration.descriptionHint.translate())
            doneButton.setTitle(ModalKeys.Save.done.translate(), for: .normal)
        case .controller:
            nameInputField.setup(title: ModalKeys.Controller.nameTitle.translate(),
                                 placeholder: ModalKeys.Controller.namePlaceholder.translate())
            descriptionInputField.setup(title: ModalKeys.Controller.descriptionTitle.translate(),
                                        placeholder: ModalKeys.Controller.descriptionPlaceholder.translate())
        case .program:
            nameInputField.setup(title: ModalKeys.Controller.nameTitle.translate(),
                                 placeholder: ModalKeys.Controller.namePlaceholder.translate())
            descriptionInputField.setup(title: ModalKeys.Controller.descriptionTitle.translate(),
                                        placeholder: ModalKeys.Controller.descriptionPlaceholder.translate())
        }
    }
}
