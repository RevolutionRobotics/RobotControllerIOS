//
//  OnboardingKeys.swift
//  RevolutionRobotics
//
//  Created by Pável Áron on 2019. 10. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

enum OnboardingKeys {
    enum UserType {
        static let title = "onboarding_user_type_title"
        static let typeStudent = "onboarding_user_type_student"
        static let typeParent = "onboarding_user_type_parent"
        static let typeTeacher = "onboarding_user_type_teacher"
        static let typeHobbyist = "onboarding_user_type_hobbyist"
    }

    enum AgeSelection {
        static let title = "onboarding_age_select_title"
        static let inputLabel = "onboarding_age_select_input_label"
        static let inputDone = "onboarding_age_select_input_done"
        static let confirm = "onboarding_age_select_confirm"
    }

    enum BuildRevvy {
        static let title = "onboarding_prompt_build_title"
        static let yes = "onboarding_prompt_build_yes"
        static let no = "onboarding_prompt_build_no"
        static let skip = "onboarding_prompt_build_skip"
    }

    enum CompletedModal {
        static let title = "onboarding_completed_title"
        static let message = "onboarding_completed_message"
        static let start = "onboarding_completed_start"
    }
}
