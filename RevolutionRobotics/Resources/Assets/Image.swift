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
        static let calendar = UIImage(named: "CalendarIcon")
        static let bluetoothIcon = UIImage(named: "BluetoothIcon")
        static let bluetoothInactiveIcon = UIImage(named: "BluetoothInactiveIcon")
        static let bluetoothWhiteIcon = UIImage(named: "BluetoothWhiteIcon")
        static let underConstruction = UIImage(named: "UnderConstructionIcon")
        static let plusIcon = UIImage(named: "plus16")
        static let closeIcon = UIImage(named: "CloseIcon")
        static let arrowUp = UIImage(named: "ArrowUp")
    }

    enum BuildRobot {
        static let cellRedBorder = UIImage(named: "CellRedBorder")
        static let cellWhiteBorder = UIImage(named: "CellWhiteBorder")
        static let currentBuildStepIndicator = UIImage(named: "CurrentBuildStepIndicator")
        static let nextButton = UIImage(named: "nextStep")
        static let finishButton = UIImage(named: "FinishButton")
    }

    enum Configuration {
        enum Connections {
            static let doneIcon = UIImage(named: "configDone")
            static let addIconDark = UIImage(named: "addIconDark")
            static let addIconDark20 = UIImage(named: "addIconDark20")
            static let addIconLight = UIImage(named: "addIconLight")
            static let defaultRobotImage = UIImage(named: "defaultRobotImage")
            static let drivetrainIcon = UIImage(named: "drivetrainIcon")
            static let motorIcon = UIImage(named: "motorIcon")
            static let bumperIcon = UIImage(named: "bumperIcon")
            static let ultrasonicIcon = UIImage(named: "ultrasonicIcon")
        }
        enum Controllers {
            static let cellRedBorderSelected = UIImage(named: "ControllerCellBorderSelectedRed")
            static let cellWhiteBorderSelected = UIImage(named: "ControllerCellBorderSelectedWhite")
            static let cellRedBorderNonSelected = UIImage(named: "ControllerCellBorderNonSelectedRed")
            static let cellWhiteBorderNonSelected = UIImage(named: "ControllerCellBorderNonSelectedWhite")
        }
    }

    enum YourRobots {
        static let cellRedBorderEditable = UIImage(named: "YourRobotsEditableRedCell")
        static let cellWhiteBorderEditable = UIImage(named: "YourRobotsEditableWhiteCell")
        static let robotPlaceholder = UIImage(named: "RobotPlaceholder")
    }

    enum Configure {
        static let emptySelected = UIImage(named: "EmptySelected")
        static let emptyUnselected = UIImage(named: "EmptyUnselected")
        static let drivetrainSelected = UIImage(named: "DrivetrainSelected")
        static let drivetrainUnselected = UIImage(named: "DrivetrainUnselected")
        static let motorSelected = UIImage(named: "MotorSelected")
        static let motorUnselected = UIImage(named: "MotorUnselected")
        static let clockwiseSelected = UIImage(named: "ClockwiseSelected")
        static let clockwiseUnselected = UIImage(named: "ClockwiseUnselected")
        static let counterclockwiseSelected = UIImage(named: "CounterclockwiseSelected")
        static let counterclockwiseUnselected = UIImage(named: "CounterclockwiseUnselected")
        static let leftSelected = UIImage(named: "LeftSelected")
        static let leftUnselected = UIImage(named: "LeftUnselected")
        static let rightSelected = UIImage(named: "RightSelected")
        static let rightUnselected = UIImage(named: "RightUnselected")
        static let bumperSelected = UIImage(named: "BumperSelected")
        static let bumperUnselected = UIImage(named: "BumperUnselected")
        static let ultrasoundSelected = UIImage(named: "UltrasoundSelected")
        static let ultrasoundUnselected = UIImage(named: "UltrasoundUnselected")
    }

    enum Controller {
        static let gamerPadJoystick = UIImage(named: "GamerPadJoystick")
        static let gamer = UIImage(named: "Controller3")
        static let multiTasker = UIImage(named: "Controller2")
        static let driver = UIImage(named: "Controller1")
        static let padButtonBackground = UIImage(named: "PadButtonCircle")
        static let directionSlider = UIImage(named: "DirectionSlider")
        static let nextIcon = UIImage(named: "NextIcon")
        static let unassignedButtonIcon = UIImage(named: "ControllerButtonUnassignedIcon")
        static let assignedButtonIcon = UIImage(named: "ControllerButtonAssigned")
        static let highlightedButtonIcon = UIImage(named: "ControllerButtonHighlighted")
    }

    enum Programs {
        static let compatibleIcon = UIImage(named: "CompatibleIcon")
    }

    enum Challenges {
        static let ChallengeCardGold = UIImage(named: "ChallengeCardGold")
        static let ChallengeCardGoldCorner = UIImage(named: "ChallengeCardGoldCorner")
        static let ChallengeCardGrey = UIImage(named: "ChallengeCardGrey")
        static let ChallengeCardGreyCorner = UIImage(named: "ChallengeCardGreyCorner")
    }

    static let downloadIcon = UIImage(named: "DownloadIcon")
    static let retryIcon = UIImage(named: "RetryIcon")
    static let tickIcon = UIImage(named: "TickWhiteIcon")
}
