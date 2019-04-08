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
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction private func blocklyButtonTapped(_ sender: Any) {
        navigationController?.pushViewController(BlocklyViewController(), animated: true)
    }
}
