//
//  YourRobotsViewController.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import os

final class YourRobotsViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var rightButton: UIButton!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var collectionView: RRCollectionView!
    @IBOutlet private weak var emptyStateImageView: UIImageView!
    @IBOutlet private weak var leftButtonLeadingConstraint: NSLayoutConstraint!

    // MARK: - Properties
    var realmService: RealmServiceInterface!
    var firebaseService: FirebaseServiceInterface!
    private var robots: [UserRobot] = [] {
        didSet {
            robots = [newRobot] + robots.sorted(by: { $0.lastModified > $1.lastModified })
            collectionView.reloadSections(IndexSet(integer: 0))
            if !robots.isEmpty {
                self.collectionView.refreshCollectionView()
            }
        }
    }
    private var selectedIndexPath: IndexPath?
    private let newCellNib = "YourRobotsCollectionViewCell"
    private let newCellReuseId = "robot_new"
    private let newRobot = UserRobot(
        id: "",
        remoteId: "",
        buildStatus: .new,
        actualBuildStep: 0,
        lastModified: Date(),
        configId: "",
        customName: RobotsKeys.YourRobots.newRobotName.translate(),
        customImage: nil,
        customDescription: ""
    )
}

// MARK: - View lifecycle
extension YourRobotsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: RobotsKeys.YourRobots.title.translate(), delegate: self)
        navigationBar.bluetoothButtonState = bluetoothService.connectedDevice != nil ? .connected : .notConnected
        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.setupLayout()
        if UIView.notchSize > .zero {
            leftButtonLeadingConstraint.constant = UIView.actualNotchSize
        }
        robots = realmService.getRobots()
        collectionView.selectCell(at: 1)

        guard let indexPath = selectedIndexPath else {
            return
        }
        collectionView.reloadItems(at: [indexPath])
        selectedIndexPath = nil
    }

    private func setupCollectionView() {
        let newRobotNib = UINib(nibName: newCellNib, bundle: nil)

        collectionView.rrDelegate = self
        collectionView.dataSource = self
        collectionView.register(YourRobotsCollectionViewCell.self)
        collectionView.register(newRobotNib, forCellWithReuseIdentifier: newCellReuseId)

        let longPressGesture = UILongPressGestureRecognizer(target: self,
                                                            action: #selector(handleCellLongPress(recognizer:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true

        collectionView.addGestureRecognizer(longPressGesture)
    }
}

// MARK: - Actions
extension YourRobotsViewController {
    @IBAction private func leftButtonTapped(_ sender: Any) {
        collectionView.leftStep()
    }

    @IBAction private func rightButtonTapped(_ sender: Any) {
        collectionView.rightStep()
    }

    @objc private func handleCellLongPress(recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: point) {
            presentRobotOptionsModal(with: indexPath)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension YourRobotsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        rightButton.isHidden = robots.isEmpty
        leftButton.isHidden = robots.isEmpty
        emptyStateImageView.isHidden = !robots.isEmpty
        return robots.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard robots[indexPath.item].buildStatus != BuildStatus.new.rawValue else {
            guard let newCell = collectionView.dequeueReusableCell(withReuseIdentifier: newCellReuseId, for: indexPath)
                as? YourRobotsCollectionViewCell else {
                fatalError("Failed to dequeue new robot cell")
            }

            newCell.indexPath = indexPath
            newCell.configure(with: newRobot)
            newCell.optionsButtonHandler = navigateToNewRobot
            return newCell
        }

        let cell: YourRobotsCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.indexPath = indexPath
        cell.configure(with: robots[indexPath.item])
        cell.optionsButtonHandler = { [weak self] in
            self?.presentRobotConfiguration(with: indexPath)
        }
        return cell
    }

    private func presentRobotConfiguration(with indexPath: IndexPath) {
        let robot = robots[indexPath.item]
        guard let buildStatus = BuildStatus(rawValue: robot.buildStatus) else {
            return
        }

        selectedIndexPath = indexPath

        switch buildStatus {
        case .initial, .inProgress:
            self.navigateToBuildYourRobotViewController(with: robot)
        case .invalidConfiguration, .completed:
            self.navigateToConfiguration(with: robot)
        default:
            fatalError("Unknown build status")
        }
    }

    private func presentRobotOptionsModal(with indexPath: IndexPath) {
        let robot = robots[indexPath.item]
        let modifyView = RobotOptionsModalView.instatiate()
        setupHandlers(on: modifyView, with: robot, for: indexPath)
        modifyView.robot = robot
        presentModal(with: modifyView)
    }

    private func presentDeleteModal(with indexPath: IndexPath) {
        let robot = robots[indexPath.item]
        dismissModalViewController()
        let deleteView = DeleteModalView.instatiate()
        deleteView.title = ModalKeys.DeleteRobot.description.translate()
        deleteView.deleteButtonHandler = { [weak self] in
            self?.deleteRobot(robot)
            self?.dismissModalViewController()
        }
        deleteView.cancelButtonHandler = { [weak self] in
            self?.dismissModalViewController()
        }
        presentModal(with: deleteView)
    }

    private func setupHandlers(on view: RobotOptionsModalView, with robot: UserRobot?, for indexPath: IndexPath) {
        view.deleteHandler = { [weak self] in
            self?.presentDeleteModal(with: indexPath)
        }
        view.editHandler = { [weak self] in
            self?.presentRobotConfiguration(with: indexPath)
        }
        view.duplicateHandler = { [weak self] in
            guard let robot = robot else { return }
            self?.duplicate(robot)
        }
    }

    private func duplicate(_ robot: UserRobot) {
        realmService.deepCopyRobot(robot)
        robots = realmService.getRobots()
        collectionView.reloadData()
        dismissModalViewController()
    }

    private func navigateToNewRobot() {
        let whoToBuildViewController = AppContainer.shared.container.unwrappedResolve(WhoToBuildViewController.self)
        navigationController?.pushViewController(whoToBuildViewController, animated: true)
    }

    private func deleteRobot(_ robot: UserRobot) {
        FileManager.default.delete(name: robot.id)
        realmService.deleteRobot(robot)
        robots = realmService.getRobots()
        collectionView.clearIndexPath()
        collectionView.performBatchUpdates(nil, completion: { [weak self] _ in
            self?.collectionView.refreshCollectionView(cellDeleted: true)
        })
    }
}

// MARK: - RRCollectionViewDelegate
extension YourRobotsViewController: RRCollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedIndex = indexPath.item
        guard let status = BuildStatus(rawValue: robots[selectedIndex].buildStatus) else { return }
        selectedIndexPath = indexPath
        switch status {
        case .new:
            navigateToNewRobot()
        case .completed:
            navigateToPlayControllerViewController(with: robots[selectedIndex])
        case .initial, .inProgress:
            navigateToBuildYourRobotViewController(with: robots[selectedIndex])
        case .invalidConfiguration:
            navigateToConfiguration(with: robots[selectedIndex])
        }
    }

    private func navigateToPlayControllerViewController(with robot: UserRobot) {
        guard let configuration = realmService.getConfiguration(id: robot.configId),
            let controller = realmService.getController(id: configuration.controller) else {
                return
        }

        let playController = AppContainer.shared.container.unwrappedResolve(PlayControllerViewController.self)
        playController.controllerDataModel = controller
        playController.robotName = robot.customName
        navigationController?.pushViewController(playController, animated: true)
    }

    private func navigateToBuildYourRobotViewController(with robot: UserRobot) {
        firebaseService.getRobots { [weak self] result in
            switch result {
            case .success(let robots):
                let buildViewController = AppContainer.shared.container.unwrappedResolve(BuildRobotViewController.self)
                buildViewController.remoteRobotDataModel = robots.first(where: { $0.id == robot.remoteId })
                buildViewController.storedRobotDataModel = robot
                self?.navigationController?.pushViewController(buildViewController, animated: true)
            case .failure:
                os_log("Error: Failed to fetch robots from Firebase!")
            }
        }
    }

    func setButtons(rightHidden: Bool, leftHidden: Bool) {
        rightButton.isHidden = rightHidden
        leftButton.isHidden = leftHidden
    }

    private func navigateToConfiguration(with robot: UserRobot?) {
        guard let robot = robot else { return }
        let configuration = AppContainer.shared.container.unwrappedResolve(RobotConfigurationViewController.self)
        configuration.selectedRobot = robot
        configuration.saveCallback = { [weak self] in
            self?.collectionView.reloadData()
        }
        configuration.duplicateCallback = { [weak self] in
            self?.duplicate(robot)
        }
        configuration.deleteCallback = { [weak self] in
            self?.deleteRobot(robot)
        }

        navigationController?.pushViewController(configuration, animated: true)
    }
}

// MARK: - Bluetooth connection
extension YourRobotsViewController {
    override func connected() {
        super.connected()
        navigationBar.bluetoothButtonState = .connected
    }

    override func disconnected() {
        super.disconnected()
        navigationBar.bluetoothButtonState = .notConnected
    }
}
