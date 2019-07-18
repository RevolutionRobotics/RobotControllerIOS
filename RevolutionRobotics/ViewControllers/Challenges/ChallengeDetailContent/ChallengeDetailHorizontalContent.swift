//
//  ChallengeDetailHorizontalContent.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 27..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ChallengeDetailHorizontalContent: UIView {
    // MARK: - Constants
    private enum Constants {
        static let fontSize: CGFloat = 18.0
    }

    // MARK: - Outlets
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var challengeImageView: UIImageView!
}

// MARK: - ChallengeDetailContent
extension ChallengeDetailHorizontalContent: ChallengeDetailContentProtocol {
    func setup(with step: ChallengeStep) {
        descriptionLabel.attributedText = NSAttributedString.attributedString(from: step.description.text,
                                                                              fontSize: Constants.fontSize)
        challengeImageView.downloadImage(googleStorageURL: step.image)
    }
}
