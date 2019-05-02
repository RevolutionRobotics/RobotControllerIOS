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
    @IBOutlet private weak var actionLabel: UILabel!

    // MARK: - Variables
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
    func configure(with robot: Robot) {
    }

    override func set(multiplier: CGFloat) {
        baseWidth = baseWidth.setMultiplier(multiplier: multiplier * baseWidthMultiplier)
        baseHeight = baseHeight.setMultiplier(multiplier: multiplier * baseHeightMultiplier)
        nameLabel.font = nameLabel.font.withSize(baseNameFontSize * multiplier * multiplier)
        descriptionLabel.font = descriptionLabel.font.withSize(baseDescriptionFontSize * multiplier * multiplier)
        lastModifiedLabel.font = lastModifiedLabel.font.withSize(baseLastModifiedFontSize * multiplier * multiplier)
        actionLabel.font = actionLabel.font.withSize(baseActionFontSize * multiplier * multiplier)
    }
}
