//
//  RRCollectionView.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 29..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class RRCollectionView: UICollectionView {
    // MARK: - Constants
    enum Constants {
        static let cellRatio: CGFloat = 213 / 224
        static let sineMultiplier: CGFloat = 0.25
        static let cellMaxSize: CGFloat = 0.74
        static let minimumLineSpacing: CGFloat = 40
        static let duration: Double = 0.5
    }

    // MARK: - Variables
    private var highestSine: CGFloat = 0
    private var indexPathOfCentermostCell = IndexPath(row: 0, section: 0)
    weak var rrDelegate: RRCollectionViewDelegate?
}

// MARK: - View lifecycle
extension RRCollectionView {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.decelerationRate = .fast
        delegate = self
    }
}

// MARK: - UICollectionViewDelegate
extension RRCollectionView: UICollectionViewDelegate {
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
        rrDelegate?.collectionView(collectionView, didSelectItemAt: indexPath)
    }
}

// MARK: - Design
extension RRCollectionView {
    // MARK: - Private funtions
    private func resizeVisibleCells() {
        highestSine = 0
        for cell in self.visibleCells {
            guard let customCell = cell as? ResizableCell else {
                continue
            }
            let distaneFromLeft = self.convert(CGPoint(x: customCell.frame.midX, y: customCell.frame.midY),
                                               to: self.superview).x
            let multiplier = min(max(distaneFromLeft / self.frame.width, 0), 1)
            let sine = Constants.sineMultiplier * sin(multiplier * CGFloat(Double.pi)) + Constants.cellMaxSize
            if sine > highestSine, let indexPath = self.indexPath(for: customCell) {
                indexPathOfCentermostCell = indexPath
                highestSine = sine
            }
            customCell.set(multiplier: sine)
            rrDelegate?.setButtons(rightHidden: indexPathOfCentermostCell.row == self.numberOfItems(inSection: 0) - 1,
                                   leftHidden: indexPathOfCentermostCell.row == 0)
        }
    }

    private func centerCell() {
        self.scrollToItem(at: indexPathOfCentermostCell, at: .centeredHorizontally, animated: true)
        designCells()
    }

    private func designCells() {
        self.visibleCells
            .compactMap { $0 as? ResizableCell }
            .forEach { cell in
                cell.isCentered = self.indexPath(for: cell)! == indexPathOfCentermostCell
        }
    }

    // MARK: - Public functions
    func rightStep() {
        guard indexPathOfCentermostCell.row != self.numberOfItems(inSection: 0) - 1 else { return }
        indexPathOfCentermostCell.row += 1

        centerCell()
    }

    func leftStep() {
        guard indexPathOfCentermostCell.row != 0 else { return }
        indexPathOfCentermostCell.row -= 1

        centerCell()
    }

    func refreshCollectionView() {
        self.performBatchUpdates(nil) { [weak self] completed in
            if completed {
                self?.resizeVisibleCells()
                self?.centerCell()
            }
        }
    }

    func setupInset() {
        let cellWidth: CGFloat = self.frame.size.height * Constants.cellRatio
        let cellheight: CGFloat = self.frame.size.height
        let cellSize = CGSize(width: cellWidth, height: cellheight)
        let padding = (self.frame.width / 2) - (cellWidth / 2)
        self.layoutIfNeeded()
        self.contentInset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = cellSize
        layout.minimumLineSpacing = Constants.minimumLineSpacing
        self.setCollectionViewLayout(layout, animated: true)
    }
}
