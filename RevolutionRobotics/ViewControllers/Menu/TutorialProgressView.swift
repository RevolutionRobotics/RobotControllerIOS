//
//  TutorialProgressView.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 29..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class TutorialProgressView: RRCustomView {
    // MARK: - Constants
    private enum Constants {
        static let cornerRadius: CGFloat = 5.0
        static let borderWidth: CGFloat = 1.0
        static let borderColor: CGColor = UIColor.white.cgColor
        static let unselectedBackgroundColor: UIColor = .clear
        static let selectedBackgroundColor: UIColor = Color.brightRed
    }

    // MARK: - Outlets
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var previousButton: UIButton!
    @IBOutlet private weak var progressView1: UIView!
    @IBOutlet private weak var progressView2: UIView!
    @IBOutlet private weak var progressView3: UIView!
    @IBOutlet private weak var progressView4: UIView!
    @IBOutlet private weak var progressView5: UIView!
    @IBOutlet private var progressViews: [UIView]!

    var nextButtonTapped: CallbackType<TutorialStep>?
    var previousButtonTapped: CallbackType<TutorialStep>?

    private var currentStep: TutorialStep = .robot
}

// MARK: - View lifecycle
extension TutorialProgressView {
    override func awakeFromNib() {
        super.awakeFromNib()
        setupProgressViewInitialState(on: progressViews)

        setSelected(progressView1)
    }
}

// MARK: - Setup
extension TutorialProgressView {
    private func setupProgressViewInitialState(on views: [UIView]) {
        views.forEach { view in
            view.layer.cornerRadius = Constants.cornerRadius
            view.layer.borderWidth = Constants.borderWidth
            view.layer.borderColor = Constants.borderColor
            view.backgroundColor = Constants.unselectedBackgroundColor
        }
    }

    private func setSelected(_ view: UIView) {
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.borderWidth = 0.0
        view.layer.borderColor = nil
        view.backgroundColor = Constants.selectedBackgroundColor
    }

    private func setupInitialState() {
        nextButton.isEnabled = true
        previousButton.isEnabled = true
        setupProgressViewInitialState(on: progressViews)
    }
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
        setupInitialState()
        switch currentStep {
        case .robot:
            currentStep = .programs
            setSelected(progressView2)
        case .programs:
            currentStep = .challenges
            setSelected(progressView3)
        case .challenges:
            currentStep = .community
            setSelected(progressView4)
        case .community:
            currentStep = .settings
            setSelected(progressView5)
        case .settings:
            currentStep = .settings
            setSelected(progressView5)
        }
        if currentStep == .settings {
            nextButton.isEnabled = false
        }
    }

    private func decreaseStep() {
        setupInitialState()
        switch currentStep {
        case .robot:
            currentStep = .robot
            setSelected(progressView1)
        case .programs:
            currentStep = .robot
            setSelected(progressView1)
        case .challenges:
            currentStep = .programs
            setSelected(progressView2)
        case .community:
            currentStep = .challenges
            setSelected(progressView3)
        case .settings:
            currentStep = .community
            setSelected(progressView4)
        }
        if currentStep == .robot {
            previousButton.isEnabled = false
        }
    }
}
