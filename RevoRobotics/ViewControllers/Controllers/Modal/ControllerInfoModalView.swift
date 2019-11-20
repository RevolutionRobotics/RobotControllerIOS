//
//  ControllerInfoModalView.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 02..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ControllerInfoModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var controllerNameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var lastModifiedLabel: UILabel!
    @IBOutlet private weak var gotItButton: RRButton!

    // MARK: - Properties
    private var callback: Callback?
}

// MARK: - View lifecycle
extension ControllerInfoModalView {
    override func awakeFromNib() {
        super.awakeFromNib()

        gotItButton.setBorder(fillColor: .clear, strokeColor: .white)
        gotItButton.setTitle(ModalKeys.Controller.infoButtonTitle.translate(), for: .normal)
    }
}

// MARK: - Setup
extension ControllerInfoModalView {
    func setup(name: String?, description: String?, date: Date?, callback: Callback?) {
        controllerNameLabel.text = name
        descriptionLabel.text = description
        lastModifiedLabel.text = DateFormatter.string(from: date, format: .yearMonthDay)
        self.callback = callback
    }
}

// MARK: - Event handlers
extension ControllerInfoModalView {
    @IBAction private func gotItButtonTapped(_ sender: Any) {
        callback?()
    }
}
