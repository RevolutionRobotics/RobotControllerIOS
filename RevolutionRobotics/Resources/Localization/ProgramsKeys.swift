//
//  ProgramsKeys.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

enum ProgramsKeys {
    static let drivePriorityPlaceholder = "priority_drivetrain_item"

    enum Main {
        static let title = "programs_screen_title"
    }

    enum MostRecent {
        static let showMore = "most_recent_show_more"
        static let empty = "most_recent_empty"
    }

    enum Selector {
        static let title = "program_selector_title"
        static let orderByName = "program_selector_order_by_name"
        static let orderByDate = "program_selector_order_by_date"
        static let showCompatiblePrograms = "program_selector_show_compatible_programs"
        static let showAllPrograms = "program_selector_show_all_programs"
    }

    enum Buttonless {
        static let title = "buttonless_program_selector_title"
        static let selectAll = "buttonless_program_select_all_checkbox"
        static let showCompatible = "buttonless_program_show_compatible_programs"
        static let showAll = "buttonless_program_show_all_programs"
    }

    enum BlockContext {
        static let delete = "dialog_block_options_delete"
        static let help = "dialog_block_options_help"
        static let duplicate = "dialog_block_options_duplicate"
        static let title = "dialog_block_options_comment_title"
        static let placeholder = "dialog_block_options_comment_description"
    }

    enum SelectProgram {
        static let delete = "program_info_delete_program"
        static let load = "program_info_load_program"
    }

    enum Priority {
        static let title = "program_priority_screen_title"
    }

    enum SaveProgram {
        static let title = "dialog_save_program_title"
        static let nameTitle = "dialog_save_program_name"
        static let namePlaceholder = "dialog_save_program_name_hint"
        static let descriptionTitle = "dialog_save_program_description"
        static let descriptionPlaceholder = "dialog_save_program_description_hint"
        static let nameInUse = "error_program_already_in_use"
    }

    enum NavigateBack {
        static let title = "program_confirm_title"
        static let subtitle = "program_confirm_description"
        static let positive = "program_confirm_positive"
        static let programLeaveConfirmPositive = "program_leave_confirmation_dialog_leave_button"
        static let programLeaveConfirmNegative = "dialog_load_program_confirm_button_negative"
        static let programOpenConfirmPositive = "dialog_load_program_confirm_button_positive"
    }

    enum ConfirmOpen {
        static let title = "dialog_load_program_confirm_title"
        static let subtitle = "dialog_load_program_confirm_description"
        static let positive = "dialog_load_program_confirm_button_positive"
    }
}
