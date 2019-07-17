//
//  FirmwareUpdateViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 13..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import os
import struct RevolutionRoboticsBluetooth.Device

final class FirmwareUpdateViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var newConnectionButton: SideButton!
    @IBOutlet private weak var connectedBrainView: UIView!
    @IBOutlet private weak var brainIDTitleLabel: UILabel!
    @IBOutlet private weak var brainImageView: UIImageView!
    @IBOutlet private weak var checkForUpdatesLabel: UILabel!

    // MARK: - Properties
    var firebaseService: FirebaseServiceInterface!
    private let checkForUpdatesModal = CheckForUpdateModalView.instatiate()
    private var currentFirmware: String = ""
    private var updateURL: String = ""
    private var updateVersion: String = ""
    private var writeInterrupted = false
}

// MARK: - View lifecycle
extension FirmwareUpdateViewController {
    // swiftlint:disable cyclomatic_complexity
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.bluetoothButtonState = bluetoothService.connectedDevice != nil ? .connected : .notConnected
        navigationBar.setup(title: SettingsKeys.Firmware.title.translate(), delegate: self)
        brainIDTitleLabel.text = ModalKeys.FirmwareUpdate.loading.translate()
        newConnectionButton.title = SettingsKeys.Firmware.newConnectionButton.translate()
        newConnectionButton.image = Image.Common.bluetoothWhiteIcon
        newConnectionButton.selectionHandler = { [weak self] in
            self?.presentConnectModal()
        }

        if bluetoothService.connectedDevice != nil {
            bluetoothService.getSystemId(onCompleted: { [weak self] result in
                switch result {
                case .success(let systemId):
                    self?.brainIDTitleLabel.text = systemId
                    self?.checkForUpdatesModal.brainId = systemId
                    self?.connectedBrainView.isHidden = false
                case .failure:
                    os_log("Error: Failed to fetch system ID from robot via bluetooth!")
                }
            })
        }

        checkForUpdatesModal.buttonHandler = { [weak self] status in
            switch status {
            case .initial:
                if Reachability.isConnectedToNetwork() {
                    self?.firebaseService.getFirmwareUpdate(completion: { result in
                        switch result {
                        case .success(let updates):
                            if self?.currentFirmware != updates.first?.fileName {
                                self?.checkForUpdatesModal.status = .updateNeeded((updates.first?.fileName)!)
                                self?.updateURL = (updates.first?.url)!
                                self?.updateVersion = (updates.first?.fileName)!
                            } else {
                                self?.checkForUpdatesModal.status = .updated
                            }
                        case .failure:
                            os_log("Error while getting firmware update!")
                        }
                    })
                } else {
                    self?.presentedViewController?.present(UIAlertController.errorAlert(type: .network), animated: true)

                }
            case .updateNeeded:
                self?.firebaseService.downloadFirmwareUpdate(
                    resourceURL: (self?.updateURL)!,
                    completion: { result in
                        switch result {
                        case .success(let data):
                            self?.uploadFramework(data: data)
                        case .failure:
                            os_log("Error while downloading firmware update!")
                        }
                })
            case .updated:
                self?.dismissModalViewController()
            }
        }
    }

    private func uploadFramework(data: Data) {
        dismiss(animated: true, completion: {
            let downloadView = UpdatingFirmwareModalView.instatiate()
            self.presentModal(
                with: downloadView,
                animated: true,
                closeHidden: false,
                onDismissed: { [weak self] in
                    self?.presentConfirmModal()
                },
                shouldDismissOnBackgroundTap: false)

            self.bluetoothService.updateFramework(
                data: data,
                version: self.updateVersion,
                onCompleted: { [weak self] result in
                    switch result {
                    case .success:
                        self?.dismissModalViewController()
                        if !(self?.writeInterrupted)! {
                            let successModalView = SuccessfulUpdateModalView.instatiate()
                            successModalView.doneCallback = { [weak self] in
                                self?.dismissModalViewController()
                            }
                            self?.presentModal(with: successModalView)
                        }
                    case .failure:
                        os_log("Error while sending firmware update to the robot!")
                    }
            })
        })
    }

    private func presentConfirmModal() {
        let confirmModal = ConfirmModalView.instatiate()
        confirmModal.setup(title: ModalKeys.FirmwareUpdate.frameworkStopConfirmTitle.translate().uppercased(),
                           subtitle: nil,
                           negativeButtonTitle: ModalKeys.FirmwareUpdate.frameworkStopConfirmNo.translate(),
                           positiveButtonTitle: ModalKeys.FirmwareUpdate.frameworkStopConfirmYes.translate())
        confirmModal.confirmSelected = { [weak self] positive in
            if positive {
                self?.writeInterrupted = true
                self?.bluetoothService.stopWrite()
            } else {
                self?.dismiss(animated: true, completion: {
                    let downloadView = UpdatingFirmwareModalView.instatiate()
                    self?.presentModal(
                        with: downloadView,
                        animated: true,
                        closeHidden: false,
                        onDismissed: { [weak self] in
                            self?.presentConfirmModal()
                        },
                        shouldDismissOnBackgroundTap: false)
                })
            }
        }
        presentModal(with: confirmModal,
                     animated: true,
                     closeHidden: true,
                     onDismissed: nil,
                     shouldDismissOnBackgroundTap: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIApplication.shared.isIdleTimerDisabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        UIApplication.shared.isIdleTimerDisabled = false
    }
}

// MARK: - Bluetooth connection
extension FirmwareUpdateViewController {
    override func connected() {
        navigationBar.bluetoothButtonState = .connected
        connectedBrainView.isHidden = false
        bluetoothService.stopDiscovery()
        dismissModalViewController()
        let connectionModal = ConnectionModalView.instatiate()
        presentModal(with: connectionModal.successful, closeHidden: true)

        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.dismissModalViewController()
            self?.bluetoothService.getSystemId(onCompleted: { [weak self] result in
                switch result {
                case .success(let systemId):
                    self?.brainIDTitleLabel.text = systemId
                    self?.checkForUpdatesModal.brainId = systemId
                case .failure:
                    os_log("Error: Failed to fetch system ID from robot via bluetooth!")
                }
            })
        }
    }

    override func disconnected() {
        super.disconnected()
        navigationBar.bluetoothButtonState = .notConnected
        connectedBrainView.isHidden = true
    }

    override func connectionError() {
        let connectionModal = ConnectionModalView.instatiate()
        dismissModalViewController()
        presentModal(with: connectionModal.failed)

        connectionModal.tryAgainButtonTapped = dismissAndTryAgain

        connectionModal.tipsButtonTapped = { [weak self] in
            self?.dismissModalViewController()
            let failedConnectionTipsModal = TipsModalView.instatiate()
            failedConnectionTipsModal.skipTitle = ModalKeys.Connection.failedConnectionSkipButton.translate()
            failedConnectionTipsModal.skipCallback = { [weak self] in
                self?.dismissModalViewController()
            }
            failedConnectionTipsModal.tryAgainCallback = self?.dismissAndTryAgain
            failedConnectionTipsModal.communityCallback = { [weak self] in
                self?.openSafari(presentationFinished: { [weak self] in
                    self?.dismissAndTryAgain()
                })
            }
            self?.presentModal(with: failedConnectionTipsModal)
        }
    }

    private func dismissAndTryAgain() {
        dismissModalViewController()
        presentConnectModal()
    }
}

// MARK: - Actions
extension FirmwareUpdateViewController {
    @IBAction private func checkForUpdatesButtonTapped(_ sender: Any) {
        getDeviceInfo()
        presentModal(with: checkForUpdatesModal)
    }
}

extension FirmwareUpdateViewController {
    private func getDeviceInfo() {
        getSerialNumber()
        getManufacturerName()
        getHardwareRevision()
        getSoftwareRevision()
        getModelNumber()
        getPrimaryBatteryPercentage()
        getMotorBatteryPercentage()
    }

    private func getSerialNumber() {
        bluetoothService.getSerialNumber(onCompleted: { [weak self] result in
            switch result {
            case .success(let serialNumber):
                self?.checkForUpdatesModal.serialNumber = serialNumber
            case .failure:
                os_log("Error: Failed to fetch serial number from robot via bluetooth!")
            }
        })
    }

    private func getManufacturerName() {
        bluetoothService.getManufacturerName(onCompleted: { [weak self] result in
            switch result {
            case .success(let manufacturerName):
                self?.checkForUpdatesModal.manufacturerName = manufacturerName
            case .failure:
                os_log("Error: Failed to fetch manufacturer name from robot via bluetooth!")
            }
        })
    }

    private func getHardwareRevision() {
        bluetoothService.getHardwareRevision(onCompleted: { [weak self] result in
            switch result {
            case .success(let hardwareRevision):
                self?.checkForUpdatesModal.hardwareVersion = hardwareRevision
            case .failure:
                os_log("Error: Failed to fetch hardware revision from robot via bluetooth!")
            }
        })
    }

    private func getSoftwareRevision() {
        bluetoothService.getSoftwareRevision(onCompleted: { [weak self] result in
            switch result {
            case .success(let softwareRevision):
                self?.checkForUpdatesModal.softwareVersion = softwareRevision
                self?.checkForUpdatesModal.firmwareVersion = softwareRevision
                self?.currentFirmware = softwareRevision
            case .failure:
                os_log("Error: Failed to fetch software revision from robot via bluetooth!")
            }
        })
    }

    private func getModelNumber() {
        bluetoothService.getModelNumber(onCompleted: { [weak self] result in
            switch result {
            case .success(let modelNumber):
                self?.checkForUpdatesModal.modelNumber = modelNumber
            case .failure:
                os_log("Error: Failed to fetch model number from robot via bluetooth!")
            }
        })
    }

    private func getPrimaryBatteryPercentage() {
        bluetoothService.getPrimaryBatteryPercentage(onCompleted: { [weak self] result in
            switch result {
            case .success(let percentage):
                self?.checkForUpdatesModal.mainBattery = percentage
            case .failure:
                os_log("Error: Failed to fetch primary battery percentage from robot via bluetooth!")
            }
        })
    }

    private func getMotorBatteryPercentage() {
        bluetoothService.getMotorBatteryPercentage(onCompleted: { [weak self] result in
            switch result {
            case .success(let percentage):
                self?.checkForUpdatesModal.motorBattery = percentage
            case .failure:
                os_log("Error: Failed to fetch motor battery percentage from robot via bluetooth!")
            }
        })
    }
}
