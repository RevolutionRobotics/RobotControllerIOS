//
//  DisconnectModalView.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 06. 05..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class DisconnectModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var disconnectButton: RRButton!
    @IBOutlet private weak var cancelButton: RRButton!

    // MARK: - Properties
    var disconnectHandler: Callback?
    var cancelHandler: Callback?
    var robotName: String? {
        didSet {
            titleLabel.text = robotName
        }
    }
}

// MARK: - View lifecycle
extension DisconnectModalView {
    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionLabel.text = ModalKeys.Disconnect.description.translate()
        disconnectButton.setTitle(ModalKeys.Disconnect.disconnect.translate(), for: .normal)
        cancelButton.setTitle(ModalKeys.Disconnect.cancel.translate(), for: .normal)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        disconnectButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
        cancelButton.setBorder(fillColor: .clear, strokeColor: .clear, croppedCorners: [.bottomLeft])
    }
}

// MARK: - Actions
extension DisconnectModalView {
    @IBAction private func disconnectButtonTapped(_ sender: RRButton) {
        disconnectHandler?()
    }

    @IBAction private func cancelButtonTapped(_ sender: RRButton) {
        cancelHandler?()
    }
}
