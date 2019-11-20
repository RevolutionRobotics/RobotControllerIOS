//
//  SaveProgramModalView.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 18..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class SaveProgramModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var nameInputField: RRInputField!
    @IBOutlet private weak var descriptionInputField: RRInputField!
    @IBOutlet private weak var doneButton: RRButton!

    // MARK: - SaveData
    typealias SaveData = (name: String, description: String?)

    // MARK: Callbacks
    var doneCallback: CallbackType<SaveData>?
}

// MARK: - View lifecycle
extension SaveProgramModalView {
    override func awakeFromNib() {
        super.awakeFromNib()

        nameInputField.textFieldResigned = { [weak self] text in
            self?.setDoneButton(enabled: text != nil && !text!.isEmpty)
        }
        nameInputField.setup(title: ProgramsKeys.SaveProgram.nameTitle.translate(),
                             placeholder: ProgramsKeys.SaveProgram.namePlaceholder.translate(),
                             characterLimit: nil)
        descriptionInputField.setup(title: ProgramsKeys.SaveProgram.descriptionTitle.translate(),
                                    placeholder: ProgramsKeys.SaveProgram.descriptionPlaceholder.translate(),
                                    characterLimit: nil)
        titleLabel.text = ProgramsKeys.SaveProgram.title.translate()
        doneButton.setTitle(CommonKeys.done.translate(), for: .normal)
        setDoneButton(enabled: false)
    }
}

// MARK: - Functions
extension SaveProgramModalView {
    func setup(with program: ProgramDataModel) {
        nameInputField.text = program.name
        descriptionInputField.text = program.customDescription
        setDoneButton(enabled: !program.name.isEmpty)
    }

    private func setDoneButton(enabled: Bool) {
        doneButton.isEnabled = enabled
        doneButton.setBorder(fillColor: .clear, strokeColor: enabled ? .white : .black)
    }
}

// MARK: - Action handlers
extension SaveProgramModalView {
    @IBAction private func doneButtonTapped(_ sender: Any) {
        guard let name = nameInputField.text else {
            return
        }
        doneCallback?(SaveData(name: name, description: descriptionInputField.text))
    }
}
