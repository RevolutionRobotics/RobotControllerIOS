//
//  ServerSelectionModalView.swift
//  RevoRobotics
//
//  Created by Pável Áron on 2020. 05. 19..
//  Copyright © 2020. Revolution Robotics. All rights reserved.
//

import UIKit

final class ServerSelectionModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var globalButton: RRButton!
    @IBOutlet private weak var chinaButton: RRButton!

    // MARK: - Properties
    var callback: CallbackType<String>?

    func setup() {
        let selectedRegion = Locale.current.userRegion

        titleLabel.text = SettingsKeys.Modal.serverLocationTitle.translate().uppercased()
        globalButton.setBorder(fillColor: .clear, strokeColor: selectedRegion == Locale.Server.global.rawValue
            ? .red : .white)
        chinaButton.setBorder(fillColor: .clear, strokeColor: selectedRegion == Locale.Server.asia.rawValue
            ? .red : .white)

        chinaButton.setTitleColor(
            selectedRegion == Locale.Server.asia.rawValue ? .red : .white,
            for: .normal)
        globalButton.setTitleColor(
            selectedRegion == Locale.Server.global.rawValue ? .red : .white,
            for: .normal)
    }
}

// MARK: - Actions
extension ServerSelectionModalView {
    @IBAction private func chinaSelected(_ sender: Any) {
        callback?(Locale.Server.asia.rawValue)
    }

    @IBAction private func globalSelected(_ sender: Any) {
        callback?(Locale.Server.global.rawValue)
    }
}
