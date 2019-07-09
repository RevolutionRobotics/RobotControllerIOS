//
//  CheckForUpdatesModal.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 13..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class CheckForUpdateModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var checkForUpdatesButton: RRButton!
    @IBOutlet private weak var brainIDLabel: UILabel!
    @IBOutlet private weak var versionLabel: UILabel!
    @IBOutlet private weak var updateView: UIView!
    @IBOutlet private weak var updateLabel: UILabel!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var devInfoView: UIView!

    @IBOutlet private weak var hardwareVersionLabel: UILabel!
    @IBOutlet private weak var modelNumberLabel: UILabel!
    @IBOutlet private weak var softwareVersionLabel: UILabel!
    @IBOutlet private weak var serialNumberLabel: UILabel!
    @IBOutlet private weak var manufacturerNameLabel: UILabel!
    @IBOutlet private weak var mainBatteryLabel: UILabel!
    @IBOutlet private weak var motorBatteryLabel: UILabel!

    var checkForUpdateCallback: Callback?
    var downloadAndUpdataCallback: Callback?

    private var foundUpdate = false

    // MARK: - Properties
    var brainId: String = "" {
        didSet {
            brainIDLabel.text = brainId
        }
    }
    var firmwareVersion: String = "" {
        didSet {
            versionLabel.text = ModalKeys.FirmwareUpdate.currentVersion.translate(args: firmwareVersion)
        }
    }
    var hardwareVersion: String = "" {
        didSet {
            hardwareVersionLabel.text = ModalKeys.FirmwareUpdate.hardwareVersion.translate(args: hardwareVersion)
        }
    }
    var modelNumber: String = "" {
        didSet {
            modelNumberLabel.text = ModalKeys.FirmwareUpdate.modelNumber.translate(args: modelNumber)
        }
    }
    var softwareVersion: String = "" {
        didSet {
            softwareVersionLabel.text = ModalKeys.FirmwareUpdate.softwareVersion.translate(args: softwareVersion)
        }
    }
    var serialNumber: String = "" {
        didSet {
            serialNumberLabel.text = ModalKeys.FirmwareUpdate.serialNumber.translate(args: serialNumber)
        }
    }
    var manufacturerName: String = "" {
        didSet {
            manufacturerNameLabel.text = ModalKeys.FirmwareUpdate.manufacturerName.translate(args: manufacturerName)
        }
    }
    var mainBattery: Int = 0 {
        didSet {
            mainBatteryLabel.text = ModalKeys.FirmwareUpdate.mainBattery.translate(args: "\(mainBattery)")
        }
    }
    var motorBattery: Int = 0 {
        didSet {
            motorBatteryLabel.text = ModalKeys.FirmwareUpdate.motorBattery.translate(args: "\(motorBattery)")
        }
    }
}

// MARK: - View lifecycle
extension CheckForUpdateModalView {
    override func awakeFromNib() {
        super.awakeFromNib()

        checkForUpdatesButton.setBorder(fillColor: .clear, strokeColor: .white)
        checkForUpdatesButton.setTitle(ModalKeys.FirmwareUpdate.checkForUpdates.translate(), for: .normal)
        checkForUpdatesButton.setImage(Image.retryIcon, for: .normal)
        brainIDLabel.text = ModalKeys.FirmwareUpdate.loading.translate()
    }
}

// MARK: - Public methods
extension CheckForUpdateModalView {
    func updateFound(version: String) {
        loadingIndicator.isHidden = true
        devInfoView.isHidden = true
        updateView.isHidden = false
        updateLabel.text = ModalKeys.FirmwareUpdate.downloadReady.translate(args: version)
        checkForUpdatesButton.setTitle(ModalKeys.FirmwareUpdate.downloadUpdate.translate(), for: .normal)
        checkForUpdatesButton.setImage(Image.downloadIcon, for: .normal)
        foundUpdate = true
    }

    func upToDate() {
        loadingIndicator.isHidden = true
        devInfoView.isHidden = true
        updateView.isHidden = false
        updateLabel.text = ModalKeys.FirmwareUpdate.upToDate.translate()
        checkForUpdatesButton.setTitle(ModalKeys.FirmwareUpdate.done.translate(), for: .normal)
        checkForUpdatesButton.setImage(Image.tickIcon, for: .normal)
    }
}

// MARK: - Actions
extension CheckForUpdateModalView {
    @IBAction private func checkForUpdatesTapped(_ sender: Any) {
        if foundUpdate {
            loadingIndicator.isHidden = true
            downloadAndUpdataCallback?()
        } else {
            loadingIndicator.isHidden = false
            checkForUpdateCallback?()
        }
    }
}
