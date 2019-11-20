//
//  UserTypeSelectionViewController.swift
//  RevolutionRobotics
//
//  Created by Pável Áron on 2019. 09. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import Firebase

enum UserProperty: String {
    case userType = "user_type"
    case yearOfBirth = "year_of_birth"
    case robotId = "robot_id"
}

final class UserTypeSelectionViewController: BaseViewController {

    // MARK: - Constants
    private enum Constants {
        static let userTypeEvent = "selected_user_type"
    }

    private enum UserType: String {
        case student, parent, teacher = "teacher_mentor", hobbyist
    }

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var studentCardLabel: UILabel!
    @IBOutlet private weak var parentCardLabel: UILabel!
    @IBOutlet private weak var teacherCardLabel: UILabel!
    @IBOutlet private weak var hobbyistCardLabel: UILabel!

    // MARK: - Properties
    private var birthYear: Int?
    private var selectedUserType: UserType? {
        didSet {
            (selectedUserType == .student ? showAgeModal : promptBuildRevvy)()
        }
    }
}

// MARK: - View lifecycle
extension UserTypeSelectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabels()
    }
}

// MARK: - Private methods
extension UserTypeSelectionViewController {
    private func setupLabels() {
        titleLabel.text = OnboardingKeys.UserType.title.translate()
        studentCardLabel.text = OnboardingKeys.UserType.typeStudent.translate()
        parentCardLabel.text = OnboardingKeys.UserType.typeParent.translate()
        teacherCardLabel.text = OnboardingKeys.UserType.typeTeacher.translate()
        hobbyistCardLabel.text = OnboardingKeys.UserType.typeHobbyist.translate()
    }

    private func showAgeModal() {
        let modal = AgeSelectionModalView.instatiate()
        modal.ageSelectedCallback = { [weak self] birthYear in
            guard let `self` = self else { return }

            self.birthYear = birthYear
            self.dismissModalViewController()
            self.promptBuildRevvy()
        }

        presentModal(with: modal, closeHidden: true)
    }

    private func promptBuildRevvy() {
        guard let userType = selectedUserType else { return }

        var userProperties = [
            UserProperty.userType.rawValue: userType.rawValue
        ]

        if let birthYear = birthYear {
            userProperties[UserProperty.yearOfBirth.rawValue] = "\(birthYear)"
        }

        userProperties.forEach({ (key, value) in
            Analytics.setUserProperty(value, forName: key)
        })

        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: UserDefaults.Keys.userPropertiesSet)

        if !userProperties.keys.isEmpty {
            Analytics.logEvent(Constants.userTypeEvent, parameters: userProperties)
        }

        let buildRevvy = AppContainer.shared.container.unwrappedResolve(BuildRevvyViewController.self)
        navigationController?.pushViewController(buildRevvy, animated: true)
    }
}

// MARK: - Actions
extension UserTypeSelectionViewController {

    @IBAction private func studentTapped(_ sender: Any) {
        selectedUserType = .student
    }

    @IBAction private func parentTapped(_ sender: Any) {
        selectedUserType = .parent
    }

    @IBAction private func teacherTapped(_ sender: Any) {
        selectedUserType = .teacher
    }

    @IBAction private func hobbyistTapped(_ sender: Any) {
        selectedUserType = .hobbyist
    }
}
