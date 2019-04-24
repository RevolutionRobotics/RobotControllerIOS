//
//  YourRobotsViewController.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class YourRobotsViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var buildNewButton: RRButton!
}

// MARK: - View lifecycle
extension YourRobotsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: RobotsKeys.YourRobots.title.translate(), delegate: self)
        buildNewButton.setTitle(RobotsKeys.YourRobots.buildNewButtonTitle.translate(), for: .normal)
    }
}

// MARK: - Actions
extension YourRobotsViewController {
    @IBAction private func builNewButtonTapped(_ sender: Any) {
        let whoToBuildViewController = AppContainer.shared.container.unwrappedResolve(WhoToBuildViewController.self)
        navigationController?.pushViewController(whoToBuildViewController, animated: true)
    }
}
