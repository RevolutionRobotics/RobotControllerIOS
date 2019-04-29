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
    // MARK: - Constants
    enum Constants {
        static let cellRatio: CGFloat = 213 / 224
        static let sineMultiplier: CGFloat = 0.25
        static let cellMaxSize: CGFloat = 0.74
        static let minimumLineSpacing: CGFloat = 40
        static let duration: Double = 0.5
    }

    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var rightButton: UIButton!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var buildYourOwnButton: RRButton!

    // MARK: - Variables
    var firebaseService: FirebaseServiceInterface!
    private var highestSine: CGFloat = 0
    private let discoverer: RoboticsDeviceDiscovererInterface = RoboticsDeviceDiscoverer()
    private let blutoothDiscovery = AvailableRobotsView.instatiate()
    private var indexPathOfCentermostCell = IndexPath(row: 0, section: 0) {
        didSet {
            leftButton.isHidden = indexPathOfCentermostCell.row == 0
            rightButton.isHidden = indexPathOfCentermostCell.row == robots.count - 1
        }
    }

    private var robots: [Robot] = [] {
        didSet {
            collectionView.reloadData()
            collectionView.performBatchUpdates(nil) { [weak self] completed in
                if completed { self?.refreshCollectionView() }
            }
        }
    }
}

// MARK: - Private functions
extension WhoToBuildViewController {
    private func resizeVisibleCells() {
        highestSine = 0
        for cell in collectionView.visibleCells {
            guard let customCell = cell as? WhoToBuildCollectionViewCell else {
                continue
            }
            let distaneFromLeft = collectionView.convert(CGPoint(x: customCell.frame.midX, y: customCell.frame.midY),
                                                         to: collectionView.superview).x
            let multiplier = min(max(distaneFromLeft / collectionView.frame.width, 0), 1)
            let sine = Constants.sineMultiplier * sin(multiplier * CGFloat(Double.pi)) + Constants.cellMaxSize
            if sine > highestSine, let indexPath = collectionView.indexPath(for: customCell) {
                indexPathOfCentermostCell = indexPath
                highestSine = sine
            }
            customCell.setSize(multiplier: sine)
            designCells()
        }
    }

    private func centerCell() {
        collectionView.scrollToItem(at: indexPathOfCentermostCell, at: .centeredHorizontally, animated: true)
        designCells()
    }

    private func designCells() {
        collectionView.visibleCells
            .compactMap { $0 as? WhoToBuildCollectionViewCell }
            .forEach { cell in
                cell.isCentered = collectionView.indexPath(for: cell)! == indexPathOfCentermostCell
            }
    }

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

    private func refreshCollectionView() {
        centerCell()
        resizeVisibleCells()
    }
}

// MARK: - Event handlers
extension WhoToBuildViewController {
    @IBAction private func rightButtonTapped(_ sender: Any) {
        guard indexPathOfCentermostCell.row != collectionView.numberOfItems(inSection: 0) - 1 else { return }
        indexPathOfCentermostCell.row += 1

        centerCell()
    }

    @IBAction private func leftButtonTapped(_ sender: Any) {
        guard indexPathOfCentermostCell.row != 0 else { return }
        indexPathOfCentermostCell.row -= 1

        centerCell()
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

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.decelerationRate = .fast
        collectionView.register(WhoToBuildCollectionViewCell.self)
        navigationBar.setup(title: RobotsKeys.WhoToBuild.title.translate(), delegate: self)
        buildYourOwnButton.setTitle(RobotsKeys.WhoToBuild.buildNewButtonTitle.translate(), for: .normal)

        fetchRobots()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let cellWidth: CGFloat = collectionView.frame.size.height * Constants.cellRatio
        let cellheight: CGFloat = collectionView.frame.size.height
        let cellSize = CGSize(width: cellWidth, height: cellheight)
        let padding = (collectionView.frame.width / 2) - (cellWidth / 2)
        collectionView.layoutIfNeeded()
        collectionView.contentInset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = cellSize
        layout.minimumLineSpacing = Constants.minimumLineSpacing
        collectionView.setCollectionViewLayout(layout, animated: true)
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
        cell.configure(with: robots[indexPath.row])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension WhoToBuildViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        centerCell()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            centerCell()
        }
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        designCells()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        resizeVisibleCells()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !collectionView.isDecelerating,
            let cell = collectionView.cellForItem(at: indexPath) as? WhoToBuildCollectionViewCell,
            cell.isCentered else { return }

        showTurnOnTheBrain()
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
        self.presentModal(with: blutoothDiscovery)
        discoverer.discoverRobots(onScanResult: { [weak self] (devices) in
            self?.blutoothDiscovery.discoveredDevices = devices
        }, onError: { error in
            print(error.localizedDescription)
        })
    }
}
