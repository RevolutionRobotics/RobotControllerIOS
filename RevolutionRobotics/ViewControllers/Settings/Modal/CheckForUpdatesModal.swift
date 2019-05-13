//
//  CheckForUpdatesModal.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 13..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class CheckForUpdatesModal: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var checkForUpdatesButton: RRButton!
    @IBOutlet private weak var brainIDLabel: UILabel!
    @IBOutlet private weak var versionLabel: UILabel!
    @IBOutlet private weak var updateView: UIView!
    @IBOutlet private weak var updateLabel: UILabel!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!

    // MARK: - DevInfo
    @IBOutlet private weak var devInfoView: UIView!
    @IBOutlet private weak var label1: UILabel!
    @IBOutlet private weak var label2: UILabel!
    @IBOutlet private weak var label3: UILabel!
    @IBOutlet private weak var label4: UILabel!
    @IBOutlet private weak var label5: UILabel!
    @IBOutlet private weak var label6: UILabel!
    @IBOutlet private weak var label7: UILabel!
    @IBOutlet private weak var label8: UILabel!
    @IBOutlet private weak var label9: UILabel!
    @IBOutlet private weak var label10: UILabel!
}

// MARK: - View lifecycle
extension CheckForUpdatesModal {
    override func awakeFromNib() {
        super.awakeFromNib()

        if let environment = Bundle.main.infoDictionary?["Environment"] as? String, environment.contains("Dev") {
            devInfoView.isHidden = false
        }
        checkForUpdatesButton.setBorder(fillColor: .clear, strokeColor: .white)
        checkForUpdatesButton.setTitle(ModalKeys.FirmwareUpdate.checkForUpdates.translate(), for: .normal)
        checkForUpdatesButton.setImage(Image.retryIcon, for: .normal)
        brainIDLabel.text = ModalKeys.FirmwareUpdate.braindID.translate(args: "1231231231231")
        versionLabel.text = ModalKeys.FirmwareUpdate.currentVersion.translate(args: "3.1.6.7")
    }
}

// MARK: - Functions
extension CheckForUpdatesModal {
    func updateFound() {
        loadingIndicator.isHidden = true
        devInfoView.isHidden = true
        updateView.isHidden = false
        updateLabel.text = ModalKeys.FirmwareUpdate.downloadReady.translate(args: "3.2.0.0")
        checkForUpdatesButton.setTitle(ModalKeys.FirmwareUpdate.downloadUpdate.translate(), for: .normal)
        checkForUpdatesButton.setImage(Image.downloadIcon, for: .normal)
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

// MARK: - Event handler
extension CheckForUpdatesModal {
    @IBAction private func checkForUpdatesTapped(_ sender: Any) {
        loadingIndicator.isHidden = false
    }
}
