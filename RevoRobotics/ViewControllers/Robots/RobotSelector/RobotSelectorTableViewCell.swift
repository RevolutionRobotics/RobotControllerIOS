//
//  RobotSelectorTableViewCell.swift
//  RevolutionRobotics
//
//  Created by Pável Áron on 2019. 11. 06..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class RobotSelectorTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var borderView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!

    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        borderView.setBorder(fillColor: Color.black,
                             strokeColor: Color.brownGrey,
                             croppedCorners: [.bottomLeft, .topRight])
    }
}

// MARK: - Configure
extension RobotSelectorTableViewCell {
    func configure(robot: UserRobot) {
        nameLabel.text = robot.customName ?? ""
    }
}
