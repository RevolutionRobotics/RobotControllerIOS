//
//  PeripheralTableViewCell.swift
//  RevolutionRobotics
//
//  Created by Pável Áron on 2019. 11. 12..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class PeripheralTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var borderView: UIView!
    @IBOutlet private weak var leftView: UIView!

    // MARK: - Properties
    private var hasCustomBorder: Bool = false
}

// MARK: - Setup
extension PeripheralTableViewCell {
    func setup(with title: String) {
        titleLabel.text = title
    }

    func setSelectedState(_ isSelected: Bool) {
        hasCustomBorder = isSelected
        let stateColor = isSelected ? Color.brightRed : Color.brownGrey

        borderView.setBorder(fillColor: Color.black, strokeColor: stateColor)
        leftView.backgroundColor = stateColor

        setNeedsLayout()
    }
}

// MARK: - View lifecycle
extension PeripheralTableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        if !hasCustomBorder {
            borderView.setBorder(fillColor: Color.black, strokeColor: Color.brownGrey)
            leftView.backgroundColor = Color.brownGrey
        }
    }
}
