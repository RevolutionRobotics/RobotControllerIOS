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
    var bluetoothService: BluetoothServiceInterface!
    private let checkForUpdatesModal = CheckForUpdatesModal.instatiate()
}

// MARK: - View lifecycle
extension FirmwareUpdateViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: SettingsKeys.Firmware.title.translate(), delegate: self)
        brainIDTitleLabel.text = ModalKeys.FirmwareUpdate.loading.translate()
        newConnectionButton.title = SettingsKeys.Firmware.newConnectionButton.translate()
        newConnectionButton.image = Image.Common.bluetoothWhiteIcon
        newConnectionButton.selectionHandler = { [weak self] in
            self?.showTurnOnTheBrain()
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        subscribeForConnectionChange()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        unsubscribeFromConnectionChange()
    }
}

// MARK: - Functions
extension FirmwareUpdateViewController {
    private func showTurnOnTheBrain() {
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
                self?.connectedBrainView.isHidden = false
                self?.bluetoothService.connect(to: device)
            },
            nextStep: nil)
    }
}

// MARK: - Connection
extension FirmwareUpdateViewController {
    override func connected() {
        dismissModalViewController()
        let connectionModal = ConnectionModal.instatiate()
        presentModal(with: connectionModal.successful)

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
        os_log("Info: Disconnected from robot!")
    }

    override func connectionError() {
        let connectionModal = ConnectionModal.instatiate()
        dismissModalViewController()
        presentModal(with: connectionModal.failed)

        connectionModal.tryAgainButtonTapped = dismissAndTryAgain

        connectionModal.tipsButtonTapped = { [weak self] in
            self?.dismissModalViewController()
            let failedConnectionTipsModal = TipsModalView.instatiate()
            failedConnectionTipsModal.isSkipButtonHidden = true
            failedConnectionTipsModal.tryAgainCallback = self?.dismissAndTryAgain
            failedConnectionTipsModal.communityCallback = { [weak self] in
                self?.presentSafariModal(presentationFinished: { [weak self] in
                    self?.dismissAndTryAgain()
                })
            }
            self?.presentModal(with: failedConnectionTipsModal)
        }
    }

    private func dismissAndTryAgain() {
        dismissModalViewController()
        showTurnOnTheBrain()
    }
}

// MARK: - Event handlers
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
