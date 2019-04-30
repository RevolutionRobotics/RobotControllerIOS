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

    // MARK: - Variables
    var firebaseService: FirebaseServiceInterface!
    private let discoverer: RoboticsDeviceDiscovererInterface = RoboticsDeviceDiscoverer()
    private let bluetoothDiscovery = AvailableRobotsView.instatiate()

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
        let buildRobotViewController = AppContainer.shared.container.unwrappedResolve(BuildRobotViewController.self)
        navigationController?.pushViewController(buildRobotViewController, animated: true)
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
        turnOnModal.laterHandler = { [weak self] in
            self?.dismissViewController()
        }
        turnOnModal.tipsHandler = { [weak self] in
            self?.dismissViewController()
        }
        turnOnModal.startHandler = { [weak self] in
            self?.dismissViewController()
            self?.showBluetoothDiscovery()
        }
        presentModal(with: turnOnModal)
    }

    private func showBluetoothDiscovery() {
        self.presentModal(with: bluetoothDiscovery)
        discoverer.discoverRobots(onScanResult: { [weak self] (devices) in
            self?.bluetoothDiscovery.discoveredDevices = devices
        }, onError: { error in
            print(error.localizedDescription)
        })
    }
}
