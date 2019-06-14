//
//  ProgramsOrderTableViewCell.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 12..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ProgramsOrderTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var borderView: UIView!
    @IBOutlet private weak var orderLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    // MARK: - Callbacks
    var infoCallback: Callback?
}

// MARK: - Setup
extension ProgramsOrderTableViewCell {
    func setup(with program: ProgramDataModel, order: Int) {
        nameLabel.text = program.name
        dateLabel.text = DateFormatter.string(from: program.lastModified, format: .yearMonthDay)
        orderLabel.text = "\(order)."
        borderView.setBorder(fillColor: Color.black, strokeColor: Color.brownGrey)
    }
}

// MARK: - Action handlers
extension ProgramsOrderTableViewCell {
    @IBAction private func infoButtonTapped(_ sender: Any) {
        infoCallback?()
    }
}
