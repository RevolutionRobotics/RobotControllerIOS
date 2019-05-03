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
    private let bluetoothDiscovery = AvailableRobotsView.instatiate()
    private var selectedRobot: Robot?

    private var robots: [Robot] = [] {
        didSet {
            collectionView.reloadData()
            self.collectionView.refreshCollectionView()
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

        collectionView.rrDelegate = self
        collectionView.dataSource = self
        collectionView.register(WhoToBuildCollectionViewCell.self)
        navigationBar.setup(title: RobotsKeys.WhoToBuild.title.translate(), delegate: self)
        buildYourOwnButton.setTitle(RobotsKeys.WhoToBuild.buildNewButtonTitle.translate(), for: .normal)

        fetchRobots()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

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
            buildScreen.selectedRobot = self?.selectedRobot
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
            let tips = FailedConnectionTipsModal.instatiate()
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
        self.presentModal(with: bluetoothDiscovery)
        discoverer.discoverRobots(
            onScanResult: { [weak self] (devices) in
                self?.bluetoothDiscovery.discoveredDevices = devices
            },
            onError: { error in
                print(error.localizedDescription)
        })
    }
}
