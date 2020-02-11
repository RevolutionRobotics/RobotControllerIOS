//
//  UserAgeSelectionViewController.swift
//  RevolutionRobotics
//
//  Created by Pável Áron on 2019. 09. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import Firebase

enum UserProperty: String {
    case yearOfBirth = "year_of_birth"
    case robotId = "robot_id"
}

final class UserAgeSelectionViewController: BaseViewController {

    // MARK: - Constants
    private enum Constants {
        static let fontSize: CGFloat = 16.0
        static let userAgeEvent = "select_year_of_birth"
        static let maxAge = 99
    }

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var yearSelectionField: RRInputField!
    @IBOutlet private weak var nextButton: RRButton!

    // MARK: - Properties
    private let ageInput = UIPickerView()
    private let currentYear = Calendar.current.component(.year, from: Date())
    private var ageTextField: UITextField?
    private var birthYear: Int?

    private var tenYearsAgo: Int {
        return currentYear - 10
    }

    private lazy var selectionToolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(
            title: OnboardingKeys.AgeSelection.inputDone.translate(),
            style: .plain,
            target: self,
            action: #selector(dismissSelector))
        doneButton.tintColor = .white

        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolBar.setItems([space, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        return toolBar
    }()
}

// MARK: - View lifecycle
extension UserAgeSelectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabels()
        setupYearSelector()
    }
}

// MARK: - Private methods
extension UserAgeSelectionViewController {
    private func setupLabels() {
        titleLabel.text = OnboardingKeys.AgeSelection.title.translate()
        nextButton.setTitle(OnboardingKeys.AgeSelection.confirm.translate(), for: .normal)
        nextButton.setBorder()
    }

    private func setupYearSelector() {
        yearSelectionField.setKeyboardAppearance(to: .dark)
        yearSelectionField.setup(
            title: OnboardingKeys.AgeSelection.inputLabel.translate(),
            placeholder: "\(tenYearsAgo)",
            characterLimit: 4)
        yearSelectionField.text = "\(tenYearsAgo)"

        guard let textField = getTextField(in: yearSelectionField) else {
            return
        }

        ageInput.delegate = self
        ageInput.dataSource = self

        textField.font = Font.jura(size: Constants.fontSize)
        textField.tintColor = .clear
        textField.textAlignment = .center

        textField.inputView = ageInput
        textField.inputAccessoryView = selectionToolBar
        textField.delegate = self

        ageTextField = textField
    }

    private func promptBuildRevvy() {
        let selectedYear = birthYear ?? tenYearsAgo
        let yearOfBirthKey = UserProperty.yearOfBirth.rawValue
        let yearOfBirthValue = "\(selectedYear)"

        Analytics.setUserProperty(yearOfBirthValue, forName: yearOfBirthKey)
        Analytics.logEvent(Constants.userAgeEvent, parameters: [
            "year": selectedYear
        ])

        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: UserDefaults.Keys.userPropertiesSet)

        let buildRevvy = AppContainer.shared.container.unwrappedResolve(BuildRevvyViewController.self)
        navigationController?.pushViewController(buildRevvy, animated: true)
    }

    private func getTextField(in parentView: UIView) -> UITextField? {
        return parentView.allSubviews().first(where: { $0 is UITextField }) as? UITextField
    }

    private func year(for row: Int) -> Int {
        let oldestYearOfBirth = currentYear - Constants.maxAge
        return oldestYearOfBirth + row + 1
    }

    private func row(for year: Int) -> Int {
        let oldestYearOfBirth = currentYear - Constants.maxAge
        return year - oldestYearOfBirth - 1
    }

    @objc private func dismissSelector(_ sender: Any) {
        birthYear = year(for: ageInput.selectedRow(inComponent: 0))
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension UserAgeSelectionViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard
            let yearString = textField.text,
            let yearValue = Int(yearString)
        else { return }

        ageInput.selectRow(row(for: yearValue), inComponent: 0, animated: false)
    }
}

// MARK: - UIPickerViewDelegate
extension UserAgeSelectionViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let rowValue = year(for: row)
        return "\(rowValue)"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let rowValue = year(for: row)
        ageTextField?.text = "\(rowValue)"
    }
}

// MARK: - UIPickerViewDataSource
extension UserAgeSelectionViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.maxAge
    }
}

// MARK: - Actions
extension UserAgeSelectionViewController {
    @IBAction private func nextButtonTapped(_ sender: Any) {
        promptBuildRevvy()
    }
}
