//
//  ConfigurationView.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 12..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ConfigurationView: RRCustomView {
    // MARK: - Constants
    enum Constants {
        static let m1PortNumber = 1
        static let m2PortNumber = 2
        static let m3PortNumber = 3
        static let m4PortNumber = 4
        static let m5PortNumber = 5
        static let m6PortNumber = 6
        static let s1PortNumber = 7
        static let s2PortNumber = 8
        static let s3PortNumber = 9
        static let s4PortNumber = 10
    }
    // MARK: - Outlets
    @IBOutlet private weak var robotImageView: UIImageView!

    @IBOutlet private weak var motorPort1: PortButton!
    @IBOutlet private var motorPort1Lines: [DashedView]!
    @IBOutlet private weak var motorPort1Dot: UIImageView!

    @IBOutlet private weak var motorPort2: PortButton!
    @IBOutlet private var motorPort2Lines: [DashedView]!
    @IBOutlet private weak var motorPort2Dot: UIImageView!

    @IBOutlet private weak var motorPort3: PortButton!
    @IBOutlet private var motorPort3Lines: [DashedView]!
    @IBOutlet private weak var motorPort3Dot: UIImageView!

    @IBOutlet private weak var motorPort4: PortButton!
    @IBOutlet private var motorPort4Lines: [DashedView]!
    @IBOutlet private weak var motorPort4Dot: UIImageView!

    @IBOutlet private weak var motorPort5: PortButton!
    @IBOutlet private var motorPort5Lines: [DashedView]!
    @IBOutlet private weak var motorPort5Dot: UIImageView!

    @IBOutlet private weak var motorPort6: PortButton!
    @IBOutlet private var motorPort6Lines: [DashedView]!
    @IBOutlet private weak var motorPort6Dot: UIImageView!

    @IBOutlet private weak var sensorPort1: PortButton!
    @IBOutlet private var sensorPort1Lines: [DashedView]!
    @IBOutlet private weak var sensorPort1Dot: UIImageView!

    @IBOutlet private weak var sensorPort2: PortButton!
    @IBOutlet private var sensorPort2Lines: [DashedView]!
    @IBOutlet private weak var sensorPort2Dot: UIImageView!

    @IBOutlet private weak var sensorPort3: PortButton!
    @IBOutlet private var sensorPort3Lines: [DashedView]!
    @IBOutlet private weak var sensorPort3Dot: UIImageView!

    @IBOutlet private weak var sensorPort4: PortButton!
    @IBOutlet private var sensorPort4Lines: [DashedView]!
    @IBOutlet private weak var sensorPort4Dot: UIImageView!

    @IBOutlet private var buttons: [PortButton]!

    var image: UIImage? {
        get {
            return robotImageView.image
        }
        set {
            robotImageView.image = newValue
        }
    }
    var portSelectionHandler: CallbackType<(type: PortButton.PortType, number: Int)>?
}

// MARK: - View lifecycle
extension ConfigurationView {
    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }
}

// MARK: - Setups
extension ConfigurationView {
    private func setup() {
        setupMotorPorts()
        setupSensorPorts()
    }

    private func setupMotorPorts() {
        motorPort1.lines = motorPort1Lines
        motorPort1.dotImageView = motorPort1Dot
        motorPort1.portNumber = Constants.m1PortNumber
        motorPort1.portType = .motor

        motorPort2.lines = motorPort2Lines
        motorPort2.dotImageView = motorPort2Dot
        motorPort2.portNumber = Constants.m2PortNumber
        motorPort2.portType = .motor

        motorPort3.lines = motorPort3Lines
        motorPort3.dotImageView = motorPort3Dot
        motorPort3.portNumber = Constants.m3PortNumber
        motorPort3.portType = .motor

        motorPort4.lines = motorPort4Lines
        motorPort4.dotImageView = motorPort4Dot
        motorPort4.portNumber = Constants.m4PortNumber
        motorPort4.portType = .motor

        motorPort5.lines = motorPort5Lines
        motorPort5.dotImageView = motorPort5Dot
        motorPort5.portNumber = Constants.m5PortNumber
        motorPort5.portType = .motor

        motorPort6.lines = motorPort6Lines
        motorPort6.dotImageView = motorPort6Dot
        motorPort6.portNumber = Constants.m6PortNumber
        motorPort6.portType = .motor
    }

    private func setupSensorPorts() {
        sensorPort1.lines = sensorPort1Lines
        sensorPort1.dotImageView = sensorPort1Dot
        sensorPort1.portNumber = Constants.s1PortNumber
        sensorPort1.portType = .bumper

        sensorPort2.lines = sensorPort2Lines
        sensorPort2.dotImageView = sensorPort2Dot
        sensorPort2.portNumber = Constants.s2PortNumber
        sensorPort2.portType = .bumper

        sensorPort3.lines = sensorPort3Lines
        sensorPort3.dotImageView = sensorPort3Dot
        sensorPort3.portNumber = Constants.s3PortNumber
        sensorPort3.portType = .bumper

        sensorPort4.lines = sensorPort4Lines
        sensorPort4.dotImageView = sensorPort4Dot
        sensorPort4.portNumber = Constants.s4PortNumber
        sensorPort4.portType = .bumper
    }
}

// MARK: - Actions
extension ConfigurationView {
    @IBAction private func portTapped(_ sender: PortButton) {
        portSelectionHandler?((sender.portType, sender.portNumber))
    }

    func set(state: PortButton.PortState, on portNumber: Int, type: PortButton.PortType? = nil) {
        let button = buttons.first(where: { $0.portNumber == portNumber })
        if let type = type {
            button?.portType = type
        }
        button?.portState = state
    }
}
