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
}

// MARK: - Setup
extension ChallengeCategoryCollectionViewCell {
    func setup(with challengeCategory: ChallengeCategory) {
        categoryName.text = challengeCategory.name
        categoryImageView.downloadImage(googleStorageURL: challengeCategory.image)
    }
}

// MARK: - View lifecycle
extension ChallengeCategoryCollectionViewCell {
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
