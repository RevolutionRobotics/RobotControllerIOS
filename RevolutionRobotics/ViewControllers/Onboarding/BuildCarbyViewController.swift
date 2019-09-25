//
//  BuildCarbyViewController.swift
//  RevolutionRobotics
//
//  Created by Pável Áron on 2019. 09. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import os

final class BuildCarbyViewController: BaseViewController {
    // MARK: - Constants
    enum Constants {
        static let carbyId = "2d9b67e-804e-4022-8cae-5a26071fa275"
    }

    // MARK: - Outlets
    @IBOutlet private weak var yesButton: RRButton!
    @IBOutlet private weak var noButton: RRButton!
    @IBOutlet private weak var skipButton: UIButton!

    // MARK: - Properties
    var firebaseService: FirebaseServiceInterface!
    var realmService: RealmServiceInterface!
}

// MARK: - View lifecycle
extension BuildCarbyViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPromptButtons()
        setupSkipButton()
    }
}

// MARK: - Private methods
extension BuildCarbyViewController {
    private func setupPromptButtons() {
        let buttonAttributes: [NSAttributedString.Key: Any] = [
            .font: Font.jura(size: 17.0)
        ]

        yesButton.titleLabel?.attributedText = NSMutableAttributedString(string: "Yes", attributes: buttonAttributes)
        noButton.titleLabel?.attributedText = NSMutableAttributedString(string: "No", attributes: buttonAttributes)

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
            NSMutableAttributedString(string: "Skip onboarding", attributes: attributes)
    }

    private func savePromptVisited() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: UserDefaults.Keys.buildCarbyPromptVisited)
    }

    private func getCarbyDataModel(completion: @escaping CallbackType<Robot>) {
        firebaseService.getRobots { result in
            switch result {
            case .success(let robots):
                guard let carby = robots.first(where: { $0.id == Constants.carbyId }) else {
                    os_log("Error: Failed to fetch Carby from Firebase!")
                    return
                }

                completion(carby)
            case .failure:
                os_log("Error: Failed to fetch Carby from Firebase!")
            }
        }
    }

    private func createNewRobot(using dataModel: Robot) {
        firebaseService.getConfigurations(completion: { [weak self] result in
            switch result {
            case .success(let remoteConfigurations):
                self?.firebaseService.getControllers(completion: { [weak self] result in
                    switch result {
                    case .success(let remoteControllers):
                        self?.saveCarbyDataModel(
                            using: dataModel,
                            remoteConfigurations: remoteConfigurations,
                            remoteControllers: remoteControllers)
                    case .failure:
                        os_log("Failed to retrieve controllers!")
                    }
                })
            case .failure:
                os_log("Failed to retrieve configurations!")
            }
        })
    }

    private func saveCarbyDataModel(
        using dataModel: Robot,
        remoteConfigurations: [Configuration],
        remoteControllers: [Controller]
    ) {
        let carbyDataModel = UserRobot(
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
            id: carbyDataModel.configId,
            remoteConfiguration: remoteConfiguration)
        let controllers = remoteControllers
            .map({ ControllerDataModel(controller: $0, localConfigurationId: localConfiguration.id) })

        localConfiguration.controller = controllers.first(where: { $0.type == ControllerType.gamer.rawValue })?.id ?? ""

        realmService.saveControllers(controllers)
        realmService.saveConfigurations([localConfiguration])

        guard let selectedController = controllers.first(where: {
            $0.id == localConfiguration.controller
        }) else { return }

        realmService.saveRobot(carbyDataModel, shouldUpdate: true)
        navigateToPlayController(with: carbyDataModel, controller: selectedController)
    }

    private func navigateToPlayController(with robot: UserRobot, controller: ControllerDataModel) {
        let playController = AppContainer.shared.container.unwrappedResolve(PlayControllerViewController.self)
        playController.controllerDataModel = controller
        playController.robotName = robot.customName
        navigationController?.pushViewController(playController, animated: true)
    }
}

// MARK: - Actions
extension BuildCarbyViewController {
    @IBAction private func skipButtonTapped(_ sender: Any) {
        savePromptVisited()
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction private func yesButtonTapped(_ sender: Any) {
        savePromptVisited()
        getCarbyDataModel(completion: { [weak self] carby in
            self?.createNewRobot(using: carby)
        })
    }

    @IBAction private func noButtonTapped(_ sender: Any) {
        savePromptVisited()
        getCarbyDataModel(completion: { [weak self] carby in
            guard let `self` = self else { return }

            let buildCarby = AppContainer.shared.container.unwrappedResolve(BuildRobotViewController.self)
            buildCarby.firebaseService = self.firebaseService
            buildCarby.realmService = self.realmService

            buildCarby.remoteRobotDataModel = carby
            self.navigationController?.pushViewController(buildCarby, animated: true)
        })
    }
}
