//
//  SensorViewController.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 30..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class SensorConfigViewController: BaseViewController {
    // MARK: - SensorConfig
    typealias SensorConfig = (SensorType, String?)

    // MARK: - SensorType
    enum SensorType {
        case empty
        case bumper
        case ultrasound
    }

    // MARK: - Outlets
    @IBOutlet private weak var buttonContainer: UIStackView!
    @IBOutlet private weak var nameInputField: RRInputField!
    @IBOutlet private weak var testButton: RRButton!
    @IBOutlet private weak var doneButton: RRButton!

    // MARK: - Views
    private let emptyButton = PortConfigurationItemView.instatiate()
    private let bumperButton = PortConfigurationItemView.instatiate()
    private let ultrasoundButton = PortConfigurationItemView.instatiate()

    // MARK: - Variables
    var selectedSensorType: SensorType = .empty {
        didSet {
            handleSelectionChange()
            validateActionButtons()
        }
    }

    var portNumber = 0
    var doneButtonTapped: CallbackType<SensorConfig>?
    var testButtonTapped: CallbackType<SensorConfig>?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupButtonRow()
        setupNameInputField()
        handleSelectionChange()
        validateActionButtons()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        setupActionButtons()
    }
}

// MARK: - Setup
extension SensorConfigViewController {
    private func setupNameInputField() {
        nameInputField.setup(title: RobotsKeys.Configure.Motor.nameInputfield.translate(args: "S\(portNumber)"))
    }

    private func setupButtonRow() {
        emptyButton.configure(options: PortConfigurationItemView.Options(
            title: RobotsKeys.Configure.Motor.emptyButton.translate(),
            selectedImage: Image.Configure.emptySelected,
            unselectedImage: Image.Configure.emptyUnselected) { [weak self] in
                self?.selectedSensorType = .empty
            }
        )
        buttonContainer.addArrangedSubview(emptyButton)

        bumperButton.configure(options: PortConfigurationItemView.Options(
            title: RobotsKeys.Configure.Sensor.bumperButton.translate(),
            selectedImage: Image.Configure.bumperSelected,
            unselectedImage: Image.Configure.bumperUnselected) { [weak self] in
                self?.selectedSensorType = .bumper
            }
        )
        buttonContainer.addArrangedSubview(bumperButton)

        ultrasoundButton.configure(options: PortConfigurationItemView.Options(
            title: RobotsKeys.Configure.Sensor.ultrasoundButton.translate(),
            selectedImage: Image.Configure.ultrasoundSelected,
            unselectedImage: Image.Configure.ultrasoundUnselected) { [weak self] in
                self?.selectedSensorType = .ultrasound
            }
        )
        buttonContainer.addArrangedSubview(ultrasoundButton)
    }

    private func setupActionButtons() {
        testButton.setBorder(fillColor: Color.black26, croppedCorners: [.bottomLeft])
        doneButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
    }
}

// MARK: - Event handling
extension SensorConfigViewController {
    private func handleSelectionChange() {
        emptyButton.set(selected: selectedSensorType == .empty)
        bumperButton.set(selected: selectedSensorType == .bumper)
        ultrasoundButton.set(selected: selectedSensorType == .ultrasound)
    }

    private func validateActionButtons() {
        testButton.isEnabled = selectedSensorType != .empty
    }
}

// MARK: - Actions
extension SensorConfigViewController {
    @IBAction private func testButtonTapped(_ sender: Any) {
        testButtonTapped?((selectedSensorType, nameInputField.text))
    }

    @IBAction private func doneButtonTapped(_ sender: Any) {
        testButtonTapped?((selectedSensorType, nameInputField.text))
    }
}
