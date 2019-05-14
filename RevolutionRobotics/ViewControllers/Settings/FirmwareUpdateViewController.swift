//
//  FirmwareUpdateViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 13..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class FirmwareUpdateViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var newConnectionButton: SideButton!
}

// MARK: - View lifecycle
extension FirmwareUpdateViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: SettingsKeys.Firmware.title.translate(), delegate: self)
        newConnectionButton.title = SettingsKeys.Firmware.newConnectionButton.translate()
        newConnectionButton.image = Image.Common.bluetoothWhiteIcon
        newConnectionButton.selectionHandler = {
        }
    }
}
