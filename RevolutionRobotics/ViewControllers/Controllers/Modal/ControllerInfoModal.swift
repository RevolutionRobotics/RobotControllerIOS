//
//  ControllerInfoModal.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 02..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ControllerInfoModal: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var controllerNameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var lastModifiedLabel: UILabel!
    @IBOutlet private weak var gotItButton: RRButton!

    // MARK: - Callbacks
    var gotItCallback: Callback?
}

// MARK: - View lifecycle
extension ControllerInfoModal {
    override func awakeFromNib() {
        super.awakeFromNib()

        gotItButton.setBorder(fillColor: .clear, strokeColor: .white)
        gotItButton.setTitle(ModalKeys.Controller.infoButtonTitle.translate(), for: .normal)
    }
}

// MARK: - Event handlers
extension ControllerInfoModal {
    @IBAction private func gotItButtonTapped(_ sender: Any) {
        gotItCallback?()
    }
}
