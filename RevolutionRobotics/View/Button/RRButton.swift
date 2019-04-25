//
//  RRButton.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class RRButton: UIButton {
    // MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        setBackgroundImage(UIImage.from(color: Color.white40), for: .highlighted)
    }
}
