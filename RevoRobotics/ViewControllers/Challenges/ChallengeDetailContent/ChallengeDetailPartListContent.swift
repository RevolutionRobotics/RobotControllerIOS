//
//  ChallengeDetailPartListContent.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 27..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ChallengeDetailPartListContent: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var partsCollectionView: UICollectionView!

    // MARK: - Properties
    private var parts: [Part] = []
}

// MARK: - ChallengeDetailContent
extension ChallengeDetailPartListContent: ChallengeDetailContentProtocol {
    func setup(with step: ChallengeStep) {
        parts = sortParts(in: step)
        partsCollectionView.reloadData()
    }
}

// MARK: - Private methods
extension ChallengeDetailPartListContent {
    private func sortParts(in step: ChallengeStep) -> [Part] {
        guard let parts = step.parts else {
            return []
        }

        let orderable: [FirebaseOrderable] = Array(parts.values)
        let ordered = orderable.sorted(by: { $0.order < $1.order }) as? [Part]

        return ordered ?? []
    }
}

// MARK: - View lifecycle
extension ChallengeDetailPartListContent {
    override func awakeFromNib() {
        super.awakeFromNib()

        partsCollectionView.register(ChallengeDetailCollectionViewCell.self)
        partsCollectionView.dataSource = self
    }
}

// MARK: - UICollectionViewDataSource
extension ChallengeDetailPartListContent: UICollectionViewDataSource {
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
