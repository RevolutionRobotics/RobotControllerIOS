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

final class MenuViewController: BaseViewController {
    // MARK: - Constants
    private enum Constants {
        static let communityURL: URL = URL(string: "https://www.google.com")! // TODO: Change to the real community URL
    }

    // MARK: - Outlets
    @IBOutlet private weak var menuItemContainer: UIView!
    @IBOutlet private weak var robotsTitleLabel: UILabel!
    @IBOutlet private weak var programsTitleLabel: UILabel!
    @IBOutlet private weak var challengesTitleLabel: UILabel!

    private let shouldShowTutorial = UserDefaults.standard.bool(forKey: UserDefaults.Keys.shouldShowTutorial)
}

// MARK: - View lifecycle
extension MenuViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        robotsTitleLabel.text = MenuKeys.robotCellTitle.translate()
        programsTitleLabel.text = MenuKeys.programsCellTitle.translate()
        challengesTitleLabel.text = MenuKeys.challengesCellTitle.translate()

        if shouldShowTutorial {
            let vc = AppContainer.shared.container.unwrappedResolve(MenuTutorialViewController.self)
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: false, completion: nil)
        }
    }
}

// MARK: - Event handlers
extension MenuViewController {
    @IBAction private func communityButtonTapped(_ sender: UIButton) {
        let communityViewController = SFSafariViewController(url: Constants.communityURL)
        communityViewController.modalPresentationStyle = .overFullScreen
        present(communityViewController, animated: true, completion: nil)
    }

    @IBAction private func settingsButtonTapped(_ sender: UIButton) {
        let settingsViewController = AppContainer.shared.container.unwrappedResolve(SettingsViewController.self)
        navigationController?.pushViewController(settingsViewController, animated: true)
    }

    @IBAction private func robotsButtonTapped(_ sender: UIButton) {
        let yourRobotsViewController = AppContainer.shared.container.unwrappedResolve(YourRobotsViewController.self)
        navigationController?.pushViewController(yourRobotsViewController, animated: true)
    }

    @IBAction private func programsButtonTapped(_ sender: UIButton) {
        let programsViewController = AppContainer.shared.container.unwrappedResolve(ProgramsViewController.self)
        navigationController?.pushViewController(programsViewController, animated: true)
    }

    @IBAction private func challengesButtonTapped(_ sender: UIButton) {
        let challengesViewController = AppContainer.shared.container.unwrappedResolve(ChallengesViewController.self)
        navigationController?.pushViewController(challengesViewController, animated: true)
    }
}
