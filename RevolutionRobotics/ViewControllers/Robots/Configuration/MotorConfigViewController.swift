//
//  MotorConfigViewController.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 29..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import SideMenu
import os

final class MotorConfigViewController: BaseViewController {
    // MARK: - Constants
    private enum Constants {
        static let defaultDriveName = "drive"
        static let defaultMotorName = "motor"
        static let iPhoneSEScreenHeight: CGFloat = 320
        static let iPhoneSETopConstraintConstant: CGFloat = 8
    }

    // MARK: - Outlets
    @IBOutlet private weak var topButtonContainer: UIStackView!
    @IBOutlet private weak var middleButtonContainer: UIStackView!
    @IBOutlet private weak var bottomButtonContainer: UIStackView!
    @IBOutlet private weak var nameInputField: RRInputField!
    @IBOutlet private weak var testButton: RRButton!
    @IBOutlet private weak var doneButton: RRButton!
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!

    // MARK: - Properties
    private let emptyButton = PortConfigurationItemView.instatiate()
    private let driveButton = PortConfigurationItemView.instatiate()
    private let motorButton = PortConfigurationItemView.instatiate()
    private let leftButton = PortConfigurationItemView.instatiate()
    private let rightButton = PortConfigurationItemView.instatiate()
    private let reverseSwitch = UISwitch()
    private let reverseLabel = UILabel()

    var selectedMotorState: MotorConfigViewModelState = .empty {
        didSet {
            if isViewLoaded {
                switchTo(state: selectedMotorState)
                validateActionButtons()
            }
        }
    }
    var portNumber = 0
    var numberOfDrives = 0
    var doneButtonTapped: CallbackType<MotorConfigViewModel>?
    var testButtonTapped: CallbackType<MotorConfigViewModel>?
    var screenDismissed: Callback?
    var name: String? {
        didSet {
            guard let name = name else { return }

            switch selectedMotorState {
            case .drive, .driveWithoutSide:
                customDriveName = name
            case .motor, .motorWithoutRotation:
                customMotorName = name
            case .empty:
                customDriveName = ""
                customMotorName = ""
            }
        }
    }
    var prohibitedNames: [String] = []
    var testCodeService: PortTestCodeServiceInterface!
    private var customMotorName = ""
    private var customDriveName = ""
    private var shouldCallDismiss = true
    private var shouldRunTestScriptOnConnection = false
}

// MARK: - View lifecycle
extension MotorConfigViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        nameInputField.text = name

        setupTopButtonRow()
        setupSideButtons()
        setupNameInputField()
        setupReverseRow()
        switchTo(state: selectedMotorState)

        if UIScreen.main.bounds.size.height == Constants.iPhoneSEScreenHeight {
            topConstraint.constant = Constants.iPhoneSETopConstraintConstant
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupActionButtons()
        validateActionButtons()
    }
}

// MARK: - State change
extension MotorConfigViewController {
    private func switchTo(state: MotorConfigViewModelState) {
        switch state {
        case .empty:
            switchToEmptyState()
        case .driveWithoutSide:
            switchToDriveWithoutSideState()
        case .drive(let side, let rotation):
            switchToDriveState(side: side, rotation: rotation)
        case .motorWithoutRotation:
            switchToMotorWithoutRotationState()
        case .motor(let rotation):
            switchToMotorState(rotation: rotation)
        }

        let stateIsEmpty = state == .empty

        nameInputField.isUserInteractionEnabled = !stateIsEmpty
        nameInputField.layer.opacity = stateIsEmpty ? 0.5 : 1.0
        nameInputField.text = nameInputFieldText(for: state)
    }

    private func switchToEmptyState() {
        resetButtons()
        nameInputField.text = name
        emptyButton.set(selected: true)
        middleButtonContainer.isHidden = true
        bottomButtonContainer.isHidden = true
    }

    private func switchToDriveWithoutSideState() {
        resetButtons()
        driveButton.set(selected: true)
        middleButtonContainer.removeAllArrangedSubviews()
        middleButtonContainer.addArrangedSubview(leftButton)
        middleButtonContainer.addArrangedSubview(rightButton)
        middleButtonContainer.isHidden = false
        bottomButtonContainer.isHidden = true
    }

    private func switchToDriveState(side: Side, rotation: Rotation) {
        driveButton.set(selected: true)
        middleButtonContainer.isHidden = false
        if !middleButtonContainer.arrangedSubviews.contains(leftButton) {
            middleButtonContainer.addArrangedSubview(leftButton)
            middleButtonContainer.addArrangedSubview(rightButton)
        }

        bottomButtonContainer.addArrangedSubview(reverseSwitch)
        bottomButtonContainer.addArrangedSubview(reverseLabel)

        bottomButtonContainer.isHidden = false
        leftButton.set(selected: side == .left)
        rightButton.set(selected: side == .right)

        reverseSwitch.isOn = rotation == .reversed

        NSLayoutConstraint.activate([
            reverseLabel.topAnchor.constraint(equalTo: reverseSwitch.topAnchor),
            reverseLabel.bottomAnchor.constraint(equalTo: reverseSwitch.bottomAnchor)
        ])
    }

    private func switchToMotorWithoutRotationState() {
        resetButtons()
        motorButton.set(selected: true)
        middleButtonContainer.removeAllArrangedSubviews()
        middleButtonContainer.isHidden = false
        bottomButtonContainer.isHidden = true
    }

    private func switchToMotorState(rotation: Rotation) {
        motorButton.set(selected: true)
        middleButtonContainer.isHidden = true
    }
}

// MARK: - Setup
extension MotorConfigViewController {
    private func setupReverseRow() {
        reverseLabel.text = "Reversed"
        reverseLabel.font = Font.jura(size: 14.0)
        reverseLabel.textColor = .white

        reverseSwitch.addTarget(self, action: #selector(reverseSwitchTapped), for: .valueChanged)
    }

    private func setupNameInputField() {
        nameInputField.setup(title: RobotsKeys.Configure.Motor.nameInputfield.translate(args: "M\(portNumber)"))
        nameInputField.textFieldResigned = { [weak self] _ in
            self?.validateActionButtons()
        }
    }

    private func nameInputFieldText(for state: MotorConfigViewModelState) -> String? {
        switch state {
        case .motorWithoutRotation:
            if customMotorName.isEmpty {
                if let name = name, name.contains(Constants.defaultMotorName) { return name }
                return "\(Constants.defaultMotorName)\(portNumber)"
            } else {
                return customMotorName
            }
        case .driveWithoutSide:
            if customDriveName.isEmpty {
                if let name = name, name.contains(Constants.defaultDriveName) { return name }
                return "\(Constants.defaultDriveName)\(portNumber)"
            } else {
                return customDriveName
            }
        default: return nameInputField.text
        }
    }

    private func setupTopButtonRow() {
        emptyButton.configure(options: PortConfigurationItemView.Options(
            title: RobotsKeys.Configure.Motor.emptyButton.translate(),
            selectedImage: Image.Configure.emptySelected,
            unselectedImage: Image.Configure.emptyUnselected) { [weak self] in
                self?.selectedMotorState = .empty
            }
        )
        topButtonContainer.addArrangedSubview(emptyButton)

        driveButton.configure(options: PortConfigurationItemView.Options(
            title: RobotsKeys.Configure.Motor.driveButton.translate(),
            selectedImage: Image.Configure.driveSelected,
            unselectedImage: Image.Configure.driveUnselected) { [weak self] in
                self?.selectedMotorState = .driveWithoutSide
            }
        )
        topButtonContainer.addArrangedSubview(driveButton)

        motorButton.configure(options: PortConfigurationItemView.Options(
            title: RobotsKeys.Configure.Motor.motorButton.translate(),
            selectedImage: Image.Configure.motorSelected,
            unselectedImage: Image.Configure.motorUnselected) { [weak self] in
                self?.selectedMotorState = .motorWithoutRotation
            }
        )
        topButtonContainer.addArrangedSubview(motorButton)
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
        testButton.setTitle(RobotsKeys.Configure.Motor.testButton.translate(), for: .normal)
        testButton.setBorder(fillColor: .clear, croppedCorners: [.bottomLeft])
        doneButton.setTitle(RobotsKeys.Configure.Motor.doneButton.translate(), for: .normal)
        doneButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
    }
}

// MARK: - Event handling
extension MotorConfigViewController {
    private func handleRotationChange(to rotation: Rotation) {
        switch selectedMotorState {
        case .motor, .motorWithoutRotation:
            selectedMotorState = .motor(rotation)
        case .drive(let side, _):
            selectedMotorState = .drive(side, rotation)
        default: return
        }
    }

    private func handleSideChange(to side: Side) {
        switch selectedMotorState {
        case .driveWithoutSide:
            selectedMotorState = .drive(side, .forward)
        case .drive(_, let rotation):
            selectedMotorState = .drive(side, rotation)
        default: return
        }
    }

    private func resetButtons() {
        emptyButton.set(selected: false)
        driveButton.set(selected: false)
        motorButton.set(selected: false)
        leftButton.set(selected: false)
        rightButton.set(selected: false)
    }

    private func presentTestingModal() {
        let modal = TestingModalView.instatiate()
        switch selectedMotorState {
        case .motor:
            modal.setup(with: .motor)
        case .drive:
            modal.setup(with: .drive)
        default: break
        }
        modal.positiveButtonTapped = { [weak self] in
            self?.dismissModalViewController()
        }
        modal.negativeButtonTapped = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
            self?.presentTipsModal()
        }
        presentModal(with: modal)
    }

    private func startPortTest() {
        var testCode = ""
        switch selectedMotorState {
        case .motor(let rotation):
            testCode = testCodeService.motorTestCode(for: portNumber, direction: rotation)
        case .drive(let side, let rotation):
            testCode = testCodeService.drivatrainTestCode(for: portNumber, direction: rotation, side: side)
        default: break
        }

        bluetoothService.testKit(data: testCode, onCompleted: nil)
    }

    private func presentTipsModal() {
        let tips = TipsModalView.instatiate()
        tips.title = ModalKeys.Tips.title.translate()
        tips.subtitle = ModalKeys.Tips.subtitle.translate()
        tips.tips = ModalKeys.Tips.tips.translate()
        tips.skipTitle = ModalKeys.Tips.reconfigure.translate()
        tips.communityTitle = ModalKeys.Tips.community.translate()
        tips.tryAgainTitle = ModalKeys.Tips.tryAgin.translate()
        tips.skipIcon = Image.Configure.reconfigure

        tips.communityCallback = { [weak self] in
            self?.openSafari(presentationFinished: nil)
        }
        tips.skipCallback = { [weak self] in
            self?.dismissModalViewController()
        }
        tips.tryAgainCallback = { [weak self] in
            self?.dismissModalViewController()
            self?.presentTestingModal()
            self?.startPortTest()
        }
        presentModal(with: tips)
    }
}

// MARK: - Button validation
extension MotorConfigViewController {
    private func validateActionButtons() {
        testButton.isEnabled = selectedMotorState != .empty
            && selectedMotorState != .driveWithoutSide
        guard let name = nameInputField.text else {
            doneButton.isEnabled = selectedMotorState == .empty
            return
        }

        doneButton.isEnabled = (selectedMotorState != .driveWithoutSide
            && !name.isEmpty)
            || selectedMotorState == .empty
    }
}

// MARK: - Actions
extension MotorConfigViewController {
    @IBAction private func testButtonTapped(_ sender: Any) {
        if bluetoothService.connectedDevice != nil {
            startPortTest()
            presentTestingModal()
        } else {
            shouldRunTestScriptOnConnection = true
            presentConnectModal()
        }
    }

    @IBAction private func doneButtonTapped(_ sender: Any) {
        guard selectedMotorState != .empty else {
            shouldCallDismiss = false
            doneButtonTapped?(MotorConfigViewModel(portName: nameInputField.text, state: selectedMotorState))
            return
        }
        guard let name = nameInputField.text, !name.isEmpty else {
            return
        }
        guard !prohibitedNames.contains(name) else {
            let alert = UIAlertController.errorAlert(type: .variableNameAlreadyInUse)
            present(alert, animated: true, completion: nil)
            return
        }
        shouldCallDismiss = false
        doneButtonTapped?(MotorConfigViewModel(portName: nameInputField.text, state: selectedMotorState))
    }

    @objc private func reverseSwitchTapped(_ sender: UISwitch) {
        handleRotationChange(to: sender.isOn ? .reversed : .forward)
    }
}

// MARK: - UISideMenuNavigationControllerDelegate
extension MotorConfigViewController: UISideMenuNavigationControllerDelegate {
    func sideMenuWillDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        if shouldCallDismiss {
            screenDismissed?()
        }
    }
}

// MARK: - Bluetooth connection
extension MotorConfigViewController {
    override func connected() {
        bluetoothService.stopDiscovery()
        dismiss(animated: true, completion: {
            self.presentConnectedModal(onCompleted: { [weak self] in
                guard let runTest = self?.shouldRunTestScriptOnConnection, runTest else { return }

                self?.shouldRunTestScriptOnConnection = false
                self?.startPortTest()
                self?.presentTestingModal()
            })
        })
    }

    private func presentConnectedModal(onCompleted callback: Callback?) {
        let connectionModal = ConnectionModalView.instatiate()
        presentModal(with: connectionModal.successful, closeHidden: true)

        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.presentedViewController?.dismiss(animated: true, completion: nil)
            callback?()
        }
    }
}
