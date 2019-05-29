//
//  TutorialProgressView.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 29..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class TutorialProgressView: RRCustomView {
    // MARK: - Outlets
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var previousButton: UIButton!
    @IBOutlet private weak var imageView1: UIImageView!
    @IBOutlet private weak var imageView2: UIImageView!
    @IBOutlet private weak var imageView3: UIImageView!
    @IBOutlet private weak var imageView4: UIImageView!
    @IBOutlet private weak var imageView5: UIImageView!

    var nextButtonTapped: CallbackType<TutorialStep>?
    var previousButtonTapped: CallbackType<TutorialStep>?

    private var currentStep: TutorialStep = .robot
}

// MARK: - Actions
extension TutorialProgressView {
    @IBAction private func previousButtonTapped(_ sender: UIButton) {
        decreaseStep()
        previousButtonTapped?(currentStep)
    }

    @IBAction private func nextButtonTapped(_ sender: UIButton) {
        increaseStep()
        nextButtonTapped?(currentStep)
    }
}

// MARK: - Private methods
extension TutorialProgressView {
    private func increaseStep() {
        nextButton.isEnabled = true
        previousButton.isEnabled = true
        switch currentStep {
        case .robot:
            currentStep = .programs
        case .programs:
            currentStep = .challenges
        case .challenges:
            currentStep = .community
        case .community:
            currentStep = .settings
        case .settings:
            currentStep = .settings
        }
        if currentStep == .settings {
            nextButton.isEnabled = false
        }
    }

    private func decreaseStep() {
        nextButton.isEnabled = true
        previousButton.isEnabled = true
        switch currentStep {
        case .robot:
            currentStep = .robot
        case .programs:
            currentStep = .robot
        case .challenges:
            currentStep = .programs
        case .community:
            currentStep = .challenges
        case .settings:
            currentStep = .community
        }
        if currentStep == .robot {
            previousButton.isEnabled = false
        }
    }
}
