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
        static let defaultSliderValue: Float = 128.0
        static let rotationAngle = -(CGFloat.pi / 2)
        static let animationDuration = 0.2
    }

    // MARK: - Outlets
    @IBOutlet private var buttons: [PadButton]!
    @IBOutlet private weak var verticalDirectionSlider: UISlider!
    @IBOutlet private weak var horizontalDirectionSlider: UISlider!

    // MARK: - Playable
    var horizontalPositionChanged: CallbackType<CGFloat>?
    var verticalPositionChanged: CallbackType<CGFloat>?
    var buttonTapped: CallbackType<PressedPadButton>?

    func configure(programs: [ProgramDataModel?]) {
        programs.enumerated().forEach { [weak self] in
            let (index, program) = $0
            guard let unwrappedProgram = program else { return }
            self?.connectButtonHandling(at: index, program: unwrappedProgram, to: buttons[index])
        }
    }
}

// MARK: - Lifecycle
extension DriverPadView {
    override func awakeFromNib() {
        super.awakeFromNib()
        setupSliders()
    }
}

// MARK: - Actions
extension DriverPadView {
    @IBAction private func verticalReset(_ slider: UISlider) {
        verticalPositionChanged?(CGFloat(Constants.defaultSliderValue))
        resetValue(in: slider)
    }

    @IBAction private func verticalValueChanged(_ slider: UISlider) {
        verticalPositionChanged?(CGFloat(slider.value))
    }

    @IBAction private func horizontalReset(_ slider: UISlider) {
        horizontalPositionChanged?(CGFloat(Constants.defaultSliderValue))
        resetValue(in: slider)
    }

    @IBAction private func horizontalValueChanged(_ slider: UISlider) {
        horizontalPositionChanged?(CGFloat(slider.value))
    }
}

// MARK: - Setup
extension DriverPadView {
    private func setupSliders() {
        customizeAppearance(for: verticalDirectionSlider)
        customizeAppearance(for: horizontalDirectionSlider)
    }

    private func customizeAppearance(for slider: UISlider) {
        slider.transform = CGAffineTransform(rotationAngle: Constants.rotationAngle)
        slider.setThumbImage(Image.Controller.padButtonBackground, for: .normal)
        slider.setThumbImage(Image.Controller.padButtonBackground, for: .highlighted)

        let imageView = UIImageView(image: Image.Controller.directionSlider)
        imageView.transform = CGAffineTransform(rotationAngle: Constants.rotationAngle)
        slider.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: slider.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: slider.centerYAnchor).isActive = true
    }

    private func resetValue(in slider: UISlider) {
        UIView.animate(withDuration: Constants.animationDuration) {
            slider.setValue(Constants.defaultSliderValue, animated: true)
        }
    }
}
