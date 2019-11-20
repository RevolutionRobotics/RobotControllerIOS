//
//  VariableContextCell.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 06. 14..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class VariableContextCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var checkboxImageView: UIImageView!
    @IBOutlet private weak var borderView: UIView!
    @IBOutlet private weak var croppedView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!

    override var isSelected: Bool {
        didSet {
            updateViewCell()
        }
    }
}

// MARK: - Setup
extension VariableContextCell {
    func setup(variableName: String) {
        nameLabel.text = variableName
    }

    private func selectedViewState() {
        checkboxImageView.image = Image.Programs.Buttonless.checkboxChecked
        borderView.setBorder(fillColor: .clear, strokeColor: Color.brightRed)
        croppedView.backgroundColor = Color.brightRed
    }

    private func normalViewState() {
        checkboxImageView.image = Image.Programs.Buttonless.checkboxNotChecked
        borderView.setBorder(fillColor: .clear, strokeColor: Color.brownishGrey)
        croppedView.backgroundColor = Color.brownishGrey
    }

    private func updateViewCell() {
        (isSelected ? selectedViewState : normalViewState)()
    }
}

// MARK: - View lifecycle
extension VariableContextCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        updateViewCell()
    }
}
