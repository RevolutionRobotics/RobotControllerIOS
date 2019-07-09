//
//  SliderInputView.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 06. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import RevolutionRoboticsBlockly

final class SliderInputModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var sliderMaxValueLabel: UILabel!
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var doneButton: RRButton!

    // MARK: - Properties
    private var valueSelected: CallbackType<String>?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        setupDoneButton()
    }
}

// MARK: - Setup
extension SliderInputModalView {
    func setup(sliderHandler: SliderHandler, valueSelected: CallbackType<String>?) {
        self.valueSelected = valueSelected
        titleLabel.text = sliderHandler.title.uppercased()
        sliderMaxValueLabel.text = "\(sliderHandler.maximum)"
        slider.maximumValue = Float(sliderHandler.maximum)
        slider.minimumValue = Float(sliderHandler.minimum)
        slider.value = Float(sliderHandler.defaultValue) ?? 0.0
        slider.addTarget(self, action: #selector(updateValueLabel), for: .valueChanged)
        updateValueLabel(for: slider)
    }

    private func setupDoneButton() {
        doneButton.setBorder(fillColor: .clear, strokeColor: .white)
        doneButton.setTitle(ModalKeys.Save.done.translate(), for: .normal)
    }

    @objc private func updateValueLabel(for slider: UISlider) {
        valueLabel.text = "\(Int(slider.value.rounded()))"
    }
}

// MARK: - Action
extension SliderInputModalView {
    @IBAction private func doneButtonTapped(_ sender: Any) {
        valueSelected?("\(Int(slider.value.rounded()))")
    }
}
