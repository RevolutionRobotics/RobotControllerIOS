//
//  OptionSelectorButton.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 06. 03..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import RevolutionRoboticsBlockly

final class OptionSelectorButton: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var button: RRButton!
    @IBOutlet private weak var label: UILabel!

    // MARK: - Properties
    private var option: Option!
    private var optionSelected: CallbackType<Option>?
}

// MARK: - Setup
extension OptionSelectorButton {
    func setup(option: Option, isSelected: Bool, optionSelected: CallbackType<Option>?) {
        self.option = option
        self.optionSelected = optionSelected

        label.text = option.value.isEmoji ? nil : option.value
        button.backgroundColor = isSelected ? Color.blackTwo : Color.black
        button.setBorder(fillColor: .clear, strokeColor: isSelected ? .white : Color.blackTwo)
        button.setImage(UIImage(named: option.key), for: .normal)
        button.layoutIfNeeded()
    }
}

// MARK: - Action
extension OptionSelectorButton {
    @IBAction private func buttonTapped(_ sender: Any) {
        optionSelected?(option)
    }
}
