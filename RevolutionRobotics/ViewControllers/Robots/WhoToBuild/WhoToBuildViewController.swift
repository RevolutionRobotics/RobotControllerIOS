//
//  WhoToBuildViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import RevolutionRoboticsBluetooth

final class WhoToBuildViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var collectionView: RRCollectionView!
    @IBOutlet private weak var rightButton: UIButton!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var buildYourOwnButton: RRButton!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!

    // MARK: - Variables
    var firebaseService: FirebaseServiceInterface!
    private let discoverer: RoboticsDeviceDiscovererInterface = RoboticsDeviceDiscoverer()
    private let connector: RoboticsDeviceConnectorInterface = RoboticsDeviceConnector()
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
        let configureScreen = AppContainer.shared.container.unwrappedResolve(ConfigurationViewController.self)
        navigationController?.pushViewController(configureScreen, animated: true)
    }
}

// MARK: - View lifecycle
extension WhoToBuildViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: RobotsKeys.WhoToBuild.title.translate(), delegate: self)
        buildYourOwnButton.setTitle(RobotsKeys.WhoToBuild.buildNewButtonTitle.translate(), for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCollectionView()
        fetchRobots()
    }

    private func setupCollectionView() {
        collectionView.rrDelegate = self
        collectionView.dataSource = self
        collectionView.register(WhoToBuildCollectionViewCell.self)
        collectionView.setupInset()
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
        showTurnOnTheBrain()
    }

    func setButtons(rightHidden: Bool, leftHidden: Bool) {
        rightButton.isHidden = rightHidden
        leftButton.isHidden = leftHidden
    }
}

// MARK: - Modals
extension WhoToBuildViewController {
    private func showTurnOnTheBrain() {
        let turnOnModal = TurnOnBrainView.instatiate()
        setupHandlers(on: turnOnModal)
        presentModal(with: turnOnModal)
    }

    private func setupHandlers(on modal: TurnOnBrainView) {
        setupLaterHandler(on: modal)
        setupTipsHandler(on: modal)
        setupStartDiscoveryHandler(on: modal)
    }

    private func setupLaterHandler(on modal: TurnOnBrainView) {
        modal.laterHandler = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
            let buildScreen = AppContainer.shared.container.unwrappedResolve(BuildRobotViewController.self)
            buildScreen.remoteRobotDataModel = self?.selectedRobot
            self?.navigationController?.pushViewController(buildScreen, animated: true)
        }
    }

    private func setupTipsHandler(on modal: TurnOnBrainView) {
        modal.tipsHandler = { [weak self] in
            self?.showTipsModal()
        }
    }

    private func showTipsModal() {
        self.dismiss(animated: true, completion: {
            let tips = TipsModalView.instatiate()
            tips.title = ModalKeys.Tips.title.translate()
            tips.subtitle = ModalKeys.Tips.subtitle.translate()
            tips.tips = "Lorem ipsum dolor sit amet, eu commodo numquam comprehensam vel. Quo cu alia placerat."
            tips.skipTitle = ModalKeys.Connection.failedConnectionSkipButton.translate()
            tips.communityTitle = ModalKeys.Tips.community.translate()
            tips.tryAgainTitle = ModalKeys.Tips.tryAgin.translate()
            tips.skipCallback = { [weak self] in
                self?.dismiss(animated: true, completion: {
                    let buildScreen = AppContainer.shared.container.unwrappedResolve(BuildRobotViewController.self)
                    self?.navigationController?.pushViewController(buildScreen, animated: true)
                })
            }
            tips.tryAgainCallback = { [weak self] in
                self?.dismiss(animated: true, completion: {
                    self?.showTurnOnTheBrain()
                })
            }
            self.presentModal(with: tips)
        })
    }

    private func setupStartDiscoveryHandler(on modal: TurnOnBrainView) {
        modal.startHandler = { [weak self] in
            self?.dismiss(animated: true, completion: {
                self?.showBluetoothDiscovery()
            })
        }
    }

    private func showBluetoothDiscovery() {
        let bluetoothDiscovery = AvailableRobotsView.instatiate()
        bluetoothDiscovery.selectionHandler = onDeviceSelected
        presentModal(with: bluetoothDiscovery)

        discoverer.discoverRobots(
            onScanResult: { devices in
                bluetoothDiscovery.discoveredDevices = devices
            },
            onError: { error in
                print(error.localizedDescription)
        })
    }
}

// MARK: - Connection
extension WhoToBuildViewController {
    private func onDeviceSelected(_ device: Device) {
        connector.connect(
            to: device,
            onConnected: onSelectedDeviceConnected,
            onDisconnected: onSelectedDeviceDisconnected,
            onError: onSelectedDeviceConnectionError
        )
    }

    private func onSelectedDeviceConnected() {
        dismissViewController()
        let connectionModal = ConnectionModal.instatiate()
        presentModal(with: connectionModal.successful)

        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.dismissAndNavigateToBuildRobot()
        }
    }

    private func onSelectedDeviceDisconnected() {
        print("Disconnected")
    }

    private func onSelectedDeviceConnectionError(_ error: Error) {
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
        showBluetoothDiscovery()
    }

    private func dismissAndNavigateToBuildRobot() {
        dismissViewController()
        let buildRobotViewController = AppContainer.shared.container.unwrappedResolve(BuildRobotViewController.self)
        buildRobotViewController.remoteRobotDataModel = selectedRobot
        navigationController?.pushViewController(buildRobotViewController, animated: true)
    }
}
