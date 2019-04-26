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
    }

    enum BuildRobot {
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
}
