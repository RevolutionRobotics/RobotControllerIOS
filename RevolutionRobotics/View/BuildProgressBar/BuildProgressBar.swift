//
//  BuildProgressBar.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 25..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class BuildProgressBar: RRCustomView {
    // MARK: - Outlets
    @IBOutlet private weak var slider: RRSlider!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!

    // MARK: - Properties
    var valueDidChange: CallbackType<Int>?
    var markers: [Int] = [] {
        didSet {
            slider.markValues(markers)
        }
    }
    var numberOfSteps: Int = 0 {
        didSet {
            slider.maximumValue = Float(numberOfSteps)
        }
    }
}

// MARK: - Actions
extension BuildProgressBar {
    @IBAction private func sliderValueChanged(_ sender: RRSlider) {
        sender.setValue(sender.value.rounded(), animated: true)
        let isMaximumValueReached = sender.value == sender.maximumValue
        let image = isMaximumValueReached ? Image.BuildRobot.finishButton : Image.BuildRobot.nextButton
        nextButton.setImage(image, for: .normal)
        valueDidChange?(Int(sender.value))
    }

    @IBAction private func nextButtonTapped(_ sender: Any) {
        guard slider.value + 1 <= slider.maximumValue else { return }
        slider.setValue(slider.value + 1, animated: true)
        let isMaximumValueReached = slider.value == slider.maximumValue
        let image = isMaximumValueReached ? Image.BuildRobot.finishButton : Image.BuildRobot.nextButton
        nextButton.setImage(image, for: .normal)
        valueDidChange?(Int(slider.value))
    }

    @IBAction private func backButtonTapped(_ sender: Any) {
        guard slider.value - 1 >= slider.minimumValue else { return }
        slider.setValue(slider.value - 1, animated: true)
        nextButton.setImage(Image.BuildRobot.nextButton, for: .normal)
        valueDidChange?(Int(slider.value))
    }
}
