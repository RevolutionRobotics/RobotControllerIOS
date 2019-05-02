//
//  WhoToBuildCollectionViewCell.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class WhoToBuildCollectionViewCell: ResizableCell {
    // MARK: - Outlets
    @IBOutlet private weak var baseHeight: NSLayoutConstraint!
    @IBOutlet private weak var baseWidth: NSLayoutConstraint!
    @IBOutlet private weak var baseImageWidth: NSLayoutConstraint!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var buildTimeLabel: UILabel!
    @IBOutlet private weak var robotImageView: UIImageView!
    @IBOutlet private weak var robotNameLabel: UILabel!

    // MARK: - Variables
    private var baseHeightMultiplier: CGFloat = 0
    private var baseWidthMultiplier: CGFloat = 0
    private var baseImageWidthMultiplier: CGFloat = 0
    private var baseNameFontSize: CGFloat = 0
    private var baseBuildTimeFontSize: CGFloat = 0

    override var isCentered: Bool {
        didSet {
            backgroundImageView.image = isCentered ? Image.BuildRobot.cellRedBorder : Image.BuildRobot.cellWhiteBorder
        }
    }
}

// MARK: - Functions
extension WhoToBuildCollectionViewCell {
    func configure(with robot: Robot) {
        robotNameLabel.text = robot.name
        buildTimeLabel.text = robot.buildTime
        robotImageView.downloadImage(googleStorageURL: robot.coverImageGSURL)
    }

    override func set(multiplier: CGFloat) {
        baseWidth = baseWidth.setMultiplier(multiplier: multiplier * baseWidthMultiplier)
        baseHeight = baseHeight.setMultiplier(multiplier: multiplier * baseHeightMultiplier)
        baseImageWidth = baseImageWidth.setMultiplier(multiplier: multiplier * baseImageWidthMultiplier)
        robotNameLabel.font = robotNameLabel.font.withSize(baseNameFontSize * multiplier * multiplier)
        buildTimeLabel.font = buildTimeLabel.font.withSize(baseBuildTimeFontSize * multiplier * multiplier)
    }
}

// MARK: - View lifecycle
extension WhoToBuildCollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()

        baseHeightMultiplier = baseHeight.multiplier
        baseWidthMultiplier = baseWidth.multiplier
        baseImageWidthMultiplier = baseImageWidth.multiplier
        baseNameFontSize = robotNameLabel.font.pointSize
        baseBuildTimeFontSize = buildTimeLabel.font.pointSize
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        backgroundImageView.image = Image.BuildRobot.cellWhiteBorder
    }
}
