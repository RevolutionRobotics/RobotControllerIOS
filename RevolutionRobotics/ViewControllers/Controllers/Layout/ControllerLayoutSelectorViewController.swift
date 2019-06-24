//
//  ControllerSelectorViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ControllerLayoutSelectorViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var gamerControllerLabel: UILabel!
    @IBOutlet private weak var gamerControllerButton: UIButton!
    @IBOutlet private weak var multiTaskerControllerLabel: UILabel!
    @IBOutlet private weak var multiTaskerControllerButton: UIButton!
    @IBOutlet private weak var driverControllerLabel: UILabel!
    @IBOutlet private weak var driverControllerButton: UIButton!
    @IBOutlet private weak var gamerButton: UIButton!
    @IBOutlet private weak var multiTaskerButton: UIButton!
    @IBOutlet private weak var driverButton: UIButton!

    // MARK: - Properties
    var configurationId: String?
}

// MARK: - View lifecycle
extension ControllerLayoutSelectorViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: ControllerKeys.selectorScreenTitle.translate(), delegate: self)
        gamerButton.setTitle(ControllerKeys.gamer.translate(), for: .normal)
        multiTaskerButton.setTitle(ControllerKeys.multiTasker.translate(), for: .normal)
        driverButton.setTitle(ControllerKeys.driver.translate(), for: .normal)
    }
}

// MARK: - Event handlers
extension ControllerLayoutSelectorViewController {
    @IBAction private func gamerButtonTapped(_ sender: Any) {
        let vc = AppContainer.shared.container.unwrappedResolve(PadConfigurationViewController.self)
        vc.configurationId = configurationId
        vc.controllerType = .gamer
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction private func multiTaskerButtonTapped(_ sender: Any) {
        let vc = AppContainer.shared.container.unwrappedResolve(PadConfigurationViewController.self)
        vc.configurationId = configurationId
        vc.controllerType = .multiTasker
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction private func driverButtonTapped(_ sender: Any) {
        let vc = AppContainer.shared.container.unwrappedResolve(PadConfigurationViewController.self)
        vc.configurationId = configurationId
        vc.controllerType = .driver
        navigationController?.pushViewController(vc, animated: true)
    }
}
