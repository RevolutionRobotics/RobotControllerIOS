//
//  RRButton.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class RRButton: UIButton {
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
        }
    }
}

// MARK: - View lifecycle
extension RRButton {
    override func awakeFromNib() {
        super.awakeFromNib()

        setBackgroundColor(Color.white16, for: .highlighted)
        adjustsImageWhenHighlighted = false
    }
}
