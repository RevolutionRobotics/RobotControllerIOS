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
        static let revvyId = "c92b9a90-e069-11e9-9d36-2a2ae2dbcce4"
    }

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var yesButton: RRButton!
    @IBOutlet private weak var noButton: RRButton!
    @IBOutlet private weak var skipButton: UIButton!

    // MARK: - Properties
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
        let buttonAttributes: [NSAttributedString.Key: Any] = [
            .font: Font.jura(size: 17.0)
        ]

        yesButton.titleLabel?.attributedText = NSMutableAttributedString(
            string: OnboardingKeys.BuildRevvy.yes.translate(),
            attributes: buttonAttributes)
        noButton.titleLabel?.attributedText = NSMutableAttributedString(
            string: OnboardingKeys.BuildRevvy.no.translate(),
            attributes: buttonAttributes)

        for button in [yesButton, noButton] {
            button?.setBorder(
                fillColor: .clear,
                strokeColor: .white,
                croppedCorners: [.bottomLeft, .topRight])
        }
    }

    private func setupSkipButton() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Font.jura(size: 17.0),
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
            case .failure:
                os_log("Error: Failed to fetch Revvy from Firebase!")
            }
        }
    }

    private func createNewRobot(using dataModel: Robot) {
        firebaseService.getConfigurations { [weak self] result in
            switch result {
            case .success(let remoteConfigurations):
                self?.firebaseService.getControllers(completion: { [weak self] result in
                    switch result {
                    case .success(let remoteControllers):
                        self?.fetchPrograms(for: dataModel.id, callback: { [weak self] programs in
                            self?.saveRevvyDataModel(
                                using: dataModel,
                                remoteConfigurations: remoteConfigurations,
                                remoteControllers: remoteControllers,
                                programs: programs)
                        })
                    case .failure:
                        os_log("Failed to retrieve controllers!")
                    }
                })
            case .failure:
                os_log("Failed to retrieve configurations!")
            }
        }
    }

    private func fetchPrograms(for robotId: String, callback: @escaping CallbackType<[Program]>) {
        firebaseService.getRobotPrograms(for: robotId, completion: { result in
            switch result {
            case .success(let programs):
                callback(programs.compactMap({ $0 }))
            case .failure:
                os_log("Failed to retrieve programs for robot!")
            }
        })
    }

    private func saveRevvyDataModel(
        using dataModel: Robot,
        remoteConfigurations: [Configuration],
        remoteControllers: [Controller],
        programs: [Program]
    ) {
        let revvyDataModel = UserRobot(
            id: UUID().uuidString,
            remoteId: dataModel.id,
            buildStatus: .completed,
            actualBuildStep: -1,
            lastModified: Date(),
            configId: UUID().uuidString,
            customName: dataModel.name.text,
            customImage: dataModel.coverImageGSURL,
            customDescription: dataModel.customDescription.text)

        guard let remoteConfiguration = remoteConfigurations.first(where: {
            $0.id == dataModel.configurationId
        }) else { return }

        let localConfiguration = ConfigurationDataModel(
            id: revvyDataModel.configId,
            remoteConfiguration: remoteConfiguration)
        let controllers = remoteControllers
            .map({ ControllerDataModel(controller: $0, localConfigurationId: localConfiguration.id) })

        localConfiguration.controller = controllers.first(where: { $0.type == ControllerType.gamer.rawValue })?.id ?? ""

        let userDefaults = UserDefaults.standard
        let revvyBuiltKey = UserDefaults.Keys.revvyBuilt
        let allPrograms = realmService.getPrograms()
            + programs.map({ ProgramDataModel(program: $0, robotId: revvyDataModel.id) })

        if !userDefaults.bool(forKey: revvyBuiltKey) {
            realmService.saveControllers(controllers)
            realmService.saveConfigurations([localConfiguration])
            realmService.savePrograms(programs: allPrograms)
            realmService.saveRobot(revvyDataModel, shouldUpdate: true)
            userDefaults.set(true, forKey: revvyBuiltKey)
        }

        if let selectedController = controllers.first(where: {
            $0.id == localConfiguration.controller
        }) {
             navigateToPlayController(with: revvyDataModel, controller: selectedController)
        }
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
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction private func yesButtonTapped(_ sender: Any) {
        savePromptVisited()
        getRevvyDataModel(completion: { [weak self] revvy in
            self?.createNewRobot(using: revvy)
        })
    }

    @IBAction private func noButtonTapped(_ sender: Any) {
        savePromptVisited()
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
