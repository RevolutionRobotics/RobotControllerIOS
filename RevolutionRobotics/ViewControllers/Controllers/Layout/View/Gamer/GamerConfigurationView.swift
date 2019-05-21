//
//  GamerConfigurationView.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 20..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import UIKit

final class GamerConfigurationView: UIView, ConfigurableControllerView {
    // MARK: - Outlets
    @IBOutlet private weak var drivetrainButton: ControllerButton!
    @IBOutlet private weak var button1: ControllerButton!
    @IBOutlet private weak var button2: ControllerButton!
    @IBOutlet private weak var button3: ControllerButton!
    @IBOutlet private weak var button4: ControllerButton!
    @IBOutlet private weak var button5: ControllerButton!
    @IBOutlet private weak var button6: ControllerButton!
    @IBOutlet private var buttons: [ControllerButton]!

    @IBOutlet private var drivetrainDashedView: [DashedView]!
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
extension GamerConfigurationView {
    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }
}

// MARK: - Setup
extension GamerConfigurationView {
    private func setup() {
        setupDrivetrainButton()
        setupB1()
        setupB2()
        setupB3()
        setupB4()
        setupB5()
        setupB6()
    }

    private func setupDrivetrainButton() {
        drivetrainButton.lines = drivetrainDashedView
        drivetrainButton.setTitle(ControllerKeys.drivetrain.translate(), for: .normal)
        drivetrainButton.setupStaticState()
    }

    private func setupB1() {
        button1.setTitle(ControllerKeys.configureEmpty.translate(), for: .normal)
        button1.lines = dashedView1
        button1.dotImageView = imageView1
    }

    private func setupB2() {
        button2.setTitle(ControllerKeys.configureEmpty.translate(), for: .normal)
        button2.lines = dashedView2
        button2.dotImageView = imageView2
    }

    private func setupB3() {
        button3.setTitle(ControllerKeys.configureEmpty.translate(), for: .normal)
        button3.lines = dashedView3
        button3.dotImageView = imageView3
    }

    private func setupB4() {
        button4.setTitle(ControllerKeys.configureEmpty.translate(), for: .normal)
        button4.lines = dashedView4
        button4.dotImageView = imageView4
    }

    private func setupB5() {
        button5.setTitle(ControllerKeys.configureEmpty.translate(), for: .normal)
        button5.lines = dashedView5
        button5.dotImageView = imageView5
    }

    private func setupB6() {
        button6.setTitle(ControllerKeys.configureEmpty.translate(), for: .normal)
        button6.lines = dashedView6
        button6.dotImageView = imageView6
    }
}

// MARK: - ConfigurableControllerView
extension GamerConfigurationView {
    @IBAction private func controllerButtonTapped(_ sender: ControllerButton) {
        selectionCallback?(sender.buttonNumber)
    }

    func set(state: ControllerButton.ControllerButtonState, on buttonNumber: Int, title: String?) {
        let button = buttons.first(where: { $0.buttonNumber == buttonNumber })
        button?.buttonState = state
        if let title = title {
            button?.setTitle(title, for: .normal)
        }
    }
}
