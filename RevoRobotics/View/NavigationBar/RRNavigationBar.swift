//
//  RRNavigationBar.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

enum BluetoothButtonState {
    case connected
    case notConnected
}

protocol RRNavigationBarDelegate: class {
    func backButtonDidTap()
    func popToRootViewController(animated: Bool)
    func bluetoothButtonTapped()
}

final class RRNavigationBar: RRCustomView {
    // MARK: - Outlets
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var bluetoothButton: RRButton!

    // MARK: - Properties
    var shouldHideBackButton: Bool = false {
        didSet {
            backButton.isHidden = shouldHideBackButton
        }
    }
    var bluetoothButtonState: BluetoothButtonState = .notConnected {
        didSet {
            switch bluetoothButtonState {
            case .connected:
                bluetoothButton.setImage(Image.Common.bluetoothIcon, for: .normal)
            case .notConnected:
                bluetoothButton.setImage(Image.Common.bluetoothInactiveIcon, for: .normal)
            }
        }
    }

    private weak var delegate: RRNavigationBarDelegate? = nil {
        didSet {
            backButton.isHidden = delegate == nil
        }
    }
}

// MARK: - Setup
extension RRNavigationBar {
    func setup(title: String? = nil, delegate: RRNavigationBarDelegate? = nil) {
        titleLabel.text = title
        self.delegate = delegate
    }
}

// MARK: - Actions
extension RRNavigationBar {
    @IBAction private func backButtonTapped(_ sender: Any) {
        delegate?.backButtonDidTap()
    }

    @IBAction private func bluetoothButtonTapped(_ sender: Any) {
        delegate?.bluetoothButtonTapped()
    }
}
