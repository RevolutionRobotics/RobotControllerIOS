//
//  CarouselCollectionViewCell.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

class CarouselCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var baseHeight: NSLayoutConstraint!
    @IBOutlet private weak var baseWidth: NSLayoutConstraint!
    @IBOutlet private weak var backgroundImage: UIImageView!

    // MARK: - Variables
    private var baseHeightMultiplier: CGFloat = 0
    private var baseWidthMultiplier: CGFloat = 0

    var centered: Bool = false {
        didSet {
            backgroundImage.image = centered ? Image.BuildRobot.cellRedBorder : Image.BuildRobot.cellWhiteBorder
        }
    }
}

// MARK: - Functions
extension CarouselCollectionViewCell {
    func setSize(multiplier: CGFloat) {
        baseWidth = baseWidth.setMultiplier(multiplier: multiplier * baseWidthMultiplier)
        baseHeight = baseHeight.setMultiplier(multiplier: multiplier * baseHeightMultiplier)
    }
}

// MARK: - View lifecycle
extension CarouselCollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()

        baseHeightMultiplier = baseHeight.multiplier
        baseWidthMultiplier = baseWidth.multiplier
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        backgroundImage.image = Image.BuildRobot.cellWhiteBorder
    }
}
