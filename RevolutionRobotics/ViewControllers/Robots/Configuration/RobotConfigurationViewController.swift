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
        static let newCellNib = "ControllerCollectionViewCell"
        static let newCellReuseId = "cell_new"
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
    @IBOutlet private weak var leftButtonLeadingConstraint: NSLayoutConstraint!

    // MARK: - Properties
    var realmService: RealmServiceInterface!
    var firebaseService: FirebaseServiceInterface!
    var viewModel: ViewModel!
    private let photoModal = PhotoModalView.instatiate()
    private let newControllerModel = ControllerDataModel(
        id: "",
        configurationId: "",
        type: ControllerType.new.rawValue,
        mapping: ControllerButtonMappingDataModel()
    )

    private var robotImage: UIImage?
    private var shouldPrefillConfiguration = false
    private var controllers: [ControllerDataModel] = [] {
        didSet {
            var controllerTitle = RobotsKeys.Configure.controllerTabTitle.translate()
            if !controllers.isEmpty {
                collectionView.reloadSections(IndexSet(integer: 0))
                collectionView.refreshCollectionView(callback: { [weak self] in
                    self?.collectionView.selectCell(at: 1)
                })
            } else {
                controllerTitle += " ⚠️"
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if selectedRobot == nil {
            createNewConfiguration()
        }

        collectionView.setupLayout()
        if UIView.notchSize > .zero {
            leftButtonLeadingConstraint.constant = UIView.actualNotchSize
        }

        controllers = [newControllerModel] + realmService.getControllers()
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
        let cell: ControllerCollectionViewCell
        if controllers[indexPath.row].type == ControllerType.new.rawValue {
            guard let newCell = collectionView
                .dequeueReusableCell(withReuseIdentifier: Constants.newCellReuseId, for: indexPath)
                as? ControllerCollectionViewCell
            else {
                fatalError("Failed to dequeue new controller cell")
            }

            cell = newCell
        } else {
            cell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        }

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
        guard indexPath.item > 0 else {
            navigateToNewController()
            return
        }

        guard let cell = collectionView.cellForItem(at: indexPath) as? ControllerCollectionViewCell,
            lastSelectedIndexPath != indexPath else { return }

        guard !cell.isControllerSelected else {
            navigateToPlayControllerViewController(with: controllers[indexPath.row])
            return
        }

        for index in 0..<collectionView.numberOfItems(inSection: 0) {
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
            } else {
                self.collectionView.selectCell(at: 1)
            }
        }
        segmentedControl.setSelectedIndex(0)
    }

    private func segmentSelected(_ segment: ConfigurationSegment) {
        configurationView.isHidden = segment == .controllers
        controllerCollectionView.isHidden = segment == .connections
        if segment == .controllers {
            collectionView.reloadSections(IndexSet(integer: 0))
            if controllers.count > 1 {
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
        let newCellNib = UINib(nibName: Constants.newCellNib, bundle: nil)

        collectionView.rrDelegate = self
        collectionView.dataSource = self
        collectionView.register(ControllerCollectionViewCell.self)
        collectionView.register(newCellNib, forCellWithReuseIdentifier: Constants.newCellReuseId)
        collectionView.cellRatio = Constants.cellRatio
    }
}

// MARK: - Actions
extension RobotConfigurationViewController {
    @IBAction private func deleteTapped(_ sender: Any) {
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
        presentModal(with: deleteView)
    }

    @IBAction private func duplicateTapped(_ sender: Any) {
        duplicateCallback?()
        navigationController?.popViewController(animated: true)
    }

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

    private func navigateToNewController() {
        let controllersViewController = AppContainer.shared.container
            .unwrappedResolve(ControllerLayoutSelectorViewController.self)
        controllersViewController.configurationId = configuration?.id
        navigationController?.pushViewController(controllersViewController, animated: true)
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
        mapping.motors.enumerated().forEach({ index, motor in
            let motorState = motor != nil ? PortButton.PortState.selected : PortButton.PortState.normal
            let motorType = PortButton.PortType(string: motor?.type)
            configurationView.set(state: motorState, on: index + 1, type: motorType)
        })
        mapping.sensors.enumerated().forEach({ index, sensor in
            let sensorState = sensor != nil ? PortButton.PortState.selected : PortButton.PortState.normal
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
