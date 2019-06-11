//
//  ColorSelectorView.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 06. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import RevolutionRoboticsBlockly

final class ColorSelectorView: UIView {
    // MARK: - Constant
    private enum Constant {
        static let minimumSpacing: CGFloat = 2.0
        static let selectedCellBorderWidth: CGFloat = 3.0
        static let cellSize: CGSize = CGSize(width: 45, height: 40)
        static let cellID = "ColorSelectorCell"
    }

    // MARK: - Outlets
    @IBOutlet private weak var collectionView: UICollectionView!

    // MARK: - Properties
    private var colorSelected: CallbackType<String>?
    private var defaultOptionKey: String?
    private var options: [Option] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        setupCollectionView()
    }
}

// MARK: - Setup
extension ColorSelectorView {
    func setup(optionSelector: OptionSelector, colorSelected: CallbackType<String>?) {
        self.colorSelected = colorSelected
        defaultOptionKey = optionSelector.defaultKey
        options = optionSelector.options
    }

    private func setupCollectionView() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = Constant.minimumSpacing
        collectionViewLayout.minimumInteritemSpacing = Constant.minimumSpacing
        collectionViewLayout.itemSize = Constant.cellSize
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Constant.cellID)
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

// MARK: - UICollectionViewDelegate
extension ColorSelectorView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        colorSelected?(options[indexPath.row].key)
    }
}

// MARK: - UICollectionViewDataSource
extension ColorSelectorView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.cellID, for: indexPath)
        let colorOption = options[indexPath.row]
        let selectedView = UIView(frame: cell.frame)
        selectedView.setBorder(
            fillColor: .clear,
            strokeColor: .white,
            lineWidth: Constant.selectedCellBorderWidth,
            croppedCorners: []
        )
        cell.selectedBackgroundView = selectedView
        cell.backgroundColor = UIColor(hex: colorOption.value)
        cell.isSelected = colorOption.key == defaultOptionKey

        return cell
    }
}
