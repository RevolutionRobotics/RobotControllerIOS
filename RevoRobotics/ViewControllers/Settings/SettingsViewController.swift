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
    @IBOutlet private weak var serverLocationButton: RRButton!

    // MARK: - Properties
    private let defaults = UserDefaults.standard
    private let keys = UserDefaults.Keys.self

    override func backButtonDidTap() {
        let navController = navigationController
        navController?.popViewController(animated: true, completion: { [weak self] in
            guard let `self` = self,
                self.defaults.bool(forKey: self.keys.buildRevvyPromptVisited) != true
            else { return }

            let onboarding = AppContainer.shared.container.unwrappedResolve(BuildRevvyViewController.self)
            navController?.pushViewController(onboarding, animated: true)
        })
    }
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

        [
            firmwareButton,
            resetButton,
            aboutButton,
            serverLocationButton
        ]
        .forEach({ $0?.setBorder(fillColor: .clear, strokeColor: .white) })

        let selectedLocation = Locale.current.userRegion == Locale.Server.asia.rawValue
            ? SettingsKeys.Modal.serverLocationChina
            : SettingsKeys.Modal.serverLocationGlobal

        firmwareButton.setTitle(SettingsKeys.Main.firmwareUpdate.translate(), for: .normal)
        resetButton.setTitle(SettingsKeys.Main.resetTutorial.translate(), for: .normal)
        aboutButton.setTitle(SettingsKeys.Main.aboutApplication.translate(), for: .normal)
        serverLocationButton.setTitle(
            SettingsKeys.Main.serverLocation.translate(args: selectedLocation.translate()),
            for: .normal)
    }
}

// MARK: - Actions
extension SettingsViewController {
    @IBAction private func resetButtonTapped(_ sender: Any) {
        let modal = ResetTutorialModalView.instatiate()
        modal.setup(with: SettingsKeys.Tutorial.successfulReset.translate().uppercased())
        presentModal(with: modal, closeHidden: true)

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

    @IBAction private func serverLocationTapped(_ sender: Any) {
        let serverLocationModal = ServerSelectionModalView.instatiate()
        var userSelectedRegion = false

        serverLocationModal.setup()
        serverLocationModal.callback = { [weak self] location in
            guard let `self` = self else { return }
            userSelectedRegion = true
            let selectedLocation = location == Locale.Server.asia.rawValue
                ? SettingsKeys.Modal.serverLocationChina
                : SettingsKeys.Modal.serverLocationGlobal

            self.defaults.set(location, forKey: UserDefaults.Keys.selectedServer)
            self.serverLocationButton.setTitle(
                SettingsKeys.Main.serverLocation.translate(args: selectedLocation.translate()),
                for: .normal)
            self.dismissModalViewController()
        }

        presentModal(with: serverLocationModal, onDismissed: { [weak self] in
            guard userSelectedRegion else { return }
            self?.showUpdatedAlert()
        })
    }
}

// MARK: Private methods
extension SettingsViewController {
    private func showUpdatedAlert() {
        let alertController = UIAlertController(title: SettingsKeys.Modal.alertUpdatedTitle.translate(),
                                                message: SettingsKeys.Modal.alertUpdatedText.translate(),
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: CommonKeys.errorOk.translate(), style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true)
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
