//
//  Image.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

enum Image {
    enum Common {
        static let imagePlaceholder = UIImage(named: "ImagePlaceholder")
        static let connectionFailed = UIImage(named: "FailedConnectionIcon")
        static let connectionSuccessful = UIImage(named: "SuccessfulConnectionIcon")
    }

    enum BuildRobot {
        static let cellRedBorder = UIImage(named: "CellRedBorder")
        static let cellWhiteBorder = UIImage(named: "CellWhiteBorder")
    }
}
