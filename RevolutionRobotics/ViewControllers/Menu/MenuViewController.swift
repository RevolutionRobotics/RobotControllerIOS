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
    // MARK: - Outlets
    @IBOutlet private weak var menuItemContainer: UIView!
    @IBOutlet private weak var robotsTitleLabel: UILabel!
    @IBOutlet private weak var programsTitleLabel: UILabel!
    @IBOutlet private weak var challengesTitleLabel: UILabel!
    @IBOutlet private weak var navigationBar: RRNavigationBar!

    // MARK: - Properties
    var realmService: RealmServiceInterface!
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let shouldShowTutorial = UserDefaults.standard.bool(forKey: UserDefaults.Keys.shouldShowTutorial)
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
        let communityViewController = AppContainer.shared.container.unwrappedResolve(CommunityViewController.self)
        navigationController?.pushViewController(communityViewController, animated: true)
    }

    @IBAction private func settingsButtonTapped(_ sender: UIButton) {
        let settingsViewController = AppContainer.shared.container.unwrappedResolve(SettingsViewController.self)
        navigationController?.pushViewController(settingsViewController, animated: true)
    }

    @IBAction private func robotsButtonTapped(_ sender: UIButton) {
        let vc = realmService.getRobots().isEmpty ?
            AppContainer.shared.container.unwrappedResolve(WhoToBuildViewController.self) :
            AppContainer.shared.container.unwrappedResolve(YourRobotsViewController.self)
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction private func programsButtonTapped(_ sender: UIButton) {
        let programsViewController = AppContainer.shared.container.unwrappedResolve(ProgramsViewController.self)
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
