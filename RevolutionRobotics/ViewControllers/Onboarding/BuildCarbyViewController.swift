//
//  BuildCarbyViewController.swift
//  RevolutionRobotics
//
//  Created by Pável Áron on 2019. 09. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class BuildCarbyViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var yesButton: RRButton!
    @IBOutlet private weak var noButton: RRButton!
    @IBOutlet private weak var skipButton: UIButton!
}

// MARK: - View lifecycle
extension BuildCarbyViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPromptButtons()
        setupSkipButton()
    }
}

// MARK: - Private methods
extension BuildCarbyViewController {
    private func setupPromptButtons() {
        let buttonAttributes: [NSAttributedString.Key: Any] = [
            .font: Font.jura(size: 17.0)
        ]

        yesButton.titleLabel?.attributedText = NSMutableAttributedString(string: "Yes", attributes: buttonAttributes)
        noButton.titleLabel?.attributedText = NSMutableAttributedString(string: "No", attributes: buttonAttributes)

        for button in [yesButton, noButton] {
            button?.setBorder(
                fillColor: .clear,
                strokeColor: .white,
                croppedCorners: [.bottomLeft, .topRight])
        }
    }

    private func setupSkipButton() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Font.jura(size: 17.0),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        skipButton.titleLabel?.attributedText =
            NSMutableAttributedString(string: "Skip onboarding", attributes: attributes)
    }
}

// MARK: - Actions
extension BuildCarbyViewController {
    @IBAction private func skipButtonTapped(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction private func yesButtonTapped(_ sender: Any) {
        print("YES")
    }

    @IBAction private func noButtonTapped(_ sender: Any) {
        print("NO")
    }
}
