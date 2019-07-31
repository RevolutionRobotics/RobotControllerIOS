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
    // MARK: - Outlets
    @IBOutlet private weak var menuItemContainer: UIView!
    @IBOutlet private weak var robotsTitleLabel: UILabel!
    @IBOutlet private weak var programsTitleLabel: UILabel!
    @IBOutlet private weak var challengesTitleLabel: UILabel!
    @IBOutlet private weak var navigationBar: RRNavigationBar!

    // MARK: - Properties
    var firebaseService: FirebaseServiceInterface!
    var realmService: RealmServiceInterface!

    private let updateViewController = AppContainer.shared.container.unwrappedResolve(ModalViewController.self)
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

        checkMinVersion(with: { [weak self] in
            if shouldShowTutorial {
                self?.showTutorial()
            }
        })
    }

    private func checkMinVersion(with completion: @escaping Callback) {
        guard let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            fatalError("Failed to get build number")
        }

        let buildNumber = Int(build) ?? 0
        firebaseService.getMinVersion(completion: { [weak self] result in
            switch result {
            case .success(let version):
                if version.build > buildNumber {
                    self?.showUpdateNeeded()
                    return
                }
            case .failure:
                os_log("Error: Failed to fetch minimum version from Firebase!")
            }

            completion()
        })
    }

    private func showUpdateNeeded() {
        guard updateViewController.viewIfLoaded?.window == nil else { return }

        let modalView = UpdateModalView.instatiate()
        modalView.addTapHandler(callback: { [weak self] in
            let urlString = "itms-apps://itunes.apple.com/app/id1473280499"
            if let appUrl = URL(string: urlString) {
                self?.openAppStore(with: appUrl)
            }
        })

        updateViewController.contentView = modalView
        updateViewController.isCloseHidden = true

        presentViewControllerModally(
            updateViewController,
            transitionStyle: .crossDissolve,
            presentationStyle: .overFullScreen
        )
    }

    private func openAppStore(with url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func showTutorial() {
        let vc = AppContainer.shared.container.unwrappedResolve(MenuTutorialViewController.self)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
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
