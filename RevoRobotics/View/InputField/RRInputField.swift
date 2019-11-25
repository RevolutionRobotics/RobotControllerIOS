//
//  RRInputField.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 02..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class RRInputField: RRCustomView {
    // MARK: - Outlets
    @IBOutlet private weak var borderView: UIView!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var titleLabel: UILabel!

    // MARK: - Properties
    private var characterLimit: Int?
    var textFieldResigned: CallbackType<String?>?
    var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }
}

// MARK: - View lifecycle
extension RRInputField {
    override func awakeFromNib() {
        super.awakeFromNib()

        textField.delegate = self
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        borderView.setBorder(fillColor: .clear, strokeColor: Color.brownGrey)
    }
}

// MARK: - Setup
extension RRInputField {
    func setup(title: String, placeholder: String? = nil, characterLimit: Int? = nil) {
        titleLabel.text = title
        textField.placeholder = placeholder
        self.characterLimit = characterLimit
    }
    
    func setKeyboardAppearance(to appearance: UIKeyboardAppearance) {
        textField.keyboardAppearance = appearance
    }
}

// MARK: - UITextViewDelegate
extension RRInputField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldResigned?(textField.text)
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let limit = characterLimit, range.location >= limit || string.count >= limit {
            return false
        }

        return true
    }
}
