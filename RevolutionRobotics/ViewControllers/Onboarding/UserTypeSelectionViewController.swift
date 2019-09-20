//
//  UserTypeSelectionViewController.swift
//  RevolutionRobotics
//
//  Created by Pável Áron on 2019. 09. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

enum UserProperty: String {
    case userType = "user_type"
    case yearOfBirth = "year_of_birth"
    case robotId = "robot_id"
}

final class UserTypeSelectionViewController: BaseViewController {

    // MARK: - Constants
    enum UserType: String {
        case student, parent, teacher = "teacher_mentor", hobbyist
    }

    // MARK: - Properties
    private var birthYear: Int?
    private var selectedUserType: UserType? {
        didSet {
            (selectedUserType == .student ? showAgeModal : scanBarcode)()
        }
    }
}

// MARK: - View lifecycle
extension UserTypeSelectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Private methods
extension UserTypeSelectionViewController {

    private func showAgeModal() {
        let modal = AgeSelectionModalView.instatiate()
        modal.ageSelectedCallback = { [weak self] birthYear in
            guard let `self` = self else { return }

            self.birthYear = birthYear
            self.dismissModalViewController()
            self.scanBarcode()
        }

        presentModal(with: modal, closeHidden: true)
    }

    private func scanBarcode() {
        guard let userType = selectedUserType else { return }

        let qrScanner = AppContainer.shared.container.unwrappedResolve(BarcodeScannerViewController.self)
        var userProperties = [
            UserProperty.userType.rawValue: userType.rawValue
        ]

        if let birthYear = birthYear {
            userProperties[UserProperty.yearOfBirth.rawValue] = "\(birthYear)"
        }

        qrScanner.userProperties = userProperties
        navigationController?.pushViewController(qrScanner, animated: true)
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
