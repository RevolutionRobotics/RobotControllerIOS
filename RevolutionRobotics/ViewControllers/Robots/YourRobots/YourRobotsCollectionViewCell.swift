//
//  YourRobotsCollectionViewCell.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 30..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class YourRobotsCollectionViewCell: ResizableCell {
    // MARK: - Outlets
    @IBOutlet private weak var baseHeight: NSLayoutConstraint!
    @IBOutlet private weak var baseWidth: NSLayoutConstraint!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var lastModifiedLabel: UILabel!
    @IBOutlet private weak var statusImageView: UIImageView!
    @IBOutlet private weak var actionLabel: UILabel!
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var robotImageView: UIImageView!

    // MARK: - Properties
    private var baseHeightMultiplier: CGFloat = 0
    private var baseWidthMultiplier: CGFloat = 0
    private var baseNameFontSize: CGFloat = 0
    private var baseDescriptionFontSize: CGFloat = 0
    private var baseLastModifiedFontSize: CGFloat = 0
    private var baseActionFontSize: CGFloat = 0

    override var isCentered: Bool {
        didSet {
            if isFinished {
                backgroundImageView.image =
                    isCentered ? Image.YourRobots.cellRedBorderEditable :
                    Image.YourRobots.cellWhiteBorderEditable
            } else {
                backgroundImageView.image =
                    isCentered ? Image.YourRobots.cellRedBorderNonEditable :
                    Image.YourRobots.cellWhiteBorderNonEditable
            }
        }
    }

    var isFinished: Bool = false
    var editButtonHandler: Callback?
    var deleteButtonHandler: Callback?
}

// MARK: - View lifecycle
extension YourRobotsCollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()

        baseHeightMultiplier = baseHeight.multiplier
        baseWidthMultiplier = baseWidth.multiplier
        baseNameFontSize = nameLabel.font.pointSize
        baseDescriptionFontSize = descriptionLabel.font.pointSize
        baseLastModifiedFontSize = lastModifiedLabel.font.pointSize
        baseActionFontSize = actionLabel.font.pointSize
    }
}

// MARK: - Functions
extension YourRobotsCollectionViewCell {
    func configure(with robot: UserRobot) {
        nameLabel.text = robot.customName
        isFinished = robot.buildStatus == BuildStatus.completed.rawValue
        actionLabel.text = isFinished ? RobotsKeys.YourRobots.play.translate() :
            RobotsKeys.YourRobots.continueBuilding.translate()
        descriptionLabel.text = robot.customDescription
        let isCompleted = robot.buildStatus == BuildStatus.completed.rawValue
        editButton.isEnabled = isCompleted
        statusImageView.image = isCompleted ? Image.Common.calendar : Image.Common.underConstruction
        lastModifiedLabel.text = isCompleted ?
            dateFormatter.string(from: robot.lastModified) : RobotsKeys.YourRobots.underConstruction.translate()
        if let image = FileManager.default.image(for: robot.id) {
            robotImageView.image = image
        } else {
            if !robot.remoteId.isEmpty {
                robotImageView.downloadImage(googleStorageURL: robot.customImage)
            } else {
                robotImageView.image = Image.YourRobots.robotPlaceholder
            }
        }
    }

    override func set(multiplier: CGFloat) {
        baseWidth = baseWidth.setMultiplier(multiplier: multiplier * baseWidthMultiplier)
        baseHeight = baseHeight.setMultiplier(multiplier: multiplier * baseHeightMultiplier)
        nameLabel.font = nameLabel.font.withSize(baseNameFontSize * multiplier * multiplier)
        descriptionLabel.font = descriptionLabel.font.withSize(baseDescriptionFontSize * multiplier)
        lastModifiedLabel.font = lastModifiedLabel.font.withSize(baseLastModifiedFontSize * multiplier * multiplier)
        actionLabel.font = actionLabel.font.withSize(baseActionFontSize * multiplier * multiplier)
    }
}

// MARK: - Actions
extension YourRobotsCollectionViewCell {
    @IBAction private func editButtonTapped(_ sender: Any) {
        editButtonHandler?()
    }

    @IBAction private func deleteButtonTapped(_ sender: Any) {
        deleteButtonHandler?()
    }
}
