//
//  ChallengesViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 03..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ChallengesViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var challengeDescription: UILabel!
    @IBOutlet private weak var challengesCollectionView: UICollectionView!

    // MARK: - Properties
    var realmService: RealmServiceInterface!
    private var challengeCategory: ChallengeCategory?
    private var progress: Int = 0
}

// MARK: - View lifecycle
extension ChallengesViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let category = challengeCategory else { return }
        navigationBar.setup(title: category.name, delegate: self)
        challengesCollectionView.delegate = self
        challengesCollectionView.dataSource = self
        challengesCollectionView.register(ChallengesCollectionViewCell.self)
    }
}

// MARK: - Setup
extension ChallengesViewController {
    func setup(with challengeCategory: ChallengeCategory) {
        self.challengeCategory = challengeCategory
        if let category = realmService.getChallengeCategory(id: challengeCategory.id) {
            progress = category.progress
        } else {
            let category = ChallengeCategoryDataModel(id: challengeCategory.id, progress: 0)
            realmService.saveChallengeCategory(category)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension ChallengesViewController: UICollectionViewDelegate {
}

extension ChallengesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let category = challengeCategory else { return 0 }
        return category.challenges.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = challengesCollectionView.dequeueReusableCell(forIndexPath: indexPath) as ChallengesCollectionViewCell
        if let category = challengeCategory {
            if progress == indexPath.row {
                cell.progress = .available
            }
            if progress > indexPath.row {
                cell.progress = .completed
            }
            cell.setup(with: category.challenges[indexPath.row],
                       isEven: indexPath.row % 2 != 0,
                       index: indexPath.row + 1)
            cell.isFirstItem = indexPath.row == 0
        }
        return cell
    }
}
