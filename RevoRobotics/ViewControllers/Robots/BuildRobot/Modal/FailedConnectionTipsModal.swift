//
//  FailedConnectionTipsModal.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 26..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class TipsModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var tipsTitleLabel: UILabel!
    @IBOutlet private weak var skipConnectionButton: RRButton!
    @IBOutlet private weak var tryAgainButton: RRButton!
    @IBOutlet private weak var communityButton: RRButton!
    @IBOutlet private weak var instructionLabel: UILabel!
    @IBOutlet private weak var tipsLabel: UILabel!

    // MARK: - Properties
    var communityCallback: Callback?
    var tryAgainCallback: Callback?
    var skipCallback: Callback?
    var skipTitle: String? {
        get {
            return skipConnectionButton.titleLabel?.text
        }
        set {
            skipConnectionButton.titleLabel?.text = newValue
        }
    }
}

// MARK: - View lifecycle
extension TipsModalView {
    override func awakeFromNib() {
        super.awakeFromNib()

        skipConnectionButton.setBorder(fillColor: Color.black26, croppedCorners: [.bottomLeft])
        communityButton.setBorder(fillColor: Color.black26, croppedCorners: [])
        tryAgainButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
    }
}

// MARK: - Event handlers
extension TipsModalView {
    @IBAction private func communityButtonTapped(_ sender: Any) {
        communityCallback?()
    }

    @IBAction private func tryAgainButtonTapped(_ sender: Any) {
        tryAgainCallback?()
    }

    @IBAction private func skipButtonTapped(_ sender: Any) {
        skipCallback?()
    }
}
