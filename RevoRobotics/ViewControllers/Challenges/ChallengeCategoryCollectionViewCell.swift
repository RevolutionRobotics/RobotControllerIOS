//
//  ChallengeCategoryCollectionViewCell.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 03..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ChallengeCategoryCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var categoryImageView: UIImageView!
    @IBOutlet private weak var categoryName: UILabel!
    @IBOutlet private weak var categoryProgress: UILabel!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var cornerImageView: UIImageView!

    // MARK: - Properties
    var index: Int = 0
    var completedCount: Int = 0
}

// MARK: - Setup
extension ChallengeCategoryCollectionViewCell {
    func setup(with challengeCategory: ChallengeCategory, userCategory: ChallengeCategoryDataModel?) {
        categoryName.text = challengeCategory.name.text
        categoryImageView.downloadImage(from: challengeCategory.image)

        if completedCount == challengeCategory.challenges.count {
            backgroundImageView.image = Image.Challenges.ChallengeCategoryCardGold
            cornerImageView.image = Image.Challenges.ChallengeCategoryCardGoldCorner
            categoryProgress.textColor = .black
        } else {
            backgroundImageView.image = Image.Challenges.ChallengeCategoryCardGrey
            cornerImageView.image = Image.Challenges.ChallengeCategoryCardGreyCorner
            categoryProgress.textColor = .white
        }
        progressView.progress = Float(completedCount) / Float(challengeCategory.challenges.count)
        categoryProgress.text =
            ChallengesKeys.Main.progress.translate(args: completedCount, challengeCategory.challenges.count)
    }
}

// MARK: - View lifecycle
extension ChallengeCategoryCollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()

        layoutIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let size = progressView.bounds.height / 2
        let maskLayerPath = UIBezierPath(roundedRect: progressView.bounds,
                                         byRoundingCorners: [.topLeft, .bottomLeft],
                                         cornerRadii: CGSize(width: size, height: size))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = progressView.bounds
        maskLayer.path = maskLayerPath.cgPath
        progressView.layer.mask = maskLayer
    }
}
