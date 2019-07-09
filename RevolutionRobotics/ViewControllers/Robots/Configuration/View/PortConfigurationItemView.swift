//
//  PortConfigurationItemView.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 29..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class PortConfigurationItemView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var button: RRButton!
    @IBOutlet private weak var label: UILabel!

    // MARK: - Properties
    private var callback: Callback?

    // MARK: - Options
    struct Options {
        let title: String
        let selectedImage: UIImage?
        let unselectedImage: UIImage?
        let callback: Callback?
    }
}

// MARK: - Public
extension PortConfigurationItemView {
    func configure(options: Options) {
        callback = options.callback
        label.text = options.title
        button.setBackgroundImage(options.selectedImage, for: .selected)
        button.setBackgroundImage(options.unselectedImage, for: .normal)
        button.setBackgroundImage(options.selectedImage, for: .highlighted)
    }

    func set(selected: Bool) {
        button.isSelected = selected
    }
}

// MARK: - Actions
extension PortConfigurationItemView {
    @IBAction private func buttonTapped() {
        callback?()
    }
}
