//
//  OnboardingCompletedModalView.swift
//  RevolutionRobotics
//
//  Created by Pável Áron on 2019. 09. 27..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class OnboardingCompletedModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var startButton: RRButton!
    var startPressedCallback: Callback!
}

// MARK: - View lifecycle
extension OnboardingCompletedModalView {
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLabels()
        setupStartButton()
    }
}

// MARK: - Private methods
extension OnboardingCompletedModalView {
    private func setupLabels() {
        titleLabel.text = OnboardingKeys.CompletedModal.title.translate()
        messageLabel.text = OnboardingKeys.CompletedModal.message.translate()
    }

    private func setupStartButton() {
        startButton.setTitle(OnboardingKeys.CompletedModal.start.translate(), for: .normal)
        startButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.bottomLeft, .topRight])
    }
}

// MARK: - Actions
extension OnboardingCompletedModalView {
    @IBAction private func startButtonTapped(_ sender: Any) {
        startPressedCallback()
    }
}
