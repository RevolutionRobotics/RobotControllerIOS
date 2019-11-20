//
//  ChallengesViewController.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ChallengeCategoriesViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var challengesCollectionView: UICollectionView!

    // MARK: - Properties
    var firebaseService: FirebaseServiceInterface!
    var realmService: RealmServiceInterface!

    private var challengeCategories: [ChallengeCategory] = [] {
        didSet {
            challengesCollectionView.reloadData()
        }
    }
}

// MARK: - View lifecycle
extension ChallengeCategoriesViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
        fetchChallenges()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        challengesCollectionView.reloadData()
    }
}

// MARK: - Setup
extension ChallengeCategoriesViewController {
    private func setupNavigationBar() {
        navigationBar.bluetoothButtonState = bluetoothService.connectedDevice != nil ? .connected : .notConnected
        navigationBar.setup(title: ChallengesKeys.Main.title.translate(), delegate: self)
    }

    private func setupCollectionView() {
        challengesCollectionView.register(ChallengeCategoryCollectionViewCell.self)
        challengesCollectionView.delegate = self
        challengesCollectionView.dataSource = self
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ChallengeCategoriesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (challengesCollectionView.bounds.width - 36) / 3
        return CGSize(width: width, height: width * 98 / 162)
    }
}

// MARK: - UICollectionViewDelegate
extension ChallengeCategoriesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let challengesViewController =
            AppContainer.shared.container.unwrappedResolve(ChallengesViewController.self)
        navigationController?.pushViewController(challengesViewController, animated: true)
        challengesViewController.setup(with: challengeCategories[indexPath.row])
    }
}

// MARK: - UICollectionViewDataSource
extension ChallengeCategoriesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return challengeCategories.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = challengesCollectionView.dequeueReusableCell(forIndexPath: indexPath)
            as ChallengeCategoryCollectionViewCell
        let category = realmService.getChallengeCategory(id: challengeCategories[indexPath.row].id)
        cell.setup(with: challengeCategories[indexPath.row], userCategory: category)
        return cell
    }
}

// MARK: - Private fucntions
extension ChallengeCategoriesViewController {
    private func fetchChallenges() {
        firebaseService.getChallengeCategories { [weak self] result in
            switch result {
            case .success(let challengeCategories):
                self?.challengeCategories = challengeCategories.sorted(by: { $0.order < $1.order })
            case .failure:
                let alert = UIAlertController.errorAlert(type: .network)
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - Bluetooth connection
extension ChallengeCategoriesViewController {
    override func connected() {
        super.connected()
        navigationBar.bluetoothButtonState = .connected
    }

    override func disconnected() {
        super.disconnected()
        navigationBar.bluetoothButtonState = .notConnected
    }
}
