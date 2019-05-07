//
//  RRInputField.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 02..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class RRInputField: RRCustomView {
    // MARK: - Constants
    enum Constants {
        static let returnText = "\n"
    }

    // MARK: - Outlets
    @IBOutlet private weak var borderView: UIView!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var descriptionLabel: UILabel!

    // MARK: - Variables
    private var placeholder: String?
    private var characterLimit: Int?

    // MARK: - Public
    var text: String? {
        return textView.text
    }
}

// MARK: - View lifecycle
extension RRInputField {
    override func awakeFromNib() {
        super.awakeFromNib()

        borderView.setBorder(fillColor: .clear, strokeColor: Color.brownGrey)
        textView.delegate = self
        textView.textContainer.maximumNumberOfLines = 2
        textView.tintAdjustmentMode = .normal
        textView.tintColor = .white
    }
}

// MARK: - Setup
extension RRInputField {
    func setup(title: String, placeholder: String? = nil, characterLimit: Int? = nil) {
        descriptionLabel.text = title
        textView.text = placeholder

        self.placeholder = placeholder
        self.characterLimit = characterLimit
        self.layoutIfNeeded()
    }
}

// MARK: - UITextViewDelegate
extension RRInputField: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let placeholder = self.placeholder, textView.text == placeholder, textView.textColor == Color.brownGrey {
            textView.text = nil
            textView.textColor = .white
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = Color.brownGrey
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == Constants.returnText {
            textView.resignFirstResponder()
        }
        if let limit = characterLimit, range.location >= limit || text.count >= limit {
            return false
        }
        return true
    }
}
