//
//  GamerConfigurationViewController.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 20..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import UIKit

final class PadConfigurationViewController: BaseViewController {
    // MARK: - Constants
    private enum Constants {
        static let nextButtonFont = Font.barlow(size: 14.0, weight: .medium)
        static let widthVisualFormat = "H:[configurationView(392)]"
        static let heightVisualFormat = "V:[configurationView(176)]"
        static let configurationView = "configurationView"
    }

    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var nextButton: RRButton!
    @IBOutlet private weak var containerView: UIView!

    // MARK: - Properties
    var controllerType: ControllerType = .gamer
    var configurationView: ConfigurableControllerView!
}

// MARK: - View lifecycle
extension PadConfigurationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: ControllerKeys.configureTitle.translate(), delegate: self)
        setupConfigurationView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupNextButton()
    }
}

// MARK: - Setups
extension PadConfigurationViewController {
    private func setupNextButton() {
        nextButton.setTitle(CommonKeys.next.translate(), for: .normal)
        nextButton.titleLabel?.font = Constants.nextButtonFont
        nextButton.setBorder(strokeColor: .white)
    }

    private func setupConfigurationView() {
        switch controllerType {
        case .gamer:
            configurationView = GamerConfigurationView.instatiate()
        case .driver:
            configurationView = DriverConfigurationView.instatiate()
        case .multiTasker:
            configurationView = MultiTaskerConfigurationView.instatiate()
        }

        configurationView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(configurationView)
        setupConstraints()
    }

    private func setupConstraints() {
        let height = NSLayoutConstraint.constraints(
            withVisualFormat: Constants.heightVisualFormat,
            options: [],
            metrics: nil,
            views: [Constants.configurationView: configurationView!])
        let width = NSLayoutConstraint.constraints(
            withVisualFormat: Constants.widthVisualFormat,
            options: [],
            metrics: nil,
            views: [Constants.configurationView: configurationView!])
        let centerX = NSLayoutConstraint(item: containerView!,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: configurationView,
                                         attribute: .centerX,
                                         multiplier: 1.0,
                                         constant: 0.0)
        let centerY = NSLayoutConstraint(item: containerView!,
                                         attribute: .centerY,
                                         relatedBy: .equal,
                                         toItem: configurationView,
                                         attribute: .centerY,
                                         multiplier: 1.0,
                                         constant: 0.0)
        containerView.addConstraints([centerY, centerX])
        configurationView.addConstraints(width + height)
    }
}
