//
//  SettingsViewController.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class SettingsViewController: BaseViewController {
    // MARK: - Outlet
    @IBOutlet private weak var navigationBar: RRNavigationBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: "Settings", delegate: self)
    }
}
