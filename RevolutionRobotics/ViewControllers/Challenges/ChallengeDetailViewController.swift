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

    // MARK: - Properties
    private var challenge: Challenge?
    private var parts: [Part] = []
    var challengeFinished: Callback?
}

// MARK: - Setup
extension ChallengeDetailViewController {
    func setup(with challenge: Challenge, needsReload: Bool = false) {
        self.challenge = challenge
        if needsReload {
            navigationBar.setup(title: challenge.name, delegate: self)
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
            self?.setupContent(for: challengeStep)
        }
        progressBar.buildFinished = challengeFinished
    }

    private func setupContent(for step: Int) {
        guard let challengeStep = challenge?.challengeSteps[step] else { return }
        switch challengeStep.challengeType {
        case .horizontal:
            setupDetailContent(with: challengeStep, on: ChallengeDetailHorizontalContent.instatiate())
        case .vertical:
            setupDetailContent(with: challengeStep, on: ChallengeDetailVerticalContent.instatiate())
        case .zoomable:
            setupDetailContent(with: challengeStep, on: ChallengeDetailZoomableContent.instatiate())
        case .partList:
            setupDetailContent(with: challengeStep, on: ChallengeDetailPartListContent.instatiate())
        }
    }

    private func setupDetailContent(with step: ChallengeStep, on content: ChallengeDetailContentView) {
        contentView.removeAllSubViews()
        content.setup(with: step)
        contentView.addSubview(content)
        content.anchorToSuperview()
    }
}

// MARK: - View lifecycle
extension ChallengeDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let challenge = challenge else { return }
        navigationBar.setup(title: challenge.name, delegate: self)
        setupContent(for: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupProgressBar()
        contentView.layoutIfNeeded()
    }
}
