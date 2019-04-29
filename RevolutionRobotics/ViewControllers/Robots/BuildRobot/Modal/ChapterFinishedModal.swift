//
//  ChapterFinishedModal.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 26..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ChapterFinishedModal: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var homeButton: UIButton!
    @IBOutlet private weak var testLaterButton: UIButton!
    @IBOutlet private weak var testNowButton: UIButton!

    // MARK: - Callbacks
    var homeButtonTapped: Callback?
    var testLaterButtonTapped: Callback?
    var testNowButtonTapped: Callback?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = RobotsKeys.BuildRobot.ChapterFinished.title.translate().uppercased()
        subtitleLabel.text = RobotsKeys.BuildRobot.ChapterFinished.description.translate().uppercased()

        homeButton.setBorder(fillColor: Color.black26, croppedCorners: [.bottomLeft])
        homeButton.setTitle(RobotsKeys.BuildRobot.ChapterFinished.homeButton.translate(), for: .normal)

        testLaterButton.setBorder(fillColor: Color.black26, croppedCorners: [])
        testLaterButton.setTitle(RobotsKeys.BuildRobot.ChapterFinished.testLaterButton.translate(), for: .normal)

        testNowButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
        testNowButton.setTitle(RobotsKeys.BuildRobot.ChapterFinished.testNowButton.translate(), for: .normal)
    }

    // MARK: - Actions
    @IBAction private func homeButtonTapped(_ sender: Any) {
        homeButtonTapped?()
    }

    @IBAction private func testLaterButtonTapped(_ sender: Any) {
        testLaterButtonTapped?()
    }

    @IBAction private func testNowButtonTapped(_ sender: Any) {
        testNowButtonTapped?()
    }
}
