//
//  ProgramsKeys.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

enum ProgramsKeys {
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

    static let programOrderTitle = "program_priority_screen_title"
}
