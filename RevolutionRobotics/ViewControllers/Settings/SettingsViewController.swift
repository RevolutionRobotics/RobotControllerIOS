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

// MARK: - Event handlers
extension SettingsViewController {
    @IBAction private func resetButtonTapped(_ sender: Any) {
    }

    @IBAction private func firmwareButtonTapped(_ sender: Any) {
    }

    @IBAction private func aboutButtonTapped(_ sender: Any) {
    }
}
