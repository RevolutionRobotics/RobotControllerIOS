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
    @IBOutlet private weak var partStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(delegate: self)

        setup()
    }
}

// MARK: - Setup
extension BuildRobotViewController {
    func setup() {
        if let lastView = partStackView.arrangedSubviews.last as? PartView {
            lastView.isLast = true
        }
        partStackView.setBorder(showTopArrow: true, croppedCorners: [.topRight, .bottomLeft])
    }
}

// MARK: - Event handlers
extension BuildRobotViewController {
    @IBAction private func showPartsButtonTapped(_ sender: Any) {
        guard !partStackView.arrangedSubviews.isEmpty else {
            return
        }
        partStackView.isHidden = !partStackView.isHidden
    }
}
