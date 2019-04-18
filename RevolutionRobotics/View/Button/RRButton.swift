//
//  RRButton.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class RRButton: UIButton {
    // MARK: - Constants
    private enum Constants {
        static let highlightColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.13)
    }
}

// MARK: - View lifecycle
extension RRButton {
    override func awakeFromNib() {
        super.awakeFromNib()

        setBackgroundImage(UIImage.from(color: Constants.highlightColor), for: .highlighted)
    }
}
