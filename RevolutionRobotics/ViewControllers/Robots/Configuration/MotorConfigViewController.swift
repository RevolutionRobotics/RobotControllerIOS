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
    var selectedMotorState: MotorConfigViewModelState = .empty {
        didSet {
            if isViewLoaded {
                switchTo(state: selectedMotorState)
                validateActionButtons()
            }
        }
    }

    var portNumber = 0
    var numberOfDrivetrains = 0
    var doneButtonTapped: CallbackType<MotorConfigViewModel>?
    var testButtonTapped: CallbackType<MotorConfigViewModel>?
    var screenDismissed: Callback?
    var name: String?
    var prohibitedNames: [String] = []
    var bluetoothService: BluetoothServiceInterface!
    var testCodeService: PortTestCodeServiceInterface!

    private var shouldCallDismiss = true
    private var shouldRunTestScriptOnConnection = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTopButtonRow()
        setupRotationButtons()
        setupSideButtons()
        setupNameInputField()
        validateActionButtons()
        switchTo(state: selectedMotorState)

        nameInputField.text = name
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        subscribeForConnectionChange()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromConnectionChange()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupActionButtons()
    }

    override func connected() {
        presentConnectedModal(onCompleted: { [weak self] in
            guard let runTest = self?.shouldRunTestScriptOnConnection, runTest else { return }

            self?.shouldRunTestScriptOnConnection = false
            self?.startPortTest()
            self?.presentTestingModal()
        })
    }

    private func presentConnectedModal(onCompleted callback: Callback?) {
        let connectionModal = ConnectionModal.instatiate()
        presentModal(with: connectionModal.successful)

        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.presentedViewController?.dismiss(animated: true, completion: nil)
            callback?()
        }
    }
}

// MARK: - State change
extension MotorConfigViewController {
    private func switchTo(state: MotorConfigViewModelState) {
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
        nameInputField.text = name
        emptyButton.set(selected: true)
        middleButtonContainer.isHidden = true
        bottomButtonContainer.isHidden = true
    }

    private func switchToDrivetrainWithoutSideState() {
        resetButtons()
        nameInputField.text = name ??
            RobotsKeys.Configure.Motor.drivetrainButton.translate() + String(numberOfDrivetrains + 1)
        drivetrainButton.set(selected: true)
        middleButtonContainer.removeAllArrangedSubviews()
        middleButtonContainer.addArrangedSubview(leftButton)
        middleButtonContainer.addArrangedSubview(rightButton)
        middleButtonContainer.isHidden = false
        bottomButtonContainer.isHidden = true
    }

    private func switchToDrivetrainState(side: Side, rotation: Rotation) {
        drivetrainButton.set(selected: true)
        middleButtonContainer.isHidden = false
        if !middleButtonContainer.arrangedSubviews.contains(leftButton) {
            middleButtonContainer.addArrangedSubview(leftButton)
            middleButtonContainer.addArrangedSubview(rightButton)
        }
        bottomButtonContainer.addArrangedSubview(counterclockwiseButton)
        bottomButtonContainer.addArrangedSubview(clockwiseButton)
        bottomButtonContainer.isHidden = false
        leftButton.set(selected: side == .left)
        rightButton.set(selected: side == .right)
        clockwiseButton.set(selected: rotation == .clockwise)
        counterclockwiseButton.set(selected: rotation == .counterclockwise)
    }

    private func switchToMotorWithoutRotationState() {
        resetButtons()
        nameInputField.text = name
        motorButton.set(selected: true)
        middleButtonContainer.removeAllArrangedSubviews()
        middleButtonContainer.addArrangedSubview(counterclockwiseButton)
        middleButtonContainer.addArrangedSubview(clockwiseButton)
        middleButtonContainer.isHidden = false
        bottomButtonContainer.isHidden = true
    }

    private func switchToMotorState(rotation: Rotation) {
        motorButton.set(selected: true)
        middleButtonContainer.isHidden = false
        if !middleButtonContainer.arrangedSubviews.contains(clockwiseButton) {
            middleButtonContainer.addArrangedSubview(counterclockwiseButton)
            middleButtonContainer.addArrangedSubview(clockwiseButton)
        }
        clockwiseButton.set(selected: rotation == .clockwise)
        counterclockwiseButton.set(selected: rotation == .counterclockwise)
    }
}

// MARK: - Setup
extension MotorConfigViewController {
    private func setupNameInputField() {
        nameInputField.setup(title: RobotsKeys.Configure.Motor.nameInputfield.translate(args: "M\(portNumber)"))
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

        drivetrainButton.configure(options: PortConfigurationItemView.Options(
            title: RobotsKeys.Configure.Motor.drivetrainButton.translate(),
            selectedImage: Image.Configure.drivetrainSelected,
            unselectedImage: Image.Configure.drivetrainUnselected) { [weak self] in
                self?.selectedMotorState = .drivetrainWithoutSide
            }
        )
        topButtonContainer.addArrangedSubview(drivetrainButton)

        motorButton.configure(options: PortConfigurationItemView.Options(
            title: RobotsKeys.Configure.Motor.motorButton.translate(),
            selectedImage: Image.Configure.motorSelected,
            unselectedImage: Image.Configure.motorUnselected) { [weak self] in
                self?.selectedMotorState = .motorWithoutRotation
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
        case .drivetrain(let side, _):
            selectedMotorState = .drivetrain(side, rotation)
        default: return
        }
    }

    private func handleSideChange(to side: Side) {
        switch selectedMotorState {
        case .drivetrainWithoutSide:
            selectedMotorState = .drivetrain(side, side == .left ? .counterclockwise : .clockwise)
        case .drivetrain(_, let rotation):
            selectedMotorState = .drivetrain(side, rotation)
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

    private func presentTestingModal() {
        let modal = TestingModal.instatiate()
        switch selectedMotorState {
        case .motor:
            modal.setup(with: .motor)
        case .drivetrain:
            modal.setup(with: .drivetrain)
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
        case .drivetrain(let side, let rotation):
            testCode = testCodeService.drivatrainTestCode(for: portNumber, direction: rotation, side: side)
        default: break
        }

        bluetoothService.testKit(data: testCode, onCompleted: nil)
    }

    private func presentConnectModal() {
        let modalPresenter = BluetoothConnectionModalPresenter()
        modalPresenter.present(
            on: self,
            startDiscoveryHandler: { [weak self] in
                self?.bluetoothService.startDiscovery(onScanResult: { result in
                    switch result {
                    case .success(let devices):
                        modalPresenter.discoveredDevices = devices
                    case .failure:
                        os_log("Error: Failed to discover peripherals!")
                    }
                })

            },
            deviceSelectionHandler: { [weak self] device in
                self?.bluetoothService.connect(to: device)
            },
            nextStep: nil)
    }

    private func presentTipsModal() {
        let tips = TipsModalView.instatiate()
        tips.title = ModalKeys.Tips.title.translate()
        tips.subtitle = ModalKeys.Tips.subtitle.translate()
        tips.tips = "Lorem ipsum dolor sit amet, eu commodo numquam comprehensam vel. Quo cu alia placerat."
        tips.skipTitle = ModalKeys.Tips.reconfigure.translate()
        tips.communityTitle = ModalKeys.Tips.community.translate()
        tips.tryAgainTitle = ModalKeys.Tips.tryAgin.translate()
        tips.skipIcon = Image.Configure.reconfigure

        tips.communityCallback = { [weak self] in
            self?.presentSafariModal(presentationFinished: nil)
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
        testButton.isEnabled = selectedMotorState != .empty &&
            selectedMotorState != .drivetrainWithoutSide &&
            selectedMotorState != .motorWithoutRotation
        doneButton.isEnabled = selectedMotorState != .drivetrainWithoutSide &&
            selectedMotorState != .motorWithoutRotation
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
            let alert = UIAlertController.errorAlert(type: .variableNameEmpty)
            present(alert, animated: true, completion: nil)
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
}

// MARK: - UISideMenuNavigationControllerDelegate
extension MotorConfigViewController: UISideMenuNavigationControllerDelegate {
    func sideMenuWillDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        if shouldCallDismiss {
            screenDismissed?()
        }
    }
}
