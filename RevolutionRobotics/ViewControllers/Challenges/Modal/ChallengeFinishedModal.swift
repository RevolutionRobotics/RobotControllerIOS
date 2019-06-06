//
//  ChallengeFinishedModal.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 06..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ChallengeFinishedModal: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var finishedLabel: UILabel!
    @IBOutlet private weak var homeButton: RRButton!
    @IBOutlet private weak var listButton: RRButton!
    @IBOutlet private weak var nextButton: RRButton!

    // MARK: - Properties
    var isLastChallenge: Bool = false {
        didSet {
            if isLastChallenge {
                nextButton.removeFromSuperview()
                self.layoutIfNeeded()
                listButton.backgroundColor = Color.blackTwo
                listButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
                homeButton.setBorder(fillColor: .clear, strokeColor: .clear, croppedCorners: [.bottomLeft])
            }
        }
    }
    var homeCallback: Callback?
    var listCallback: Callback?
    var nextCallback: Callback?
}

// MARK: - View lifecycle
extension ChallengeFinishedModal {
    override func awakeFromNib() {
        super.awakeFromNib()

        homeButton.backgroundColor = Color.black26
        homeButton.setBorder(fillColor: .clear, strokeColor: .clear, croppedCorners: [.bottomLeft])
        listButton.backgroundColor = Color.black26
        listButton.setBorder(fillColor: .clear, strokeColor: .clear, croppedCorners: [])
        nextButton.backgroundColor = Color.blackTwo
        nextButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
    }
}

// MARK: - Action handlers
extension ChallengeFinishedModal {
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
