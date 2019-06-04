//
//  ChallengesViewController.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ChallengesViewController: BaseViewController {
    // MARK: - Outlet
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

// MARK: - Private fucntions
extension ChallengesViewController {
    private func fetchChallenges() {
        firebaseService.getChallengeCategory { [weak self] result in
            switch result {
            case .success(let challengeCategories):
                self?.challengeCategories = challengeCategories
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: - View lifecycle
extension ChallengesViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: ChallengesKeys.Main.title.translate(), delegate: self)
        challengesCollectionView.register(ChallengeCategoryCollectionViewCell.self)
        challengesCollectionView.delegate = self
        challengesCollectionView.dataSource = self
        fetchChallenges()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ChallengesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (challengesCollectionView.bounds.width - 36) / 3
        return CGSize(width: width, height: width * 98 / 162)
    }
}

// MARK: - UICollectionViewDelegate
extension ChallengesViewController: UICollectionViewDelegate {
}

// MARK: - UICollectionViewDataSource
extension ChallengesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return challengeCategories.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ChallengeCategoryCollectionViewCell =
            challengesCollectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.setup(with: challengeCategories[indexPath.row])
        return cell
    }
}
