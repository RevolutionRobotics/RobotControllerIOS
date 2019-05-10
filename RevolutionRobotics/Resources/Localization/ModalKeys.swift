//
//  ModalKeys.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 02..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

enum ModalKeys {
    enum Camera {
        static let title = "camera_dialog_title"
        static let delete = "camera_dialog_delete_title"
        static let newPhoto = "camera_dialog_new_photo_title"
    }

    enum Controller {
        static let infoButtonTitle = "controller_got_it_button_title"
    }

    enum DeleteRobot {
        static let description = "delete_robot_description"
        static let confirm = "delete_robot_confirm"
        static let cancel = "delete_robot_cancel"
    }

    enum Tips {
        static let title = "tips_dialog_title"
        static let subtitle = "tips_dialog_sub_title"
        static let reconfigure = "tips_dialog_button_reconfigure"
        static let skipTesting = "tips_dialog_button_skip_testing"
        static let community = "tips_dialog_button_community"
        static let tryAgin = "tips_dialog_button_try_again"
    }

    enum Connection {
        static let successfulConnectionTitle = "connection_successful_message"
        static let failedConnectionTitle = "connection_failed_message"
        static let failedConnectionSubtitle = "connection_failed_subtitle"
        static let failedConnectionSkipButton = "connection_failed_skip_button_title"
        static let failedConnectionTipsButton = "connection_failed_tips_button_title"
        static let failedConnectionTryAgainButton = "connection_failed_try_again_button_title"
    }
}
