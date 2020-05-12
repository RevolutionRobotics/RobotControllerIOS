//
//  ChallengesViewController.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftyJSON

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
        let categoryItem = challengeCategories[indexPath.row]
        let missingImages = self.checkMissingImages(for: categoryItem)

        guard missingImages.isEmpty else {
            downloadImages(for: missingImages)
            return
        }

        let challengesViewController =
            AppContainer.shared.container.unwrappedResolve(ChallengesViewController.self)
        navigationController?.pushViewController(challengesViewController, animated: true)
        challengesViewController.setup(with: categoryItem)
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
        let categoryItem = challengeCategories[indexPath.row]

        let missingImages = self.checkMissingImages(for: categoryItem)
        guard missingImages.isEmpty else {
            cell.setupDownloadNeeded(with: categoryItem)
            return cell
        }

        let categoryId = categoryItem.id
        let category = realmService.getChallengeCategory(id: categoryId)

        let completedChallengeCount = realmService.getChallenges()
            .filter({ $0.categoryId == categoryId && $0.isCompleted })
            .count

        cell.index = indexPath.row
        cell.completedCount = completedChallengeCount
        cell.setup(with: categoryItem, userCategory: category)
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

    private func checkMissingImages(for category: ChallengeCategory) -> [Challenge] {
        guard let documentsDirectory = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first else {
            return []
        }

        let challengeRoot = documentsDirectory
            .appendingPathComponent(ZipType.challenges.rawValue, isDirectory: true)

        let challengeIds: [Challenge] = category.challenges.compactMap({ challenge in
            let challengeDir = challengeRoot.appendingPathComponent(challenge.id, isDirectory: true)
            do {
                guard try !challengeDir.checkResourceIsReachable() else {
                    return nil
                }
            } catch let error {
                error.report()
            }

            return challenge
        })

        return challengeIds
    }

    private func challengePromise(for id: String, url: String) -> Promise<Error?> {
        return Promise { seal in
            ApiFetchHandler().fetchZip(from: url, type: .challenges, id: id, callback: { error in
                guard let error = error else {
                    seal.fulfill(nil)
                    return
                }

                seal.reject(error)
            })
        }
    }

    private func downloadImages(for challenges: [Challenge]) {
        showDownloadingModal()
        let promises = challenges.map({ challengePromise(for: $0.id, url: $0.stepsArchive) })

        firstly {
            when(fulfilled: promises)
        }
        .done { [weak self] error in
            guard error.allSatisfy({ $0 == nil }) else {
                error.forEach { $0?.report() }
                _ = UIAlertController.errorAlert(type: .network)
                return
            }

            self?.dismissModalViewController()
            self?.challengesCollectionView.reloadData()
        }
        .catch { error in
            error.report()
            _ = UIAlertController.errorAlert(type: .network)
        }
    }

    private func showDownloadingModal() {
        let zipDownloadView = ZipDownloadView.instatiate()
        zipDownloadView.setup(
            with: CommonKeys.modalZipDownloadTitle.translate().uppercased(),
            message: ChallengesKeys.Main.modalZipDownloadMessage.translate().uppercased())
        presentModal(with: zipDownloadView, closeHidden: true)
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
