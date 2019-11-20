//
//  AlertModalView.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 06. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class AlertModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var cancelButton: RRButton!
    @IBOutlet private weak var okButton: RRButton!

    // MARK: - Properties
    private var callback: Callback?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        setupOkButton()
    }
}

// MARK: - Setup
extension AlertModalView {
    func setup(message: String, callback: Callback?) {
        self.callback = callback
        titleLabel.text = message.uppercased()
    }

    private func setupOkButton() {
        okButton.setBorder(fillColor: .clear, strokeColor: .white)
        okButton.setTitle(ModalKeys.Blockly.ok.translate(), for: .normal)
    }
}

// MARK: - Action
extension AlertModalView {
    @IBAction private func okButtonTapped(_ sender: Any) {
        callback?()
    }
}
