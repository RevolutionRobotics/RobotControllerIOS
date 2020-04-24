//
//  TestingModalView.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 25..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class TestingModalView: UIView {
    // MARK: - TestingModalType
    enum TestingModalType {
        case motor
        case drive
        case distance
        case bumper
        case milestone(Milestone)
    }

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var testImageView: UIImageView!
    @IBOutlet private weak var testInstructionLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var positiveButton: RRButton!
    @IBOutlet private weak var negativeButton: RRButton!

    // MARK: - Properties
    var positiveButtonTapped: Callback?
    var negativeButtonTapped: Callback?
}

// MARK: - View lifecycle
extension TestingModalView {
    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.text = ModalKeys.Testing.testingTitle.translate().uppercased()
        questionLabel.text = ModalKeys.Testing.testingQuestion.translate().uppercased()
        negativeButton.setTitle(ModalKeys.Testing.testingNegativeButtonTitle.translate(), for: .normal)
        positiveButton.setTitle(ModalKeys.Testing.testingPositiveButtonTitle.translate(), for: .normal)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        negativeButton.setBorder(fillColor: .clear, strokeColor: Color.blackTwo, croppedCorners: [.bottomLeft])
        positiveButton.setBorder(fillColor: .clear, strokeColor: UIColor.white, croppedCorners: [.topRight])
    }
}

// MARK: - Setup
extension TestingModalView {
    func setup(with type: TestingModalType) {
        switch type {
        case .bumper:
            testImageView.image = Image.Testing.BumperTestImage
            testInstructionLabel.text = ModalKeys.Testing.bumperTest.translate()
        case .distance:
            testImageView.image = Image.Testing.distanceTestImage
            testInstructionLabel.text = ModalKeys.Testing.distanceTest.translate()
        case .drive:
            testImageView.image = Image.Testing.driveTestImage
            testInstructionLabel.text = ModalKeys.Testing.driveTest.translate()
        case .motor:
            testImageView.image = Image.Testing.MotorTestImage
            testInstructionLabel.text = ModalKeys.Testing.motorTest.translate()
        case .milestone(let milestone):
            testImageView.downloadImage(from: milestone.testImage)
            testInstructionLabel.text = milestone.testDescription.text
        }
    }
}

// MARK: - Actions
extension TestingModalView {
    @IBAction private func positiveButtonTapped(_ sender: Any) {
        positiveButtonTapped?()
    }

    @IBAction private func negativeButtonTapped(_ sender: Any) {
        negativeButtonTapped?()
    }
}
