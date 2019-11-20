//
//  UpdateModalView.swift
//  RevolutionRobotics
//
//  Created by Pável Áron on 2019. 07. 17..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class UpdateModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var updateModalTitle: UILabel!
    @IBOutlet private weak var updateModalMessage: UILabel!
    @IBOutlet private weak var updateButton: RRButton!

    // MARK: - Properties
    private var callback: Callback?
}

// MARK: - View lifecycle
extension UpdateModalView {
    override func awakeFromNib() {
        super.awakeFromNib()

        updateModalTitle.text = ModalKeys.Menu.updateTitle.translate()
        updateModalMessage.text = ModalKeys.Menu.updateMessage.translate()

        updateButton.setBorder(fillColor: .clear, strokeColor: .white)
        updateButton.setTitle(ModalKeys.Menu.updateButton.translate(), for: .normal)
    }
}

// MARK: - Setup
extension UpdateModalView {
    func addTapHandler(callback: Callback?) {
        self.callback = callback
    }
}

// MARK: - Event handlers
extension UpdateModalView {
    @IBAction private func updateButtonTapped(_ sender: Any) {
        callback?()
    }
}
