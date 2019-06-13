//
//  ButtonlessProgramCollectionViewCell.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 12..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ButtonlessProgramTableViewCell: UITableViewCell {
    // MARK: - State
    enum State {
        case available
        case incompatible
        case selected
    }

    // MARK: - Outlets
    @IBOutlet private weak var selectButton: UIButton!
    @IBOutlet private weak var borderView: UIView!
    @IBOutlet private var separatorViews: [UIView]!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    // MARK: - Callbacks
    var selectedCallback: Callback?
    var infoCallback: Callback?
}

// MARK: - Setup
extension ButtonlessProgramTableViewCell {
    func update(state: State) {
        switch state {
        case .available:
            borderView.setBorder(fillColor: Color.black, strokeColor: Color.brownGrey)
            selectButton.setImage(Image.Programs.Buttonless.checkboxNotChecked, for: .normal)
            nameLabel.textColor = .white
            dateLabel.textColor = .white
            separatorViews.forEach { view in
                view.backgroundColor = Color.brownGrey
            }
        case .incompatible:
            borderView.setBorder(fillColor: Color.black, strokeColor: Color.brownGrey)
            selectButton.setImage(Image.Programs.Buttonless.checkboxIncompatible, for: .normal)
            nameLabel.textColor = Color.brownGrey
            dateLabel.textColor = Color.brownGrey
            separatorViews.forEach { view in
                view.backgroundColor = Color.brownGrey
            }
        case .selected:
            borderView.setBorder(fillColor: Color.black, strokeColor: Color.brightRed)
            selectButton.setImage(Image.Programs.Buttonless.checkboxChecked, for: .normal)
            nameLabel.textColor = .white
            dateLabel.textColor = .white
            separatorViews.forEach { view in
                view.backgroundColor = Color.brightRed
            }
        }
    }

    func setup(with program: ProgramDataModel) {
        nameLabel.text = program.name
        dateLabel.text = DateFormatter.string(from: program.lastModified,
                                              format: .yearMonthDay)
    }
}

// MARK: - Action handlers
extension ButtonlessProgramTableViewCell {
    @IBAction private func selectButtonTapped(_ sender: Any) {
        selectedCallback?()
    }

    @IBAction private func infoButtonTapped(_ sender: Any) {
        infoCallback?()
    }
}
