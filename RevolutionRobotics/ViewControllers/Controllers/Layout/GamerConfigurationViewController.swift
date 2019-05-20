//
//  GamerConfigurationViewController.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 20..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation

final class GamerConfigurationViewController: BaseViewController {
    // MARK: - Constants
    private enum Constants {
        static let nextButtonFont = Font.barlow(size: 14.0, weight: .medium)
    }

    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var nextButton: RRButton!
}

// MARK: - View lifecycle
extension GamerConfigurationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: ControllerKeys.configureTitle.translate(), delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupNextButton()
    }
}

// MARK: - Setups
extension GamerConfigurationViewController {
    private func setupNextButton() {
        nextButton.setTitle(CommonKeys.next.translate(), for: .normal)
        nextButton.titleLabel?.font = Constants.nextButtonFont
        nextButton.setBorder(strokeColor: .white)
    }
}
