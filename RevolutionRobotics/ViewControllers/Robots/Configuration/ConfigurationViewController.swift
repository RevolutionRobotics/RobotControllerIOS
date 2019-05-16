//
//  ConfigurationViewController.swift
//  RevolutionRobotics
//
//  Created by Csaba Vidó on 2019. 04. 29..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ConfigurationViewController: BaseViewController {
    // MARK: - Constants
    private enum Constants {
        static let defaultRobotImage = "defaultRobotImage"
        static let cellRatio: CGFloat = 213 / 190
    }

    // MARK: - Outlets
    @IBOutlet private weak var configurationView: ConfigurationView!
    @IBOutlet private weak var segmentedControl: SegmentedControl!
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    @IBOutlet private weak var collectionView: RRCollectionView!
    @IBOutlet private weak var controllerCollectionView: UIView!

    // MARK: - Properties
    var realmService: RealmServiceInterface!
    private let photoModal = PhotoModal.instatiate()
    private var robotImage: UIImage?
    private var shouldPrefillConfiguration = false
    private var controllers: [Int] = [] {
        didSet {
            collectionView.reloadData()
            if !controllers.isEmpty {
                self.collectionView.refreshCollectionView()
            }
        }
    }

    var selectedRobot: UserRobot? {
        didSet {
            configuration = realmService.getConfiguration(id: selectedRobot?.configId)
            shouldPrefillConfiguration = true
        }
    }
    var configuration: ConfigurationDataModel?
}

// MARK: - View lifecycle
extension ConfigurationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: selectedRobot?.customName ?? RobotsKeys.Configure.title.translate(), delegate: self)

        setupSegmentedControl()
        setupRobotImageView()
        setupCollectionView()
        setupConfigurationView()
        if shouldPrefillConfiguration {
            refreshConfigurationData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        controllers = realmService.getControllers()
        collectionView.setupInset()
    }
}

// MARK: - UICollectionViewDataSource
extension ConfigurationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return controllers.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ControllerCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.indexPath = indexPath
        return cell
    }
}

// MARK: - RRCollectionViewDelegate
extension ConfigurationViewController: RRCollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }

    func setButtons(rightHidden: Bool, leftHidden: Bool) {
        leftButton.isHidden = leftHidden
        rightButton.isHidden = rightHidden
    }
}

// MARK: - Setups
extension ConfigurationViewController {
    private func setupConfigurationView() {
        configurationView.portSelectionHandler = { [weak self] port in
            self?.configurationView.set(state: .highlighted, on: port.number)
            switch port.type {
            case .motor, .drivetrain:
                self?.showMotorConfiguration(portNumber: port.number)
            case .bumper, .ultrasonic:
                self?.showSensorConfiguration(portNumber: port.number)
            }

        }
    }

    private func showMotorConfiguration(portNumber: Int) {
        let motorConfig = AppContainer.shared.container.unwrappedResolve(MotorConfigViewController.self)
        motorConfig.portNumber = portNumber
        motorConfig.selectedMotorState =
            MotorConfigViewModelState(dataModel: configuration?.mapping?.motor(for: portNumber))
        motorConfig.doneButtonTapped = { [weak self] config in
            self?.dismissViewController()
            self?.updateMotorPort(config, on: motorConfig.portNumber)
        }
        motorConfig.screenDismissed = { [weak self] in
            self?.refreshConfigurationData()
        }
        present(viewController: motorConfig, onSide: .right)
    }

    private func updateMotorPort(_ motor: MotorConfigViewModel?, on port: Int) {
        guard let motor = motor else { return }
        realmService.updateObject { [weak self] in
            self?.configuration?.mapping?.updateMotor(portNumber: port, config: motor)
            self?.refreshConfigurationData()
        }
    }

    private func updateSensorPort(_ sensor: SensorConfigViewModel?, on port: Int) {
        guard let sensor = sensor else { return }
        realmService.updateObject { [weak self] in
            self?.configuration?.mapping?.updateSensor(portNumber: port, config: sensor)
            self?.refreshConfigurationData()
        }
    }

    private func showSensorConfiguration(portNumber: Int) {
        let sensorConfig = AppContainer.shared.container.unwrappedResolve(SensorConfigViewController.self)
        sensorConfig.portNumber = portNumber
        sensorConfig.selectedSensorType =
            SensorConfigViewModelType(dataModel: configuration?.mapping?.sensor(for: portNumber))
        sensorConfig.doneButtonTapped = { [weak self] config in
            self?.dismissViewController()
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
        segmentedControl.setSelectedIndex(0)
        segmentedControl.selectionCallback = { [weak self] selectedSegment in
            self?.segmentSelected(selectedSegment)
        }
    }

    private func segmentSelected(_ segment: ConfigurationSegment) {
        configurationView.isHidden = segment == .controllers
        controllerCollectionView.isHidden = segment == .connections
        leftButton.isHidden = segment == .connections
        rightButton.isHidden = segment == .connections
        controllers = realmService.getControllers()
    }

    private func setupRobotImageView() {
        if robotImage != nil {
            configurationView.image = robotImage
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
extension ConfigurationViewController {
    @IBAction private func saveTapped(_ sender: Any) {
        guard let robot = selectedRobot else {
            createNewConfiguration()
            return
        }

        updateConfiguration(on: robot)
    }

    private func createNewConfiguration() {

    }

    private func updateConfiguration(on robot: UserRobot) {
    }

    @IBAction private func bluetoothTapped(_ sender: Any) {
    }

    @IBAction private func leftButtonTapped(_ sender: Any) {
        collectionView.leftStep()
    }

    @IBAction private func rightButtonTapped(_ sender: Any) {
        collectionView.rightStep()
    }
}

// MARK: - Image picker
extension ConfigurationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBAction private func takePhotoTapped(_ sender: Any) {
        UIImagePickerController.show(with: self, on: self)
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
        configurationView.image = newImage

        dismiss(animated: true)
        photoModal.showImagePicker = { [weak self] in
            UIImagePickerController.show(with: self!, on: (self?.presentedViewController)!)
        }
        photoModal.deleteHandler = { [weak self] in
            self?.configurationView.image = Image.Configuration.Connections.defaultRobotImage
            self?.dismiss(animated: true)
        }
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
