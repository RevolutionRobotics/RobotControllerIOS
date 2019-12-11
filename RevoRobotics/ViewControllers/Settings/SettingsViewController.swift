//
//  SettingsViewController.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class SettingsViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var resetButton: RRButton!
    @IBOutlet private weak var firmwareButton: RRButton!
    @IBOutlet private weak var aboutButton: RRButton!
}

// MARK: - View lifecycle
extension SettingsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: SettingsKeys.Main.title.translate(), delegate: self)
        navigationBar.bluetoothButtonState = bluetoothService.connectedDevice != nil ? .connected : .notConnected
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        firmwareButton.setBorder(fillColor: .clear, strokeColor: .white)
        resetButton.setBorder(fillColor: .clear, strokeColor: .white)
        aboutButton.setBorder(fillColor: .clear, strokeColor: .white)
        firmwareButton.setTitle(SettingsKeys.Main.firmwareUpdate.translate(), for: .normal)
        resetButton.setTitle(SettingsKeys.Main.resetTutorial.translate(), for: .normal)
        aboutButton.setTitle(SettingsKeys.Main.aboutApplication.translate(), for: .normal)
    }
}

// MARK: - Actions
extension SettingsViewController {
    @IBAction private func resetButtonTapped(_ sender: Any) {
        let modal = ResetTutorialModalView.instatiate()
        modal.setup(with: SettingsKeys.Tutorial.successfulReset.translate().uppercased())
        presentModal(with: modal, closeHidden: true)
        let defaults = UserDefaults.standard
        let keys = UserDefaults.Keys.self

        defaults.set(false, forKey: keys.userPropertiesSet)
        defaults.set(false, forKey: keys.buildRevvyPromptVisited)
        defaults.set(false, forKey: keys.revvyBuilt)

        logEvent(named: "reset_tutorial")
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.dismissModalViewController()
        }
    }

    @IBAction private func firmwareButtonTapped(_ sender: Any) {
        let firmwareViewController = AppContainer.shared.container.unwrappedResolve(FirmwareUpdateViewController.self)
        navigationController?.pushViewController(firmwareViewController, animated: true)
    }

    @IBAction private func aboutButtonTapped(_ sender: Any) {
        let aboutViewController = AppContainer.shared.container.unwrappedResolve(AboutViewController.self)
        navigationController?.pushViewController(aboutViewController, animated: true)
    }
}

// MARK: - Bluetooth connection
extension SettingsViewController {
    override func connected() {
        super.connected()
        navigationBar.bluetoothButtonState = .connected
    }

    override func disconnected() {
        super.disconnected()
        navigationBar.bluetoothButtonState = .notConnected
    }
}
