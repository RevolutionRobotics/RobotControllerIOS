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

    enum Configuration {
        static let doneIconName: String = "configDone"
        static let addIconDarkName: String = "addIconDark"
        static let addIconLightName: String = "addIconLight"
    }

    enum YourRobots {
        static let cellRedBorderEditable = UIImage(named: "YourRobotsEditableRedCell")
        static let cellWhiteBorderEditable = UIImage(named: "YourRobotsEditableWhiteCell")
        static let cellRedBorderNonEditable = UIImage(named: "YourRobotsNonEditableRedCell")
        static let cellWhiteBorderNonEditable = UIImage(named: "YourRobotsNonEditableWhiteCell")
    }
}
