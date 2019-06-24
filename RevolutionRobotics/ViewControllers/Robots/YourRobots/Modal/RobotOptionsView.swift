//
//  RobotOptionsView.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 06. 02..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class RobotOptionsView: UIView {
    // MARK: - Constants
    private enum Constants {
        static let titleFont = Font.jura(size: 18.0, weight: .bold)
        static let descriptionFont = Font.barlow(size: 12.0, weight: .regular)
        static let dateFont = Font.barlow(size: 12.0, weight: .medium)
    }

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var deleteButton: RRButton!
    @IBOutlet private weak var duplicateButton: RRButton!
    @IBOutlet private weak var editButton: RRButton!

    // MARK: - Properties
    var deleteHandler: Callback?
    var duplicateHandler: Callback?
    var editHandler: Callback?

    var isCompatible: Bool = false {
        didSet {
            errorLabel.isHidden = false
        }
    }
    var robot: UserRobot? {
        didSet {
            setupRobotDetails()

            guard let robotStatus = robot?.buildStatus,
                let status = BuildStatus(rawValue: robotStatus),
                status != .completed else {
                    return
            }

            removeEditButton()
        }
    }
}

// MARK: - View lifecycle
extension RobotOptionsView {
    override func awakeFromNib() {
        super.awakeFromNib()

        setupLabels()
        setupButtons()
    }
}

// MARK: - Setups
extension RobotOptionsView {
    private func setupLabels() {
        titleLabel.font = Constants.titleFont
        descriptionLabel.font = Constants.descriptionFont
        dateLabel.font = Constants.descriptionFont
        errorLabel.font = Constants.descriptionFont
        errorLabel.text = ModalKeys.RobotInfo.error.translate()
    }

    private func setupButtons() {
        deleteButton.setBorder(fillColor: .clear, strokeColor: .clear, croppedCorners: [.bottomLeft])
        deleteButton.setTitle(ModalKeys.RobotInfo.delete.translate(), for: .normal)
        duplicateButton.setBorder(fillColor: .clear, strokeColor: .clear, croppedCorners: [])
        duplicateButton.setTitle(ModalKeys.RobotInfo.duplicate.translate(), for: .normal)
        editButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
        editButton.setTitle(ModalKeys.RobotInfo.edit.translate(), for: .normal)
    }

    private func setupRobotDetails() {
        titleLabel.text = robot?.customName
        descriptionLabel.text = robot?.customDescription
        dateLabel.text = DateFormatter.string(from: robot?.lastModified, format: .yearMonthDay)
    }

    private func removeEditButton() {
        editButton.removeFromSuperview()
        setNeedsLayout()
        layoutIfNeeded()
        deleteButton.setBorder(fillColor: Color.black26, strokeColor: .clear, croppedCorners: [.bottomLeft])
        duplicateButton.setBorder(fillColor: Color.black26, strokeColor: .clear, croppedCorners: [.topRight])
    }
}

// MARK: - Actions
extension RobotOptionsView {
    @IBAction private func deleteButtonTapped(_ sender: Any) {
        deleteHandler?()
    }

    @IBAction private func duplicateButtonTapped(_ sender: Any) {
        duplicateHandler?()
    }

    @IBAction private func editButtonTapped(_ sender: Any) {
        editHandler?()
    }
}
