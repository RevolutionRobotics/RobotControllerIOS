//
//  ChapterFinishedModalView.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 26..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ChapterFinishedModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var testLaterButton: UIButton!
    @IBOutlet private weak var testNowButton: UIButton!

    // MARK: - Properties
    var testLaterButtonTapped: Callback?
    var testNowButtonTapped: Callback?
}

// MARK: - View lifecycle
extension ChapterFinishedModalView {
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = RobotsKeys.BuildRobot.ChapterFinished.title.translate().uppercased()
        subtitleLabel.text = RobotsKeys.BuildRobot.ChapterFinished.description.translate().uppercased()

        testLaterButton.setBorder(fillColor: Color.black26, croppedCorners: [.bottomLeft])
        testLaterButton.setTitle(RobotsKeys.BuildRobot.ChapterFinished.testLaterButton.translate(), for: .normal)

        testNowButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
        testNowButton.setTitle(RobotsKeys.BuildRobot.ChapterFinished.testNowButton.translate(), for: .normal)
    }
}

// MARK: - Actions
extension ChapterFinishedModalView {
    @IBAction private func testLaterButtonTapped(_ sender: Any) {
        testLaterButtonTapped?()
    }

    @IBAction private func testNowButtonTapped(_ sender: Any) {
        testNowButtonTapped?()
    }
}
