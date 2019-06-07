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
    var buildFinished: Callback?
    var showMilestone: Callback?
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
    var currentStep: Int {
        get {
            return Int(slider.value)
        }
        set {
            previousStep = newValue
            slider.value = Float(newValue)
            self.setupNextButton(step: Float(newValue))
        }
    }
    private var previousStep: Int = 0

}

// MARK: - Functions
extension BuildProgressBar {
    func milestoneFinished() {
        guard slider.value + 1 <= slider.maximumValue else {
            buildFinished?()
            return
        }
        slider.setValue(slider.value + 1, animated: true)
        let isMaximumValueReached = slider.value == slider.maximumValue
        let image = isMaximumValueReached ? Image.BuildRobot.finishButton : Image.BuildRobot.nextButton
        nextButton.setImage(image, for: .normal)
        valueDidChange?(Int(slider.value))
    }

    private func setupNextButton(step: Float) {
        let isMaximumValueReached = step == slider.maximumValue
        let image = isMaximumValueReached ? Image.BuildRobot.finishButton : Image.BuildRobot.nextButton
        nextButton.setImage(image, for: .normal)
    }
}

// MARK: - Actions
extension BuildProgressBar {
    @IBAction private func sliderValueChanged(_ sender: RRSlider) {
        sender.setValue(sender.value.rounded(), animated: true)
        guard previousStep != Int(sender.value) else { return }
        previousStep = Int(sender.value)
        setupNextButton(step: sender.value)
        valueDidChange?(Int(sender.value))
    }

    @IBAction private func nextButtonTapped(_ sender: Any) {
        guard slider.value + 1 <= slider.maximumValue else {
            buildFinished?()
            return
        }
        if markers.contains(Int(slider.value)) {
            showMilestone?()
            return
        }
        slider.setValue(slider.value + 1, animated: true)
        previousStep = Int(slider.value)
        let isMaximumValueReached = slider.value == slider.maximumValue
        let image = isMaximumValueReached ? Image.BuildRobot.finishButton : Image.BuildRobot.nextButton
        nextButton.setImage(image, for: .normal)
        valueDidChange?(Int(slider.value))
    }

    @IBAction private func backButtonTapped(_ sender: Any) {
        guard slider.value - 1 >= slider.minimumValue else { return }
        slider.setValue(slider.value - 1, animated: true)
        previousStep = Int(slider.value)
        nextButton.setImage(Image.BuildRobot.nextButton, for: .normal)
        valueDidChange?(Int(slider.value))
    }
}
