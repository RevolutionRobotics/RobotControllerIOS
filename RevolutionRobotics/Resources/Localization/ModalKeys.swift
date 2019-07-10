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
        static let nameTitle = "save_controller_dialog_title"
        static let namePlaceholder = "save_controller_dialog_name_title"
        static let descriptionTitle = "save_controller_dialog_description_hint"
        static let descriptionPlaceholder = "save_controller_dialog_name_hint"
    }

    enum DeleteRobot {
        static let description = "delete_robot_description"
        static let confirm = "delete_robot_confirm"
        static let cancel = "delete_robot_cancel"
    }

    enum Tips {
        static let title = "tips_dialog_title"
        static let subtitle = "tips_dialog_sub_title"
        static let tips = "tips_dialog_tips"
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

    enum FirmwareUpdate {
        static let checkForUpdates = "firmware_update_check_for_updates"
        static let currentVersion = "firmware_current_version"
        static let downloadUpdate = "firmware_update_download"
        static let downloadReady = "firmware_update_download_ready"
        static let upToDate = "firmware_up_to_date"
        static let done = "firmware_done_button"
        static let downloading = "firmware_download_info"
        static let pleaseWait = "firmware_please_wait"
        static let successfulUpdate = "firmware_successful_update"
        static let hardwareVersion = "firmware_hardware_version"
        static let modelNumber = "firmware_model_number"
        static let softwareVersion = "firmware_software_version"
        static let serialNumber = "firmware_serial_number"
        static let manufacturerName = "firmware_manufacturer_name"
        static let mainBattery = "firmware_main_battery"
        static let motorBattery = "firmware_motor_battery"
        static let loading = "firmware_loading"
        static let firmwareDownloadInfo = "firmware_download_info"
        static let firmwareDownloadPleaseWait = "firmware_please_wait"
    }

    enum Program {
        static let addProgram = "program_modal_add"
        static let removeProgram = "program_modal_remove"
        static let edigProgram = "program_modal_edit"
        static let gotIt = "program_modal_got_it"
        static let compatibilityIssue = "program_info_compatibility_issue"
        static let generatedCodeTitle = "title_python_code"
        static let newVariableName = "new_variable_name"
    }

    enum Save {
        static let done = "save_dialog_done"

        enum Configuration {
            static let title = "save_robot_dialog_title"
            static let nameTitle = "save_robot_dialog_name_title"
            static let nameHint = "save_robot_dialog_name_hint"
            static let descriptionTitle = "save_dialog_description_title"
            static let descriptionHint = "save_robot_dialog_description_hint"
        }
    }

    enum RobotInfo {
        static let delete = "info_robot_delete"
        static let duplicate = "info_robot_duplicate"
        static let edit = "info_robot_edit"
        static let error = "dialog_robot_info_edit"
        static let copyPostfix = "duplicated_robot_name_suffix"
    }

    enum Disconnect {
        static let description = "disconnect_modal_description"
        static let cancel = "disconnect_modal_cancel"
        static let disconnect = "disconnect_modal_disconnect"
    }

    enum ControllerDelete {
        static let description = "delete_controller_description"
        static let confirm = "delete_controller_confirm"
        static let cancel = "delete_controller_cancel"
    }

    enum Blockly {
        static let deleteVariable = "blockly_delete_variable"
        static let ledSelectorSelectAll = "blockly_donut_selector_select_all"
        static let ok = "blockly_confirm_ok"
        static let cancel = "blockly_confirm_cancel"
    }

    enum Testing {
        static let testingTitle = "build_robot_testing_title"
        static let testingQuestion = "build_robot_testing_question"
        static let testingNegativeButtonTitle = "build_robot_testing_negative_button_title"
        static let testingPositiveButtonTitle = "build_robot_testing_positive_button_title"
        static let driveTest = "testing_drive_test"
        static let motorTest = "testing_motor_test"
        static let bumperTest = "testing_bumper_test"
        static let distanceTest = "testing_distance_test"
    }

    enum Challenge {
        static let challengeFinished = "challenge_finished_dialog_title"
        static let lastChallengeFinished = "challenge_finished_dialog_latest_title"
        static let homeButton = "challenge_finished_dialog_button_home"
        static let listButton = "challenge_finished_dialog_button_challenge_list"
        static let nextButton = "challenge_finished_dialog_button_next"
    }
}
