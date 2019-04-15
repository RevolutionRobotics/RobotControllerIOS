//
//  MenuViewController.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 01..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import RevolutionRoboticsBlockly

final class MenuViewController: ViewController {
    // MARK: - Constants
    private enum Constants {
        static let titleLabelRatio: CGFloat = 16 / 162
    }

    // MARK: - Outlets
    @IBOutlet private weak var menuItemContainer: UIView!
    @IBOutlet private weak var robotsTitleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var programsTitleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var challengesTitleLabelTopConstraint: NSLayoutConstraint!
}

// MARK: - View lifecycle
extension MenuViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

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
    @IBAction private func blocklyButtonTapped(_ sender: Any) {
        navigationController?.pushViewController(BlocklyViewController(), animated: true)
    }
}
