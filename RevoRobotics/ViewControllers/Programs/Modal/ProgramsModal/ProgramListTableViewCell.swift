//
//  ProgramListTableViewCell.swift
//  RevolutionRobotics
//
//  Created by Pável Áron on 2019. 11. 13..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ProgramListTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var borderView: UIView!
    @IBOutlet private weak var leftView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var robotNameLabel: UILabel!

    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        borderView.setBorder(fillColor: Color.black,
                             strokeColor: Color.brownGrey,
                             croppedCorners: [.bottomLeft, .topRight])
        leftView.backgroundColor = Color.brownGrey
    }
}

// MARK: - Setup
extension ProgramListTableViewCell {
    func setup(with programName: String, robotName: String?) {
        nameLabel.text = programName
        robotNameLabel.text = robotName ?? "?"
    }
}
