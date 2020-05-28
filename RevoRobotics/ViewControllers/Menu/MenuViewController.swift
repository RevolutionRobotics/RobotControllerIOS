//
//  MenuViewController.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 01..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import RevolutionRoboticsBlockly
import SafariServices
import os

final class MenuViewController: BaseViewController {
    // MARK: - Constants
    enum Constants {
        static let onboardingCompletedProgress = 2
        static let onboardingCategoryId = "ef504b31-d64f-4bfb-bd4b-5b96a9a0489f"
        static let onboardingChallengeIds = [
            "e32cbf06-3343-446b-a17f-af84e160cee5",
            "ce95005e-16e1-4d7b-ac9c-b24ba9b6625f"
        ]
    }

    // MARK: - Outlets
    @IBOutlet private weak var menuItemContainer: UIView!
    @IBOutlet private weak var robotsTitleLabel: UILabel!
    @IBOutlet private weak var programsTitleLabel: UILabel!
    @IBOutlet private weak var challengesTitleLabel: UILabel!
    @IBOutlet private weak var navigationBar: RRNavigationBar!

    // MARK: - Properties
    var firebaseService: FirebaseServiceInterface!
    var realmService: RealmServiceInterface!
    var onboardingInProgress = false
}

// MARK: - View lifecycle
extension MenuViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        robotsTitleLabel.text = MenuKeys.robotCellTitle.translate()
        programsTitleLabel.text = MenuKeys.programsCellTitle.translate()
        challengesTitleLabel.text = MenuKeys.challengesCellTitle.translate()
        navigationBar.setup(title: nil, delegate: self)
        navigationBar.shouldHideBackButton = true

        let userDefaults = UserDefaults.standard
        if !userDefaults.bool(forKey: UserDefaults.Keys.buildRevvyPromptVisited) {
            showOnboarding()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard onboardingInProgress else { return }

        let onboardingProgress = realmService.getChallenges()
            .filter({ Constants.onboardingChallengeIds.contains($0.id) && $0.isCompleted })
            .count

        if onboardingProgress < Constants.onboardingCompletedProgress {
            setOnboardingCompletedProgress()
        }

        let modal = OnboardingCompletedModalView.instatiate()
        modal.startPressedCallback = { [weak self] in
            guard let `self` = self else { return }
            self.presentedViewController?
                .dismiss(animated: true, completion: self.navigateToChallenge)
        }

        onboardingInProgress = false
        presentModal(with: modal)
    }
}

// MARK: - Private methods
extension MenuViewController {
    private func navigateToChallenge() {
        let challengesViewController =
        AppContainer.shared.container.unwrappedResolve(ChallengesViewController.self)

        firebaseService.getChallengeCategories(completion: { [weak self] result in
            switch result {
            case .success(let challengeCategories):
                guard let onboardingChallenge = challengeCategories.first(where: {
                    $0.id == Constants.onboardingCategoryId
                }) else { return }
                self?.navigationController?.pushViewController(challengesViewController, animated: true)
                challengesViewController.setup(with: onboardingChallenge)
            case .failure:
                os_log("Error: Failed to fetch challenge categories from Firebase!")
            }
        })
    }

    private func setOnboardingCompletedProgress() {
        let onboardingChallenges: [ChallengeDataModel] = Constants.onboardingChallengeIds.compactMap({ challengeId in
            guard let challenge = realmService.getChallenges().first(where: { $0.id == challengeId }) else {
                return nil
            }

            return ChallengeDataModel(
                id: challenge.id,
                categoryId: challenge.categoryId,
                isDraft: challenge.isDraft,
                isCompleted: true,
                order: challenge.order)
        })

        realmService.saveChallenges(onboardingChallenges)
    }

    private func showOnboarding() {
        let onboarding = AppContainer.shared.container.unwrappedResolve(BuildRevvyViewController.self)
        navigationController?.pushViewController(onboarding, animated: true)
    }
}

// MARK: - Actions
extension MenuViewController {
    @IBAction private func communityButtonTapped(_ sender: UIButton) {
        let communityViewController = AppContainer.shared.container.unwrappedResolve(CommunityViewController.self)
        navigationController?.pushViewController(communityViewController, animated: true)
    }

    @IBAction private func settingsButtonTapped(_ sender: UIButton) {
        let settingsViewController = AppContainer.shared.container.unwrappedResolve(SettingsViewController.self)
        navigationController?.pushViewController(settingsViewController, animated: true)
    }

    @IBAction private func robotsButtonTapped(_ sender: UIButton) {
        if realmService.getRobots().isEmpty {
            let vc = AppContainer.shared.container.unwrappedResolve(YourRobotsViewController.self)
            let vc2 = AppContainer.shared.container.unwrappedResolve(WhoToBuildViewController.self)
            navigationController?.pushViewController(vc, animated: false)
            navigationController?.pushViewController(vc2, animated: true)
        } else {
            let vc = AppContainer.shared.container.unwrappedResolve(YourRobotsViewController.self)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction private func programsButtonTapped(_ sender: UIButton) {
        let programsViewController = AppContainer.shared.container.unwrappedResolve(ProgramsViewController.self)
        programsViewController.openedFromMenu = true
        navigationController?.pushViewController(programsViewController, animated: true)
    }

    @IBAction private func challengesButtonTapped(_ sender: UIButton) {
        let challengesViewController =
            AppContainer.shared.container.unwrappedResolve(ChallengeCategoriesViewController.self)
        navigationController?.pushViewController(challengesViewController, animated: true)
    }
}

// MARK: - Bluetooth connection
extension MenuViewController {
    override func connected() {
        super.connected()

        navigationBar.bluetoothButtonState = .connected
    }

    override func disconnected() {
        super.disconnected()
        navigationBar.bluetoothButtonState = .notConnected
    }
}
