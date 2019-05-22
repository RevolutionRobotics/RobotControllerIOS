//
//  WhoToBuildViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import struct RevolutionRoboticsBluetooth.Device

final class WhoToBuildViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var collectionView: RRCollectionView!
    @IBOutlet private weak var rightButton: UIButton!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var buildYourOwnButton: RRButton!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!

    // MARK: - Properties
    var firebaseService: FirebaseServiceInterface!
    var realmService: RealmServiceInterface!
    var bluetoothService: BluetoothServiceInterface!

    private var selectedRobot: Robot?
    private var robots: [Robot] = [] {
        didSet {
            collectionView.reloadData()
            if !robots.isEmpty {
                self.collectionView.refreshCollectionView()
            }
        }
    }
}

// MARK: - Private functions
extension WhoToBuildViewController {
    private func fetchRobots() {
        firebaseService.getRobots { [weak self] result in
            switch result {
            case .success(let robots):
                self?.robots = robots
                self?.loadingIndicator.stopAnimating()
                self?.collectionView.isHidden = false
            case .failure(let error):
                print(error)
            }
        }
    }

    private func fetchConfigurations() {
        firebaseService.getConfigurations { [weak self] result in
            switch result {
            case .success(let configurations):
                let localConfigurations = configurations.map({ ConfigurationDataModel(remoteConfiguration: $0) })
                self?.realmService.saveConfigurations(localConfigurations)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - Event handlers
extension WhoToBuildViewController {
    @IBAction private func rightButtonTapped(_ sender: Any) {
        collectionView.rightStep()
    }

    @IBAction private func leftButtonTapped(_ sender: Any) {
        collectionView.leftStep()
    }

    @IBAction private func builYourOwnButtonTapped(_ sender: Any) {
        let configureScreen = AppContainer.shared.container.unwrappedResolve(RobotConfigurationViewController.self)
        navigationController?.pushViewController(configureScreen, animated: true)
    }
}

// MARK: - View lifecycle
extension WhoToBuildViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: RobotsKeys.WhoToBuild.title.translate(), delegate: self)
        buildYourOwnButton.setTitle(RobotsKeys.WhoToBuild.buildNewButtonTitle.translate(), for: .normal)
        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.setupInset()
        fetchRobots()
        fetchConfigurations()
        subscribeForConnectionChange()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromConnectionChange()
    }

    private func setupCollectionView() {
        collectionView.rrDelegate = self
        collectionView.dataSource = self
        collectionView.register(WhoToBuildCollectionViewCell.self)
    }
}

// MARK: - UICollectionViewDataSource
extension WhoToBuildViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return robots.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: WhoToBuildCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.indexPath = indexPath
        cell.configure(with: robots[indexPath.row])
        return cell
    }
}

// MARk: - RRCollectionViewDelegate
extension WhoToBuildViewController: RRCollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !collectionView.isDecelerating,
            let cell = collectionView.cellForItem(at: indexPath) as? WhoToBuildCollectionViewCell,
            cell.isCentered else { return }
        selectedRobot = robots[indexPath.row]
        if !bluetoothService.hasConnectedDevice {
            showTurnOnTheBrain()
        } else {
            navigateToBuildScreen()
        }
    }

    func setButtons(rightHidden: Bool, leftHidden: Bool) {
        rightButton.isHidden = rightHidden
        leftButton.isHidden = leftHidden
    }
}

// MARK: - Modal
extension WhoToBuildViewController {
    private func showTurnOnTheBrain() {
        let modalPresenter = BluetoothConnectionModalPresenter()
        modalPresenter.present(
            on: self,
            startDiscoveryHandler: { [weak self] in
                self?.bluetoothService.startDiscovery(onScanResult: { result in
                    switch result {
                    case .success(let devices):
                        modalPresenter.discoveredDevices = devices
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                })
            },
            deviceSelectionHandler: { [weak self] device in
                self?.bluetoothService.connect(to: device)
            },
            nextStep: { [weak self] in
                self?.navigateToBuildScreen()
        })
    }

    private func navigateToBuildScreen() {
        let buildScreen = AppContainer.shared.container.unwrappedResolve(BuildRobotViewController.self)
        buildScreen.remoteRobotDataModel = selectedRobot
        navigationController?.pushViewController(buildScreen, animated: true)
    }
}

// MARK: - Connection
extension WhoToBuildViewController {
    override func connected() {
        dismissViewController()
        let connectionModal = ConnectionModal.instatiate()
        presentModal(with: connectionModal.successful)

        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.dismissAndNavigateToBuildRobot()
        }
    }

    override func disconnected() {
        print("Device disconnected")
    }

    override func connectionError() {
        let connectionModal = ConnectionModal.instatiate()
        dismissViewController()
        presentModal(with: connectionModal.failed)

        connectionModal.skipConnectionButtonTapped = dismissAndNavigateToBuildRobot
        connectionModal.tryAgainButtonTapped = dismissAndTryAgain

        connectionModal.tipsButtonTapped = { [weak self] in
            self?.dismissViewController()
            let failedConnectionTipsModal = TipsModalView.instatiate()
            self?.presentModal(with: failedConnectionTipsModal)
            failedConnectionTipsModal.skipCallback = self?.dismissAndNavigateToBuildRobot
            failedConnectionTipsModal.tryAgainCallback = self?.dismissAndTryAgain
            failedConnectionTipsModal.communityCallback = {
                // TODO: Use BaseViewController showCommunityViewControoler when it's implemented
            }
        }
    }

    private func dismissAndTryAgain() {
        dismissViewController()
        showTurnOnTheBrain()
    }

    private func dismissAndNavigateToBuildRobot() {
        dismissViewController()
        let buildRobotViewController = AppContainer.shared.container.unwrappedResolve(BuildRobotViewController.self)
        buildRobotViewController.remoteRobotDataModel = selectedRobot
        navigationController?.pushViewController(buildRobotViewController, animated: true)
    }
}
