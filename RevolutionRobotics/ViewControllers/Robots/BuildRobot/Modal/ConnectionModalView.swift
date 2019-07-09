//
//  ConnectionModalView.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 25..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ConnectionModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var connectionStatusImageView: UIImageView!
    @IBOutlet private weak var connectionStatusLabel: UILabel!
    @IBOutlet private weak var failView: UIView!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var skipConnectionButton: RRButton!
    @IBOutlet private weak var tipsButton: RRButton!
    @IBOutlet private weak var tryAgainButton: RRButton!

    // MARK: - Properties
    var tryAgainButtonTapped: Callback?
    var tipsButtonTapped: Callback?
    var skipConnectionButtonTapped: Callback?

    var successful: ConnectionModalView {
        failView.removeFromSuperview()
        connectionStatusImageView.image = Image.Common.connectionSuccessful
        connectionStatusLabel.text = ModalKeys.Connection.successfulConnectionTitle.translate().uppercased()

        return self
    }

    var failed: ConnectionModalView {
        skipConnectionButton.setBorder(fillColor: .clear, strokeColor: .clear, croppedCorners: [.bottomLeft])
        skipConnectionButton.setTitle(ModalKeys.Connection.failedConnectionSkipButton.translate(), for: .normal)

        tipsButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [])
        tipsButton.setTitle(ModalKeys.Connection.failedConnectionTipsButton.translate(), for: .normal)

        tryAgainButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
        tryAgainButton.setTitle(ModalKeys.Connection.failedConnectionTryAgainButton.translate(), for: .normal)

        subtitleLabel.text = ModalKeys.Connection.failedConnectionSubtitle.translate().uppercased()
        connectionStatusImageView.image = Image.Common.connectionFailed
        connectionStatusLabel.text = ModalKeys.Connection.failedConnectionTitle.translate().uppercased()

        return self
    }
}

// MARK: - Actions
extension ConnectionModalView {
    @IBAction private func tryAgainButtonTapped(_ sender: Any) {
        tryAgainButtonTapped?()
    }

    @IBAction private func tipsButtonTapped(_ sender: Any) {
        tipsButtonTapped?()
    }

    @IBAction private func skipConnectionButtonTapped(_ sender: Any) {
        skipConnectionButtonTapped?()
    }
}
