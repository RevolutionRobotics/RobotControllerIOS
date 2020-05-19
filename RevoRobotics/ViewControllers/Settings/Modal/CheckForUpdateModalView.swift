//
//  CheckForUpdatesModal.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 13..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class CheckForUpdateModalView: UIView {
    // MARK: - Status
    enum Status {
        case initial
        case updateNeeded(String)
        case updated
    }

    // MARK: - Outlets
    @IBOutlet private weak var button: RRButton!
    @IBOutlet private weak var buttonRename: RRButton!
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

    // MARK: - Callback
    var buttonHandler: CallbackType<Status>?
    var renameButtonHandler: CallbackType<String>?

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

    var status = Status.initial {
        didSet {
            handleStatusChange()
        }
    }
}

// MARK: - View lifecycle
extension CheckForUpdateModalView {
    override func awakeFromNib() {
        super.awakeFromNib()
        handleStatusChange()
    }
}

// MARK: - Public methods
extension CheckForUpdateModalView {
    private func handleStatusChange() {
        switch status {
        case .initial:
            button.setBorder(fillColor: .clear, strokeColor: .white)
            button.setTitle(ModalKeys.FirmwareUpdate.checkForUpdates.translate(), for: .normal)
            button.setImage(Image.retryIcon, for: .normal)
            brainIDLabel.text = ModalKeys.FirmwareUpdate.loading.translate()

            buttonRename.setBorder(fillColor: .clear, strokeColor: .white)
            buttonRename.setImage(Image.renameIcon, for: .normal)
            buttonRename.setTitle(FirmwareUpdateKeys.Modal.rename.translate(), for: .normal)

        case .updateNeeded(let version):
            loadingIndicator.isHidden = true
            devInfoView.isHidden = true
            updateView.isHidden = false
            updateLabel.text = ModalKeys.FirmwareUpdate.downloadReady.translate(args: version)
            button.setTitle(ModalKeys.FirmwareUpdate.downloadUpdate.translate(), for: .normal)
            button.setImage(Image.downloadIcon, for: .normal)

        case .updated:
            loadingIndicator.isHidden = true
            devInfoView.isHidden = true
            updateView.isHidden = false
            updateLabel.text = ModalKeys.FirmwareUpdate.upToDateVersion.translate()
            button.setTitle(ModalKeys.FirmwareUpdate.done.translate(), for: .normal)
            button.setImage(Image.tickIcon, for: .normal)
        }
    }
}

// MARK: - Actions
extension CheckForUpdateModalView {
    @IBAction private func buttonTapped(_ sender: RRButton) {
        buttonHandler?(status)
    }

    @IBAction private func renameButtonTapped(_ sender: Any) {
        renameButtonHandler?(brainId)
    }
}
