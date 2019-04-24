//
//  WhoToBuildViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class WhoToBuildViewController: BaseViewController {
    // MARK: - Constants
    enum Constants {
        static let cellRatio: CGFloat = 213 / 224
        static let sineMultiplier: CGFloat = 0.25
        static let cellMaxSize: CGFloat = 0.74
        static let minimumLineSpacing: CGFloat = 40
        static let duration: Double = 0.3
    }

    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var rigthButton: UIButton!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var buildYourOwnButton: RRButton!

    // MARK: - Variables
    private var highestSine: CGFloat = 0
    private var indexPathOfCentermostCell: IndexPath?
    private var selectedIndexPath: IndexPath?
}

// MARK: - Private functions
extension WhoToBuildViewController {
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
            if sine > highestSine, let indexPath = customCell.indexPath {
                indexPathOfCentermostCell = indexPath
                highestSine = sine
                rigthButton.isHidden = indexPath.row == collectionView.numberOfItems(inSection: 0) - 1
                leftButton.isHidden = indexPath.row == 0
            }
            customCell.setSize(multiplier: sine)
            guard let cellIP = customCell.indexPath, let selected = selectedIndexPath else {
                return
            }
            if cellIP != selected {
                customCell.isCentered = false
            } else {
                customCell.isCentered = true
            }
        }
    }

    private func centerCell() {
        if let indexPath = indexPathOfCentermostCell {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            selectedIndexPath = indexPath
            designCells()
        }
    }

    private func designCells() {
        for cell in collectionView.visibleCells {
            if let cell = cell as? CarouselCollectionViewCell {
                guard let cellIP = cell.indexPath, let selected = selectedIndexPath else {
                    return
                }
                if cellIP != selected {
                    cell.isCentered = false
                } else {
                    cell.isCentered = true
                }
            }
        }
    }
}

// MARK: - Event handlers
extension WhoToBuildViewController {
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

    @IBAction private func builYourOwnButtonTapped(_ sender: Any) {
        let buildRobotViewController = AppContainer.shared.container.unwrappedResolve(BuildRobotViewController.self)
        navigationController?.pushViewController(buildRobotViewController, animated: true)
    }
}

// MARK: - View lifecycle
extension WhoToBuildViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.decelerationRate = .fast
        collectionView.register(CarouselCollectionViewCell.self)
        navigationBar.setup(title: RobotsKeys.WhoToBuild.title.translate(), delegate: self)
        buildYourOwnButton.setTitle(RobotsKeys.WhoToBuild.buildNewButtonTitle.translate(), for: .normal)
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
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredHorizontally, animated: true)
        selectedIndexPath = IndexPath(row: 0, section: 0)
        UIView.animate(withDuration: Constants.duration) { [unowned self] in
            self.collectionView.alpha = 1
        }
    }
}

// MARK: - UICollectionViewDataSource
extension WhoToBuildViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CarouselCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.indexPath = indexPath
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension WhoToBuildViewController: UICollectionViewDelegate {
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
