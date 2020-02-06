//
//  ChallengeDetailViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 05..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ChallengeDetailViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var progressBar: BuildProgressBar!
    @IBOutlet private weak var progressLabel: RRProgressLabel!

    // MARK: - Properties
    private var challenge: Challenge?
    var challengeFinished: Callback?
}

// MARK: - Setup
extension ChallengeDetailViewController {
    func setup(with challenge: Challenge, needsReload: Bool = false) {
        self.challenge = challenge
        if needsReload {
            navigationBar.setup(title: challenge.name.text, delegate: self)
            setupContent(for: 0)
            setupProgressBar()
        }
    }

    private func setupProgressBar() {
        guard let challenge = challenge else { return }
        progressBar.numberOfSteps = challenge.challengeSteps.count - 1
        progressBar.currentStep = 0
        if challenge.challengeSteps.count - 2 >= 1 {
            progressBar.markers = Array(1...challenge.challengeSteps.count - 2)
        } else {
            progressBar.markers = []
        }
        progressBar.showMilestone = { [weak self] in
            self?.progressBar.milestoneFinished()
        }
        progressBar.valueDidChange = { [weak self] challengeStep in
            guard let `self` = self else { return }
            self.setupContent(for: challengeStep)
            self.progressLabel.currentStep = challengeStep + 1
        }
        progressBar.buildFinished = challengeFinished
        setupProgressLabel(with: challenge.challengeSteps.count)
    }

    private func setupProgressLabel(with challengeStepCount: Int) {
        progressLabel.currentStep = progressBar.currentStep + 1
        progressLabel.numberOfSteps = challengeStepCount
    }

    private func findChallengeStep(at index: Int) -> ChallengeStep? {
        guard
            let steps = challenge?.challengeSteps,
            let stepKey = steps.keys.first(where: {
                steps[$0]?.order == index + 1 })
        else {
            return nil
        }

        return steps[stepKey]
    }

    private func setupContent(for step: Int) {
        guard let challengeStep = findChallengeStep(at: step) else { return }
        switch challengeStep.challengeType {
        case .horizontal:
            setupDetailContent(with: challengeStep, on: ChallengeDetailHorizontalContent.instatiate())
        case .vertical:
            setupDetailContent(with: challengeStep, on: ChallengeDetailVerticalContent.instatiate())
        case .zoomable:
            setupDetailContent(with: challengeStep, on: ChallengeDetailZoomableContent.instatiate())
        case .partList:
            setupDetailContent(with: challengeStep, on: ChallengeDetailPartListContent.instatiate())
        case .button:
            let challengeButtonContent = ChallengeDetailButtonContent.instatiate()
            challengeButtonContent.buttonPressedCallback = { [weak self] in
                guard
                    let buttonUrlString = challengeStep.buttonUrl,
                    let buttonUrl = URL(string: buttonUrlString)
                else { return }
                self?.openSafari(presentationFinished: nil, url: buttonUrl)
            }
            setupDetailContent(with: challengeStep, on: challengeButtonContent)
        }
    }

    private func setupDetailContent(with step: ChallengeStep, on content: ChallengeDetailContentProtocol) {
        contentView.removeAllSubViews()
        content.frame = contentView.bounds
        contentView.addSubview(content)
        content.setup(with: step)
        navigationBar.setup(title: step.title.text, delegate: self)
    }
}

// MARK: - View lifecycle
extension ChallengeDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.bluetoothButtonState = bluetoothService.connectedDevice != nil ? .connected : .notConnected
        guard challenge != nil else { return }
        setupContent(for: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupProgressBar()
        contentView.layoutIfNeeded()
    }
}

// MARK: - Bluetooth connection
extension ChallengeDetailViewController {
    override func connected() {
        super.connected()
        navigationBar.bluetoothButtonState = .connected
    }

    override func disconnected() {
        super.disconnected()
        navigationBar.bluetoothButtonState = .notConnected
    }
}
