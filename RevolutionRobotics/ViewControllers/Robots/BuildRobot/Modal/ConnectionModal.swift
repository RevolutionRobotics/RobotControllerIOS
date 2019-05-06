//
//  ConnectionModal.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 25..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ConnectionModal: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var connectionStatusImageView: UIImageView!
    @IBOutlet private weak var connectionStatusLabel: UILabel!
    @IBOutlet private weak var failView: UIView!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var skipConnectionButton: RRButton!
    @IBOutlet private weak var tipsButton: RRButton!
    @IBOutlet private weak var tryAgainButton: RRButton!

    // MARK: - Callbacks
    var tryAgainButtonTapped: Callback?
    var tipsButtonTapped: Callback?
    var skipConnectionButtonTapped: Callback?
}

// MARK: - View lifecycle
extension ConnectionModal {
    override func awakeFromNib() {
        super.awakeFromNib()

        skipConnectionButton.setBorder(fillColor: Color.black26,
                                       strokeColor: .clear,
                                       croppedCorners: [.bottomLeft])
        skipConnectionButton.setTitle(RobotsKeys.Common.failedConnectionSkipButton.translate(), for: .normal)
        tipsButton.setBorder(fillColor: .clear,
                             strokeColor: .white,
                             croppedCorners: [])
        tipsButton.setTitle(RobotsKeys.Common.failedConnectionTipsButton.translate(), for: .normal)
        tryAgainButton.setBorder(fillColor: .clear,
                                 strokeColor: .white,
                                 croppedCorners: [.topRight])
        tryAgainButton.setTitle(RobotsKeys.Common.failedConnectionTryAgainButton.translate(), for: .normal)
        connectionStatusLabel.text = RobotsKeys.Common.failedConnectionTitle.translate().uppercased()
        subtitleLabel.text = RobotsKeys.Common.failedConnectionSubtitle.translate().uppercased()
        connectionStatusImageView.image = Image.Common.connectionFailed
    }
}

// MARK: - Setup
extension ConnectionModal {
    func successfulConnection() {
        failView.removeFromSuperview()
        connectionStatusImageView.image = Image.Common.connectionSuccessful
        connectionStatusLabel.text = RobotsKeys.Common.successfulConnectionTitle.translate().uppercased()
    }
}

// MARK: - Event handlers
extension ConnectionModal {
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
