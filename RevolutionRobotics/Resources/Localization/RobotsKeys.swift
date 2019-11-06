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
        static let newRobotName = "your_robots_new"
        static let create = "card_create"
        static let play = "your_robots_play"
        static let continueBuilding = "your_robots_continue_building"
        static let continueEditing = "your_robots_continue_editing"
        static let underConstruction = "your_robots_under_construction"
        static let select = "your_robots_select"
    }

    enum WhoToBuild {
        static let title = "who_to_build_screen_title"
        static let buildNewButtonTitle = "who_to_build_build_new_button_title"
        static let searchingForRobotsTitle = "who_to_build_searching_title"
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

        static let buildFinishedHome = "build_robot_finished_home"
        static let buildFinishedDrive = "build_robot_finished_drive"
        static let buildFinishedAllSet = "build_robot_finished_all_set"
        static let buildFinishedMessage = "build_robot_finished_message"
    }

    enum Configure {
        static let title = "configuration_new_screen_title"
        static let connectionTabTitle = "configure_connection_tab_title"
        static let controllerTabTitle = "configure_controller_tab_title"
        static let variableError = "error_variable_already_in_use"
        static let variableEmpty = "error_variable_empty"
        static let typeChange = "configure_controller_type_change"
        static let delete = "configure_delete"
        static let duplicate = "configure_duplicate"
        static let rename = "configure_rename"
        static let changeImage = "configure_image_change"
        static let cameraPermissionTitle = "configure_camera_permission_title"
        static let cameraPermissionMessage = "configure_camera_permission_message"

        enum Motor {
            static let emptyButton = "configure_motor_empty_button_title"
            static let driveButton = "configure_motor_drive_button_title"
            static let motorButton = "configure_motor_motor_button_title"
            static let leftButton = "configure_motor_left_button_title"
            static let rightButton = "configure_motor_right_button_title"
            static let clockwiseButton = "configure_motor_clockwise_button_title"
            static let counterclockwiseButton = "configure_motor_counterclockwise_button_title"
            static let nameInputfield = "configure_motor_name_inputfield_title"
            static let testButton = "configure_motor_test_button_title"
            static let doneButton = "configure_motor_done_button_title"
        }

        enum Sensor {
            static let bumperButton = "configure_sensor_bumper_button_title"
            static let distanceButton = "configure_sensor_distance_button_title"
        }
    }

    enum Controllers {
        static let controllerChooseThis = "controller_choose_this"
        static let controllerSelected = "controller_selected"

        enum Play {
            static let screenTitle = "play_controller_screen_title"
        }
    }
}
