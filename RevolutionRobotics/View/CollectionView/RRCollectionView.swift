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

    // MARK: - Variables
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

// MARK: - UICollectionViewDelegateFlowLayout
extension RRCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let cellWidth: CGFloat = self.frame.size.height * cellRatio
        let padding = (self.frame.width / 2) - (cellWidth / 2)
        let notchSize = UIApplication.shared.keyWindow?.safeAreaInsets.left
        return UIEdgeInsets(top: 0, left: padding - (notchSize ?? 0), bottom: 0, right: padding)
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

    func refreshCollectionView(cellDeleted: Bool = false) {
        self.performBatchUpdates({
            reloadInputViews()
        }, completion: { [weak self] completed in
            if completed {
                if let indexPath = self?.selectedIndexPath {
                    self?.indexPathOfCentermostCell = indexPath
                    self?.resizeVisibleCells()
                    self?.centerCell(cellDeleted: cellDeleted)
                } else {
                    self?.resizeVisibleCells()
                    self?.centerCell(cellDeleted: cellDeleted)
                }
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
