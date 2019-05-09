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
    @IBOutlet private weak var configurationView: UIView!
    @IBOutlet private weak var segmentedControl: SegmentedControl!
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    @IBOutlet private weak var collectionView: RRCollectionView!
    @IBOutlet private weak var controllerCollectionView: UIView!
    @IBOutlet private weak var robotImageView: UIImageView!

    // MARK: - Motor Port 1
    @IBOutlet private weak var motorPort1: PortButton!
    @IBOutlet private var motorPort1Lines: [DashedView]!
    @IBOutlet private weak var motorPort1Dot: UIImageView!

    // MARK: - Motor Port 2
    @IBOutlet private weak var motorPort2: PortButton!
    @IBOutlet private var motorPort2Lines: [DashedView]!
    @IBOutlet private weak var motorPort2Dot: UIImageView!

    // MARK: - Motor Port 3
    @IBOutlet private weak var motorPort3: PortButton!
    @IBOutlet private var motorPort3Lines: [DashedView]!
    @IBOutlet private weak var motorPort3Dot: UIImageView!

    // MARK: - Motor Port 4
    @IBOutlet private weak var motorPort4: PortButton!
    @IBOutlet private var motorPort4Lines: [DashedView]!
    @IBOutlet private weak var motorPort4Dot: UIImageView!

    // MARK: - Motor Port 5
    @IBOutlet private weak var motorPort5: PortButton!
    @IBOutlet private var motorPort5Lines: [DashedView]!
    @IBOutlet private weak var motorPort5Dot: UIImageView!

    // MARK: - Motor Port 6
    @IBOutlet private weak var motorPort6: PortButton!
    @IBOutlet private var motorPort6Lines: [DashedView]!
    @IBOutlet private weak var motorPort6Dot: UIImageView!

    // MARK: - Sensor Port 1
    @IBOutlet private weak var sensorPort1: PortButton!
    @IBOutlet private var sensorPort1Lines: [DashedView]!
    @IBOutlet private weak var sensorPort1Dot: UIImageView!

    // MARK: - Sensor Port 2
    @IBOutlet private weak var sensorPort2: PortButton!
    @IBOutlet private var sensorPort2Lines: [DashedView]!
    @IBOutlet private weak var sensorPort2Dot: UIImageView!

    // MARK: - Sensor Port 3
    @IBOutlet private weak var sensorPort3: PortButton!
    @IBOutlet private var sensorPort3Lines: [DashedView]!
    @IBOutlet private weak var sensorPort3Dot: UIImageView!

    // MARK: - Sensor Port 4
    @IBOutlet private weak var sensorPort4: PortButton!
    @IBOutlet private var sensorPort4Lines: [DashedView]!
    @IBOutlet private weak var sensorPort4Dot: UIImageView!

    // MARK: - Properties
    var realmService: RealmServiceInterface!
    private let photoModal = PhotoModal.instatiate()
    private var robotImage: UIImage?
    // TODO: change to real controllers later
    private var controllers: [Int] = [] {
        didSet {
            collectionView.reloadData()
            if !controllers.isEmpty {
                self.collectionView.refreshCollectionView()
            }
        }
    }

    var selectedRobot: UserRobot?
}

// MARK: - View lifecycle
extension ConfigurationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: RobotsKeys.Configure.title.translate(), delegate: self)

        setupSegmentedControl()
        setupRobotImageView()
        setupCollectionView()
        connectMotorPorts()
        connectSensorPorts()
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
    private func connectMotorPorts() {
        motorPort1.lines = motorPort1Lines
        motorPort1.dotImageView = motorPort1Dot

        motorPort2.lines = motorPort2Lines
        motorPort2.dotImageView = motorPort2Dot

        motorPort3.lines = motorPort3Lines
        motorPort3.dotImageView = motorPort3Dot

        motorPort4.lines = motorPort4Lines
        motorPort4.dotImageView = motorPort4Dot

        motorPort5.lines = motorPort5Lines
        motorPort5.dotImageView = motorPort5Dot

        motorPort6.lines = motorPort6Lines
        motorPort6.dotImageView = motorPort6Dot
    }

    private func connectSensorPorts() {
        sensorPort1.lines = sensorPort1Lines
        sensorPort1.dotImageView = sensorPort1Dot

        sensorPort2.lines = sensorPort2Lines
        sensorPort2.dotImageView = sensorPort2Dot

        sensorPort3.lines = sensorPort3Lines
        sensorPort3.dotImageView = sensorPort3Dot

        sensorPort4.lines = sensorPort4Lines
        sensorPort4.dotImageView = sensorPort4Dot
    }

    private func setupSegmentedControl() {
        segmentedControl.setup(with: [RobotsKeys.Configure.connectionTabTitle.translate(),
                                      RobotsKeys.Configure.controllerTabTitle.translate()])
        segmentedControl.setSelectedIndex(0)
        segmentedControl.itemSelectedAt = { [weak self] in
            self?.configurationView.isHidden = $0 == .controllers
            self?.controllerCollectionView.isHidden = $0 == .connections
            self?.leftButton.isHidden = $0 == .connections
            self?.rightButton.isHidden = $0 == .connections
            if $0 == .controllers {
                guard let controllers = self?.realmService.getControllers() else {
                    return
                }
                self?.controllers = controllers
            }
        }
    }

    private func setupRobotImageView() {
        if robotImage != nil {
            robotImageView.image = robotImage
            photoModal.setImage(robotImage)
        }
    }

    private func setupCollectionView() {
        collectionView.rrDelegate = self
        collectionView.dataSource = self
        collectionView.register(ControllerCollectionViewCell.self)
        collectionView.cellRatio = Constants.cellRatio
        collectionView.setupInset()
    }
}

// MARK: - Actions
extension ConfigurationViewController {
    @IBAction private func portTapped(_ sender: PortButton) {
        switch sender.portType {
        case .motor:
            let motorConfig = AppContainer.shared.container.unwrappedResolve(MotorConfigViewController.self)
            motorConfig.portNumber = sender.portNumber
            present(viewController: motorConfig, onSide: .right)
        case .sensor:
            let sensorConfig = AppContainer.shared.container.unwrappedResolve(SensorConfigViewController.self)
            sensorConfig.portNumber = sender.portNumber
            present(viewController: sensorConfig, onSide: .left)
        }
    }

    @IBAction private func saveTapped(_ sender: Any) {
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
        photoModal.showImagePicker = { [weak self] in
            self?.showPicker()
        }

        photoModal.deleteHandler = { [weak self] in
            self?.robotImageView.image = Image.Configuration.defaultRobotImage
            self?.dismiss(animated: true)
        }

        presentModal(with: photoModal, animated: true)
    }

    private func showPicker() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.modalPresentationStyle = .currentContext
            imagePicker.allowsEditing = false
            presentedViewController?.present(imagePicker, animated: true)
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
        robotImageView.image = newImage

        dismiss(animated: true)
    }
}
