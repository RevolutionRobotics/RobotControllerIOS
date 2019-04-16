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
        static let titleLabelRatio: CGFloat = 16 / 162
        static let communityURL: URL = URL(string: "https://www.google.com")!
    }

    // MARK: - Outlets
    @IBOutlet private weak var menuItemContainer: UIView!
    @IBOutlet private weak var robotsTitleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var programsTitleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var challengesTitleLabelTopConstraint: NSLayoutConstraint!
}

// MARK: - View lifecycle
extension MenuViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupConstraints()
    }
}

// MARK: - Setups
extension MenuViewController {
    private func setupConstraints() {
        robotsTitleLabelTopConstraint.constant = menuItemContainer.frame.height * Constants.titleLabelRatio
        programsTitleLabelTopConstraint.constant = menuItemContainer.frame.height * Constants.titleLabelRatio
        challengesTitleLabelTopConstraint.constant = menuItemContainer.frame.height * Constants.titleLabelRatio
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
