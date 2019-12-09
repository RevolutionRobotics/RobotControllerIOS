//
//  ConfigurationViewController.swift
//  RevolutionRobotics
//
//  Created by Csaba Vidó on 2019. 04. 29..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
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
    var shouldCloseConnectionModal: Bool = true

    internal let padConfiguration = PadConfigurationViewController()
    internal var controller: ControllerDataModel?
    internal var robotImage: UIImage?

    private let photoModal = PhotoModalView.instatiate()
    private var shouldPrefillConfiguration = false
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

        if (selectedRobot?.customName ?? "").isEmpty {
            renameTapped(self)
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
            guard let presentedViewController = self?.presentedViewController else {
                return
            }
            self?.showPhotoController(on: presentedViewController)
        }
        photoModal.deleteHandler = { [weak self] in
            FileManager.default.delete(name: self?.selectedRobot?.id)
            self?.robotImage = nil
            self?.dismiss(animated: true)
        }
    }

    private func showPhotoController(on parent: UIViewController) {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            UIImagePickerController.show(with: self, on: parent)
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] granted in
                guard let `self` = self else { return }
                if granted {
                    UIImagePickerController.show(with: self, on: parent)
                } else {
                    DispatchQueue.main.async { [weak self] in
                        self?.showPermissionAlert()
                    }
                }
            })
        }
    }

    private func showPermissionAlert() {
        let alertTitle = RobotsKeys.Configure.cameraPermissionTitle.translate()
        let alertMessage = RobotsKeys.Configure.cameraPermissionMessage.translate()

        let alertController = UIAlertController(title: alertTitle,
                                                message: alertMessage,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: CommonKeys.errorOk.translate(),
                                                style: .default,
                                                handler: { _ in self.showAppSettings() }))
        alertController.addAction(UIAlertAction(title: CommonKeys.cancel.translate(),
                                                style: .cancel,
                                                handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    private func showAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
            : DriverConfigurationView.instatiate()

        padConfiguration.configurationId = configuration?.id
        padConfiguration.selectedControllerId = controller?.id
        padConfiguration.robotId = selectedRobot?.id
        padConfiguration.bluetoothService = bluetoothService

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

            self.shouldCloseConnectionModal = true
            self.dismiss(animated: true, completion: nil)
            self.updateMotorPort(config, on: motorConfig.portNumber)
        }
        motorConfig.screenDismissed = { [weak self] in
            guard let `self` = self else { return }

            self.shouldCloseConnectionModal = true
            self.refreshConfigurationData()
        }

        shouldCloseConnectionModal = false
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

            self.shouldCloseConnectionModal = true
            self.dismiss(animated: true, completion: nil)
            self.updateSensorPort(config, on: sensorConfig.portNumber)
        }
        sensorConfig.screenDismissed = { [weak self] in
            guard let `self` = self else { return }

            self.shouldCloseConnectionModal = true
            self.refreshConfigurationData()
        }

        shouldCloseConnectionModal = false
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

        screenName = segment == .controllers
            ? "Configure controllers" : "Configure connections"
        Analytics.setScreenName(screenName, screenClass: classForCoder.description())
    }

    private func setupRobotImageView() {
        if robotImage != nil {
            photoModal.setImage(robotImage)
        }
    }

    internal func updateNavigationBar() {
        navigationBar.setup(
            title: selectedRobot?.customName ?? RobotsKeys.Configure.title.translate(),
            delegate: self
        )
    }
}

// MARK: - Image picker
extension RobotConfigurationViewController: UIImagePickerControllerDelegate {
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
 
    internal func takePhotoTapped(_ sender: Any) {
        reloadConfigurationView()
        if robotImage == nil {
            showPhotoController(on: self)
        } else {
            presentModal(with: photoModal)
        }
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
