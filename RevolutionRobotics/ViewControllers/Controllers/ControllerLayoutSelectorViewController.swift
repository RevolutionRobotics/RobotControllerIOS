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

    // MARK: - Callbacks
    var gamerCallback: Callback?
    var multiTaskerCallback: Callback?
    var driverCallback: Callback?
}

// MARK: - View lifecycle
extension ControllerLayoutSelectorViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: ControllerKeys.selectorScreenTitle.translate(), delegate: self)
    }
}

// MARK: - Event handlers
extension ControllerLayoutSelectorViewController {
    @IBAction private func gamerButtonTapped(_ sender: Any) {
        gamerCallback?()
    }

    @IBAction private func multiTaskerButtonTapped(_ sender: Any) {
        multiTaskerCallback?()
    }

    @IBAction private func driverButtonTapped(_ sender: Any) {
        driverCallback?()
    }
}
