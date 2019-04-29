//
//  MotorConfigViewController.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 29..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class MotorConfigViewController: BaseViewController {
    // MARK: - State
    enum State: Equatable {
        case empty
        case drivetrainWithoutSide
        case drivetrain(Side, Rotation)
        case motorWithoutRotation
        case motor(Rotation)
    }

    // MARK: - Outlets
    @IBOutlet private weak var topButtonContainer: UIStackView!
    @IBOutlet private weak var middleButtonContainer: UIStackView!
    @IBOutlet private weak var bottomButtonContainer: UIStackView!
    @IBOutlet private weak var nameInputField: RRInputField!
    @IBOutlet private weak var testButton: RRButton!
    @IBOutlet private weak var doneButton: RRButton!

    // MARK: - Views
    private let emptyButton = PortConfigurationItemView.instatiate()
    private let drivetrainButton = PortConfigurationItemView.instatiate()
    private let motorButton = PortConfigurationItemView.instatiate()
    private let clockwiseButton = PortConfigurationItemView.instatiate()
    private let counterclockwiseButton = PortConfigurationItemView.instatiate()
    private let leftButton = PortConfigurationItemView.instatiate()
    private let rightButton = PortConfigurationItemView.instatiate()

    // MARK: - Variables
    var state: State = .empty {
        didSet {
            switchTo(state: state)
            validateActionButtons()
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTopButtonRow()
        setupRotationButtons()
        setupSideButtons()
        setupNameInputField()
        switchTo(state: state)
        validateActionButtons()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupActionButtons()
    }
}

// MARK: - State change
extension MotorConfigViewController {
    private func switchTo(state: State) {
        switch state {
        case .empty:
            switchToEmptyState()
        case .drivetrainWithoutSide:
            switchToDrivetrainWithoutSideState()
        case .drivetrain(let side, let rotation):
            switchToDrivetrainState(side: side, rotation: rotation)
        case .motorWithoutRotation:
            switchToMotorWithoutRotationState()
        case .motor(let rotation):
            switchToMotorState(rotation: rotation)
        }
    }

    private func switchToEmptyState() {
        resetButtons()
        emptyButton.set(selected: true)
        middleButtonContainer.isHidden = true
        bottomButtonContainer.isHidden = true
    }

    private func switchToDrivetrainWithoutSideState() {
        resetButtons()
        drivetrainButton.set(selected: true)
        middleButtonContainer.removeAllArrangedSubviews()
        middleButtonContainer.addArrangedSubview(leftButton)
        middleButtonContainer.addArrangedSubview(rightButton)
        middleButtonContainer.isHidden = false
        bottomButtonContainer.isHidden = true
    }

    private func switchToDrivetrainState(side: Side, rotation: Rotation) {
        bottomButtonContainer.addArrangedSubview(clockwiseButton)
        bottomButtonContainer.addArrangedSubview(counterclockwiseButton)
        bottomButtonContainer.isHidden = false
        leftButton.set(selected: side == .left)
        rightButton.set(selected: side == .right)
        clockwiseButton.set(selected: rotation == .clockwise)
        counterclockwiseButton.set(selected: rotation == .counterclockwise)
    }

    private func switchToMotorWithoutRotationState() {
        resetButtons()
        motorButton.set(selected: true)
        middleButtonContainer.removeAllArrangedSubviews()
        middleButtonContainer.addArrangedSubview(clockwiseButton)
        middleButtonContainer.addArrangedSubview(counterclockwiseButton)
        middleButtonContainer.isHidden = false
        bottomButtonContainer.isHidden = true
    }

    private func switchToMotorState(rotation: Rotation) {
        clockwiseButton.set(selected: rotation == .clockwise)
        counterclockwiseButton.set(selected: rotation == .counterclockwise)
    }
}

// MARK: - Setup
extension MotorConfigViewController {
    private func setupNameInputField() {
        // TODO: Change to the real name
        nameInputField.setup(title: RobotsKeys.Configure.Motor.nameInputfield.translate(args: "M2"))
    }

    private func setupTopButtonRow() {
        emptyButton.configure(options: PortConfigurationItemView.Options(
            title: RobotsKeys.Configure.Motor.emptyButton.translate(),
            selectedImage: Image.Configure.emptySelected,
            unselectedImage: Image.Configure.emptyUnselected) { [weak self] in
                self?.state = .empty
            }
        )
        topButtonContainer.addArrangedSubview(emptyButton)

        drivetrainButton.configure(options: PortConfigurationItemView.Options(
            title: RobotsKeys.Configure.Motor.drivetrainButton.translate(),
            selectedImage: Image.Configure.drivetrainSelected,
            unselectedImage: Image.Configure.drivetrainUnselected) { [weak self] in
                self?.state = .drivetrainWithoutSide
            }
        )
        topButtonContainer.addArrangedSubview(drivetrainButton)

        motorButton.configure(options: PortConfigurationItemView.Options(
            title: RobotsKeys.Configure.Motor.motorButton.translate(),
            selectedImage: Image.Configure.motorSelected,
            unselectedImage: Image.Configure.motorUnselected) { [weak self] in
                self?.state = .motorWithoutRotation
            }
        )
        topButtonContainer.addArrangedSubview(motorButton)
    }

    private func setupRotationButtons() {
        clockwiseButton.configure(options: PortConfigurationItemView.Options(
            title: RobotsKeys.Configure.Motor.clockwiseButton.translate(),
            selectedImage: Image.Configure.clockwiseSelected,
            unselectedImage: Image.Configure.clockwiseUnselected) { [weak self] in
                self?.handleRotationChange(to: .clockwise)
            }
        )

        counterclockwiseButton.configure(options: PortConfigurationItemView.Options(
            title: RobotsKeys.Configure.Motor.counterclockwiseButton.translate(),
            selectedImage: Image.Configure.counterclockwiseSelected,
            unselectedImage: Image.Configure.counterclockwiseUnselected) { [weak self] in
                self?.handleRotationChange(to: .counterclockwise)
            }
        )
    }

    private func setupSideButtons() {
        leftButton.configure(options: PortConfigurationItemView.Options(
            title: RobotsKeys.Configure.Motor.leftButton.translate(),
            selectedImage: Image.Configure.leftSelected,
            unselectedImage: Image.Configure.leftUnselected) { [weak self] in
                self?.handleSideChange(to: .left)
            }
        )

        rightButton.configure(options: PortConfigurationItemView.Options(
            title: RobotsKeys.Configure.Motor.rightButton.translate(),
            selectedImage: Image.Configure.rightSelected,
            unselectedImage: Image.Configure.rightUnselected) { [weak self] in
                self?.handleSideChange(to: .right)
            }
        )
    }

    private func setupActionButtons() {
        testButton.setBorder(fillColor: Color.black26, croppedCorners: [.bottomLeft])
        doneButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
    }
}

// MARK: - Event handling
extension MotorConfigViewController {
    private func handleRotationChange(to rotation: Rotation) {
        switch state {
        case .motor(_), .motorWithoutRotation:
            state = .motor(rotation)
        case .drivetrain(let side, _):
            state = .drivetrain(side, rotation)
        default: return
        }
    }

    private func handleSideChange(to side: Side) {
        switch state {
        case .drivetrainWithoutSide:
            state = .drivetrain(side, side == .left ? .counterclockwise : .clockwise)
        case .drivetrain(_, let rotation):
            state = .drivetrain(side, rotation)
        default: return
        }
    }

    private func resetButtons() {
        emptyButton.set(selected: false)
        drivetrainButton.set(selected: false)
        motorButton.set(selected: false)
        leftButton.set(selected: false)
        rightButton.set(selected: false)
        clockwiseButton.set(selected: false)
        counterclockwiseButton.set(selected: false)
    }
}

// MARK: - Button validation
extension MotorConfigViewController {
    private func validateActionButtons() {
        testButton.isEnabled = state != .empty && state != .drivetrainWithoutSide && state != .motorWithoutRotation
        doneButton.isEnabled = state != .drivetrainWithoutSide && state != .motorWithoutRotation
    }
}

// MARK: - Actions
extension MotorConfigViewController {
    @IBAction private func testButtonTapped(_ sender: Any) {
        print("Selected state: \(state)")
    }

    @IBAction private func doneButtonTapped(_ sender: Any) {
        print("Selected state: \(state) with name: \(nameInputField.text!)")
    }
}
