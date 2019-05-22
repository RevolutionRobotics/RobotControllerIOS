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
    }

    enum Program {
        static let addProgram = "program_modal_add"
        static let removeProgram = "program_modal_remove"
        static let edigProgram = "program_modal_edit"
        static let gotIt = "program_modal_got_it"
    }
}
