//
//  SoundPickerCell.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 06. 12..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class SoundPickerCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var emojiView: UIView!
    @IBOutlet private weak var emojiLabel: UILabel!
    @IBOutlet private weak var soundLabel: UILabel!

    // MARK: - Properties
    override var isSelected: Bool {
        didSet {
            updateEmojiView()
        }
    }

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        updateEmojiView()
    }
}

// MARK: - Setup
extension SoundPickerCell {
    func setup(name: String, emoji: String) {
        soundLabel.text = name
        emojiLabel.text = emoji
    }

    func updateEmojiView() {
        emojiView.backgroundColor = isSelected ? Color.blackTwo : Color.black
        emojiView.setBorder(fillColor: .clear, strokeColor: isSelected ? .white : Color.blackTwo)
    }
}
