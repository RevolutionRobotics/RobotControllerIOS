//
//  MenuTutorialViewController.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 29..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

enum TutorialStep: Int {
    case robot
    case programs
    case challenges
    case community
    case settings
}

final class MenuTutorialViewController: BaseViewController {
    // MARK: - Constants
    private enum Constants {
        static let titleFont = Font.barlow(size: 14.0, weight: .bold)
        static let descriptionFont = Font.barlow(size: 12.0, weight: .regular)
        static let buttonFont = Font.barlow(size: 14.0, weight: .medium)
    }

    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var menuItemContainer: UIView!
    @IBOutlet private weak var robotContainer: UIView!
    @IBOutlet private weak var programsContainer: UIView!
    @IBOutlet private weak var challengesContainer: UIView!
    @IBOutlet private weak var communityButton: RRButton!
    @IBOutlet private weak var settingsButton: RRButton!
    @IBOutlet private weak var menuDimView: UIView!
    @IBOutlet private weak var finishButton: RRButton!
    @IBOutlet private weak var skipButton: RRButton!
    @IBOutlet private weak var tutorialProgressView: TutorialProgressView!

    @IBOutlet private weak var robotDescriptionContainerView: UIView!
    @IBOutlet private weak var robotDescriptionContentView: UIView!
    @IBOutlet private weak var robotDescriptionTitleLabel: UILabel!
    @IBOutlet private weak var robotDescriptionLabel: UILabel!

    @IBOutlet private weak var programsDescriptionContainerView: UIView!
    @IBOutlet private weak var programsDescriptionContentView: UIView!
    @IBOutlet private weak var programsDescriptionTitleLabel: UILabel!
    @IBOutlet private weak var programsDescriptionLabel: UILabel!

    @IBOutlet private weak var challengesDescriptionContainerView: UIView!
    @IBOutlet private weak var challengesDescriptionContentView: UIView!
    @IBOutlet private weak var challengesDescriptionTitleLabel: UILabel!
    @IBOutlet private weak var challengesDescriptionLabel: UILabel!

    @IBOutlet private weak var communityDescriptionContainerView: UIView!
    @IBOutlet private weak var communityDescriptionContentView: UIView!
    @IBOutlet private weak var communityDescriptionTitleLabel: UILabel!
    @IBOutlet private weak var communityDescriptionLabel: UILabel!

    @IBOutlet private weak var settingsDescriptionContainerView: UIView!
    @IBOutlet private weak var settingsDescriptionContentView: UIView!
    @IBOutlet private weak var settingsDescriptionTitleLabel: UILabel!
    @IBOutlet private weak var settingsDescriptionLabel: UILabel!
}

// MARK: - Actions
extension MenuTutorialViewController {
    @IBAction private func finishButtonTapped(_ sender: RRButton) {
        dismiss()
    }
    @IBAction private func skipButtonTapped(_ sender: RRButton) {
        dismiss()
    }
}

// MARK: - View lifecycle
extension MenuTutorialViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLabels()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(step: .robot)
        setupCorners()
        setupTutorialProgressView()
    }
}

// MARK: - Setups
extension MenuTutorialViewController {
    private func setupTutorialProgressView() {
        tutorialProgressView.nextButtonTapped = { [weak self] step in
            self?.show(step: step)
        }

        tutorialProgressView.previousButtonTapped = { [weak self] step in
            self?.show(step: step)
        }
    }

    private func setupCorners() {
        setBorder(on: robotDescriptionContentView)
        setBorder(on: programsDescriptionContentView)
        setBorder(on: challengesDescriptionContentView)
        setBorder(on: communityDescriptionContentView)
        setBorder(on: settingsDescriptionContentView)
        skipButton.setBorder(fillColor: .clear, strokeColor: .white)
        skipButton.setTitle(MenuKeys.Tutorial.skipButton.translate(), for: .normal)
        finishButton.setTitle(MenuKeys.Tutorial.finishButton.translate(), for: .normal)
        finishButton.setBorder(fillColor: .clear, strokeColor: .white)
        skipButton.titleLabel?.font = Constants.buttonFont
        finishButton.titleLabel?.font = Constants.buttonFont
    }

    private func setBorder(on view: UIView) {
        view.setBorder(fillColor: Color.blackTwo, lineWidth: 0.0, croppedCorners: [.bottomLeft, .topRight])
    }

    private func setupLabels() {
        robotDescriptionTitleLabel.font = Constants.titleFont
        robotDescriptionTitleLabel.text = MenuKeys.Tutorial.robotsTitle.translate()
        robotDescriptionLabel.font = Constants.descriptionFont
        robotDescriptionLabel.text = MenuKeys.Tutorial.robotsDescription.translate()

        programsDescriptionTitleLabel.font = Constants.titleFont
        programsDescriptionTitleLabel.text = MenuKeys.Tutorial.programsTitle.translate()
        programsDescriptionLabel.font = Constants.descriptionFont
        programsDescriptionLabel.text = MenuKeys.Tutorial.programsDescription.translate()

        challengesDescriptionTitleLabel.font = Constants.titleFont
        challengesDescriptionTitleLabel.text = MenuKeys.Tutorial.challengesTitle.translate()
        challengesDescriptionLabel.font = Constants.descriptionFont
        challengesDescriptionLabel.text = MenuKeys.Tutorial.challengesDescription.translate()

        communityDescriptionTitleLabel.font = Constants.titleFont
        communityDescriptionTitleLabel.text = MenuKeys.Tutorial.communityTitle.translate()
        communityDescriptionLabel.font = Constants.descriptionFont
        communityDescriptionLabel.text = MenuKeys.Tutorial.communityDescription.translate()

        settingsDescriptionTitleLabel.font = Constants.titleFont
        settingsDescriptionTitleLabel.text = MenuKeys.Tutorial.settingsTitle.translate()
        settingsDescriptionLabel.font = Constants.descriptionFont
        settingsDescriptionLabel.text = MenuKeys.Tutorial.settingsDescription.translate()
    }
}

// MARK: - Private methods
extension MenuTutorialViewController {
    private func show(step: TutorialStep) {
        prepareViews()
        switch step {
        case .robot:
            showRobotTutorial()
        case .programs:
            showProgramsTutorial()
        case .challenges:
            showChallengesTutorial()
        case .community:
            showCommunityTutorial()
        case .settings:
            showSettingsTutorial()
        }
    }

    private func prepareViews() {
        hideAllDescriptionViews()
        sendAllViewsToBack()
        hideAllButtons()
    }

    private func showRobotTutorial() {
        menuItemContainer.bringSubviewToFront(robotContainer)
        robotDescriptionContainerView.isHidden = false
        skipButton.isHidden = false
    }
    private func showProgramsTutorial() {
        menuItemContainer.bringSubviewToFront(programsContainer)
        programsDescriptionContainerView.isHidden = false
        skipButton.isHidden = false
    }

    private func showChallengesTutorial() {
        menuItemContainer.bringSubviewToFront(challengesContainer)
        challengesDescriptionContainerView.isHidden = false
        skipButton.isHidden = false
    }

    private func showCommunityTutorial() {
        view.bringSubviewToFront(communityButton)
        communityDescriptionContainerView.isHidden = false
        skipButton.isHidden = false
    }

    private func showSettingsTutorial() {
        view.bringSubviewToFront(settingsButton)
        settingsDescriptionContainerView.isHidden = false
        finishButton.isHidden = false
    }

    private func sendAllViewsToBack() {
        menuItemContainer.sendSubviewToBack(robotContainer)
        menuItemContainer.sendSubviewToBack(programsContainer)
        menuItemContainer.sendSubviewToBack(challengesContainer)
        view.insertSubview(settingsButton, aboveSubview: navigationBar)
        view.insertSubview(communityButton, aboveSubview: navigationBar)
    }

    private func hideAllDescriptionViews() {
        robotDescriptionContainerView.isHidden = true
        programsDescriptionContainerView.isHidden = true
        challengesDescriptionContainerView.isHidden = true
        communityDescriptionContainerView.isHidden = true
        settingsDescriptionContainerView.isHidden = true
    }

    private func hideAllButtons() {
        skipButton.isHidden = true
        finishButton.isHidden = true
    }

    private func dismiss() {
        UserDefaults.standard.set(false, forKey: UserDefaults.Keys.shouldShowTutorial)
        dismiss(animated: false, completion: nil)
    }
}
