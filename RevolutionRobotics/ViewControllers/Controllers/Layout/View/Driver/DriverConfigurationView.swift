//
//  DriverConfigurationView.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 20..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class DriverConfigurationView: UIView, ConfigurableControllerView {
    // MARK: - Outlets
    @IBOutlet private weak var leftDrivetrainButton: ControllerButton!
    @IBOutlet private weak var rightDrivetrainButton: ControllerButton!
    @IBOutlet private weak var button1: ControllerButton!
    @IBOutlet private weak var button2: ControllerButton!
    @IBOutlet private weak var button3: ControllerButton!
    @IBOutlet private weak var button4: ControllerButton!
    @IBOutlet private weak var button5: ControllerButton!
    @IBOutlet private weak var button6: ControllerButton!
    @IBOutlet private var buttons: [ControllerButton]!

    @IBOutlet private var leftDrivetrainDashedView: [DashedView]!
    @IBOutlet private var rightDrivetrainDashedView: [DashedView]!
    @IBOutlet private var dashedView1: [DashedView]!
    @IBOutlet private var dashedView2: [DashedView]!
    @IBOutlet private var dashedView3: [DashedView]!
    @IBOutlet private var dashedView4: [DashedView]!
    @IBOutlet private var dashedView5: [DashedView]!
    @IBOutlet private var dashedView6: [DashedView]!

    @IBOutlet private weak var imageView1: UIImageView!
    @IBOutlet private weak var imageView2: UIImageView!
    @IBOutlet private weak var imageView3: UIImageView!
    @IBOutlet private weak var imageView4: UIImageView!
    @IBOutlet private weak var imageView5: UIImageView!
    @IBOutlet private weak var imageView6: UIImageView!

    var selectionCallback: CallbackType<Int>?
}

// MARK: - View lifecycle
extension DriverConfigurationView {
    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }
}

// MARK: - Setup
extension DriverConfigurationView {
    private func setup() {
        setupLeftDrivetrainButton()
        setupRightDrivetrainButton()
        setupB1()
        setupB2()
        setupB3()
        setupB4()
        setupB5()
        setupB6()
    }

    private func setupLeftDrivetrainButton() {
        leftDrivetrainButton.lines = leftDrivetrainDashedView
        leftDrivetrainButton.setTitle(ControllerKeys.drive.translate(), for: .normal)
        leftDrivetrainButton.setupStaticState()
    }

    private func setupRightDrivetrainButton() {
        rightDrivetrainButton.lines = rightDrivetrainDashedView
        rightDrivetrainButton.setTitle(ControllerKeys.drive.translate(), for: .normal)
        rightDrivetrainButton.setupStaticState()
    }

    private func setupB1() {
        button1.setTitle(ControllerKeys.configureEmpty.translate(), for: .normal)
        button1.lines = dashedView1
        button1.dotImageView = imageView1
        button1.titleLabel?.numberOfLines = 2
        button1.titleLabel?.textAlignment = .center
    }

    private func setupB2() {
        button2.setTitle(ControllerKeys.configureEmpty.translate(), for: .normal)
        button2.lines = dashedView2
        button2.dotImageView = imageView2
        button2.titleLabel?.numberOfLines = 2
        button2.titleLabel?.textAlignment = .center
    }

    private func setupB3() {
        button3.setTitle(ControllerKeys.configureEmpty.translate(), for: .normal)
        button3.lines = dashedView3
        button3.dotImageView = imageView3
        button3.titleLabel?.numberOfLines = 2
        button3.titleLabel?.textAlignment = .center
    }

    private func setupB4() {
        button4.setTitle(ControllerKeys.configureEmpty.translate(), for: .normal)
        button4.lines = dashedView4
        button4.dotImageView = imageView4
        button4.titleLabel?.numberOfLines = 2
        button4.titleLabel?.textAlignment = .center
    }

    private func setupB5() {
        button5.setTitle(ControllerKeys.configureEmpty.translate(), for: .normal)
        button5.lines = dashedView5
        button5.dotImageView = imageView5
        button5.titleLabel?.numberOfLines = 2
        button5.titleLabel?.textAlignment = .center
    }

    private func setupB6() {
        button6.setTitle(ControllerKeys.configureEmpty.translate(), for: .normal)
        button6.lines = dashedView6
        button6.dotImageView = imageView6
        button6.titleLabel?.numberOfLines = 2
        button6.titleLabel?.textAlignment = .center
    }
}

// MARK: - ConfigurableControllerView
extension DriverConfigurationView {
    @IBAction private func controllerButtonTapped(_ sender: ControllerButton) {
        selectionCallback?(sender.buttonNumber)
    }

    func set(state: ControllerButton.ControllerButtonState, on buttonNumber: Int) {
        let button = buttons.first(where: { $0.buttonNumber == buttonNumber })
        button?.buttonState = state
    }

    func buttonState(of buttonNumber: Int) -> ControllerButton.ControllerButtonState? {
        return buttons.first(where: { $0.buttonNumber == buttonNumber })?.buttonState
    }
}
