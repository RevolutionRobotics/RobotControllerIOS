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
        static let sineMultiplier: CGFloat = 0.25
        static let cellMaxSize: CGFloat = 0.74
        static let minimumLineSpacing: CGFloat = 40
        static let duration: Double = 0.5
    }

    // MARK: - Properties
    private var highestSine: CGFloat = 0
    private var indexPathOfCentermostCell = IndexPath(row: 0, section: 0)
    private var selectedIndexPath: IndexPath?
    weak var rrDelegate: RRCollectionViewDelegate?
    var cellRatio: CGFloat = 213 / 224
}

// MARK: - View lifecycle
extension RRCollectionView {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.bounces = false
        self.decelerationRate = .fast
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        selectedIndexPath = IndexPath(row: 0, section: 0)
        delegate = self
    }
}

// MARK: - UICollectionViewDelegate
extension RRCollectionView: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isUserInteractionEnabled = true
        centerCell()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            centerCell()
        }
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.isUserInteractionEnabled = true
        designCells()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        resizeVisibleCells()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !self.isDecelerating else { return }
        if let cell = self.cellForItem(at: indexPath) as? ResizableCell {
            if cell.isCentered {
                rrDelegate?.collectionView(collectionView, didSelectItemAt: indexPath)
            } else {
                self.isUserInteractionEnabled = false
                scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                selectedIndexPath = indexPath
                designCells()
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension RRCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let cellWidth: CGFloat = self.frame.size.height * cellRatio
        let padding = (self.frame.width / 2) - (cellWidth / 2)
        return UIEdgeInsets(top: 0, left: padding - UIView.actualNotchSize, bottom: 0, right: padding)
    }
}

// MARK: - Private funtions
extension RRCollectionView {
    private func resizeVisibleCells() {
        highestSine = 0
        for cell in self.visibleCells {
            guard let customCell = cell as? ResizableCell else {
                continue
            }
            let distanceFromLeft = self.convert(CGPoint(x: customCell.frame.midX, y: customCell.frame.midY),
                                                to: self.superview).x
            let multiplier = min(max(distanceFromLeft / self.frame.width, 0), 1)
            let sine = Constants.sineMultiplier * sin(multiplier * CGFloat(Double.pi)) + Constants.cellMaxSize
            if sine > highestSine, let indexPath = self.indexPath(for: customCell) {
                indexPathOfCentermostCell = indexPath
                highestSine = sine
            }
            customCell.set(multiplier: sine)
            rrDelegate?.setButtons(rightHidden: indexPathOfCentermostCell.row == self.numberOfItems(inSection: 0) - 1,
                                   leftHidden: indexPathOfCentermostCell.row == 0)
            guard let cellIP = customCell.indexPath, let selected = selectedIndexPath else {
                return
            }
            customCell.isCentered = cellIP == selected
        }
    }

    private func centerCell(cellDeleted: Bool = false) {
        guard self.numberOfSections > 0, self.numberOfItems(inSection: 0) > 0 else {
            return
        }
        self.scrollToItem(at: indexPathOfCentermostCell, at: .centeredHorizontally, animated: !cellDeleted)
        selectedIndexPath = indexPathOfCentermostCell
        designCells()
    }

    private func designCells() {
        self.visibleCells
            .compactMap { $0 as? ResizableCell }
            .forEach { cell in
                cell.isCentered = cell.indexPath == selectedIndexPath
        }
    }
}

// MARK: - Public functions
extension RRCollectionView {
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

    func selectCell(at index: Int, animated: Bool = false) {
        guard 0..<numberOfItems(inSection: 0) ~= index else { return }
        indexPathOfCentermostCell.row = index

        scrollToItem(at: indexPathOfCentermostCell, at: .centeredHorizontally, animated: animated)

        selectedIndexPath = indexPathOfCentermostCell
        designCells()
        refreshCollectionView(cellDeleted: false, callback: nil)
    }

    func refreshCollectionView(cellDeleted: Bool = false, callback: Callback? = nil) {
        self.performBatchUpdates({
            reloadInputViews()
        }, completion: { [weak self] completed in
            guard let `self` = self else { return }

            if completed {
                if let indexPath = self.selectedIndexPath {
                    self.indexPathOfCentermostCell = indexPath
                    self.resizeVisibleCells()
                    self.centerCell(cellDeleted: cellDeleted)
                } else {
                    self.resizeVisibleCells()
                    self.centerCell(cellDeleted: cellDeleted)
                }

                callback?()
            }
        })
    }

    func clearIndexPath() {
        selectedIndexPath = nil
        indexPathOfCentermostCell = IndexPath(row: 0, section: 0)
    }

    func setupLayout() {
        let cellWidth: CGFloat = self.frame.size.height * cellRatio
        let cellheight: CGFloat = self.frame.size.height
        let cellSize = CGSize(width: cellWidth, height: cellheight)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = cellSize
        layout.minimumLineSpacing = Constants.minimumLineSpacing
        self.setCollectionViewLayout(layout, animated: true)
    }
}
