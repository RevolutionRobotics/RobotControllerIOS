//
//  TestingModal.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 25..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class TestingModal: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var testImageView: UIImageView!
    @IBOutlet private weak var testInstructionLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var positiveButton: RRButton!
    @IBOutlet private weak var negativeButton: RRButton!

    // MARK: - Callbacks
    var positiveButtonTapped: Callback?
    var negativeButtonTapped: Callback?
}

// MARK: - View lifecycle
extension TestingModal {
    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.text = RobotsKeys.BuildRobot.testingTitle.translate().uppercased()
        questionLabel.text = RobotsKeys.BuildRobot.testingQuestion.translate().uppercased()
        negativeButton.setTitle(RobotsKeys.BuildRobot.testingNegativeButtonTitle.translate(), for: .normal)
        positiveButton.setTitle(RobotsKeys.BuildRobot.testingPositiveButtonTitle.translate(), for: .normal)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        negativeButton.setBorder(fillColor: .clear, strokeColor: Color.blackTwo, croppedCorners: [.bottomLeft])
        positiveButton.setBorder(fillColor: .clear, strokeColor: UIColor.white, croppedCorners: [.topRight])
    }
}

// MARK: - Setup
extension TestingModal {
    func setup(with milestone: Milestone) {
        testImageView.downloadImage(googleStorageURL: milestone.image)
        testInstructionLabel.text = milestone.testDescription
    }
}

// MARK: - Event handlers
extension TestingModal {
    @IBAction private func positiveButtonTapped(_ sender: Any) {
        positiveButtonTapped?()
    }

    @IBAction private func negativeButtonTapped(_ sender: Any) {
        negativeButtonTapped?()
    }
}
