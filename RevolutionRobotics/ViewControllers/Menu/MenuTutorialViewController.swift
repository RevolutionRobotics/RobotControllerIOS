//
//  MenuTutorialViewController.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 29..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class MenuTutorialViewController: BaseViewController {
    // MARK: - TutorialStep
    private enum TutorialStep: Int {
        case robot
        case programs
        case challenges
        case community
        case settings
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
}

// MARK: - View lifecycle
extension MenuTutorialViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(step: .robot)
    }
}

// MARK: - Private methods
extension MenuTutorialViewController {
    private func show(step: TutorialStep) {
        sendAllViewsToBack()
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

    private func showRobotTutorial() {
        menuItemContainer.bringSubviewToFront(robotContainer)
    }
    private func showProgramsTutorial() {
        menuItemContainer.bringSubviewToFront(programsContainer)
    }

    private func showChallengesTutorial() {
        menuItemContainer.bringSubviewToFront(challengesContainer)
    }

    private func showCommunityTutorial() {
        view.bringSubviewToFront(communityButton)
    }

    private func showSettingsTutorial() {
        view.bringSubviewToFront(settingsButton)
    }

    private func sendAllViewsToBack() {
        menuItemContainer.sendSubviewToBack(robotContainer)
        menuItemContainer.sendSubviewToBack(programsContainer)
        menuItemContainer.sendSubviewToBack(challengesContainer)
        view.insertSubview(settingsButton, aboveSubview: navigationBar)
        view.insertSubview(communityButton, aboveSubview: navigationBar)
    }
}
