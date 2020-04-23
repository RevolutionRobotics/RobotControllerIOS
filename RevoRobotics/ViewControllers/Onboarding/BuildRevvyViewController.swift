//
//  BuildRevvyViewController.swift
//  RevolutionRobotics
//
//  Created by Pável Áron on 2019. 09. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import os

final class BuildRevvyViewController: BaseViewController {
    // MARK: - Constants
    enum Constants {
        static let revvyId = "revvy"
    }

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var buttonContainer: UIView!
    @IBOutlet private weak var yesButton: RRButton!
    @IBOutlet private weak var noButton: RRButton!
    @IBOutlet private weak var skipButton: UIButton!

    // MARK: - Properties
    private var skippedOnboarding = false
    var firebaseService: FirebaseServiceInterface!
    var realmService: RealmServiceInterface!
}

// MARK: - View lifecycle
extension BuildRevvyViewController {
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupTitleLabel()
        setupPromptButtons()
        setupSkipButton()
    }
}

// MARK: - Private methods
extension BuildRevvyViewController {
    private func setupTitleLabel() {
        titleLabel.text = OnboardingKeys.BuildRevvy.title.translate()
    }

    private func setupPromptButtons() {
        yesButton.titleLabel?.text = OnboardingKeys.BuildRevvy.yes.translate()
        noButton.titleLabel?.text = OnboardingKeys.BuildRevvy.no.translate()

        var constraints: [NSLayoutConstraint] = []
        for button in [yesButton, noButton].compactMap({ $0 }) {
            button.setBorder(
                fillColor: .clear,
                strokeColor: .white,
                croppedCorners: [.bottomLeft, .topRight])

            constraints.append(button.widthAnchor.constraint(
                equalTo: buttonContainer.widthAnchor,
                multiplier: 0.5,
                constant: -10.0))
        }

        NSLayoutConstraint.activate(constraints)
    }

    private func setupSkipButton() {
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        skipButton.titleLabel?.attributedText =
            NSMutableAttributedString(string: OnboardingKeys.BuildRevvy.skip.translate(), attributes: attributes)
    }

    private func savePromptVisited() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: UserDefaults.Keys.buildRevvyPromptVisited)
    }

    private func getRevvyDataModel(completion: @escaping CallbackType<Robot>) {
        firebaseService.getRobots { result in
            switch result {
            case .success(let robots):
                guard let revvy = robots.first(where: { $0.id == Constants.revvyId }) else {
                    os_log("Error: Failed to fetch Revvy from Firebase!")
                    return
                }

                completion(revvy)
            case .failure(let error):
                print(error)
                os_log("Error: Failed to fetch Revvy from Firebase!")
            }
        }
    }

    private func saveRevvyDataModel(using dataModel: Robot) {
        let configId = UUID().uuidString

        let localController = ControllerDataModel(
            controller: dataModel.controller,
            localConfigurationId: configId)

        let remoteConfiguration = Configuration(
            id: configId,
            controller: dataModel.controller.type.rawValue,
            mapping: dataModel.portMapping)

        let config = ConfigurationDataModel(
            id: configId,
            remoteConfiguration: remoteConfiguration)

        let revvyDataModel = UserRobot(
            id: UUID().uuidString,
            remoteId: dataModel.id,
            buildStatus: .completed,
            actualBuildStep: -1,
            lastModified: Date(),
            configId: configId,
            customName: dataModel.name.text,
            customImage: dataModel.coverImage,
            customDescription: dataModel.description.text)

        let userDefaults = UserDefaults.standard
        let revvyBuiltKey = UserDefaults.Keys.revvyBuilt
        let allPrograms = realmService.getPrograms()
            + dataModel.programs.map({ ProgramDataModel(program: $0, robotId: revvyDataModel.id) })

        if !userDefaults.bool(forKey: revvyBuiltKey) {
            realmService.saveConfigurations([config])
            realmService.savePrograms(programs: allPrograms)
            realmService.saveRobot(revvyDataModel, shouldUpdate: true)
            userDefaults.set(true, forKey: revvyBuiltKey)
        }

        guard !skippedOnboarding else {
            navigationController?.popToRootViewController(animated: true)
            return
        }

        navigateToPlayController(with: revvyDataModel, controller: localController)
    }

    private func navigateToPlayController(with robot: UserRobot, controller: ControllerDataModel) {
        let playController = AppContainer.shared.container.unwrappedResolve(PlayControllerViewController.self)
        playController.controllerDataModel = controller
        playController.robotName = robot.customName
        playController.onboardingInProgress = true
        navigationController?.pushViewController(playController, animated: true)
    }
}

// MARK: - Actions
extension BuildRevvyViewController {
    @IBAction private func skipButtonTapped(_ sender: Any) {
        savePromptVisited()
        skippedOnboarding = true
        logEvent(named: "skip_onboarding")
        getRevvyDataModel(completion: { [weak self] revvy in
            self?.saveRevvyDataModel(using: revvy)
        })
    }

    @IBAction private func yesButtonTapped(_ sender: Any) {
        savePromptVisited()
        logEvent(named: "build_basic_robot_offline")
        getRevvyDataModel(completion: { [weak self] revvy in
            self?.saveRevvyDataModel(using: revvy)
        })
    }

    @IBAction private func noButtonTapped(_ sender: Any) {
        savePromptVisited()
        logEvent(named: "build_basic_robot_online")
        getRevvyDataModel(completion: { [weak self] revvy in
            guard let `self` = self else { return }

            let buildRevvy = AppContainer.shared.container.unwrappedResolve(BuildRobotViewController.self)
            buildRevvy.onboardingInProgress = true
            buildRevvy.firebaseService = self.firebaseService
            buildRevvy.realmService = self.realmService

            buildRevvy.remoteRobotDataModel = revvy
            self.navigationController?.pushViewController(buildRevvy, animated: true)
        })
    }
}
