//
//  SoundPickerModalView.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 06. 12..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import RevolutionRoboticsBlockly

final class SoundPickerModalView: UIView {
    // MARK: - Constant
    private enum Constant {
        static let minimumLineSpacing: CGFloat = 12.0
        static let minimumCellSpacing: CGFloat = 8.0
        static let cellSize = CGSize(width: 72, height: 62)
    }

    // MARK: - Outlets
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var doneButton: RRButton!

    // MARK: - Properties
    private let audioPlayer = AudioPlayer()
    private var soundSelected: CallbackType<String>?
    private var options: [Option] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        setupCollectionView()
        setupDoneButton()
    }
}

// MARK: - Setup
extension SoundPickerModalView {
    func setup(optionSelector: OptionSelector, soundSelected: CallbackType<String>?) {
        self.soundSelected = soundSelected
        options = optionSelector.options

        guard let selectedIndex = options.firstIndex(where: { $0.key == optionSelector.defaultKey }) else { return }
        collectionView.selectItem(
            at: IndexPath(row: selectedIndex, section: 0),
            animated: false,
            scrollPosition: .bottom
        )
    }

    private func setupDoneButton() {
        doneButton.setBorder(fillColor: .clear, strokeColor: .white)
        doneButton.setTitle(ModalKeys.Save.done.translate(), for: .normal)
    }

    private func setupCollectionView() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = Constant.minimumLineSpacing
        collectionViewLayout.minimumInteritemSpacing = Constant.minimumCellSpacing
        collectionViewLayout.itemSize = Constant.cellSize
        collectionView.register(SoundPickerCell.self)
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

// MARK: - UICollectionViewDelegate
extension SoundPickerModalView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        audioPlayer.playSound(name: options[indexPath.row].key)
    }
}

// MARK: - UICollectionViewDataSource
extension SoundPickerModalView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SoundPickerCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        let option = options[indexPath.row]
        cell.setup(name: option.key.replacingOccurrences(of: "_", with: " "), emoji: option.value)

        return cell
    }
}

// MARK: - Action
extension SoundPickerModalView {
    @IBAction private func doneButtonTapped(_ sender: Any) {
        guard let selectedIndex = collectionView.indexPathsForSelectedItems?.first else { return }
        soundSelected?(options[selectedIndex.row].key)
    }
}
