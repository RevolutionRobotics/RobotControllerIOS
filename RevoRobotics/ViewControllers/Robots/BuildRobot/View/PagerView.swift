//
//  PagerView.swift
//  RevoRobotics
//
//  Created by Pável Áron on 2019. 11. 26..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class PagerView: UIView {
    // MARK: - Constants
    private enum Constants {
        static let cellReuseIdentifier = "pagerViewCell"
    }

    // MARK: - Properties
    var pageSelectedCallback: CallbackType<Int>?
    var items: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0

        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear

        cv.delegate = self
        cv.dataSource = self

        return cv
    }()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
}

// MARK: - Public methods
extension PagerView {
    func selectItem(at index: Int, animated: Bool = true) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
}

// MARK: - Private methods
extension PagerView {
    private func initialize() {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        collectionView.register(PagerViewCell.self, forCellWithReuseIdentifier: Constants.cellReuseIdentifier)
    }
}

// MARK: - UICollectionViewDataSource
extension PagerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Constants.cellReuseIdentifier,
            for: indexPath) as? PagerViewCell else {
                fatalError("Failed to dequeue pager view cell")
        }
        cell.setup(with: items[indexPath.row])

        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension PagerView: UICollectionViewDelegate {
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = scrollView.contentOffset
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let contentWidth = scrollView.contentSize.width / CGFloat(items.count)
        let scrollPosition = scrollView.contentOffset.x

        let itemIndex = Int((scrollPosition / contentWidth).rounded())
        selectItem(at: itemIndex)

        pageSelectedCallback?(itemIndex)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PagerView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return frame.size
    }
}
