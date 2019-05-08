//
//  YourRobotsViewController.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCollectionView()
        robots = realmService.getRobots()
    }

    private func setupCollectionView() {
        collectionView.rrDelegate = self
        collectionView.dataSource = self
        collectionView.register(YourRobotsCollectionViewCell.self)
        collectionView.setupInset()
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
        cell.deleteButtonHandler = { [weak self] in
            self?.presentDeleteModal(with: self?.robots[indexPath.item])
        }
        return cell
    }

    private func presentDeleteModal(with robot: UserRobot?) {
        let deleteView = DeleteRobotView.instatiate()
        setupDeleteHandlers(on: deleteView, with: robot)
        presentModal(with: deleteView)
    }

    private func setupDeleteHandlers(on view: DeleteRobotView, with robot: UserRobot?) {
        view.cancelButtonHandler = { [weak self] in
            self?.dismissViewController()
        }
        view.deleteButtonHandler = { [weak self] in
            guard let robot = robot else { return }
            self?.deleteRobot(robot)
            self?.dismissViewController()
        }
    }

    private func deleteRobot(_ robot: UserRobot) {
        realmService.deleteRobot(robot)
        robots = realmService.getRobots()
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
            cell.isCentered else { return }
    }

    func setButtons(rightHidden: Bool, leftHidden: Bool) {
        rightButton.isHidden = rightHidden
        leftButton.isHidden = leftHidden
    }
}
