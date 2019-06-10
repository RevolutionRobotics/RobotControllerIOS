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

    // MARK: - Variables
    var realmService: RealmServiceInterface!
    var firebaseService: FirebaseServiceInterface!
    private var robots: [UserRobot] = [] {
        didSet {
            collectionView.reloadData()
            if !robots.isEmpty {
                self.collectionView.refreshCollectionView()
            }
        }
    }
}

// MARK: - View lifecycle
extension YourRobotsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: RobotsKeys.YourRobots.title.translate(), delegate: self)
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
        robots = realmService.getRobots()
    }

    private func setupCollectionView() {
        collectionView.rrDelegate = self
        collectionView.dataSource = self
        collectionView.register(YourRobotsCollectionViewCell.self)
    }
}

// MARK: - Event handlers
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
            self?.presentRobotOptionsModal(with: self?.robots[indexPath.item])
        }
        return cell
    }

    private func presentRobotOptionsModal(with robot: UserRobot?) {
        let modifyView = RobotOptionsView.instatiate()
        setupHandlers(on: modifyView, with: robot)
        modifyView.robot = robot
        presentModal(with: modifyView)
    }

    private func setupHandlers(on view: RobotOptionsView, with robot: UserRobot?) {
        view.deleteHandler = { [weak self] in
            guard let robot = robot else { return }
            self?.dismissViewController()
            let deleteView = DeleteView.instatiate()
            deleteView.title = ModalKeys.DeleteRobot.description.translate()
            deleteView.deleteButtonHandler = { [weak self] in
                self?.deleteRobot(robot)
                self?.dismissViewController()
            }
            deleteView.cancelButtonHandler = { [weak self] in
                self?.dismissViewController()
            }
            self?.presentModal(with: deleteView)
        }
        view.editHandler = { [weak self] in
            guard let robot = robot else { return }
            self?.dismissViewController()
            self?.navigateToConfiguration(with: robot)
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
        dismissViewController()
    }

    private func deleteRobot(_ robot: UserRobot) {
        FileManager.default.delete(name: robot.id)
        realmService.deleteRobot(robot)
        robots = realmService.getRobots()
        collectionView.clearIndexPath()
        collectionView.performBatchUpdates({
            collectionView.reloadSections(IndexSet(integer: 0))
        }, completion: nil)
    }
}

// MARK: - RRCollectionViewDelegate
extension YourRobotsViewController: RRCollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !collectionView.isDecelerating,
            let cell = collectionView.cellForItem(at: indexPath) as? ResizableCell,
            cell.isCentered,
            let status = BuildStatus(rawValue: robots[indexPath.item].buildStatus) else { return }
        switch status {
        case .completed:
            navigateToPlayControllerViewController(with: robots[indexPath.item])
        case .initial, .inProgress:
            if robots[indexPath.item].remoteId.isEmpty {
                navigateToConfiguration(with: robots[indexPath.item])
            } else {
                navigateToBuildYourRobotViewController(with: robots[indexPath.item])
            }
        }
    }

    private func navigateToPlayControllerViewController(with robot: UserRobot) {
        let playController = AppContainer.shared.container.unwrappedResolve(PlayControllerViewController.self)
        firebaseService.getController(
            for: robot.configId,
            completion: { [weak self] result in
                switch result {
                case .success(let controller):
                    playController.controllerType = controller.type
                    self?.navigationController?.pushViewController(playController, animated: true)
                case .failure(_):
                    os_log("Error: Failed to fetch controllers from Firebase!")
                }
        })
    }

    private func navigateToBuildYourRobotViewController(with robot: UserRobot) {
        firebaseService.getRobots { [weak self] result in
            switch result {
            case .success(let robots):
                let buildViewController = AppContainer.shared.container.unwrappedResolve(BuildRobotViewController.self)
                buildViewController.remoteRobotDataModel = robots.first(where: { $0.id == robot.remoteId })
                buildViewController.storedRobotDataModel = robot
                self?.navigationController?.pushViewController(buildViewController, animated: true)
            case .failure(_):
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
        navigationController?.pushViewController(configuration, animated: true)
    }
}
