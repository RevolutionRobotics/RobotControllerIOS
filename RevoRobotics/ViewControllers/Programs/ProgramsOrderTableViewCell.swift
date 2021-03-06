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
    @IBOutlet private var innerSeparatorViews: [UIView]!
    @IBOutlet private weak var orderLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var infoButton: UIButton!
    @IBOutlet private weak var programIcon: UIImageView!
    @IBOutlet private weak var leftView: UIView!

    // MARK: - Properties
    private var infoCallback: Callback?
    private var hasCustomBorder: Bool = false
}

// MARK: - Setup
extension ProgramsOrderTableViewCell {
    func setup(with program: ProgramDataModel, order: Int, isButtonlessProgram: Bool, infoCallback: Callback?) {
        nameLabel.text = program.name
        dateLabel.text = DateFormatter.string(from: program.lastModified, format: .yearMonthDay)
        orderLabel.text = "\(order)."
        programIcon.image = isButtonlessProgram ? Image.Programs.Priority.buttonless : Image.Programs.Priority.button
        self.infoCallback = infoCallback

        infoButton.isHidden = infoCallback == nil
        dateLabel.isHidden = infoCallback == nil
        innerSeparatorViews.forEach { $0.isHidden = infoCallback == nil }
    }

    func setSelectedState(_ isSelected: Bool) {
        hasCustomBorder = isSelected
        if isSelected {
            borderView.setBorder(fillColor: Color.black, strokeColor: Color.brightRed)
            leftView.backgroundColor = Color.brightRed
        } else {
            borderView.setBorder(fillColor: Color.black, strokeColor: Color.brownGrey)
            leftView.backgroundColor = Color.brownGrey
        }

        setNeedsLayout()
    }
}

// MARK: - View lifecycle
extension ProgramsOrderTableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        if !hasCustomBorder {
            borderView.setBorder(fillColor: Color.black, strokeColor: Color.brownGrey)
            leftView.backgroundColor = Color.brownGrey
        }
    }
}

// MARK: - Actions
extension ProgramsOrderTableViewCell {
    @IBAction private func infoButtonTapped(_ sender: Any) {
        infoCallback?()
    }
}
