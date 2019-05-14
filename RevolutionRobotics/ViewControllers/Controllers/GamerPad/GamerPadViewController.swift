//
//  DriveMeViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 07..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import SpriteKit
import RevolutionRoboticsBluetooth

final class GamerPadViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var joystickContainer: SKView!
    @IBOutlet private var buttons: [GamerPadButton]!

    // MARK: - Properties
    private let liveService: RoboticsLiveControllerServiceInterface = RoboticsLiveControllerService()

    // TODO: Change to array of ProgramBinding to integrate
    typealias ProgramBinding = (name: String, xml: String)
    var demoProgramBindings: [ProgramBinding] = [
        (name: "Button 1", xml: ""),
        (name: "Button 2", xml: ""),
        (name: "Button 3", xml: ""),
        (name: "Button 4", xml: ""),
        (name: "Button 5", xml: ""),
        (name: "Button 6", xml: "")
    ]
}

// MARK: View lifecycle
extension GamerPadViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: RobotsKeys.Controllers.Play.screenTitle.translate(), delegate: self)
        setupJoystickScene()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupButtons()
        liveService.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        liveService.stop()
    }
}

// MARK: - Setup
extension GamerPadViewController {
    private func setupJoystickScene() {
        let joystickScene = JoystickScene()
        joystickScene.positionChanged = handlePositionChange
        joystickScene.returnedToDefaultPosition = handlePositionChange
        joystickContainer.presentScene(joystickScene)
    }

    private func setupButtons() {
        demoProgramBindings.enumerated().forEach(setupButtonHandling)
    }

    private func setupButtonHandling(arguments: (Int, ProgramBinding)) {
        let (index, programBinding) = arguments
        buttons[index].setup(title: programBinding.name) { [weak self] pressed in
            self?.liveService.changeButtonState(index: index, pressed: pressed)
        }
    }
}

// MARK: - Event handling
extension GamerPadViewController {
    private func handlePositionChange(position: CGPoint) {
        liveService.updateXDirection(x: Int(position.x.rounded(.toNearestOrAwayFromZero)))
        liveService.updateYDirection(y: Int(position.y.rounded(.toNearestOrAwayFromZero)))
    }
}
