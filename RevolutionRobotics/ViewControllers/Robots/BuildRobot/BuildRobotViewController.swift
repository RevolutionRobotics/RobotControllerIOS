//
//  BuildRobotViewController.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 18..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

class BuildRobotViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var currentStepCountLabel: UILabel!
    @IBOutlet private weak var overallStepCountLabel: UILabel!
    @IBOutlet private weak var bluetoothButton: RRButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(delegate: self)
    }
}
