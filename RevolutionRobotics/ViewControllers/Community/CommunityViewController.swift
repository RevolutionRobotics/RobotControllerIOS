//
//  CommunityViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 13..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class CommunityViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var beginButton: RRButton!
}

// MARK: - View lifecycle
extension CommunityViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.bluetoothButtonState = bluetoothService.connectedDevice != nil ? .connected : .notConnected
        navigationBar.setup(title: CommunityKeys.title.translate(), delegate: self)
        beginButton.setTitle(CommunityKeys.beginButton.translate(), for: .normal)
        titleLabel.text = CommunityKeys.contentTitle.translate().uppercased()
        descriptionLabel.text = CommunityKeys.contentDescription.translate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        beginButton.setBorder(fillColor: .clear, strokeColor: .white)
    }
}

// MARK: - Actions
extension CommunityViewController {
    @IBAction private func beginButtonTapped(_ sender: Any) {
        openSafari(presentationFinished: nil)
    }
}

// MARK: - Bluetooth connection
extension CommunityViewController {
    override func connected() {
        super.connected()
        navigationBar.bluetoothButtonState = .connected
    }

    override func disconnected() {
        super.disconnected()
        navigationBar.bluetoothButtonState = .notConnected
    }
}
