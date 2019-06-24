//
//  SensorViewController.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 30..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import SideMenu
import os

final class SensorConfigViewController: BaseViewController {
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
    var selectedSensorType: SensorConfigViewModelType = .empty {
        didSet {
            if isViewLoaded {
                handleSelectionChange()
                validateActionButtons()
            }
        }
    }

    var portNumber = 0
    var doneButtonTapped: CallbackType<SensorConfigViewModel>?
    var testButtonTapped: CallbackType<SensorConfigViewModel>?
    var screenDismissed: Callback?
    var name: String?
    var prohibitedNames: [String] = []
    var bluetoothService: BluetoothServiceInterface!
    var testCodeService: PortTestCodeServiceInterface!

    private var shouldCallDismiss = true
    private var shouldStartTestProcess = false

    private var sensorPortNumber: Int {
        return portNumber - 6
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupButtonRow()
        setupNameInputField()
        handleSelectionChange()
        validateActionButtons()
        nameInputField.text = name
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupActionButtons()
    }

    override func connected() {
        super.connected()
        if shouldStartTestProcess {
            shouldStartTestProcess = false
            startPortTest()
        }
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
                self?.selectedSensorType = .ultrasonic
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
        ultrasoundButton.set(selected: selectedSensorType == .ultrasonic)
    }

    private func validateActionButtons() {
        testButton.isEnabled = selectedSensorType != .empty
    }

    private func presentTestingModal() {
        let modal = TestingModal.instatiate()
        modal.positiveButtonTapped = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        modal.negativeButtonTapped = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        presentModal(with: modal)
    }

    private func startPortTest() {
        let isBumperType = selectedSensorType == .bumper
        let testCode = isBumperType ?
            testCodeService.bumperTestCode(for: sensorPortNumber) :
            testCodeService.ultrasonicTestCode(for: sensorPortNumber)

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
}

// MARK: - Actions
extension SensorConfigViewController {
    @IBAction private func testButtonTapped(_ sender: Any) {
        if bluetoothService.connectedDevice != nil {
            startPortTest()
            presentTestingModal()
        } else {
            shouldStartTestProcess = true
            presentConnectModal()
        }
    }

    @IBAction private func doneButtonTapped(_ sender: Any) {
        guard selectedSensorType != .empty else {
            shouldCallDismiss = false
            doneButtonTapped?(SensorConfigViewModel(portName: nameInputField.text, type: selectedSensorType))
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
        doneButtonTapped?(SensorConfigViewModel(portName: nameInputField.text, type: selectedSensorType))
    }
}

// MARK: - UISideMenuNavigationControllerDelegate
extension SensorConfigViewController: UISideMenuNavigationControllerDelegate {
    func sideMenuWillDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        if shouldCallDismiss {
            screenDismissed?()
        }
    }
}
