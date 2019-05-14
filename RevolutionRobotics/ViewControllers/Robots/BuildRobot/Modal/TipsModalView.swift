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
    @IBOutlet private weak var instructionLabel: UILabel!
    @IBOutlet private weak var tipsLabel: UILabel!
    @IBOutlet private weak var skipConnectionButton: RRButton!
    @IBOutlet private weak var tryAgainButton: RRButton!
    @IBOutlet private weak var communityButton: RRButton!

    // MARK: - Properties
    var communityCallback: Callback?
    var tryAgainCallback: Callback?
    var skipCallback: Callback?
    var title: String? {
        get {
            return tipsTitleLabel.text
        }
        set {
            tipsTitleLabel.text = newValue
        }
    }
    var subtitle: String? {
        get {
            return instructionLabel.text
        }
        set {
            instructionLabel.text = newValue
        }
    }
    var tips: String? {
        get {
            return tipsLabel.text
        }
        set {
            tipsLabel.text = newValue
        }
    }
    var skipTitle: String? {
        get {
            return skipConnectionButton.titleLabel?.text
        }
        set {
            skipConnectionButton.setTitle(newValue, for: .normal)
        }
    }
    var communityTitle: String? {
        get {
            return communityButton.titleLabel?.text
        }
        set {
            communityButton.setTitle(newValue, for: .normal)
        }
    }
    var tryAgainTitle: String? {
        get {
            return communityButton.titleLabel?.text
        }
        set {
            tryAgainButton.setTitle(newValue, for: .normal)
        }
    }

    var isSkipButtonHidden: Bool = false {
        didSet {
            if isSkipButtonHidden {
                skipConnectionButton.removeFromSuperview()
                setupBorders()
            }
        }
    }
}

// MARK: - Functions
extension TipsModalView {
    private func setupBorders() {
        layoutIfNeeded()
        if isSkipButtonHidden {
            communityButton.setBorder(fillColor: Color.black26, croppedCorners: [.bottomLeft])
        } else {
            skipConnectionButton.setBorder(fillColor: Color.black26, croppedCorners: [.bottomLeft])
            communityButton.setBorder(fillColor: Color.black26, croppedCorners: [])
        }
        tryAgainButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
    }
}

// MARK: - View lifecycle
extension TipsModalView {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.setupBorders()
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
