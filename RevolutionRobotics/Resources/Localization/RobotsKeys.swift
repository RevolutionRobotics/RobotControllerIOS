//
//  RobotsKeys.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

enum RobotsKeys {
    enum YourRobots {
        static let title = "your_robots_screen_title"
        static let buildNewButtonTitle = "your_robots_build_new_button_title"
    }

    enum WhoToBuild {
        static let title = "who_to_build_screen_title"
        static let buildNewButtonTitle = "who_to_build_build_new_button_title"
        static let searchingForRobotsTitle = "who_to_build_searching_title"
    }

    enum BuildRobot {
        static let testingTitle = "build_robot_testing_title"
        static let testingQuestion = "build_robot_testing_question"
        static let testingNegativeButtonTitle = "build_robot_testing_negative_button_title"
        static let testingPositiveButtonTitle = "build_robot_testing_positive_button_title"
        static let turnOnTheBrainInstruction = "build_robot_turn_on_the_brain_instruction"
        static let turnOnTheBrainTip = "build_robot_turn_on_the_brain_tip"

        enum ChapterFinished {
            static let title = "build_chapter_finish_dialog_title"
            static let description = "build_chapter_finish_dialog_description"
            static let homeButton = "build_chapter_finish_dialog_button_home"
            static let testLaterButton = "build_chapter_finish_dialog_button_next_chapter"
            static let testNowButton = "build_chapter_finish_dialog_button_test"
        }
    }

    enum Common {
        static let successfulConnectionTitle = "connection_successful_message"
        static let failedConnectionTitle = "connection_failed_message"
        static let failedConnectionSubtitle = "connection_failed_subtitle"
        static let failedConnectionSkipButton = "connection_failed_skip_button_title"
        static let failedConnectionTipsButton = "connection_failed_tips_button_title"
        static let failedConnectionTryAgainButton = "connection_failed_try_again_button_title"
    }

    enum Configure {
        static let title = "configuration_new_screen_title"
        static let connectionTabTitle = "configure_connection_tab_title"
        static let controllerTabTitle = "configure_controller_tab_title"

        enum Motor {
            static let emptyButton = "configure_motor_empty_button_title"
            static let drivetrainButton = "configure_motor_drivetrain_button_title"
            static let motorButton = "configure_motor_motor_button_title"
            static let leftButton = "configure_motor_left_button_title"
            static let rightButton = "configure_motor_right_button_title"
            static let clockwiseButton = "configure_motor_clockwise_button_title"
            static let counterclockwiseButton = "configure_motor_counterclockwise_button_title"
            static let nameInputfield = "configure_motor_name_inputfield_title"
        }
    }
}
