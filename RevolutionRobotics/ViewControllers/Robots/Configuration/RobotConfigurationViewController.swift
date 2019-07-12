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
        static let defaultRobotImage = "defaultRobotImage"
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
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    @IBOutlet private weak var collectionView: RRCollectionView!
    @IBOutlet private weak var controllerCollectionView: UIView!
    @IBOutlet private weak var createNewButton: SideButton!
    @IBOutlet private weak var leftButtonLeadingConstraint: NSLayoutConstraint!

    // MARK: - Properties
    var realmService: RealmServiceInterface!
    var firebaseService: FirebaseServiceInterface!
    var viewModel: ViewModel!
    private let photoModal = PhotoModalView.instatiate()
    private var robotImage: UIImage?
    private var shouldPrefillConfiguration = false
    private var controllers: [ControllerDataModel] = [] {
        didSet {
            var controllerTitle = RobotsKeys.Configure.controllerTabTitle.translate()
            if !controllers.isEmpty {
                self.collectionView.reloadSections(IndexSet(integer: 0))
                self.collectionView.refreshCollectionView()
            } else {
                if controllers.isEmpty {
                    controllerTitle += " ⚠️"
                }
            }
            segmentedControl.updateControllersSegment(with: controllerTitle)
        }
    }
    private var lastSelectedIndexPath: IndexPath?
    var selectedRobot: UserRobot? {
        didSet {
            configuration = realmService.getConfiguration(id: selectedRobot?.configId)
            shouldPrefillConfiguration = true
            robotImage = FileManager.default.image(for: selectedRobot?.id)
        }
    }
    var configuration: ConfigurationDataModel?
    var saveCallback: Callback?

    override func backButtonDidTap() {
        navigationController?.pop(to: YourRobotsViewController.self)
    }
}

// MARK: - View lifecycle
extension RobotConfigurationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: selectedRobot?.customName ?? RobotsKeys.Configure.title.translate(), delegate: self)
        navigationBar.bluetoothButtonState = bluetoothService.connectedDevice != nil ? .connected : .notConnected

        setupSegmentedControl()
        setupRobotImageView()
        setupCollectionView()
        setupConfigurationView()
        setupPhotoModal()
        if shouldPrefillConfiguration {
            refreshConfigurationData()
        }
        createNewButton.title = ControllerKeys.createNew.translate()
        createNewButton.selectionHandler = { [weak self] in
            let controllersViewController =
                AppContainer.shared.container.unwrappedResolve(ControllerLayoutSelectorViewController.self)
            controllersViewController.configurationId = self?.configuration?.id
            self?.navigationController?.pushViewController(controllersViewController, animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if selectedRobot == nil {
            createNewConfiguration()
        }

        collectionView.setupLayout()
        if UIView.notchSize > CGFloat.zero {
            leftButtonLeadingConstraint.constant = UIView.actualNotchSize
        }
        controllers = realmService.getControllers()
            .filter({ $0.configurationId == configuration!.id })
            .sorted(by: { $0.lastModified > $1.lastModified })
    }
}

// MARK: - UICollectionViewDataSource
extension RobotConfigurationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return controllers.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ControllerCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.indexPath = indexPath
        cell.setup(with: controllers[indexPath.row])
        cell.isControllerSelected = configuration?.controller == controllers[indexPath.row].id
        cell.infoCallback = { [weak self] in
            let controllerInfoView = ControllerInfoModalView.instatiate()
            controllerInfoView.setup(
                name: self?.controllers[indexPath.row].name,
                description: self?.controllers[indexPath.row].controllerDescription,
                date: self?.controllers[indexPath.row].lastModified,
                callback: { [weak self] in
                    self?.dismissModalViewController()
            })
            self?.presentModal(with: controllerInfoView)
        }
        cell.editCallback = { [weak self] in
            let vc = AppContainer.shared.container.unwrappedResolve(PadConfigurationViewController.self)
            vc.selectedControllerId = self?.controllers[indexPath.row].id
            vc.configurationId = self?.configuration?.id
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        cell.deleteCallback = { [weak self] in
            let deleteView = DeleteModalView.instatiate()
            deleteView.title = ModalKeys.ControllerDelete.description.translate()
            deleteView.deleteButtonHandler = { [weak self] in self?.handleControllerDeletion(on: indexPath) }
            deleteView.cancelButtonHandler = { [weak self] in self?.dismissModalViewController() }
            self?.presentModal(with: deleteView)
        }
        if let lastIndexPath = lastSelectedIndexPath {
            cell.isControllerSelected = lastIndexPath == indexPath
        }
        return cell
    }

    private func handleControllerDeletion(on indexPath: IndexPath) {
        guard let configuration = configuration else { return }
        let controllerToDelete = controllers[indexPath.row]
        let hasOnlyOneAvailableController =
            realmService.getControllers().filter({ $0.configurationId == configuration.id }).count == 1
        let isControllerToDeleteTheSelectedOne = controllerToDelete.id == configuration.controller
        if isControllerToDeleteTheSelectedOne && hasOnlyOneAvailableController {
            realmService.updateObject(closure: { [weak self] in
                configuration.controller = ""
                self?.selectedRobot?.buildStatus = BuildStatus.invalidConfiguration.rawValue
            })
            deleteController(controllerToDelete)
            saveCallback?()
        } else if isControllerToDeleteTheSelectedOne {
            let controller = realmService.getControllers().first(where: { $0.configurationId == configuration.id &&
                $0.id != controllerToDelete.id })!
            realmService.updateObject(closure: {
                configuration.controller = controller.id
            })
            deleteController(controllerToDelete)
        } else {
            deleteController(controllerToDelete)
        }

        collectionView.clearIndexPath()
        controllers = realmService.getControllers()
            .filter({ $0.configurationId == configuration.id })
            .sorted(by: { $0.lastModified > $1.lastModified })
        collectionView.reloadData()
        dismissModalViewController()
    }

    private func deleteController(_ controller: ControllerDataModel?) {
        guard let controller = controller else { return }
        realmService.deleteController(controller)
    }
}

// MARK: - RRCollectionViewDelegate
extension RobotConfigurationViewController: RRCollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ControllerCollectionViewCell,
            lastSelectedIndexPath != indexPath else { return }

        guard !cell.isControllerSelected else {
            navigateToPlayControllerViewController(with: controllers[indexPath.row])
            return
        }

        for index in 0...collectionView.numberOfItems(inSection: 0) {
            let cell =
                collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ControllerCollectionViewCell
            cell?.isControllerSelected = false
        }

        cell.isControllerSelected = true

        realmService.updateObject(closure: { [weak self] in
            guard let id = self?.controllers[indexPath.item].id else { return }
            self?.configuration?.controller = id
        })
    }

    func setButtons(rightHidden: Bool, leftHidden: Bool) {
        if segmentedControl.selectedSegment == .controllers {
            leftButton.isHidden = leftHidden
            rightButton.isHidden = rightHidden
        }
    }
}

// MARK: - Setups
extension RobotConfigurationViewController {
    private func navigateToPlayControllerViewController(with controller: ControllerDataModel) {
        let playController = AppContainer.shared.container.unwrappedResolve(PlayControllerViewController.self)
        playController.controllerDataModel = controller
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
            self?.dismiss(animated: true, completion: nil)
            self?.updateMotorPort(config, on: motorConfig.portNumber)
        }
        motorConfig.screenDismissed = { [weak self] in
            self?.refreshConfigurationData()
        }
        present(viewController: motorConfig, onSide: .right)
    }

    private func updateMotorPort(_ motor: MotorConfigViewModel?, on port: Int) {
        guard let motor = motor else { return }
        if motor.state == .empty {
            realmService.updateObject(closure: { [weak self] in
                self?.configuration?.mapping?.set(motor: nil, to: port)
            })
        } else {
            let config = MotorDataModel(viewModel: motor)
            realmService.updateObject(closure: { [weak self] in
                self?.configuration?.mapping?.set(motor: config, to: port)
            })
        }

        refreshConfigurationData()
    }

    private func updateSensorPort(_ sensor: SensorConfigViewModel?, on port: Int) {
        guard let sensor = sensor else { return }
        if sensor.type == .empty {
            realmService.updateObject(closure: { [weak self] in
                self?.configuration?.mapping?.set(sensor: nil, to: port)
            })
        } else {
            let config = SensorDataModel(viewModel: sensor)
            realmService.updateObject(closure: { [weak self] in
                self?.configuration?.mapping?.set(sensor: config, to: port)
            })
        }

        refreshConfigurationData()
    }

    private func showSensorConfiguration(portNumber: Int) {
        let sensorConfig = AppContainer.shared.container.unwrappedResolve(SensorConfigViewController.self)
        sensorConfig.portNumber = portNumber
        sensorConfig.selectedSensorType =
            SensorConfigViewModelType(dataModel: configuration?.mapping?.sensor(for: portNumber))
        sensorConfig.name = configuration?.mapping?.sensor(for: portNumber)?.variableName
        sensorConfig.bumperSensorCounts = configuration?.mapping?.bumperSensorCount ?? 0
        sensorConfig.distanceSensorCounts = configuration?.mapping?.distanceSensorCount ?? 0
        sensorConfig.prohibitedNames = configuration?.mapping?.variableNames.filter({ $0 != sensorConfig.name }) ?? []
        sensorConfig.doneButtonTapped = { [weak self] config in
            self?.dismiss(animated: true, completion: nil)
            self?.updateSensorPort(config, on: sensorConfig.portNumber)
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
            self?.segmentSelected(selectedSegment)
            if selectedSegment == .controllers {
                if (self?.configuration?.controller.isEmpty)! {
                    let controllersViewController =
                        AppContainer.shared.container.unwrappedResolve(ControllerLayoutSelectorViewController.self)
                    controllersViewController.configurationId = self?.configuration?.id
                    self?.navigationController?.pushViewController(controllersViewController, animated: true)
                }
            }
        }
        segmentedControl.setSelectedIndex(segmentedControl.selectedSegment.rawValue)
    }

    private func segmentSelected(_ segment: ConfigurationSegment) {
        configurationView.isHidden = segment == .controllers
        controllerCollectionView.isHidden = segment == .connections
        if segment == .controllers {
            collectionView.reloadSections(IndexSet(integer: 0))
            if !controllers.isEmpty {
                collectionView.refreshCollectionView()
            }
        }
    }

    private func setupRobotImageView() {
        if robotImage != nil {
            photoModal.setImage(robotImage)
        }
    }

    private func setupCollectionView() {
        collectionView.rrDelegate = self
        collectionView.dataSource = self
        collectionView.register(ControllerCollectionViewCell.self)
        collectionView.cellRatio = Constants.cellRatio
    }
}

// MARK: - Actions
extension RobotConfigurationViewController {
    @IBAction private func saveTapped(_ sender: Any) {
        guard let robot = selectedRobot else { return }

        let modal = SaveModalView.instatiate()
        modal.type = .configuration
        modal.name = robot.customName
        modal.descriptionTitle = robot.customDescription
        modal.saveCallback = { [weak self] data in
            self?.updateConfiguration(on: robot, name: data.name, description: data.description)
            FileManager.default.save(self?.robotImage, as: robot.id)
            self?.dismissModalViewController()
            self?.navigationBar.setup(title: self?.selectedRobot?.customName ?? RobotsKeys.Configure.title.translate(),
                                      delegate: self)
            self?.saveCallback?()
        }
        presentModal(with: modal)
    }

    private func createNewConfiguration() {
        let configId = UUID().uuidString
        let robot = UserRobot(
            id: UUID().uuidString,
            remoteId: "",
            buildStatus: .invalidConfiguration,
            actualBuildStep: -1,
            lastModified: Date(),
            configId: configId,
            customName: nil,
            customImage: nil,
            customDescription: nil)
        let configuration = ConfigurationDataModel(id: configId, controller: "", mapping: PortMappingDataModel())
        realmService.saveRobot(robot, shouldUpdate: true)
        realmService.saveConfigurations([configuration])
        selectedRobot = robot
    }

    private func updateConfiguration(on robot: UserRobot, name: String, description: String?) {
        realmService.updateObject(closure: { [weak self] in
            self?.selectedRobot?.customName = name
            self?.selectedRobot?.customDescription = description
        })
    }

    @IBAction private func leftButtonTapped(_ sender: Any) {
        collectionView.leftStep()
    }

    @IBAction private func rightButtonTapped(_ sender: Any) {
        collectionView.rightStep()
    }
}

// MARK: - Image picker
extension RobotConfigurationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBAction private func takePhotoTapped(_ sender: Any) {
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
        let m1State = mapping.m1 != nil ? PortButton.PortState.selected : PortButton.PortState.normal
        let m1Type = PortButton.PortType(string: mapping.m1?.type)
        configurationView.set(state: m1State, on: ConfigurationView.Constants.m1PortNumber, type: m1Type)
        let m2State = mapping.m2 != nil ? PortButton.PortState.selected : PortButton.PortState.normal
        let m2Type = PortButton.PortType(string: mapping.m2?.type)
        configurationView.set(state: m2State, on: ConfigurationView.Constants.m2PortNumber, type: m2Type)
        let m3State = mapping.m3 != nil ? PortButton.PortState.selected : PortButton.PortState.normal
        let m3Type = PortButton.PortType(string: mapping.m3?.type)
        configurationView.set(state: m3State, on: ConfigurationView.Constants.m3PortNumber, type: m3Type)
        let m4State = mapping.m4 != nil ? PortButton.PortState.selected : PortButton.PortState.normal
        let m4Type = PortButton.PortType(string: mapping.m4?.type)
        configurationView.set(state: m4State, on: ConfigurationView.Constants.m4PortNumber, type: m4Type)
        let m5State = mapping.m5 != nil ? PortButton.PortState.selected : PortButton.PortState.normal
        let m5Type = PortButton.PortType(string: mapping.m5?.type)
        configurationView.set(state: m5State, on: ConfigurationView.Constants.m5PortNumber, type: m5Type)
        let m6State = mapping.m6 != nil ? PortButton.PortState.selected : PortButton.PortState.normal
        let m6Type = PortButton.PortType(string: mapping.m6?.type)
        configurationView.set(state: m6State, on: ConfigurationView.Constants.m6PortNumber, type: m6Type)
        let s1State = mapping.s1 != nil ? PortButton.PortState.selected : PortButton.PortState.normal
        let s1Type = PortButton.PortType(string: mapping.s1?.type)
        configurationView.set(state: s1State, on: ConfigurationView.Constants.s1PortNumber, type: s1Type)
        let s2State = mapping.s2 != nil ? PortButton.PortState.selected : PortButton.PortState.normal
        let s2Type = PortButton.PortType(string: mapping.s2?.type)
        configurationView.set(state: s2State, on: ConfigurationView.Constants.s2PortNumber, type: s2Type)
        let s3State = mapping.s3 != nil ? PortButton.PortState.selected : PortButton.PortState.normal
        let s3Type = PortButton.PortType(string: mapping.s3?.type)
        configurationView.set(state: s3State, on: ConfigurationView.Constants.s3PortNumber, type: s3Type)
        let s4State = mapping.s4 != nil ? PortButton.PortState.selected : PortButton.PortState.normal
        let s4Type = PortButton.PortType(string: mapping.s4?.type)
        configurationView.set(state: s4State, on: ConfigurationView.Constants.s4PortNumber, type: s4Type)
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
