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

        button.backgroundColor = isSelected ? Color.blackTwo : Color.black
        button.setBorder(fillColor: .clear, strokeColor: isSelected ? .white : Color.blackTwo)

        if option.value.isEmoji {
            button.setTitle(option.value, for: .normal)
            label.text = nil
        } else if let linkedImage = UIImage(named: option.key) {
            let maxHeight: CGFloat = 35.0
            let scaledWidth: CGFloat = linkedImage.size.width * (maxHeight / linkedImage.size.height)
            let buttonImage = linkedImage.size.height >= maxHeight
                ? linkedImage.resized(to: CGSize(width: scaledWidth, height: maxHeight))
                : linkedImage

            label.text = option.value
            button.imageView?.contentMode = .scaleAspectFit
            button.setImage(buttonImage, for: .normal)
        }

        button.layoutIfNeeded()
    }
}

// MARK: - Action
extension OptionSelectorButton {
    @IBAction private func buttonTapped(_ sender: Any) {
        optionSelected?(option)
    }
}
