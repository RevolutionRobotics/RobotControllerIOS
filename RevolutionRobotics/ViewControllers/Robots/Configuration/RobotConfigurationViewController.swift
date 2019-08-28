//
//  ConfigurationViewController.swift
//  RevolutionRobotics
//
//  Created by Csaba Vidó on 2019. 04. 29..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import os

final class RobotConfigurationViewController: BaseViewController {
    // MARK: - Constants
    private enum Constants {
        static let cellRatio: CGFloat = 213 / 190
    }

    // MARK: - ViewModel
    struct ViewModel {
        let id: String
        let remoteId: String
        let buildStatus: BuildStatus
        let actualBuildStep: Int
        let lastModified: Date
        let configId: String
        let customName: String?
        let customImage: String?
        let customDescription: String?

        init(userRobot: UserRobot) {
            self.id = userRobot.id
            self.remoteId = "\(userRobot.remoteId)"
            self.buildStatus = BuildStatus(rawValue: userRobot.buildStatus)!
            self.actualBuildStep = userRobot.actualBuildStep
            self.lastModified = userRobot.lastModified
            self.configId = "\(userRobot.configId)"
            self.customName = userRobot.customName
            self.customImage = userRobot.customImage
            self.customDescription = userRobot.customDescription
        }
    }

    // MARK: - Outlets
    @IBOutlet private weak var configurationView: ConfigurationView!
    @IBOutlet private weak var segmentedControl: RRSegmentedControl!
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var playButton: RRButton!
    @IBOutlet private weak var controllerContainerView: UIView!

    // MARK: - Properties
    var realmService: RealmServiceInterface!
    var firebaseService: FirebaseServiceInterface!
    var viewModel: ViewModel!

    private let photoModal = PhotoModalView.instatiate()
    private let padConfiguration = PadConfigurationViewController()
    private var robotImage: UIImage?
    private var shouldPrefillConfiguration = false
    private var controller: ControllerDataModel?
    private var lastSelectedIndexPath: IndexPath?

    var selectedRobot: UserRobot? {
        didSet {
            configuration = realmService.getConfiguration(id: selectedRobot?.configId)
            shouldPrefillConfiguration = true
            robotImage = FileManager.default.image(for: selectedRobot?.id)
        }
    }
    var configuration: ConfigurationDataModel?
    var deleteCallback: Callback?
    var duplicateCallback: Callback?
    var saveCallback: Callback?

    override func backButtonDidTap() {
        navigationController?.pop(to: YourRobotsViewController.self)
    }
}

// MARK: - View lifecycle
extension RobotConfigurationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        if selectedRobot == nil {
            createNewConfiguration()
        }

        let controllerType = realmService.getController(id: configuration?.controller)?.type
        controller = ControllerDataModel(
            id: configuration?.controller ?? UUID().uuidString,
            configurationId: configuration?.id ?? UUID().uuidString,
            type: controllerType ?? ControllerType.gamer.rawValue,
            mapping: ControllerButtonMappingDataModel()
        )

        navigationBar.setup(title: selectedRobot?.customName ?? RobotsKeys.Configure.title.translate(), delegate: self)
        navigationBar.bluetoothButtonState = bluetoothService.connectedDevice != nil ? .connected : .notConnected

        setupPadConfiguration()
        setupSegmentedControl()
        setupRobotImageView()
        setupPlayButton()
        setupConfigurationView()
        setupPhotoModal()

        if shouldPrefillConfiguration {
            refreshConfigurationData()
        }
    }
}

// MARK: - Setups
extension RobotConfigurationViewController {
    private func setupPlayButton() {
        playButton.setTitle(RobotsKeys.YourRobots.play.translate(), for: .normal)
        playButton.titleLabel?.font = Font.barlow(size: 14.0, weight: .medium)
        playButton.setBorder(strokeColor: .white)
    }

    private func navigateToPlayControllerViewController(with controller: ControllerDataModel) {
        let playController = AppContainer.shared.container.unwrappedResolve(PlayControllerViewController.self)
        playController.controllerDataModel = controller
        playController.robotName = selectedRobot?.customName
        navigationController?.pushViewController(playController, animated: true)
    }

    private func setupPhotoModal() {
        photoModal.showImagePicker = { [weak self] in
            UIImagePickerController.show(with: self!, on: (self?.presentedViewController)!)
        }
        photoModal.deleteHandler = { [weak self] in
            FileManager.default.delete(name: self?.selectedRobot?.id)
            self?.robotImage = nil
            self?.dismiss(animated: true)
        }
    }

    private func setupConfigurationView() {
        configurationView.portSelectionHandler = { [weak self] port in
            self?.configurationView.set(state: .highlighted, on: port.number)
            switch port.type {
            case .motor, .drive:
                self?.showMotorConfiguration(portNumber: port.number)
            case .bumper, .distance:
                self?.showSensorConfiguration(portNumber: port.number)
            }
        }
    }

    private func setupPadConfiguration(with type: ControllerType? = nil) {
        padConfiguration.realmService = realmService
        padConfiguration.configurationView = (type?.rawValue ?? controller?.type) == ControllerType.gamer.rawValue
            ? GamerConfigurationView.instatiate()
            : MultiTaskerConfigurationView.instatiate()

        padConfiguration.configurationId = configuration?.id
        padConfiguration.selectedControllerId = controller?.id

        guard let configView = padConfiguration.view else { return }

        addChild(padConfiguration)
        controllerContainerView.addSubview(configView)
        padConfiguration.didMove(toParent: self)

        configView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            configView.topAnchor.constraint(equalTo: controllerContainerView.topAnchor),
            configView.bottomAnchor.constraint(equalTo: controllerContainerView.bottomAnchor),
            configView.leadingAnchor.constraint(equalTo: controllerContainerView.leadingAnchor),
            configView.trailingAnchor.constraint(equalTo: controllerContainerView.trailingAnchor)
        ])
    }

    private func showMotorConfiguration(portNumber: Int) {
        let motorConfig = AppContainer.shared.container.unwrappedResolve(MotorConfigViewController.self)
        motorConfig.portNumber = portNumber
        if let motors = configuration?.mapping?.motors.compactMap({ $0 }) {
            motorConfig.numberOfDrives = motors.filter({ $0.type == MotorDataModel.Constants.drive }).count
        }
        motorConfig.selectedMotorState =
            MotorConfigViewModelState(dataModel: configuration?.mapping?.motor(for: portNumber))
        motorConfig.name = configuration?.mapping?.motor(for: portNumber)?.variableName
        motorConfig.prohibitedNames = configuration?.mapping?.variableNames.filter({ $0 != motorConfig.name }) ?? []
        motorConfig.doneButtonTapped = { [weak self] config in
            guard let `self` = self else { return }
            self.dismiss(animated: true, completion: nil)
            self.updateMotorPort(config, on: motorConfig.portNumber)
        }
        motorConfig.screenDismissed = { [weak self] in
            self?.refreshConfigurationData()
        }
        present(viewController: motorConfig, onSide: .right)
    }

    private func updateMotorPort(_ motor: MotorConfigViewModel?, on port: Int) {
        guard let motor = motor else { return }
        let config = motor.state == .empty ? nil : MotorDataModel(viewModel: motor)
        realmService.updateObject(closure: { [weak self] in
            self?.configuration?.mapping?.set(motor: config, to: port)
        })
        refreshConfigurationData()
    }

    private func updateSensorPort(_ sensor: SensorConfigViewModel?, on port: Int) {
        guard let sensor = sensor else { return }
        let config = sensor.type == .empty ? nil : SensorDataModel(viewModel: sensor)
        realmService.updateObject(closure: { [weak self] in
            self?.configuration?.mapping?.set(sensor: config, to: port)
        })
        refreshConfigurationData()
    }

    private func showSensorConfiguration(portNumber: Int) {
        let mapping = configuration?.mapping
        let sensorConfig = AppContainer.shared.container.unwrappedResolve(SensorConfigViewController.self)

        sensorConfig.portNumber = portNumber
        sensorConfig.selectedSensorType =
            SensorConfigViewModelType(dataModel: mapping?.sensor(for: portNumber))
        sensorConfig.name = mapping?.sensor(for: portNumber)?.variableName
        sensorConfig.bumperSensorCounts = mapping?.bumperSensorCount ?? 0
        sensorConfig.distanceSensorCounts = mapping?.distanceSensorCount ?? 0
        sensorConfig.prohibitedNames = mapping?.variableNames.filter({ $0 != sensorConfig.name }) ?? []
        sensorConfig.doneButtonTapped = { [weak self] config in
            guard let `self` = self else { return }
            self.dismiss(animated: true, completion: nil)
            self.updateSensorPort(config, on: sensorConfig.portNumber)
        }
        sensorConfig.screenDismissed = { [weak self] in
            self?.refreshConfigurationData()
        }
        present(viewController: sensorConfig, onSide: .left)
    }

    private func setupSegmentedControl() {
        segmentedControl.setup(with: [RobotsKeys.Configure.connectionTabTitle.translate(),
                                      RobotsKeys.Configure.controllerTabTitle.translate()])
        segmentedControl.selectionCallback = { [weak self] selectedSegment in
            guard let `self` = self else { return }

            self.segmentSelected(selectedSegment)
            guard let configuration = self.configuration else { return }
            if selectedSegment == .controllers {
                if configuration.controller.isEmpty {
                    let controllersViewController =
                        AppContainer.shared.container.unwrappedResolve(ControllerLayoutSelectorViewController.self)
                    controllersViewController.configurationId = self.configuration?.id
                    self.navigationController?.pushViewController(controllersViewController, animated: true)
                }
            }
        }
        segmentedControl.setSelectedIndex(0)
    }

    private func segmentSelected(_ segment: ConfigurationSegment) {
        configurationView.isHidden = segment == .controllers
        padConfiguration.view.isHidden = segment == .connections
    }

    private func setupRobotImageView() {
        if robotImage != nil {
            photoModal.setImage(robotImage)
        }
    }
}

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
        }
        deleteView.cancelButtonHandler = { [weak self] in
            self?.dismissModalViewController()
        }

        reloadConfigurationView()
        presentModal(with: deleteView)
    }

    private func duplicateTapped(_ sender: Any) {
        duplicateCallback?()
        navigationController?.popViewController(animated: true)
    }

    private func controllerButtonTapped(_ sender: Any) {
        reloadConfigurationView()

        guard
            let configurationView = padConfiguration.configurationView,
            let controllerType = controller?.type
        else { return }

        let toggledType: ControllerType = controllerType == ControllerType.gamer.rawValue
            ? .multiTasker
            : .gamer

        configurationView.removeFromSuperview()
        padConfiguration.controllerType = toggledType

        let savedController = realmService.getController(id: controller?.id)
        realmService.updateObject(closure: {
            savedController?.type = toggledType.rawValue
        })

        controller?.type = toggledType.rawValue
    }

    @IBAction private func backgroundProgramsTapped(_ sender: Any) {
        let vc = AppContainer.shared.container.unwrappedResolve(ButtonlessProgramsViewController.self)
        vc.configurationId = padConfiguration.configurationId
        vc.controllerViewModel = padConfiguration.viewModel
        navigationController?.pushViewController(vc, animated: true)
    }

    private func renameTapped(_ sender: Any) {
        guard let robot = selectedRobot else { return }

        let modal = SaveModalView.instatiate()
        modal.type = .configuration
        modal.name = robot.customName
        modal.descriptionTitle = robot.customDescription
        modal.saveCallback = { [weak self] data in
            guard let `self` = self else { return }

            self.updateConfiguration(name: data.name, description: data.description)
            FileManager.default.save(self.robotImage, as: robot.id)
            self.dismissModalViewController()
            self.navigationBar.setup(
                title: self.selectedRobot?.customName ?? RobotsKeys.Configure.title.translate(),
                delegate: self
            )
            self.saveCallback?()
        }

        reloadConfigurationView()
        presentModal(with: modal)
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
        })
    }

    @objc private func tappedOutside(callback: Callback? = nil) {
        dismiss(animated: true, completion: { [weak self] in
            self?.reloadConfigurationView()
        })
    }

    private func reloadConfigurationView() {
        padConfiguration.configurationView.removeFromSuperview()
        padConfiguration.refreshViewState()
    }

    private func isProgramCompatible(_ program: ProgramDataModel) -> Bool {
        let variableNames = realmService.getConfiguration(id: configuration?.id)?.mapping?.variableNames ?? []
        return Set(program.variableNames).isSubset(of: Set(variableNames))
    }

    private func fetchBackgroundPrograms() -> [ProgramDataModel] {
        let programs = Set(realmService.getPrograms())
        let prohibited = Set(padConfiguration.viewModel.buttonPrograms)
        return Array(programs.subtracting(prohibited))
    }

    private func createNewConfiguration() {
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
}

// MARK: - Image picker
extension RobotConfigurationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func takePhotoTapped(_ sender: Any) {
        reloadConfigurationView()

        if robotImage == nil {
            UIImagePickerController.show(with: self, on: self)
        } else {
            presentModal(with: photoModal)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        var newImage: UIImage
        if let possibleImage = info[.editedImage] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info[.originalImage] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }

        photoModal.setImage(newImage)
        robotImage = newImage
        if let robotId = selectedRobot?.id {
            FileManager.default.save(robotImage, as: robotId)
        }
        dismiss(animated: true)
        presentModal(with: photoModal, animated: true)
    }

    private func refreshConfigurationData() {
        guard let mapping = configuration?.mapping else { return }
        mapping.motors.enumerated().forEach({ index, motor in
            let motorState: PortButton.PortState = motor != nil ? .selected : .normal
            let motorType = PortButton.PortType(string: motor?.type)
            configurationView.set(state: motorState, on: index + 1, type: motorType)
        })
        mapping.sensors.enumerated().forEach({ index, sensor in
            let sensorState: PortButton.PortState = sensor != nil ? .selected : .normal
            let sensorType = PortButton.PortType(string: sensor?.type)
            configurationView.set(state: sensorState, on: mapping.motors.count + index + 1, type: sensorType)
        })
    }
}

// MARK: - Connections
extension RobotConfigurationViewController {
    override func connected() {
        if presentedViewController == nil {
            super.connected()
            bluetoothService.stopDiscovery()
        }

        navigationBar.bluetoothButtonState = .connected
    }

    override func disconnected() {
        super.disconnected()
        navigationBar.bluetoothButtonState = .notConnected
    }
}
