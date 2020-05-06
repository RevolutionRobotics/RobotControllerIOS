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
        static let arrowDown = UIImage(named: "ArrowDown")
    }

    enum BuildRobot {
        static let cellRedBorder = UIImage(named: "CellRedBorder")
        static let cellWhiteBorder = UIImage(named: "CellWhiteBorder")
        static let cellDownloadRed = UIImage(named: "CellDownloadRed")
        static let cellDownloadWhite = UIImage(named: "CellDownloadWhite")
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
            static let driveIcon = UIImage(named: "DriveIcon")
            static let motorIcon = UIImage(named: "motorIcon")
            static let bumperIcon = UIImage(named: "bumperIcon")
            static let distanceIcon = UIImage(named: "DistanceIcon")
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
    }

    enum Configure {
        static let reconfigure = UIImage(named: "Reconfigure")
        static let emptySelected = UIImage(named: "EmptySelected")
        static let emptyUnselected = UIImage(named: "EmptyUnselected")
        static let driveSelected = UIImage(named: "DriveSelected")
        static let driveUnselected = UIImage(named: "DriveUnselected")
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
        static let distanceSelected = UIImage(named: "DistanceSelected")
        static let distanceUnselected = UIImage(named: "DistanceUnselected")
    }

    enum Controller {
        static let gamerPadJoystick = UIImage(named: "GamerPadJoystick")
        static let gamer = UIImage(named: "Controller3")
        static let multiTasker = UIImage(named: "Controller2")
        static let driver = UIImage(named: "Controller1")
        static let padButtonBackground = UIImage(named: "PadButtonCircle")
        static let directionSlider = UIImage(named: "DirectionSlider")
        static let nextIcon = UIImage(named: "NextIcon")
        static let assignedButtonIcon = UIImage(named: "ControllerButtonAssigned")
        static let unassignedButtonIcon =
            UIImage(named: "ControllerButtonUnassignedIcon")?.withRenderingMode(.alwaysOriginal)
        static let highlightedButtonIcon = UIImage(named: "ControllerButtonHighlighted")
    }

    enum Programs {
        static let compatibleIcon = UIImage(named: "CompatibleIcon")
        static let filterIcon = UIImage(named: "FilterIcon")
        static let checkboxWhiteChecked = UIImage(named: "CheckboxWhiteChecked")

        enum Buttonless {
            static let checkboxNotChecked = UIImage(named: "CheckboxNotChecked")
            static let checkboxIncompatible = UIImage(named: "CheckboxIncompatible")
            static let checkboxChecked = UIImage(named: "CheckboxChecked")
            static let CompatibleIcon = UIImage(named: "CompatibleIcon")
            static let CompatibleIconAll = UIImage(named: "CompatibleIconAll")
            static let SortDateDown = UIImage(named: "SortDateDown")
            static let SortDateDownSelected = UIImage(named: "SortDateDownSelected")
            static let SortDateUp = UIImage(named: "SortDateUp")
            static let SortDateUpSelected = UIImage(named: "SortDateUpSelected")
            static let SortNameDown = UIImage(named: "SortNameDown")
            static let SortNameDownSelected = UIImage(named: "SortNameDownSelected")
            static let SortNameUp = UIImage(named: "SortNameUp")
            static let SortNameUpSelected = UIImage(named: "SortNameUpSelected")
        }

        enum Priority {
            static let button = UIImage(named: "ControllerIcon")
            static let buttonless = UIImage(named: "ButtonlessIcon")
        }
    }

    enum Challenges {
        static let ChallengeCategoryCardGold = UIImage(named: "ChallengeCategoryCardGold")
        static let ChallengeCategoryCardGoldCorner = UIImage(named: "ChallengeCategoryCardGoldCorner")
        static let ChallengeCategoryCardGrey = UIImage(named: "ChallengeCategoryCardGrey")
        static let ChallengeCategoryCardGreyCorner = UIImage(named: "ChallengeCategoryCardGreyCorner")

        static let ChallengeActiveCard = UIImage(named: "ChallengeActiveCard")
        static let ChallengeFinishedCard = UIImage(named: "ChallengeFinishedCard")
        static let ChallengeGoldLine = UIImage(named: "ChallengeGoldLine")
        static let ChallengeGreyLine = UIImage(named: "ChallengeGreyLine")
        static let ChallengeInactiveCard = UIImage(named: "ChallengeInactiveCard")
    }

    enum Testing {
        static let MotorTestImage = UIImage(named: "MotorTestImage")
        static let driveTestImage = UIImage(named: "DriveTestImage")
        static let distanceTestImage = UIImage(named: "DistanceTestImage")
        static let BumperTestImage = UIImage(named: "BumperTestImage")
    }

    static let downloadIcon = UIImage(named: "DownloadIcon")
    static let retryIcon = UIImage(named: "RetryIcon")
    static let tickIcon = UIImage(named: "TickWhiteIcon")
}
