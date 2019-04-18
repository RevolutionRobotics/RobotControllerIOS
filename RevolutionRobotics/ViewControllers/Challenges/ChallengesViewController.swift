//
//  ChallengesViewController.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ChallengesViewController: BaseViewController {
    // MARK: - Outlet
    @IBOutlet private weak var navigationBar: RRNavigationBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: "Challenges", delegate: self)
    }
}
