//
//  ProgramSelectorTableViewCell.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 05. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ProgramSelectorTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var borderView: UIView!
    @IBOutlet private weak var leftView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    // MARK: - Properties
    var infoButtonCallback: Callback?
    var editButtonCallback: Callback?

    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        borderView.setBorder(fillColor: Color.black,
                             strokeColor: Color.brownGrey,
                             croppedCorners: [.bottomLeft, .topRight])
    }
}

// MARK: - Configure
extension ProgramSelectorTableViewCell {
    func configure(program: ProgramDataModel) {
        nameLabel.text = program.name
        dateLabel.text = DateFormatter.string(from: program.lastModified, format: .yearMonthDay)
    }
}

// MARK: - Actions
extension ProgramSelectorTableViewCell {
    @IBAction private func infoButtonTapped(_ sender: Any) {
        infoButtonCallback?()
    }

    @IBAction private func editButtonTapped(_ sender: Any) {
        editButtonCallback?()
    }
}
