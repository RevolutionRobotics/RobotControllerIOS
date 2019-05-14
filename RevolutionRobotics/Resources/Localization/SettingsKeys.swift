//
//  SettingsKeys.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

enum SettingsKeys {
    enum Main {
        static let title = "settings_screen_title"
        static let resetTutorial = "settings_reset_turorial"
        static let firmwareUpdate = "settings_firmware_update"
        static let aboutApplication = "settings_about_application"
    }

    enum Firmware {
        static let title = "firmware_screen_title"
        static let newConnectionButton = "firmware_new_connection_button"
    }

    enum About {
        static let title = "about_screen_title"
        static let permissionsTitle = "about_permissions_title"
        static let permissionsInstruction = "about_permissions_instruction"
        static let privacyPolicyButton = "about_privacy_policy_button_title"
        static let termsAndConditionsButton = "about_terms_conditions_button_title"
        static let version = "about_version"
    }
}
