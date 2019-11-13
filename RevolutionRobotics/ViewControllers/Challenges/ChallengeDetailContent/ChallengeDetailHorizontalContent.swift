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
        guard let data = step.description.text.data(using: .utf8) else { return }

        do {
            try descriptionLabel.attributedText = NSAttributedString(data: data, options: [:], documentAttributes: nil)
            descriptionLabel.font = UIFont(name: descriptionLabel.font.familyName, size: Constants.fontSize)
        } catch let err {
            fatalError(err.localizedDescription)
        }

        challengeImageView.downloadImage(googleStorageURL: step.image)
    }
}
