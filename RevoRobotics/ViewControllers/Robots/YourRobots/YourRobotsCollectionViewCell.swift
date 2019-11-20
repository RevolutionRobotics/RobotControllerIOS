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
    @IBOutlet private weak var robotImageView: UIImageView!
    @IBOutlet private weak var underConstructionBg: UIImageView!
    @IBOutlet private weak var optionsButton: UIButton!

    // MARK: - Properties
    private var baseHeightMultiplier: CGFloat = 0
    private var baseWidthMultiplier: CGFloat = 0
    private var baseNameFontSize: CGFloat = 0
    private var baseDescriptionFontSize: CGFloat = 0
    private var baseLastModifiedFontSize: CGFloat = 0
    private var baseActionFontSize: CGFloat = 0

    override var isCentered: Bool {
        didSet {
            guard statusImageView.image != nil else {
                backgroundImageView.image =
                    isCentered ? Image.BuildRobot.cellRedBorder :
                    Image.BuildRobot.cellWhiteBorder

                    NSLayoutConstraint.activate([
                        actionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
                    ])
                return
            }

            backgroundImageView.image =
                isCentered ? Image.YourRobots.cellRedBorderEditable :
                Image.YourRobots.cellWhiteBorderEditable
        }
    }

    var optionsButtonHandler: Callback?
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
        descriptionLabel.text = robot.customDescription

        switch robot.buildStatus {
        case BuildStatus.new.rawValue:
            configureNewCard()
            return
        case BuildStatus.inProgress.rawValue, BuildStatus.initial.rawValue:
            actionLabel.text = RobotsKeys.YourRobots.continueBuilding.translate()
        case BuildStatus.completed.rawValue:
            actionLabel.text = RobotsKeys.YourRobots.play.translate()
        case BuildStatus.invalidConfiguration.rawValue:
            actionLabel.text = RobotsKeys.YourRobots.continueEditing.translate()
        default:
            break
        }

        let isCompleted = robot.buildStatus == BuildStatus.completed.rawValue
        underConstructionBg.isHidden = isCompleted
        statusImageView.image = isCompleted ? Image.Common.calendar : Image.Common.underConstruction
        lastModifiedLabel.text = isCompleted ?
            DateFormatter.string(from: robot.lastModified, format: .yearMonthDay) :
            RobotsKeys.YourRobots.underConstruction.translate()
        if let image = FileManager.default.image(for: robot.id) {
            robotImageView.image = image
        } else {
            if !robot.remoteId.isEmpty {
                robotImageView.downloadImage(googleStorageURL: robot.customImage)
            } else {
                robotImageView.image = Image.Common.imagePlaceholder
            }
        }
    }

    private func configureNewCard() {
        actionLabel.text = RobotsKeys.YourRobots.create.translate()
        robotImageView.translatesAutoresizingMaskIntoConstraints = false
        robotImageView.image = UIImage(named: "build-new")
        statusImageView.image = nil
        lastModifiedLabel.text = nil

        let scale: CGFloat = 2.0
        let scaledWidth = robotImageView.frame.size.width * scale
        let scaledHeight = robotImageView.frame.size.height * scale

        NSLayoutConstraint.activate([
            robotImageView.widthAnchor.constraint(equalToConstant: scaledWidth),
            robotImageView.heightAnchor.constraint(equalToConstant: scaledHeight),
            robotImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
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
    @IBAction private func deleteButtonTapped(_ sender: Any) {
        optionsButtonHandler?()
    }
}
