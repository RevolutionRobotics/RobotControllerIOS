//
//  DialpadInputViewController.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 06. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import RevolutionRoboticsBlockly

final class DialpadInputViewController: UIViewController {
    // MARK: - Constants
    private enum Constants {
        static let clippingRadius: CGFloat = 6.0
        static let decimalSeparator = "."
    }

    // MARK: - Outlet
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var resultContainerView: UIView!
    @IBOutlet private weak var resultLabel: UILabel!
    @IBOutlet private weak var dotButton: RRButton!
    @IBOutlet private weak var okButton: RRButton!
    @IBOutlet private var numberButtons: [RRButton]!

    // MARK: - Properties
    private var valueSelected: CallbackType<String?>?

    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBorders()
    }
}

// MARK: - Setup
extension DialpadInputViewController {
    func setup(inputHandler: InputHandler, valueSelected: CallbackType<String?>?) {
        self.valueSelected = valueSelected
        resultLabel.text = inputHandler.defaultInput
    }

    private func setupBorders() {
        okButton.setBorder(fillColor: .clear, strokeColor: .white)
        dotButton.setBorder(fillColor: .clear, strokeColor: Color.black)
        numberButtons.forEach { $0.setBorder(fillColor: .clear, strokeColor: Color.black) }
        containerView.setBorder(fillColor: Color.blackTwo, strokeColor: Color.blackTwo)
        resultContainerView.setBorder(
            fillColor: .clear,
            strokeColor: Color.brownishGrey,
            radius: Constants.clippingRadius,
            croppedCorners: [.bottomLeft, .bottomRight, .topLeft, .topRight]
        )
    }
}

// MARK: - Action
extension DialpadInputViewController {
    @IBAction private func clearButtonTapped(_ sender: Any) {
        guard let resultText = resultLabel.text, !resultText.isEmpty else { return }
        resultLabel.text = String(resultText.dropLast())
    }

    @IBAction private func okButtonTapped(_ sender: Any) {
        valueSelected?(resultLabel.text)
    }

    @IBAction private func dotButtonTapped(_ sender: Any) {
        guard let resultText = resultLabel.text, !resultText.contains(Constants.decimalSeparator) else { return }

        resultLabel.text?.append(".")
    }

    @IBAction private func numberButtonTapped(_ sender: RRButton) {
        guard let resultText = resultLabel.text, let buttonText = sender.titleLabel?.text else { return }

        if resultText == "0" {
            resultLabel.text = buttonText
        } else {
            resultLabel.text?.append(buttonText)
        }
    }
}
