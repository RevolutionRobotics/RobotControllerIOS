//
//  ChallengeDetailHorizontalContent.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 27..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ChallengeDetailHorizontalContent: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var challengeImageView: UIImageView!
}

// MARK: - ChallengeDetailContent
extension ChallengeDetailHorizontalContent: ChallengeDetailContentProtocol {
    func setup(with step: ChallengeStep) {
        descriptionLabel.text = step.description
        challengeImageView.downloadImage(googleStorageURL: step.image)
    }
}
