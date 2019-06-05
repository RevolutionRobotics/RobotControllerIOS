//
//  ChallengeDetailViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 05..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ChallengeDetailViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var stepImage: UIImageView!
    @IBOutlet private weak var progressBar: BuildProgressBar!
    @IBOutlet private weak var partsCollectionView: UICollectionView!

    // MARK: - Properties
    private var challenge: Challenge?
    private var parts: [Part] = []
    var challengeFinished: Callback?
}

// MARK: - Setup
extension ChallengeDetailViewController {
    func setup(with challenge: Challenge) {
        self.challenge = challenge
    }

    private func setupProgressBar() {
        guard let challenge = challenge else { return }
        progressBar.numberOfSteps = challenge.challengeSteps.count - 1
        if challenge.challengeSteps.count - 2 >= 1 {
            progressBar.markers = Array(1...challenge.challengeSteps.count - 2)
        }
        progressBar.showMilestone = { [weak self] in
            self?.progressBar.milestoneFinished()
        }
        progressBar.valueDidChange = { [weak self] challengeStep in
            self?.setupContent(for: challengeStep)
        }
        progressBar.buildFinished = challengeFinished
    }

    private func setupContent(for step: Int) {
        guard let challenge = challenge else { return }
        let hasParts = !challenge.challengeSteps[step].parts.isEmpty
        partsCollectionView.isHidden = !hasParts
        descriptionLabel.isHidden = hasParts
        stepImage.isHidden = hasParts
        if !hasParts {
            descriptionLabel.text = challenge.challengeSteps[step].description
            stepImage.downloadImage(googleStorageURL: challenge.challengeSteps[step].image)
        } else {
            parts = challenge.challengeSteps[step].parts
            partsCollectionView.reloadData()
        }
    }
}

// MARK: - View lifecycle
extension ChallengeDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        partsCollectionView.delegate = self
        partsCollectionView.dataSource = self
        partsCollectionView.register(ChallengeDetailCollectionViewCell.self)
        guard let challenge = challenge else { return }
        navigationBar.setup(title: challenge.name, delegate: self)
        setupContent(for: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupProgressBar()
    }
}

// MARK: - UICollectionViewDelegate
extension ChallengeDetailViewController: UICollectionViewDelegate {
}

// MARK: - UICollectionViewDataSource
extension ChallengeDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return parts.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ChallengeDetailCollectionViewCell = partsCollectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.setup(wiht: parts[indexPath.row])
        return cell
    }
}
