//
//  CarouselViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class CarouselViewController: BaseViewController {
    // MARK: - Constants
    enum Constants {
        static let cellRatio: CGFloat = 213 / 224
        static let sineMultiplier: CGFloat = 0.25
        static let cellMaxSize: CGFloat = 0.74
        static let minimumLineSpacing: CGFloat = 40
        static let duration: Double = 0.3
        static let cellIdentifier: String = "CarouselCollectionViewCell"
    }

    // MARK: - Outlets
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var rigthButton: UIButton!
    @IBOutlet private weak var leftButton: UIButton!

    // MARK: - Variables
    private var highestSine: CGFloat = 0
    private var indexPathOfCentermostCell: IndexPath?
}

// MARK: - Private functions
extension CarouselViewController {
    private func resizeVisibleCells() {
        highestSine = 0
        for cell in collectionView.visibleCells {
            guard let customCell = cell as? CarouselCollectionViewCell else {
                continue
            }
            let distaneFromLeft = collectionView.convert(CGPoint(x: customCell.frame.midX, y: customCell.frame.midY),
                                                         to: collectionView.superview).x
            let multiplier = min(max(distaneFromLeft / collectionView.frame.width, 0), 1)
            let sine = Constants.sineMultiplier * sin(multiplier * CGFloat(Double.pi)) + Constants.cellMaxSize
            if sine > highestSine, let indexPath = collectionView.indexPath(for: cell) {
                indexPathOfCentermostCell = indexPath
                highestSine = sine
                rigthButton.isHidden = indexPath.row == collectionView.numberOfItems(inSection: 0) - 1
                leftButton.isHidden = indexPath.row == 0
            }
            customCell.setSize(multiplier: sine)
        }
    }

    private func centerCell() {
        if let indexPath = indexPathOfCentermostCell {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            designCells()
        }
    }

    private func designCells() {
        for cell in collectionView.visibleCells {
            if let cell = cell as? CarouselCollectionViewCell {
                let asd = cell.superview?.convert(CGPoint(x: cell.frame.midX, y: cell.frame.midY), to: nil).x
                let basd = collectionView.superview?.convert(CGPoint(x: collectionView.frame.midX,
                                                                     y: collectionView.frame.midY), to: nil).x

                if let cellMid = asd, let collMid = basd, Int(cellMid) == Int(collMid) {
                    cell.centered = true
                } else {
                    cell.centered = false
                }
            }
        }
    }
}

// MARK: - Event handlers
extension CarouselViewController {
    @IBAction private func rightButtonTapped(_ sender: Any) {
        if leftButton.isHidden {
            leftButton.isHidden = false
        }
        guard indexPathOfCentermostCell != nil,
            indexPathOfCentermostCell!.row != collectionView.numberOfItems(inSection: 0) - 1 else {
                return
        }
        indexPathOfCentermostCell!.row += 1
        if indexPathOfCentermostCell!.row == collectionView.numberOfItems(inSection: 0) - 1 {
            rigthButton.isHidden = true
        }
        centerCell()
    }

    @IBAction private func leftButtonTapped(_ sender: Any) {
        if rigthButton.isHidden {
            rigthButton.isHidden = false
        }
        guard indexPathOfCentermostCell != nil,
            indexPathOfCentermostCell!.row != 0 else {
                return
        }
        indexPathOfCentermostCell!.row -= 1
        if indexPathOfCentermostCell!.row == 0 {
            leftButton.isHidden = true
        }
        centerCell()
    }
}

// MARK: - View lifecycle
extension CarouselViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CarouselCollectionViewCell.self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let cellWidth: CGFloat = collectionView.frame.size.height * Constants.cellRatio
        let cellheight: CGFloat = collectionView.frame.size.height
        let cellSize = CGSize(width: cellWidth, height: cellheight)
        let padding = (collectionView.frame.width / 2) - (cellWidth / 2)
        collectionView.layoutIfNeeded()
        collectionView.contentInset = UIEdgeInsets(top: 0,
                                                   left: padding,
                                                   bottom: 0,
                                                   right: padding)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = cellSize
        layout.minimumLineSpacing = Constants.minimumLineSpacing
        collectionView.setCollectionViewLayout(layout, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        resizeVisibleCells()
        centerCell()
        UIView.animate(withDuration: Constants.duration) { [unowned self] in
            self.collectionView.alpha = 1
        }
    }
}

// MARK: - UICollectionViewDataSource
extension CarouselViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier,
                                                         for: indexPath) as? CarouselCollectionViewCell {
            return cell
        }

        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegate
extension CarouselViewController: UICollectionViewDelegate {
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
}
