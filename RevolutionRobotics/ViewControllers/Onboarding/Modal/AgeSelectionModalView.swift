//
//  AgeSelectionModalView.swift
//  RevolutionRobotics
//
//  Created by Pável Áron on 2019. 09. 13..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class AgeSelectionModalView: UIView {

    // MARK: - Constants
    enum Constants {
        static let maxAge: Int = 18
    }

    // MARK: - Outlets
    @IBOutlet private weak var yearSelectionField: RRInputField!
    @IBOutlet private weak var setButton: RRButton!

    var ageSelectedCallback: CallbackType<Int>!

    // MARK: - Properties
    private let currentYear = Calendar.current.component(.year, from: Date())
    private var ageTextField: UITextField?

    private lazy var selectionToolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissSelector))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolBar.setItems([ space, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        return toolBar
    }()
}

// MARK: - Lifecycle methods
extension AgeSelectionModalView {
    override func awakeFromNib() {
        super.awakeFromNib()

        setupConfirmButton()
        setupYearSelector()
    }
}

// MARK: - Picker view delegate
extension AgeSelectionModalView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let rowValue = year(for: row)
        return "\(rowValue)"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let rowValue = year(for: row)
        ageTextField?.text = "\(rowValue)"
    }
}

// MARK: - Picker view data source
extension AgeSelectionModalView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.maxAge
    }
}

// MARK: - Private methods
extension AgeSelectionModalView {
    private func year(for row: Int) -> Int {
        let oldestYearOfBirth = currentYear - Constants.maxAge
        return oldestYearOfBirth + row + 1
    }

    private func getTextField(in parentView: UIView) -> UITextField? {
        return parentView.allSubviews().first(where: { $0 is UITextField }) as? UITextField
    }

    private func setupConfirmButton() {
        setButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.bottomLeft, .topRight])
    }

    private func setupYearSelector() {
        yearSelectionField.setup(title: "Year", placeholder: "\(currentYear)", characterLimit: 4)
        yearSelectionField.text = "\(currentYear)"

        guard let textField = getTextField(in: yearSelectionField) else {
            return
        }

        textField.font = Font.jura(size: 16.0)
        textField.tintColor = .clear
        textField.textAlignment = .center

        let ageInput = UIPickerView()
        ageInput.delegate = self
        ageInput.dataSource = self

        textField.inputView = ageInput
        textField.inputAccessoryView = selectionToolBar

        ageTextField = textField
    }

    @objc private func dismissSelector(_ sender: Any) {
        endEditing(true)
    }
}

// MARK: - Actions
extension AgeSelectionModalView {
    @IBAction private func setButtonTapped(_ sender: Any) {
        guard
            let yearOfBirthText = yearSelectionField.text,
            let yearOfBirth = Int(yearOfBirthText)
        else { return }

        ageSelectedCallback(yearOfBirth)
    }
}
