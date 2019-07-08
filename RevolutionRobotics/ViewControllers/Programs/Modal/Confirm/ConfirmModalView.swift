//
//  ConfirmModalView.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 06. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ConfirmModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var negativeButton: RRButton!
    @IBOutlet private weak var positiveButton: RRButton!

    // MARK: - Properties
    var confirmSelected: CallbackType<Bool>?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        setupButtonBorders()
    }
}

// MARK: - Setup
extension ConfirmModalView {
    func setup(
        title: String,
        subtitle: String? = nil,
        negativeButtonTitle: String = CommonKeys.cancel.translate(),
        positiveButtonTitle: String = ModalKeys.Blockly.ok.translate()
    ) {
        titleLabel.text = title.uppercased()
        subtitleLabel.text = subtitle
        negativeButton.setTitle(negativeButtonTitle, for: .normal)
        positiveButton.setTitle(positiveButtonTitle, for: .normal)
    }

    private func setupButtonBorders() {
        positiveButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
        negativeButton.setBorder(fillColor: Color.black26, strokeColor: Color.blackTwo, croppedCorners: [.bottomLeft])
    }
}

// MARK: - Action
extension ConfirmModalView {
    @IBAction private func okButtonTapped(_ sender: Any) {
        confirmSelected?(true)
    }

    @IBAction private func cancelButtonTapped(_ sender: Any) {
        confirmSelected?(false)
    }
}
