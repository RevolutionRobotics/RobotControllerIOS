//
//  ChallengeFinishedModal.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 06..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ChallengeFinishedModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var finishedLabel: UILabel!
    @IBOutlet private weak var homeButton: RRButton!
    @IBOutlet private weak var listButton: RRButton!
    @IBOutlet private weak var nextButton: RRButton!

    // MARK: - Properties
    private let audioPlayer = AudioPlayer()
    var isLastChallenge: Bool = false {
        didSet {
            if isLastChallenge {
                nextButton.removeFromSuperview()
                self.layoutIfNeeded()
                listButton.backgroundColor = Color.blackTwo
                listButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
                homeButton.setBorder(fillColor: .clear, strokeColor: .clear, croppedCorners: [.bottomLeft])
                finishedLabel.text = ModalKeys.Challenge.lastChallengeFinished.translate().uppercased()
            }
        }
    }
    var homeCallback: Callback?
    var listCallback: Callback?
    var nextCallback: Callback?
}

// MARK: - View lifecycle
extension ChallengeFinishedModalView {
    override func awakeFromNib() {
        super.awakeFromNib()

        homeButton.backgroundColor = Color.black26
        homeButton.setBorder(fillColor: .clear, strokeColor: .clear, croppedCorners: [.bottomLeft])
        homeButton.setTitle(ModalKeys.Challenge.homeButton.translate(), for: .normal)
        listButton.backgroundColor = Color.black26
        listButton.setBorder(fillColor: .clear, strokeColor: .clear, croppedCorners: [])
        listButton.setTitle(ModalKeys.Challenge.listButton.translate(), for: .normal)
        nextButton.backgroundColor = Color.blackTwo
        nextButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
        nextButton.setTitle(ModalKeys.Challenge.nextButton.translate(), for: .normal)
        finishedLabel.text = ModalKeys.Challenge.challengeFinished.translate().uppercased()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        audioPlayer.playSound(name: "ta_da")
    }
}

// MARK: - Actions
extension ChallengeFinishedModalView {
    @IBAction private func homeTapped(_ sender: Any) {
        homeCallback?()
    }

    @IBAction private func listTapped(_ sender: Any) {
        listCallback?()
    }

    @IBAction private func nextTapped(_ sender: Any) {
        nextCallback?()
    }
}
