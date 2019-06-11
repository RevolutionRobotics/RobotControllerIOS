//
//  OptionSelectorView.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 06. 03..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import RevolutionRoboticsBlockly

final class OptionSelectorView: UIView {
    // MARK: - Constant
    private enum Constant {
        static let optionPerRow = 3
        static let elementSpacing: CGFloat = 16.0
    }

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var stackViewContainer: UIStackView!

    // MARK: - Properties
    private var optionSelected: CallbackType<Option>?
}

// MARK: - Setup
extension OptionSelectorView {
    func setup(optionSelector: OptionSelector, optionSelected: CallbackType<Option>?) {
        self.optionSelected = optionSelected

        titleLabel.text = optionSelector.title?.uppercased()
        let containers = createButtonContainers(options: optionSelector.options, defaultKey: optionSelector.defaultKey)
        containers.forEach(stackViewContainer.addArrangedSubview)
    }

    private func createButtonContainers(options: [Option], defaultKey: String) -> [UIStackView] {
        let optionCount = options.count
        guard optionCount > 0 && optionCount < 7 else { return [] }

        guard optionCount > Constant.optionPerRow else {
            return [createButtonContainer(options: options, defaultKey: defaultKey)]
        }

        return [
            createButtonContainer(options: Array(options[0..<Constant.optionPerRow]), defaultKey: defaultKey),
            createButtonContainer(options: Array(options[Constant.optionPerRow..<optionCount]), defaultKey: defaultKey)
        ]
    }

    private func createButtonContainer(options: [Option], defaultKey: String) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Constant.elementSpacing

        options
            .map { [weak self] option in
                let button = OptionSelectorButton.instatiate()
                button.setup(option: option, isSelected: option.key == defaultKey, optionSelected: self?.optionSelected)

                return button
            }
            .forEach(stackView.addArrangedSubview)

        return stackView
    }
}
