//
//  ChallengeDetailCollectionViewCell.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 05..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ChallengeDetailCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var partImageView: UIImageView!
    @IBOutlet private weak var partDescriptionLabel: UILabel!
}

// MARK: - Setup
extension ChallengeDetailCollectionViewCell {
    func setup(wiht part: Part) {
        partImageView.downloadImage(googleStorageURL: part.image)
        partDescriptionLabel.text = part.name
    }
}
