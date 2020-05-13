//
//  WhoToBuildViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import struct RevolutionRoboticsBluetooth.Device
import os

final class WhoToBuildViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var collectionView: RRCollectionView!
    @IBOutlet private weak var rightButton: UIButton!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var leftButtonLeadingConstraint: NSLayoutConstraint!

    // MARK: - Properties
    var firebaseService: FirebaseServiceInterface!
    var realmService: RealmServiceInterface!

    private let newCellNib = "WhoToBuildCollectionViewCell"
    private let newCellReuseId = "build_own"

    private var selectedRobot: Robot?
    private var robots: [Robot?] = [] {
        didSet {
            robots = [nil] + robots.compactMap({ $0 })
            collectionView.reloadData()
            if !robots.isEmpty {
                self.collectionView.refreshCollectionView(callback: { [weak self] in
                    self?.collectionView.selectCell(at: 1)
                })
            }
        }
    }

    private var savedImages: [String: Bool] {
        return robots
            .compactMap({ $0 })
            .reduce(into: [String: Bool]()) { $0[$1.id] = checkImages(for: $1) }
    }
}

// MARK: - Private methods
extension WhoToBuildViewController {
    private func fetchRobots() {
        guard firebaseService.getConnectionState() == .online else {
            robots = []
            hideLoading()
            return
        }

        firebaseService.getRobots { [weak self] result in
            guard let `self` = self else { return }

            switch result {
            case .success(let robots):
                self.robots = robots
                self.hideLoading()
            case .failure:
                os_log("Error: Failed to fetch robots from Firebase!")
            }
        }
    }

    private func hideLoading() {
        loadingIndicator.stopAnimating()
        collectionView.isHidden = false
    }

    private func checkImages(for robot: Robot) -> Bool {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            return false
        }

        let target = documentsDirectory
            .appendingPathComponent(ZipType.robots.rawValue, isDirectory: true)
            .appendingPathComponent(robot.id, isDirectory: true)

        do {
            return try target.checkResourceIsReachable()
        } catch {
            return false
        }
    }

    private func deleteRobot(at index: Int) {
        guard
            let id = robots[index]?.id,
            let documentsDirectory = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first
        else { return }

        let target = documentsDirectory
            .appendingPathComponent(ZipType.robots.rawValue, isDirectory: true)
            .appendingPathComponent(id, isDirectory: true)

        do {
            try? FileManager.default.removeItem(at: target)
            collectionView.reloadData()
            collectionView.refreshCollectionView(callback: { [weak self] in
                self?.collectionView.selectCell(at: index)
            })
        }
    }
}

// MARK: - Actions
extension WhoToBuildViewController {
    @IBAction private func rightButtonTapped(_ sender: Any) {
        collectionView.rightStep()
    }

    @IBAction private func leftButtonTapped(_ sender: Any) {
        collectionView.leftStep()
    }

    @IBAction private func builYourOwnButtonTapped(_ sender: Any) {
        let configureScreen = AppContainer.shared.container
            .unwrappedResolve(RobotConfigurationViewController.self)
        navigationController?.pushViewController(configureScreen, animated: true)
    }
}

// MARK: - View lifecycle
extension WhoToBuildViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: RobotsKeys.WhoToBuild.title.translate(), delegate: self)
        navigationBar.bluetoothButtonState = bluetoothService.connectedDevice != nil ? .connected : .notConnected
        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.setupLayout()
        if UIView.notchSize > .zero {
            leftButtonLeadingConstraint.constant = UIView.actualNotchSize
        }
        fetchRobots()
    }

    private func setupCollectionView() {
        let whoToBuildNib = UINib(nibName: newCellNib, bundle: nil)

        collectionView.rrDelegate = self
        collectionView.dataSource = self
        collectionView.register(WhoToBuildCollectionViewCell.self)
        collectionView.register(whoToBuildNib, forCellWithReuseIdentifier: newCellReuseId)
    }

    private func downloadImages(for robot: Robot?) {
        guard let robot = robot else { return }

        showDownloadingModal()
        ApiFetchHandler()
            .fetchZip(from: robot.buildStepsArchive, type: .robots, id: robot.id, callback: { [weak self] error in
                guard let `self` = self else { return }
                self.dismissModalViewController()
                guard error == nil else {
                    error?.report()
                    let alert = UIAlertController.errorAlert(type: .network)
                    self.present(alert, animated: true, completion: nil)
                    return
                }

                self.collectionView.reloadData()

                if let index = self.robots.firstIndex(where: { $0?.id == robot.id }) {
                    self.collectionView.refreshCollectionView(callback: { [weak self] in
                        self?.collectionView.selectCell(at: index)
                    })
                }
            })
    }

    private func showDownloadingModal() {
        let zipDownloadView = ZipDownloadView.instatiate()
        zipDownloadView.setup(
            with: CommonKeys.modalZipDownloadTitle.translate().uppercased(),
            message: RobotsKeys.WhoToBuild.modalZipDownloadMessage.translate().uppercased())
        presentModal(with: zipDownloadView, closeHidden: true)
    }

    private func showDeleteError(for name: String) {
        let alertController = UIAlertController(title: RobotsKeys.WhoToBuild.deleteErrorTitle.translate(),
                                                message: RobotsKeys.WhoToBuild.deleteErrorText.translate(args: name),
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: CommonKeys.errorOk.translate(), style: .default, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension WhoToBuildViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return robots.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: WhoToBuildCollectionViewCell
        if let robot = robots[indexPath.row] {
            let hasImages = savedImages[robot.id] ?? false
            cell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.configure(with: robot, savedImages: hasImages)
            cell.onDeleteTapped = { [weak self] in
                guard let `self` = self else { return }
                let inProgress = self.realmService.getRobots()
                    .filter({ $0.remoteId == robot.id && $0.buildStatus != BuildStatus.completed.rawValue })

                guard inProgress.isEmpty else {
                    self.showDeleteError(for: robot.name.text)
                    return
                }

                self.deleteRobot(at: indexPath.row)
            }
        } else {
            guard let newCell = collectionView.dequeueReusableCell(withReuseIdentifier: newCellReuseId, for: indexPath)
                as? WhoToBuildCollectionViewCell else {
                fatalError("Failed to dequeue cell for robot build")
            }

            cell = newCell
            cell.configureNew()
        }

        cell.indexPath = indexPath
        return cell
    }
}

// MARk: - RRCollectionViewDelegate
extension WhoToBuildViewController: RRCollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        selectedRobot = robots[index]

        guard index == 0 else {
            navigateToBuildScreen()
            return
        }

        let configureScreen = AppContainer.shared.container.unwrappedResolve(RobotConfigurationViewController.self)
        navigationController?.pushViewController(configureScreen, animated: true)
    }

    func setButtons(rightHidden: Bool, leftHidden: Bool) {
        rightButton.isHidden = rightHidden
        leftButton.isHidden = leftHidden
    }
}

// MARK: - Navigation
extension WhoToBuildViewController {
    private func navigateToBuildScreen() {
        guard let robotId = selectedRobot?.id else { return }
        guard savedImages[robotId] ?? false else {
            downloadImages(for: selectedRobot)
            return
        }

        let buildScreen = AppContainer.shared.container.unwrappedResolve(BuildRobotViewController.self)
        buildScreen.remoteRobotDataModel = selectedRobot
        navigationController?.pushViewController(buildScreen, animated: true)
    }
}

// MARK: - Bluetooth connection
extension WhoToBuildViewController {
    override func connected() {
        super.connected()
        navigationBar.bluetoothButtonState = .connected
    }

    override func disconnected() {
        super.disconnected()
        navigationBar.bluetoothButtonState = .notConnected
    }
}
