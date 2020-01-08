//
//  RobotConfigurationViewControllerActions.swift
//  RevoRobotics
//
//  Created by Pável Áron on 2019. 12. 09..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

// MARK: - Actions
extension RobotConfigurationViewController {
    private func deleteTapped(_ sender: Any) {
        dismissModalViewController()
        let deleteView = DeleteModalView.instatiate()
        deleteView.title = ModalKeys.DeleteRobot.description.translate()
        deleteView.deleteButtonHandler = { [weak self] in
            guard let `self` = self else { return }
            self.deleteCallback?()
            self.dismissModalViewController()
            self.navigationController?.popViewController(animated: true)
            self.logEvent(named: "delete_robot")
        }
        deleteView.cancelButtonHandler = { [weak self] in
            self?.dismissModalViewController()
        }

        reloadConfigurationView()
        presentModal(with: deleteView)
    }

    private func duplicateTapped(_ sender: Any) {
        duplicateCallback?()
        logEvent(named: "duplicate_robot")
        navigationController?.popViewController(animated: true)
    }

    private func controllerButtonTapped(_ sender: Any) {
        reloadConfigurationView()
        guard
            let configurationView = padConfiguration.configurationView,
            let controllerType = controller?.type
        else { return }

        let toggledType: ControllerType = controllerType == ControllerType.gamer.rawValue ? .driver : .gamer
        configurationView.removeFromSuperview()
        padConfiguration.controllerType = toggledType

        let savedController = realmService.getController(id: controller?.id)
        realmService.updateObject(closure: {
            savedController?.type = toggledType.rawValue
        })

        controller?.type = toggledType.rawValue
        logEvent(named: "change_controller_type")
    }

    @IBAction private func backgroundProgramsTapped(_ sender: Any) {
        let vc = AppContainer.shared.container.unwrappedResolve(ButtonlessProgramsViewController.self)
        vc.configurationId = padConfiguration.configurationId
        vc.controllerViewModel = padConfiguration.viewModel
        vc.selectedRobotId = selectedRobot?.id
        navigationController?.pushViewController(vc, animated: true)
        logEvent(named: "click_background_programs")
    }

    @IBAction private func playButtonTapped(_ sender: Any) {
        guard let configuration = realmService.getConfiguration(id: selectedRobot?.configId),
            let controller = realmService.getController(id: configuration.controller) else {
                return
        }

        let playController = AppContainer.shared.container.unwrappedResolve(PlayControllerViewController.self)
        playController.controllerDataModel = controller
        playController.robotName = selectedRobot?.customName
        navigationController?.pushViewController(playController, animated: true)
    }

    @IBAction private func priorityButtonTapped(_ sender: Any) {
        let vc = AppContainer.shared.container.unwrappedResolve(ProgramPriorityViewController.self)
        vc.controllerViewModel = padConfiguration.viewModel
        navigationController?.pushViewController(vc, animated: true)
        logEvent(named: "click_priority_button")
    }

    @IBAction private func optionsTapped(_ sender: Any) {
        let optionsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        optionsMenu.addAction(UIAlertAction(
            title: RobotsKeys.Configure.typeChange.translate(),
            style: .default,
            handler: controllerButtonTapped
        ))
        optionsMenu.addAction(UIAlertAction(
            title: RobotsKeys.Configure.delete.translate(),
            style: .destructive,
            handler: deleteTapped
        ))
        optionsMenu.addAction(UIAlertAction(
            title: RobotsKeys.Configure.duplicate.translate(),
            style: .default,
            handler: duplicateTapped
        ))
        optionsMenu.addAction(UIAlertAction(
            title: RobotsKeys.Configure.rename.translate(),
            style: .default,
            handler: renameTapped
        ))
        optionsMenu.addAction(UIAlertAction(
            title: RobotsKeys.Configure.changeImage.translate(),
            style: .default,
            handler: takePhotoTapped
        ))

        if let visualEffectView = optionsMenu.view.visualEffectsSubview {
            visualEffectView.effect = UIBlurEffect(style: .dark)
            optionsMenu.view.tintColor = .white
        }

        present(optionsMenu, animated: true, completion: { [weak self] in
            guard
                let `self` = self,
                let subview = optionsMenu.view.superview?.subviews[1]
            else { return }

            subview.isUserInteractionEnabled = true
            subview.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.tappedOutside)
            ))

            self.logEvent(named: "open_overflow_menu")
        })
    }

    @objc private func tappedOutside(callback: Callback? = nil) {
        dismiss(animated: true, completion: { [weak self] in
            self?.reloadConfigurationView()
        })
    }

    private func fetchBackgroundPrograms() -> [ProgramDataModel] {
        let programs = Set(realmService.getPrograms())
        let prohibited = Set(padConfiguration.viewModel.buttonPrograms)
        return Array(programs.subtracting(prohibited))
    }

    private func navigateToNewController() {
        let controllersViewController = AppContainer.shared.container
            .unwrappedResolve(ControllerLayoutSelectorViewController.self)
        controllersViewController.configurationId = configuration?.id
        navigationController?.pushViewController(controllersViewController, animated: true)
    }

    private func updateConfiguration(name: String, description: String?) {
        realmService.updateObject(closure: { [weak self] in
            guard let selectedRobot = self?.selectedRobot else { return }
            selectedRobot.customName = name
            selectedRobot.customDescription = description
        })
    }

    internal func renameTapped(_ sender: Any) {
        guard let robot = selectedRobot else { return }
        let modal = SaveModalView.instatiate()
        modal.type = .configuration
        modal.name = robot.customName
        modal.descriptionTitle = robot.customDescription
        modal.saveCallback = { [weak self] data in
            guard let `self` = self else { return }

            self.updateConfiguration(name: data.name, description: data.description)
            self.logEvent(named: "rename_robot")
            FileManager.default.save(self.robotImage, as: robot.id)
            self.dismissModalViewController()
            self.updateNavigationBar()
            self.saveCallback?()
        }

        reloadConfigurationView()
        presentModal(with: modal)
    }

    internal func reloadConfigurationView() {
        padConfiguration.configurationView.removeFromSuperview()
        padConfiguration.refreshViewState()
    }

    internal func createNewConfiguration() {
        let configId = UUID().uuidString
        let robot = UserRobot(
            id: UUID().uuidString,
            remoteId: "",
            buildStatus: .completed,
            actualBuildStep: -1,
            lastModified: Date(),
            configId: configId,
            customName: nil,
            customImage: nil,
            customDescription: nil)
        let defaultMapping = ControllerButtonMappingDataModel(b1: nil, b2: nil, b3: nil, b4: nil, b5: nil, b6: nil)
        let controllerId = UUID().uuidString
        let controller = ControllerDataModel(
            id: controllerId,
            configurationId:
            configId,
            type: ControllerType.gamer.rawValue,
            mapping: defaultMapping
        )

        let configuration = ConfigurationDataModel(
            id: configId,
            controller: controllerId,
            mapping: PortMappingDataModel()
        )

        realmService.saveControllers([controller])
        realmService.saveRobot(robot, shouldUpdate: true)
        realmService.saveConfigurations([configuration])
        selectedRobot = robot

        logEvent(named: "create_custom_robot")
    }
}
