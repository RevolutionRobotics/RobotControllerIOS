//
//  ChallengesViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 03..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ChallengesViewController: BaseViewController {
    // MARK: - Constants
    private enum Constants {
        static let fontSize: CGFloat = 14.0
    }

    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var challengeDescription: UILabel!
    @IBOutlet private weak var challengesCollectionView: UICollectionView!

    // MARK: - Properties
    var realmService: RealmServiceInterface!
    private var challengeCategory: ChallengeCategory?
    private var challenges: [ChallengeDataModel]?
    private var oneSitting = true
    private var progress: Int = 0
    private var currentChallenge: Int = 0
}

// MARK: - View lifecycle
extension ChallengesViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let category = challengeCategory else { return }
        challenges = realmService.getChallenges()
            .filter({ $0.categoryId == challengeCategory?.id })
            .sorted(by: { $0.order < $1.order })

        navigationBar.bluetoothButtonState = bluetoothService.connectedDevice != nil ? .connected : .notConnected
        navigationBar.setup(title: category.name.text, delegate: self)
        challengeDescription.attributedText = NSAttributedString.attributedString(from: category.description.text,
                                                                                  fontSize: Constants.fontSize)
        challengesCollectionView.delegate = self
        challengesCollectionView.dataSource = self
        challengesCollectionView.register(ChallengesCollectionViewEvenCell.self)
        challengesCollectionView.register(ChallengesCollectionViewOddCell.self)
    }
}

// MARK: - Setup
extension ChallengesViewController {
    func setup(with challengeCategory: ChallengeCategory) {
        self.challengeCategory = challengeCategory

        if let category = realmService.getChallengeCategory(id: challengeCategory.id) {
            progress = category.progress
            oneSitting = false

            let legacyUnsavedChallenges = realmService.getChallenges()
                .filter({ !$0.isCompleted && $0.order < progress })

            if !legacyUnsavedChallenges.isEmpty {
                realmService.saveChallenges(legacyUnsavedChallenges)
            }

            logEvent(named: "continue_challenge", params: [
                "id": challengeCategory.id
            ])
        } else {
            let category = ChallengeCategoryDataModel(id: challengeCategory.id, progress: 0)
            realmService.saveChallengeCategory(category)

            let categotyChallenges = challengeCategory.challenges
                .map({ ChallengeDataModel(
                    id: $0.id,
                    categoryId: challengeCategory.id,
                    isCompleted: false,
                    order: $0.order)
                })
            realmService.saveChallenges(categotyChallenges)

            logEvent(named: "start_new_challenge", params: [
                "id": challengeCategory.id
            ])
        }
    }

    private func setupModal() {
        let modal = ChallengeFinishedModalView.instatiate()
        modal.homeCallback = { [weak self] in
            self?.updateProgress()
            self?.popToRootViewController(animated: true)
        }
        modal.listCallback = { [weak self] in
            self?.handleNavigateBack()
        }
        modal.nextCallback = { [weak self] in
            self?.handleNavigateBack(with: self?.showNextChallenge)
        }
        if currentChallenge + 1 == challengeCategory?.challenges.count {
            modal.isLastChallenge = true
        }
        presentModal(with: modal, closeHidden: true)
    }

    private func handleNavigateBack(with callback: Callback? = nil) {
        updateProgress()
        dismissModalViewController()
        challengesCollectionView.reloadData()
        presentedViewController?.dismiss(animated: false, completion: callback)
    }

    private func updateProgress() {
        guard let challenge = challenges?[currentChallenge] else { return }

        let updatedChallenge = ChallengeDataModel(
                id: challenge.id,
                categoryId: challenge.categoryId,
                isCompleted: true,
                order: challenge.order
            )

        realmService.saveChallenges([ updatedChallenge ])
    }

    private func showNextChallenge() {
        currentChallenge += 1
        guard
            let challengeDataModel = challenges?[currentChallenge],
            let challenge = getChallenge(for: challengeDataModel.id)
        else { return }

        let challengeDetailViewController =
            AppContainer.shared.container.unwrappedResolve(ChallengeDetailViewController.self)
        navigationController?.pushViewController(challengeDetailViewController, animated: true)
        challengeDetailViewController.setup(with: challenge, needsReload: true)
        challengeDetailViewController.challengeFinished = { [weak self] in
            self?.challengeFinished()
        }
    }

    private func challengeFinished() {
        setupModal()
        logEvent(named: "finish_challenge", params: [
            "id": challengeCategory?.id ?? "Unknown",
            "one_sitting": oneSitting
        ])
    }
}

// MARK: - UICollectionViewDelegate
extension ChallengesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let challengeDataModel = challenges?[indexPath.row],
            let challenge = getChallenge(for: challengeDataModel.id)
        else { return }
        currentChallenge = indexPath.row
        let challengeDetailViewController =
            AppContainer.shared.container.unwrappedResolve(ChallengeDetailViewController.self)
        navigationController?.pushViewController(challengeDetailViewController, animated: true)
        challengeDetailViewController.setup(with: challenge)
        challengeDetailViewController.challengeFinished = { [weak self] in
            self?.challengeFinished()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ChallengesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return challenges?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row % 2 != 0 {
            let cell: ChallengesCollectionViewEvenCell =
                challengesCollectionView.dequeueReusableCell(forIndexPath: indexPath)

            if
                let challengeDataModel = challenges?[indexPath.row],
                let challenge = getChallenge(for: challengeDataModel.id) {
                cell.progress = challengeDataModel.isCompleted ? .completed : .available
                cell.setup(with: challenge, index: indexPath.row + 1)
                cell.isFirstItem = indexPath.row == 0
            }
            return cell
        } else {
            let cell: ChallengesCollectionViewOddCell =
                challengesCollectionView.dequeueReusableCell(forIndexPath: indexPath)

            if
                let challengeDataModel = challenges?[indexPath.row],
                let challenge = getChallenge(for: challengeDataModel.id) {
                cell.progress = challengeDataModel.isCompleted ? .completed : .available
                cell.setup(with: challenge, index: indexPath.row + 1)
                cell.isFirstItem = indexPath.row == 0
            }
            return cell
        }
    }
}

// MARK: - Bluetooth connection
extension ChallengesViewController {
    override func connected() {
        super.connected()
        navigationBar.bluetoothButtonState = .connected
    }

    override func disconnected() {
        super.disconnected()
        navigationBar.bluetoothButtonState = .notConnected
    }
}

// MARK: - Private methods
extension ChallengesViewController {
    private func getChallenge(for id: String) -> Challenge? {
        return challengeCategory?.challenges.first(where: { $0.id == id })
    }
}
