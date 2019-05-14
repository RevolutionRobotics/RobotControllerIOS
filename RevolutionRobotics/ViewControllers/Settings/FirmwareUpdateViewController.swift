//
//  FirmwareUpdateViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 13..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import RevolutionRoboticsBluetooth

final class FirmwareUpdateViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var newConnectionButton: SideButton!
    @IBOutlet private weak var connectedBrainView: UIView!
    @IBOutlet private weak var brainIDTitleLabel: UILabel!
    @IBOutlet private weak var brainIDLabel: UILabel!
    @IBOutlet private weak var brainImageView: UIImageView!
    @IBOutlet private weak var checkForUpdatesLabel: UILabel!

    // MARK: - Variables
    private let discoverer: RoboticsDeviceDiscovererInterface = RoboticsDeviceDiscoverer()
    private let connector: RoboticsDeviceConnectorInterface = RoboticsDeviceConnector()
}

// MARK: - View lifecycle
extension FirmwareUpdateViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: SettingsKeys.Firmware.title.translate(), delegate: self)
        newConnectionButton.title = SettingsKeys.Firmware.newConnectionButton.translate()
        newConnectionButton.image = Image.Common.bluetoothWhiteIcon
        newConnectionButton.selectionHandler = { [weak self] in
            self?.showTurnOnTheBrain()
        }
    }
}

// MARK: - Functions
extension FirmwareUpdateViewController {
    private func showTurnOnTheBrain() {
        let turnOnModal = TurnOnBrainView.instatiate()
        turnOnModal.setup(laterHidden: true)
        setupTipsHandler(on: turnOnModal)
        setupStartDiscoveryHandler(on: turnOnModal)
        presentModal(with: turnOnModal)
    }

    private func setupTipsHandler(on modal: TurnOnBrainView) {
        modal.tipsHandler = { [weak self] in
            self?.showTipsModal()
        }
    }

    private func showTipsModal() {
        self.dismiss(animated: true, completion: {
            let tips = TipsModalView.instatiate()
            tips.isSkipButtonHidden = true
            tips.title = ModalKeys.Tips.title.translate()
            tips.subtitle = ModalKeys.Tips.subtitle.translate()
            tips.tips = "Lorem ipsum dolor sit amet, eu commodo numquam comprehensam vel. Quo cu alia placerat."
            tips.communityTitle = ModalKeys.Tips.community.translate()
            tips.tryAgainTitle = ModalKeys.Tips.tryAgin.translate()
            tips.tryAgainCallback = { [weak self] in
                self?.dismiss(animated: true, completion: {
                    self?.showTurnOnTheBrain()
                })
            }
            tips.communityCallback = { [weak self] in
                self?.presentSafariModal(presentationFinished: { [weak self] in
                    self?.showTurnOnTheBrain()
                })
            }
            self.presentModal(with: tips)
        })
    }

    private func setupStartDiscoveryHandler(on modal: TurnOnBrainView) {
        modal.startHandler = { [weak self] in
            self?.dismiss(animated: true, completion: {
                self?.showBluetoothDiscovery()
            })
        }
    }

    private func showBluetoothDiscovery() {
        let bluetoothDiscovery = AvailableRobotsView.instatiate()
        bluetoothDiscovery.selectionHandler = onDeviceSelected
        presentModal(with: bluetoothDiscovery)

        discoverer.discoverRobots(
            onScanResult: { devices in
                bluetoothDiscovery.discoveredDevices = devices
        },
            onError: { error in
                print(error.localizedDescription)
        })
    }
}

// MARK: - Connection
extension FirmwareUpdateViewController {
    private func onDeviceSelected(_ device: Device) {
        connectedBrainView.isHidden = false
        brainIDLabel.text = device.id
        connector.connect(
            to: device,
            onConnected: onSelectedDeviceConnected,
            onDisconnected: onSelectedDeviceDisconnected,
            onError: onSelectedDeviceConnectionError
        )
    }

    private func onSelectedDeviceConnected() {
        dismissViewController()
        let connectionModal = ConnectionModal.instatiate()
        presentModal(with: connectionModal.successful)

        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.dismissViewController()
        }
    }

    private func onSelectedDeviceDisconnected() {
        print("Disconnected")
    }

    private func onSelectedDeviceConnectionError(_ error: Error) {
        let connectionModal = ConnectionModal.instatiate()
        dismissViewController()
        presentModal(with: connectionModal.failed)

        connectionModal.tryAgainButtonTapped = dismissAndTryAgain

        connectionModal.tipsButtonTapped = { [weak self] in
            self?.dismissViewController()
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
        dismissViewController()
        showBluetoothDiscovery()
    }
}

// MARK: - Event handlers
extension FirmwareUpdateViewController {
    @IBAction private func checkForUpdatesButtonTapped(_ sender: Any) {
    }
}
