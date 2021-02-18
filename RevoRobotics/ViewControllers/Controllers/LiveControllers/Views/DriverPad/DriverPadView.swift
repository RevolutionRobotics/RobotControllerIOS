//
//  DriverPadView.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class DriverPadView: UIView, PlayablePadView {
    // MARK: - Constants
    private enum Constants {
        static let defaultSliderValue: Float = 127.0
        static let rotationAngle = -(CGFloat.pi / 2)
        static let animationDuration = 0.2
    }

    // MARK: - Outlets
    @IBOutlet private var buttons: [PadButton]!
    @IBOutlet private weak var xAxisSlider: UISlider!
    @IBOutlet private weak var yAxisSlider: UISlider!

    // MARK: - Properties
    var xAxisPositionChanged: CallbackType<CGFloat>?
    var yAxisPositionChanged: CallbackType<CGFloat>?
    var buttonTapped: CallbackType<PressedPadButton>?

    func configure(programs: [ProgramDataModel?]) {
        programs.enumerated().forEach { [weak self] in
            let (index, program) = $0
            guard let unwrappedProgram = program else { return }
            self?.connectButtonHandling(at: index, program: unwrappedProgram, to: buttons[index])
        }
    }
}

// MARK: - View lifecycle
extension DriverPadView {
    override func awakeFromNib() {
        super.awakeFromNib()
        setupSliders()
    }
}

// MARK: - Actions
extension DriverPadView {
    @IBAction private func xAxisReset(_ slider: UISlider) {
        xAxisPositionChanged?(CGFloat(Constants.defaultSliderValue))
        resetValue(in: slider)
    }

    @IBAction private func xAxisValueChanged(_ slider: UISlider) {
        xAxisPositionChanged?(CGFloat(slider.value))
    }

    @IBAction private func yAxisReset(_ slider: UISlider) {
        yAxisPositionChanged?(CGFloat(Constants.defaultSliderValue))
        resetValue(in: slider)
    }

    @IBAction private func yAxisValueChanged(_ slider: UISlider) {
        yAxisPositionChanged?(CGFloat(slider.value))
    }
}

// MARK: - Setup
extension DriverPadView {
    private func setupSliders() {
        customizeAppearance(for: xAxisSlider)
        customizeAppearance(for: yAxisSlider)
    }

    private func customizeAppearance(for slider: UISlider) {
        slider.transform = CGAffineTransform(rotationAngle: Constants.rotationAngle)
        slider.setThumbImage(Image.Controller.padButtonBackground, for: .normal)
        slider.setThumbImage(Image.Controller.padButtonBackground, for: .highlighted)

        let sliderBg = Image.Controller.directionSlider?.rotate(radians: Float(Constants.rotationAngle))
        slider.setMinimumTrackImage(sliderBg, for: .normal)
        slider.setMaximumTrackImage(sliderBg, for: .normal)

        resetValue(in: slider)
    }

    private func resetValue(in slider: UISlider) {
        UIView.animate(withDuration: Constants.animationDuration) {
            slider.setValue(Constants.defaultSliderValue, animated: true)
        }
    }
}
