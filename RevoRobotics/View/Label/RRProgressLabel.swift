//
//  RRProgressLabel.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 03..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class RRProgressLabel: UILabel {
    // MARK: - Contants
    private enum Constants {
        static let separator = " / "
        static let regularFont = Font.barlow(size: 15.0)
        static let boldFont = Font.barlow(size: 15.0, weight: .bold)
    }

    // MARK: - Properties
    var currentStep: Int = 0 {
        didSet {
            setupText()
        }
    }

    var numberOfSteps: Int = 0 {
        didSet {
            setupText()
        }
    }
}

// MARK: - Private methods
extension RRProgressLabel {
    private func setupText() {
        let attributedString = NSMutableAttributedString(
            string: "\(currentStep)",
            attributes: [.font: Constants.boldFont])
        attributedString.append(NSAttributedString(string: Constants.separator))
        attributedString.append(NSAttributedString(
            string: "\(numberOfSteps)",
            attributes: [.font: Constants.regularFont]))
        attributedText = attributedString
    }
}
