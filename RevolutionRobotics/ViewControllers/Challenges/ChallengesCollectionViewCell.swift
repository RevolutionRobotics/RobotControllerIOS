//
//  ChallengesCollectionViewCell.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 03..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

// MARK: - Progress
enum Progress {
    case unavailable
    case available
    case completed
}

final class ChallengesCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    enum Constants {
        static let inactiveAlpha: CGFloat = 0.4
    }

    // MARK: - Outlets
    @IBOutlet private weak var cardImageView: UIImageView!
    @IBOutlet private weak var lineImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var challengeNumberLabel: UILabel!
    @IBOutlet private weak var cardImageTopConstraint: NSLayoutConstraint!

    // MARK: - Properties
    var isFirstItem: Bool = false {
        didSet {
            lineImageView.isHidden = isFirstItem
        }
    }
    var progress: Progress = .unavailable
}

// MARK: - Setup
extension ChallengesCollectionViewCell {
    func setup(with challenge: Challenge, isEven: Bool, index: Int) {
        nameLabel.text = challenge.name
        challengeNumberLabel.text = "\(index)."
        if isEven {
            guard cardImageTopConstraint != nil else {
                return
            }
            cardImageTopConstraint.isActive = false
            cardImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }

        switch progress {
        case .unavailable:
            setUnavailable()
        case .available:
            setAvailable()
        case .completed:
            setCompleted()
        }
    }

    private func setUnavailable() {
        cardImageView.image = Image.Challenges.ChallengeInactiveCard
        lineImageView.image = Image.Challenges.ChallengeGreyLine
        lineImageView.alpha = Constants.inactiveAlpha
        nameLabel.alpha = Constants.inactiveAlpha
        challengeNumberLabel.alpha = Constants.inactiveAlpha
    }

    private func setAvailable() {
        cardImageView.image = Image.Challenges.ChallengeActiveCard
        lineImageView.image = Image.Challenges.ChallengeGreyLine
    }

    private func setCompleted() {
        cardImageView.image = Image.Challenges.ChallengeFinishedCard
        lineImageView.image = Image.Challenges.ChallengeGoldLine
        challengeNumberLabel.textColor = Color.blackTwo
    }
}
