//
//  ChallengeDetailButtonContent.swift
//  RevoRobotics
//
//  Created by Pável Áron on 2020. 01. 20..
//  Copyright © 2020. Revolution Robotics. All rights reserved.
//

import UIKit

final class ChallengeDetailButtonContent: UIView {
    // MARK: - Constants
    private enum Constants {
        static let fontSize: CGFloat = 18.0
    }

    // MARK: - Properties
    var buttonPressedCallback: Callback?

    // MARK: - Outlets
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var challengeDetailButton: RRButton!
}

// MARK: - ChallengeDetailContent
extension ChallengeDetailButtonContent: ChallengeDetailContentProtocol {
    func setup(with step: ChallengeStep) {
        descriptionLabel.attributedText = NSAttributedString
            .attributedString(from: step.description.text, fontSize: Constants.fontSize)

        guard let buttonText = step.buttonText?.text else { return }

        challengeDetailButton.setTitle(buttonText, for: .normal)
        challengeDetailButton.titleLabel?.font = Font.jura(size: Constants.fontSize)
        challengeDetailButton.setBorder()
    }
}

// MARK: - Actions
extension ChallengeDetailButtonContent {
    @IBAction private func challengeButtonTapped(_ sender: Any) {
        buttonPressedCallback?()
    }
}
