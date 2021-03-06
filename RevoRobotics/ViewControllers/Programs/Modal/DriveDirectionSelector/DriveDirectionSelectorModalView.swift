//
//  DriveDirectionSelectorModalView.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 06. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import RevolutionRoboticsBlockly

final class DriveDirectionSelectorModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private var buttonsContainer: [UIView]!
}

// MARK: - Setup
extension DriveDirectionSelectorModalView {
    func setup(optionSelector: OptionSelector, optionSelected: CallbackType<Option>?) {
        titleLabel.text = optionSelector.title?.uppercased()

        let optionCount = optionSelector.options.count
        optionSelector.options.enumerated().forEach { [weak self] (index, option) in
            let button = OptionSelectorButton.instatiate()
            button.setup(
                option: option,
                isSelected: option.key == optionSelector.defaultKey,
                optionSelected: optionSelected
            )

            let offset = optionCount <= 2 ? index * 2 : 0
            button.translatesAutoresizingMaskIntoConstraints = false
            self?.buttonsContainer[index + offset].addSubview(button)
            button.anchorToSuperview()
        }
    }
}
