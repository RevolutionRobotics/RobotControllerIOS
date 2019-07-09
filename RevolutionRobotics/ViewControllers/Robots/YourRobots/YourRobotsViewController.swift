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
    @IBOutlet private weak var buildNewButton: SideButton!
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
            robots = robots.sorted(by: { $0.lastModified > $1.lastModified })
            collectionView.reloadSections(IndexSet(integer: 0))
            if !robots.isEmpty {
                self.collectionView.refreshCollectionView()
            }
        }
    }
    private var selectedIndexPath: IndexPath?
}

// MARK: - View lifecycle
extension YourRobotsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: RobotsKeys.YourRobots.title.translate(), delegate: self)
        navigationBar.bluetoothButtonState = bluetoothService.connectedDevice != nil ? .connected : .notConnected
        buildNewButton.title = RobotsKeys.YourRobots.buildNewButtonTitle.translate()
        buildNewButton.selectionHandler = { [weak self] in
            let whoToBuildViewController = AppContainer.shared.container.unwrappedResolve(WhoToBuildViewController.self)
            self?.navigationController?.pushViewController(whoToBuildViewController, animated: true)
        }
        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.setupLayout()
        if UIView.notchSize > CGFloat.zero {
            leftButtonLeadingConstraint.constant = UIView.actualNotchSize
        }
        robots = realmService.getRobots()
        guard let indexPath = selectedIndexPath else {
            return
        }
        collectionView.reloadItems(at: [indexPath])
        selectedIndexPath = nil
    }

    private func setupCollectionView() {
        collectionView.rrDelegate = self
        collectionView.dataSource = self
        collectionView.register(YourRobotsCollectionViewCell.self)
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
        let cell: YourRobotsCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.indexPath = indexPath
        cell.configure(with: robots[indexPath.item])
        cell.optionsButtonHandler = { [weak self] in
            self?.presentRobotOptionsModal(with: indexPath)
        }
        return cell
    }

    private func presentRobotOptionsModal(with indexPath: IndexPath) {
        let robot = robots[indexPath.item]
        let modifyView = RobotOptionsModalView.instatiate()
        setupHandlers(on: modifyView, with: robot, for: indexPath)
        modifyView.robot = robot
        presentModal(with: modifyView)
    }

    private func setupHandlers(on view: RobotOptionsModalView, with robot: UserRobot?, for indexPath: IndexPath) {
        view.deleteHandler = { [weak self] in
            guard let robot = robot else { return }
            self?.dismissModalViewController()
            let deleteView = DeleteModalView.instatiate()
            deleteView.title = ModalKeys.DeleteRobot.description.translate()
            deleteView.deleteButtonHandler = { [weak self] in
                self?.deleteRobot(robot)
                self?.dismissModalViewController()
            }
            deleteView.cancelButtonHandler = { [weak self] in
                self?.dismissModalViewController()
            }
            self?.presentModal(with: deleteView)
        }
        view.editHandler = { [weak self] in
            guard let robot = robot, let robotStatus = BuildStatus(rawValue: robot.buildStatus) else { return }
            self?.selectedIndexPath = indexPath
            self?.dismissModalViewController()

            if !robot.remoteId.isEmpty && robotStatus != .completed {
                self?.navigateToBuildYourRobotViewController(with: robot)
            } else {
                self?.navigateToConfiguration(with: robot)
            }
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
        guard let status = BuildStatus(rawValue: robots[indexPath.item].buildStatus) else { return }
        selectedIndexPath = indexPath
        switch status {
        case .completed:
            navigateToPlayControllerViewController(with: robots[indexPath.item])
        case .initial, .inProgress:
            let hasNoControllers =
                realmService.getControllers().filter({ $0.configurationId == robots[indexPath.item].configId }).isEmpty
            let isRobotFromFirebase = robots[indexPath.item].remoteId.isEmpty
            if isRobotFromFirebase || (!isRobotFromFirebase && hasNoControllers) {
                navigateToConfiguration(with: robots[indexPath.item])
            } else {
                navigateToBuildYourRobotViewController(with: robots[indexPath.item])
            }
        }
    }

    private func navigateToPlayControllerViewController(with robot: UserRobot) {
        guard let configuration = realmService.getConfiguration(id: robot.configId),
            let controller = realmService.getController(id: configuration.controller) else {
                return
        }

        let playController = AppContainer.shared.container.unwrappedResolve(PlayControllerViewController.self)
        playController.controllerDataModel = controller
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
            self?.navigationController?.popViewController(animated: true)
            self?.collectionView.reloadData()
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
